# SG-Nav MP3D Reproduction

This repository contains a reproducibility snapshot for
[bagh2178/SG-Nav](https://github.com/bagh2178/SG-Nav), including the cloud
source tree, compatibility and diagnostic code, raw logs, Habitat metrics, and
visualization videos.

## Experiment scope

- Dataset: Matterport3D ObjectNav validation
- Scene: `2azQ1b91cZZ`
- Goal category: `cabinet`
- Success distance: `0.2 m`
- Completed episodes: IDs `0` through `4`
- Episode `5` was started but interrupted and is excluded from all reported metrics.
- These are preliminary diagnostic results, not the complete MP3D validation result.

## Preliminary results

| Episode | Steps | Termination | Distance to goal (m) | Success | SPL | SoftSPL |
|---:|---:|---|---:|---:|---:|---:|
| 0 | 49 | Planner STOP after target detection | 11.059553 | 0 | 0.000000 | 0.000000 |
| 1 | 276 | Planner STOP after target detection | 0.015518 | 1 | 0.058922 | 0.058462 |
| 2 | 118 | Planner STOP after target detection | 0.042603 | 1 | 0.163049 | 0.160161 |
| 3 | 93 | Planner STOP after target detection | 7.309648 | 0 | 0.000000 | 0.000000 |
| 4 | 500 | Episode step limit | 1.291116 | 0 | 0.000000 | 0.194044 |

Aggregate metrics over the five completed episodes:

- Success Rate: `0.400000`
- Mean SPL: `0.044394`
- Mean SoftSPL: `0.082533`
- Mean distance to goal: `3.943688 m`

Episodes 0 and 3 demonstrate false or incorrect-instance stopping: SG-Nav's
internal planner considered the detected target reached, while Habitat's
ground-truth distance remained large.

## Repository layout

- `code/SG-Nav-original/`: cloud source snapshot used for the run
- `artifacts/logs/`: original and structured diagnostic logs
- `artifacts/results/`: raw Habitat per-episode and aggregate metrics
- `artifacts/videos/`: visualization videos for episodes 0 through 4
- `patches/`: runtime compatibility and diagnostic patch packages
- `environment/`: Python, Conda, package, CUDA, and GPU information
- `manifests/`: source revisions and SHA256 file checksums

## Diagnostic-code policy

`SG_Nav.py` is retained as the original navigation entry point.
`SG_Nav_diagnostic.py` is a separate diagnostic copy that adds structured
logging. The diagnostic events report already-computed state and do not
intentionally change navigation actions, thresholds, target selection, FMM
planning, STOP conditions, or Habitat metrics.

## Data and model policy

This repository intentionally does not include:

- Matterport3D/HM3D scenes or licensed episode datasets
- SAM, GLIP, GroundingDINO, BERT, or Ollama model weights
- Conda environments or package caches
- CUDA build artifacts

Obtain datasets and model weights from their official sources and follow their
respective licenses.
