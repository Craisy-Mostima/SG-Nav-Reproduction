#!/usr/bin/env bash
set -euo pipefail

START_EPISODE="${1:?Usage: bash run_episodes.sh START_EPISODE [COUNT]}"
COUNT="${2:-1}"

if ! [[ "$START_EPISODE" =~ ^[0-9]+$ ]] || ! [[ "$COUNT" =~ ^[1-9][0-9]*$ ]]; then
    echo "START_EPISODE must be >= 0 and COUNT must be >= 1." >&2
    exit 2
fi

HABITAT_ROOT="/root/autodl-tmp/Habitat"
PROJECT_ROOT="$HABITAT_ROOT/projects/SG-Nav-original"
ENV_PREFIX="$HABITAT_ROOT/envs/sgnav"
OLLAMA_BIN="$HABITAT_ROOT/tools/ollama-v0.24.0/bin/ollama"
OLLAMA_MODELS_DIR="$HABITAT_ROOT/models/ollama"
LOG_DIR="$HABITAT_ROOT/logs"
OLLAMA_LOG="$LOG_DIR/ollama_serve_original_visual.log"

mkdir -p "$LOG_DIR"
source /root/miniconda3/etc/profile.d/conda.sh
conda activate "$ENV_PREFIX"

if pgrep -af '[p]ython.*SG_Nav.*\.py' >/dev/null; then
    echo "Another SG-Nav Python process is already running:" >&2
    pgrep -af '[p]ython.*SG_Nav.*\.py' >&2
    echo "Stop it cleanly before starting another episode." >&2
    exit 3
fi

export OLLAMA_MODELS="$OLLAMA_MODELS_DIR"
export OLLAMA_KEEP_ALIVE=-1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_CONTEXT_LENGTH=4096
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128

server_pid="$(pgrep -f '[o]llama.*serve' | head -n 1 || true)"
restart_server=0
if [[ -n "$server_pid" ]]; then
    server_env="$(tr '\0' '\n' < "/proc/$server_pid/environ" 2>/dev/null || true)"
    grep -qx 'OLLAMA_KEEP_ALIVE=-1' <<< "$server_env" || restart_server=1
    grep -qx 'OLLAMA_NUM_PARALLEL=1' <<< "$server_env" || restart_server=1
    grep -qx 'OLLAMA_MAX_LOADED_MODELS=1' <<< "$server_env" || restart_server=1
    grep -qx 'OLLAMA_CONTEXT_LENGTH=4096' <<< "$server_env" || restart_server=1
fi

if [[ "$restart_server" -eq 1 ]]; then
    echo "Restarting Ollama once with the controlled experiment settings."
    kill -TERM "$server_pid"
    for _ in {1..30}; do
        kill -0 "$server_pid" 2>/dev/null || break
        sleep 1
    done
    if kill -0 "$server_pid" 2>/dev/null; then
        echo "Ollama server did not stop cleanly; refusing to start a duplicate." >&2
        exit 4
    fi
    server_pid=""
fi

if [[ -z "$server_pid" ]]; then
    nohup env \
        OLLAMA_MODELS="$OLLAMA_MODELS" \
        OLLAMA_KEEP_ALIVE="$OLLAMA_KEEP_ALIVE" \
        OLLAMA_NUM_PARALLEL="$OLLAMA_NUM_PARALLEL" \
        OLLAMA_MAX_LOADED_MODELS="$OLLAMA_MAX_LOADED_MODELS" \
        OLLAMA_CONTEXT_LENGTH="$OLLAMA_CONTEXT_LENGTH" \
        "$OLLAMA_BIN" serve > "$OLLAMA_LOG" 2>&1 &
    server_pid=$!
    for _ in {1..60}; do
        if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done
fi

if ! curl -fsS http://127.0.0.1:11434/api/tags >/dev/null; then
    echo "Ollama API did not become ready. See $OLLAMA_LOG" >&2
    exit 5
fi

# A previous Forever runner must release VRAM before Python loads SAM/GLIP.
timeout 30s "$OLLAMA_BIN" stop llama3.2-vision >/dev/null 2>&1 || true
for _ in {1..30}; do
    if ! timeout 5s "$OLLAMA_BIN" ps 2>/dev/null | grep -q 'llama3.2-vision'; then
        break
    fi
    sleep 1
done
if timeout 5s "$OLLAMA_BIN" ps 2>/dev/null | grep -q 'llama3.2-vision'; then
    echo "The previous Ollama runner is still loaded; refusing an unsafe launch." >&2
    "$OLLAMA_BIN" ps >&2 || true
    exit 6
fi

cd "$PROJECT_ROOT"
printf -v start_pad '%03d' "$START_EPISODE"
printf -v end_pad '%03d' "$((START_EPISODE + COUNT - 1))"
RUN_LOG="$LOG_DIR/mp3d_original_visual_${start_pad}_${end_pad}.log"

cleanup() {
    timeout 30s "$OLLAMA_BIN" stop llama3.2-vision >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Running episode index $START_EPISODE, count $COUNT"
echo "Log: $RUN_LOG"
echo "The first Ollama call will load the model automatically; do not warm it up."

set +e
python -u SG_Nav_original_visual.py \
    --split_l 0 \
    --split_r 1 \
    --episode_start "$START_EPISODE" \
    --num_episodes "$COUNT" \
    --visualize \
    2>&1 | tee "$RUN_LOG"
status=${PIPESTATUS[0]}
set -e

echo "SG-Nav exit status: $status"
echo "Video directory:"
echo "$PROJECT_ROOT/data/visualization/experiment_0_original_visual/[0:1]/video/"
exit "$status"
