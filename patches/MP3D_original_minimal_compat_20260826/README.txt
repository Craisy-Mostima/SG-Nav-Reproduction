SG-Nav MP3D original-evaluation minimal runtime compatibility layer
==================================================================

Target:
  /root/autodl-tmp/Habitat/projects/SG-Nav-original

This installer copies only files required for:
  - PyTorch 2 removal of torch._six/private download APIs
  - CUDA extension compatibility already verified on the RTX 4090D host
  - offline/local BERT and NLTK resources
  - reuse of verified checkpoints and MP3D validation data by symlink

It intentionally does NOT replace:
  - SG_Nav.py
  - scenegraph.py
  - utils/utils_fmm/fmm_planner.py
  - habitat-lab/habitat/core/benchmark.py
  - configs/challenge_objectnav2021.local.rgbd.yaml

Therefore the original MP3D navigation policy, scene-graph logic, stopping
condition, task metrics, and evaluation configuration remain unchanged.

Install in the cloud with:
  bash /root/autodl-tmp/Habitat/downloads/MP3D_original_minimal_compat_20260826/install.sh

Then run the complete preflight check:
  bash /root/autodl-tmp/Habitat/downloads/MP3D_original_minimal_compat_20260826/preflight.sh

Before using the project in a terminal:
  source /root/miniconda3/etc/profile.d/conda.sh
  conda activate /root/autodl-tmp/Habitat/envs/sgnav
  source /root/autodl-tmp/Habitat/projects/SG-Nav-original/runtime_env.sh
  cd /root/autodl-tmp/Habitat/projects/SG-Nav-original
