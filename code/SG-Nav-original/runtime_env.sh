#!/usr/bin/env bash

# Runtime paths only. This file does not change SG-Nav's algorithm or metrics.
export SGNAV_ROOT="/root/autodl-tmp/Habitat/projects/SG-Nav-original"
export SGNAV_BERT_PATH="/root/autodl-tmp/Habitat/models/bert-base-uncased"
export SGNAV_NLTK_DATA="/root/autodl-tmp/Habitat/data/nltk_data"
export HF_HUB_OFFLINE=1
export TRANSFORMERS_OFFLINE=1
export OLLAMA_MODELS="/root/autodl-tmp/Habitat/models/ollama"
export LD_LIBRARY_PATH="/root/autodl-tmp/Habitat/envs/sgnav/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PYTHONPATH="$SGNAV_ROOT:$SGNAV_ROOT/GLIP:$SGNAV_ROOT/GroundingDINO:$SGNAV_ROOT/segment_anything:$SGNAV_ROOT/habitat-lab:/root/autodl-tmp/Habitat/projects/pytorch3d${PYTHONPATH:+:$PYTHONPATH}"
