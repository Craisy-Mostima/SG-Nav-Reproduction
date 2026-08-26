#!/usr/bin/env bash
set -euo pipefail

HABITAT_ROOT="/root/autodl-tmp/Habitat"
COMPAT_SOURCE="$HABITAT_ROOT/projects/SG-Nav"
ORIGINAL_ROOT="$HABITAT_ROOT/projects/SG-Nav-original"
PATCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_ROOT="$ORIGINAL_ROOT/patches/minimal_runtime_compat_$STAMP"

if [[ ! -f "$ORIGINAL_ROOT/SG_Nav.py" ]]; then
  echo "ERROR: clean SG-Nav source is missing: $ORIGINAL_ROOT/SG_Nav.py" >&2
  exit 1
fi
if [[ ! -f "$COMPAT_SOURCE/SG_Nav.py" ]]; then
  echo "ERROR: verified compatibility source is missing: $COMPAT_SOURCE" >&2
  exit 1
fi
if [[ ! -d "$HABITAT_ROOT/data/MatterPort3D/mp3d" ]]; then
  echo "ERROR: MP3D data is missing: $HABITAT_ROOT/data/MatterPort3D" >&2
  exit 1
fi
if [[ ! -f "$PATCH_ROOT/runtime_env.sh" ]]; then
  echo "ERROR: runtime_env.sh is missing beside install.sh" >&2
  exit 1
fi

compat_files=(
  "GLIP/maskrcnn_benchmark/csrc/cuda/ml_nms.cu"
  "GLIP/maskrcnn_benchmark/csrc/cuda/nms.cu"
  "GLIP/maskrcnn_benchmark/data/build.py"
  "GLIP/maskrcnn_benchmark/data/datasets/evaluation/lvis/lvis_eval.py"
  "GLIP/maskrcnn_benchmark/engine/inference.py"
  "GLIP/maskrcnn_benchmark/engine/predictor_glip.py"
  "GLIP/maskrcnn_benchmark/modeling/detector/generalized_vl_rcnn.py"
  "GLIP/maskrcnn_benchmark/modeling/language_backbone/bert_model.py"
  "GLIP/maskrcnn_benchmark/modeling/language_backbone/hfpt_tokenizer.py"
  "GLIP/maskrcnn_benchmark/modeling/rpn/loss.py"
  "GLIP/maskrcnn_benchmark/modeling/rpn/vldyhead.py"
  "GLIP/maskrcnn_benchmark/utils/c2_model_loading.py"
  "GLIP/maskrcnn_benchmark/utils/imports.py"
  "GLIP/maskrcnn_benchmark/utils/model_zoo.py"
  "GLIP/maskrcnn_benchmark/utils/hf_model_paths.py"
  "GroundingDINO/groundingdino/util/get_tokenlizer.py"
)

mkdir -p "$BACKUP_ROOT"
for relative_path in "${compat_files[@]}"; do
  source_path="$COMPAT_SOURCE/$relative_path"
  target_path="$ORIGINAL_ROOT/$relative_path"
  if [[ ! -f "$source_path" ]]; then
    echo "ERROR: required compatibility file is missing: $source_path" >&2
    exit 1
  fi
  if [[ -f "$target_path" ]]; then
    mkdir -p "$BACKUP_ROOT/$(dirname "$relative_path")"
    cp -a "$target_path" "$BACKUP_ROOT/$relative_path"
  fi
  mkdir -p "$(dirname "$target_path")"
  cp -a "$source_path" "$target_path"
done

copy_extension() {
  local source_pattern="$1"
  local target_dir="$2"
  local found=0
  mkdir -p "$target_dir"
  for extension_path in $source_pattern; do
    if [[ -f "$extension_path" ]]; then
      cp -a "$extension_path" "$target_dir/"
      found=1
    fi
  done
  if [[ "$found" -ne 1 ]]; then
    echo "ERROR: compiled extension not found: $source_pattern" >&2
    exit 1
  fi
}

copy_extension \
  "$COMPAT_SOURCE/GLIP/maskrcnn_benchmark/_C.cpython-39-*.so" \
  "$ORIGINAL_ROOT/GLIP/maskrcnn_benchmark"
copy_extension \
  "$COMPAT_SOURCE/GroundingDINO/groundingdino/_C.cpython-39-*.so" \
  "$ORIGINAL_ROOT/GroundingDINO/groundingdino"

mkdir -p "$ORIGINAL_ROOT/data/models" "$ORIGINAL_ROOT/GLIP/MODEL"
ln -sfn \
  "$COMPAT_SOURCE/data/models/sam_vit_h_4b8939.pth" \
  "$ORIGINAL_ROOT/data/models/sam_vit_h_4b8939.pth"
ln -sfn \
  "$COMPAT_SOURCE/data/models/groundingdino_swint_ogc.pth" \
  "$ORIGINAL_ROOT/data/models/groundingdino_swint_ogc.pth"
ln -sfn \
  "$COMPAT_SOURCE/GLIP/MODEL/glip_large_model.pth" \
  "$ORIGINAL_ROOT/GLIP/MODEL/glip_large_model.pth"
ln -sfn \
  "$HABITAT_ROOT/data/MatterPort3D" \
  "$ORIGINAL_ROOT/data/MatterPort3D"

cp -a "$PATCH_ROOT/runtime_env.sh" "$ORIGINAL_ROOT/runtime_env.sh"
chmod +x "$ORIGINAL_ROOT/runtime_env.sh"

echo "Minimal runtime compatibility installed."
echo "Clean project: $ORIGINAL_ROOT"
echo "Backup: $BACKUP_ROOT"
echo "Navigation/scene-graph/metric files were not replaced."
