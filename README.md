# SG-Nav MP3D Reproduction

This repository documents an MP3D ObjectNav reproduction attempt based on [bagh2178/SG-Nav](https://github.com/bagh2178/SG-Nav). It archives the cloud source snapshot, compatibility and visualization code, runtime patches, raw logs, Habitat metrics, and visualization videos.

> **Status as of 2026-09-19:** Outputs for 199 of the 200 selected episode indices are archived. Episode `5` was interrupted and remains excluded. The aggregate below covers the separately run **194-episode original-visual cohort (`6–199`)**, not all 200 selected episodes and not the full MP3D validation split.

## Experiment scope

- Dataset: Matterport3D ObjectNav validation
- Selected scene slice: `[0:1]` (`--split_l 0 --split_r 1`)
- Scene: `2azQ1b91cZZ`
- Selected episode indices: `0` through `199` (200 episodes)
- Goal category: varies by episode
- Success distance: `0.2 m`
- Habitat-Lab: `0.2.1`
- Habitat-Sim: `0.2.4`
- GPU: NVIDIA GeForce RTX 4090 D

The complete MP3D ObjectNav validation split contains 2,195 episodes across 11 scenes. This repository covers only the first selected scene and **does not report the full MP3D validation benchmark**.

## Current progress

Artifacts verified in repository commit [`f5b4d54`](https://github.com/Craisy-Mostima/SG-Nav-Reproduction/commit/f5b4d54):

| Episode indices | Status | Runtime |
| --- | --- | --- |
| `0–4` | Completed and archived | Initial diagnostic run |
| `5` | Interrupted and excluded | Initial diagnostic run |
| `6–199` | Per-episode metrics and videos archived | Original-visual runtime, run in batches |

The repository contains 199 archived episode outputs:

- 5 initial diagnostic episodes (`0–4`)
- 194 original-visual episodes (`6–199`)

Episode `5` remains missing; **199/200 archived is not a completed 200-episode evaluation**. The two cohorts were run with different entry points and are reported separately below. Video presence alone is not a success label.

## Original-visual cohort results (`6–199`)

The table is calculated from the per-episode Habitat metric dictionaries in the [original-visual batch logs](artifacts/logs/original_visual/). Each episode ID from `6` through `199` has exactly one completed metric record in the archived batch logs. Controller logs are retained for provenance but are **not** counted a second time.

| Measure | Result |
| --- | ---: |
| Completed episodes with metrics | `194/194` |
| Successes | `68/194` |
| Success rate | `0.350515` |
| Mean SPL | `0.128256` |
| Mean SoftSPL | `0.193200` |
| Mean distance to goal | `6.102630 m` |
| Episodes with 500 recorded steps | `65/194` |

These are descriptive results for one MP3D scene and one runtime configuration. They are **not** the paper's reproduced full-validation score. In particular, do not silently merge this 194-episode cohort with the earlier five diagnostic episodes to label the result a 200-episode score.

The audit found 29 batch logs containing 194 unique completed metric records with no missing IDs in `6–199`. The Git tree contains 194 correspondingly numbered original-visual MP4 entries (`vid_000006.mp4` through `vid_000199.mp4`) and five initial diagnostic MP4 entries (`0–4`). The archived original-visual videos use Git LFS. This inventory checks Git entries and metric records; it is not a frame-by-frame video integrity test.

## Initial five-episode results

The following table reports only the initial completed episodes `0–4`, from the [initial result file](artifacts/results/experiment_0_scene_0/results.txt). It is an early diagnostic baseline, **not** part of the 194-episode aggregate above.

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

The visualization implementation uses state and model responses already produced by the algorithm. It was designed not to change navigation actions, target selection, FMM planning, STOP thresholds, success distance, or Habitat metrics; this statement describes the patch intent, not a formal proof of behavioral equivalence.

The runtime wrapper additionally controls Ollama resource usage with:

- one Ollama server
- one loaded model
- one parallel request
- context length `4096`
- model cleanup between batches

These settings address deployment stability and GPU placement rather than intentionally changing the navigation policy. The episodes were executed in multiple batches and after some interrupted attempts, not as one uninterrupted 200-episode process.

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

MP4 files in the original-visual checkpoint are stored using Git LFS. After cloning, run `git lfs pull` to obtain the media rather than only their Git pointer files. Licensed scenes, episode datasets, and model weights must be obtained separately.

## Log and artifact audit

- The repository contains 37 log files: 29 original-visual batch logs, six original-visual controller logs, and two earlier diagnostic logs.
- The 29 batch logs provide one completed Habitat metric dictionary for each ID in `6–199`; controller logs may overlap in text and are excluded from the aggregate.
- The Git tree contains 199 MP4 entries in total: five initial diagnostic videos and 194 original-visual videos. Episode `5` has neither an accepted result nor an archived video.
- An earlier `114–123` attempt records an Ollama CUDA stream-capture error. Episode `115` was subsequently rerun successfully; the aborted attempt is retained for troubleshooting, not counted as an additional episode.
- A small final distance does not guarantee Habitat success. For example, episode `194` reports `distance_to_goal=0.032481 m` but `success=0`; the log alone does not establish the exact STOP/metric cause.

To complete the selected 200-episode scene slice, rerun and verify episode `5` under a documented runtime, archive its metrics and video, and then recompute a clearly defined 200-episode aggregate. Reproducing the **full** MP3D validation result additionally requires the remaining scenes and their episodes.

## Interpretation policy

This repository separates:

1. the upstream navigation implementation;
2. compatibility changes needed to run the software in the cloud environment;
3. visualization-only additions;
4. diagnostic instrumentation;
5. raw experimental outputs.

A generated video is evidence that an episode completed its visualization write, but it is not evidence of navigation success. Official success, SPL, SoftSPL, and distance-to-goal values must be taken from Habitat metrics.

The `6–199` cohort aggregate above is calculated from Habitat metrics, not visual inspection. It should not be presented as the selected 200-episode result or as the full MP3D validation benchmark. Results from re-runs should be selected by episode ID and provenance rather than double-counted from controller or failed-attempt logs.

## Data and model policy

This repository intentionally does not include:

- Matterport3D or HM3D scenes
- licensed ObjectNav episode datasets
- SAM, GLIP, GroundingDINO, BERT, or Ollama model weights
- Conda environments or package caches
- CUDA build artifacts

Obtain datasets and model weights from their official sources and comply with their respective licenses and terms of use.

