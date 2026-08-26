#!/usr/bin/env bash
set -euo pipefail

HABITAT_ROOT="/root/autodl-tmp/Habitat"
ORIGINAL_ROOT="$HABITAT_ROOT/projects/SG-Nav-original"

source /root/miniconda3/etc/profile.d/conda.sh
conda activate "$HABITAT_ROOT/envs/sgnav"
source "$ORIGINAL_ROOT/runtime_env.sh"
cd "$ORIGINAL_ROOT"

echo "[1/5] Original MP3D configuration"
grep -E "SUCCESS_DISTANCE|DATA_PATH|SCENES_DIR" \
  configs/challenge_objectnav2021.local.rgbd.yaml

echo "[2/5] MP3D validation data"
test -s data/MatterPort3D/objectnav/mp3d/v1/val/val.json.gz
scene_count="$(find data/MatterPort3D/mp3d -mindepth 2 -maxdepth 2 -name '*.glb' | wc -l)"
episode_file_count="$(find data/MatterPort3D/objectnav/mp3d/v1/val/content -maxdepth 1 -name '*.json.gz' | wc -l)"
echo "MP3D GLB scenes: $scene_count"
echo "ObjectNav per-scene files: $episode_file_count"
if [[ "$scene_count" -ne 11 || "$episode_file_count" -ne 11 ]]; then
  echo "ERROR: expected 11 MP3D val scenes and 11 ObjectNav files" >&2
  exit 1
fi

echo "[3/5] Checkpoints"
test -s data/models/sam_vit_h_4b8939.pth
test -s data/models/groundingdino_swint_ogc.pth
test -s GLIP/MODEL/glip_large_model.pth
ls -lh \
  data/models/sam_vit_h_4b8939.pth \
  data/models/groundingdino_swint_ogc.pth \
  GLIP/MODEL/glip_large_model.pth

echo "[4/5] Python and CUDA modules"
python -c "import torch, habitat, habitat_sim, faiss, pytorch3d; from segment_anything import sam_model_registry; import groundingdino; from groundingdino import _C as dino_c; import maskrcnn_benchmark._C as glip_c; from GLIP.maskrcnn_benchmark.engine.predictor_glip import GLIPDemo; print('PyTorch:', torch.__version__); print('GPU:', torch.cuda.get_device_name(0)); print('Habitat-Lab:', habitat.__version__); print('Habitat-Sim:', habitat_sim.__version__); print('FAISS GPUs:', faiss.get_num_gpus()); print('PyTorch3D:', pytorch3d.__version__); print('SAM, GroundingDINO and GLIP imports: OK')"

echo "[5/5] Load one original MP3D ObjectNav episode"
python -c "import habitat; c=habitat.get_config('configs/challenge_objectnav2021.local.rgbd.yaml'); e=habitat.Env(config=c); o=e.reset(); print('Episode:', e.current_episode.episode_id); print('Goal:', e.current_episode.object_category); print('Scene:', e.current_episode.scene_id); print('Sensors:', sorted(o.keys())); e.close(); print('Habitat MP3D reset: OK')"

echo "FINAL ORIGINAL MP3D PREFLIGHT OK"
