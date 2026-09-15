# SG-Nav MP3D Reproduction

This repository contains a reproducibility snapshot for [bagh2178/SG-Nav](https://github.com/bagh2178/SG-Nav), including the cloud source snapshot, compatibility and visualization code, runtime patches, raw logs, Habitat metrics, and visualization videos.

> **Status:** This repository is an incremental checkpoint. The selected 200-episode evaluation has not yet been completed, and the results below must not be interpreted as the final MP3D validation result.

## Experiment scope

- Dataset: Matterport3D ObjectNav validation
- Selected scene slice: `[0:1]`
- Scene: `2azQ1b91cZZ`
- Selected episode indices: `0` through `199` (200 episodes)
- Goal category: varies by episode
- Success distance: `0.2 m`
- Habitat-Lab: `0.2.1`
- Habitat-Sim: `0.2.4`
- GPU: NVIDIA GeForce RTX 4090 D

The complete MP3D ObjectNav validation split contains 2,195 episodes across 11 scenes. This repository currently evaluates only the first selected scene and therefore does not report the complete MP3D validation benchmark.

## Current progress

Artifacts saved in the current checkpoint:

| Episode indices | Status | Runtime |
| --- | --- | --- |
| `0–4` | Completed and archived | Initial diagnostic run |
| `5` | Interrupted and excluded | Initial diagnostic run |
| `6–150` | Completed videos and logs archived | Original-visual runtime |
| `151–199` | Pending at this checkpoint | Not yet included |

The repository currently contains 150 completed episode outputs:

- 5 initial diagnostic episodes (`0–4`)
- 145 original-visual episodes (`6–150`)

Episode `5` was interrupted and is excluded. Because the evaluation is still in progress, aggregate metrics for episodes `6–150` have not yet been published. Raw per-episode Habitat metrics are retained in the logs.

## Initial five-episode results

The following table reports only the initial completed episodes `0–4`. It is retained as an early diagnostic baseline and is not the aggregate result for the current checkpoint.

| Episode | Steps | Termination | Distance to goal (m) | Success | SPL | SoftSPL |
| ---: | ---: | --- | ---: | ---: | ---: | ---: |
| 0 | 49 | Planner STOP after target detection | 11.059553 | 0 | 0.000000 | 0.000000 |
| 1 | 276 | Planner STOP after target detection | 0.015518 | 1 | 0.058922 | 0.058462 |
| 2 | 118 | Planner STOP after target detection | 0.042603 | 1 | 0.163049 | 0.160161 |
| 3 | 93 | Planner STOP after target detection | 7.309648 | 0 | 0.000000 | 0.000000 |
| 4 | 500 | Episode step limit | 1.291116 | 0 | 0.000000 | 0.194044 |

Aggregate metrics over these five initial episodes:

- Success Rate: `0.400000`
- Mean SPL: `0.044394`
- Mean SoftSPL: `0.082533`
- Mean distance to goal: `3.943688 m`

Episodes `0` and `3` demonstrate false or incorrect-instance stopping: SG-Nav's internal planner considered the detected target reached, while Habitat's ground-truth distance remained large.

## Visualization runtime

The original navigation files remain available as:

- `SG_Nav.py`
- `scenegraph.py`

The additional visualization entry points are:

- `SG_Nav_original_visual.py`
- `scenegraph_original_visual.py`

These files populate the previously blank visualization panels:

- Scene Graph Nodes
- Scene Graph Edges
- LLM Explanation

The visualization implementation uses state and model responses already produced by the algorithm. It does not intentionally change navigation actions, target selection, FMM planning, STOP thresholds, success distance, or Habitat metrics.

The runtime wrapper additionally controls Ollama resource usage with:

- one Ollama server
- one loaded model
- one parallel request
- context length `4096`
- model cleanup between batches

These settings address deployment stability and GPU placement; they do not change the navigation policy.

## Repository layout

- `code/SG-Nav-original/`: cloud source snapshot and visualization entry points
- `artifacts/logs/`: initial diagnostic logs
- `artifacts/logs/original_visual/`: original-visual runtime and controller logs
- `artifacts/results/`: raw and aggregate result files
- `artifacts/videos/`: initial diagnostic videos
- `artifacts/videos/experiment_0_original_visual_scene_0/`: original-visual videos
- `patches/`: compatibility, diagnostic, and runtime patch packages
- `environment/`: Python, Conda, CUDA, GPU, and package information
- `manifests/`: source revisions and SHA256 checksums

MP4 files in the original-visual checkpoint are stored using Git LFS.

## Interpretation policy

This repository separates:

1. the upstream navigation implementation;
2. compatibility changes needed to run the software in the cloud environment;
3. visualization-only additions;
4. diagnostic instrumentation;
5. raw experimental outputs.

A generated video is evidence that an episode completed its visualization write, but it is not evidence of navigation success. Official success, SPL, SoftSPL, and distance-to-goal values must be taken from Habitat metrics.

No final aggregate result will be reported until all intended episodes have been completed and the logs have been checked for missing, duplicated, or interrupted episode IDs.

## Data and model policy

This repository intentionally does not include:

- Matterport3D or HM3D scenes
- licensed ObjectNav episode datasets
- SAM, GLIP, GroundingDINO, BERT, or Ollama model weights
- Conda environments or package caches
- CUDA build artifacts

Obtain datasets and model weights from their official sources and comply with their respective licenses and terms of use.

