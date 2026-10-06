# SG-Nav MP3D Reproduction and Result Audit

This repository documents an MP3D ObjectNav reproduction of [SG-Nav](https://github.com/bagh2178/SG-Nav), including an upstream source snapshot, compatibility patches, visualization extensions, environment records, raw logs, Habitat metrics, and videos. The corresponding NeurIPS 2024 paper is [SG-Nav: Online 3D Scene Graph Prompting for LLM-based Zero-shot Object Navigation](https://proceedings.neurips.cc/paper_files/paper/2024/hash/098491b37deebbe6c007e69815729e09-Abstract-Conference.html).

> **Audit conclusion (2026-10-06):** The engineering reproduction runs successfully and provides traceable artifacts for a single-scene experiment. It is not yet a strict reproduction of the paper's full MP3D validation benchmark. The aggregate covers 199 completed episodes from scene `2azQ1b91cZZ`, and the LLM/VLM, software environment, and execution protocol differ from those reported in the paper.

## Bottom line

| Level | Conclusion |
| --- | --- |
| Execution and artifact archival | **Successful:** all 199 completed episodes have one completed metric record and a corresponding video |
| Single-scene navigation quality | **Partially reaches the paper's range:** SR is `35.18%`, versus `40.1%` for SG-Nav-LLaMA in the paper |
| Path efficiency | **A clear gap remains:** SPL is `12.61%` and SoftSPL is `19.04%` |
| Full-paper reproduction | **Not established:** only 1/11 scenes and 199/2195 validation episodes were evaluated, with a different model configuration |

The most accurate description is therefore a **runnable single-scene reproduction and audit of SG-Nav**, not a reproduction of the complete MP3D benchmark score.

## Paper benchmark and reproduction scope

The paper evaluates the MP3D validation split with:

- 11 indoor scenes;
- 21 goal categories;
- 2,195 ObjectNav episodes;
- a maximum of 500 steps per episode;
- SR, SPL, and SoftSPL as the reported metrics, all higher-is-better.

The current repository evaluates:

- Dataset: Matterport3D ObjectNav validation;
- Scene slice: `[0:1]`, scene `2azQ1b91cZZ`;
- Completed episodes included in the statistics: 199;
- 19 goal categories;
- Success distance: `0.2 m`;
- Maximum episode length: 500 steps;
- Habitat-Lab: `0.2.1`;
- Habitat-Sim: `0.2.4`;
- GPU: NVIDIA GeForce RTX 4090 D.

The 199 completed episodes represent `9.07%` of the paper's full MP3D validation set. All aggregate scores give each episode equal weight, and per-category statistics use the same 199 records.

## Overall results across 199 episodes

The metrics were recomputed from 199 Habitat records in the [batch logs](artifacts/logs/original_visual/) and the [per-episode result file](artifacts/results/experiment_0_scene_0/results.txt), deduplicated by episode ID. Controller logs and running averages are not counted again.

| Metric | Result |
| --- | ---: |
| Valid completed records | `199/199` |
| Successful episodes | `70/199` |
| **SR** | **`35.18%`** |
| **Mean SPL** | **`12.61%`** |
| **Mean SoftSPL** | **`19.04%`** |
| Mean final distance to goal | `6.048 m` |
| Median final distance to goal | `3.005 m` |
| Mean episode length | `283.24` steps |
| Median episode length | `253` steps |
| Episodes reaching 500 steps | `66/199` (`33.17%`) |

SPL and SoftSPL are stored as ratios in `[0,1]` in the logs. They are shown as percentages here to match the paper's tables.

## Comparison with the paper

The table below uses the paper's complete **SG-Nav-LLaMA** configuration from Table 2 as a numerical reference. It is useful for judging scale, but it is **not a controlled, like-for-like benchmark comparison**.

| Metric | This single-scene evaluation | Paper SG-Nav-LLaMA | Absolute gap | Paper-score retention |
| --- | ---: | ---: | ---: | ---: |
| SR | `35.18%` | `40.1%` | `-4.92` pp | `87.72%` |
| SPL | `12.61%` | `16.0%` | `-3.39` pp | `78.84%` |
| SoftSPL | `19.04%` | `24.9%` | `-5.86` pp | `76.47%` |

Interpretation:

- **SR is in the same broad range, but a meaningful gap remains.** A total of 70/199 episodes succeeded, so the reproduced system is functional; however, one scene cannot represent the complete MP3D distribution.
- **Efficiency lags more than success.** The larger relative gaps in SPL and SoftSPL indicate longer routes and more trajectories that approach a goal without converting that progress into a valid success.
- **No single component can be blamed from these data alone.** The scene distribution, LLM/VLM, PyTorch/CUDA compatibility environment, and batch execution protocol all differ. Controlled ablations are required for causal claims.

Table 1 of the paper also reports `40.2% SR / 16.0% SPL` for SG-Nav-GPT on MP3D. This reproduction did not use GPT-4, so that row is not used as the primary reference.

## Failure structure and diagnostics

There are 129 failures among the 199 episodes:

| Diagnostic slice | Count | Share of all 199 | Interpretation |
| --- | ---: | ---: | --- |
| Failed after reaching 500 steps | `66` | `33.17%` | The largest single failure bucket; no valid STOP was completed before the step limit |
| Ended before 500 steps but failed | `63` | `31.66%` | May include wrong goals, wrong instances, planner STOPs, or loop exits; aggregate logs cannot separate them |
| Failed with final distance `>5 m` | `80` | `40.20%` | Most failures still ended far from the target |
| Failed with final distance `≤1 m` | `14` | `7.04%` | The agent approached the goal but did not meet the complete success condition |
| Failed with final distance `≤0.2 m` | `4` | `2.01%` | Episodes `58/92/144/194` all reached 500 steps, indicating failure to STOP near the success radius |
| Failed with SoftSPL `>0` | `72` | `36.18%` | Some navigation progress was made but did not become a final success |

All 66 episodes that reached the 500-step limit failed. The highest-priority follow-up checks are therefore:

1. STOP triggering when the agent is already near a target;
2. whether re-perception rejects wrong goals or instances early enough;
3. frontier selection and repeated exploration in long episodes;
4. consistency between Habitat success and the planner's internal notion of arrival.

Episodes `0` and `3` show a related pattern: the planner stopped after target detection, while Habitat still reported final distances of `11.060 m` and `7.310 m`.

## Per-category statistics

These values describe one scene only, and category sample sizes are highly imbalanced. Categories with `n<10` should not be treated as stable performance estimates.

| Goal | n | Successes | SR | SPL | SoftSPL | Mean final distance (m) | 500-step episodes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| chair | 38 | 26 | `68.42%` | `31.63%` | `33.61%` | 1.766 | 12 |
| cabinet | 34 | 10 | `29.41%` | `12.17%` | `18.53%` | 4.541 | 3 |
| table | 25 | 17 | `68.00%` | `15.45%` | `18.78%` | 0.723 | 7 |
| cushion | 21 | 7 | `33.33%` | `8.05%` | `16.66%` | 3.748 | 2 |
| counter | 12 | 4 | `33.33%` | `12.94%` | `23.31%` | 4.979 | 7 |
| picture | 10 | 0 | `0.00%` | `0.00%` | `12.76%` | 7.325 | 2 |
| plant | 8 | 2 | `25.00%` | `5.34%` | `16.32%` | 5.090 | 1 |
| chest_of_drawers | 7 | 1 | `14.29%` | `2.93%` | `6.22%` | 16.926 | 1 |
| sink | 7 | 0 | `0.00%` | `0.00%` | `6.82%` | 9.032 | 7 |
| sofa | 6 | 2 | `33.33%` | `15.79%` | `28.31%` | 8.180 | 3 |
| towel | 6 | 0 | `0.00%` | `0.00%` | `2.49%` | 15.961 | 5 |
| bed | 4 | 0 | `0.00%` | `0.00%` | `8.74%` | 18.458 | 4 |
| clothes | 4 | 0 | `0.00%` | `0.00%` | `8.96%` | 25.264 | 4 |
| seating | 4 | 0 | `0.00%` | `0.00%` | `2.05%` | 13.342 | 0 |
| toilet | 4 | 1 | `25.00%` | `6.55%` | `20.94%` | 6.302 | 2 |
| fireplace | 3 | 0 | `0.00%` | `0.00%` | `1.48%` | 23.988 | 1 |
| shower | 3 | 0 | `0.00%` | `0.00%` | `10.92%` | 9.916 | 3 |
| bathtub | 2 | 0 | `0.00%` | `0.00%` | `13.40%` | 10.700 | 2 |
| stool | 1 | 0 | `0.00%` | `0.00%` | `22.40%` | 8.485 | 0 |

Among categories with larger samples, `chair` and `table` reach approximately 68% SR, while `picture` is at 0%. This strong dependence on the category mix within one scene is another reason not to extrapolate the result to the paper's complete benchmark.

## Why this is not a strict paper-configuration reproduction

| Item | Paper | Repository run |
| --- | --- | --- |
| MP3D evaluation scope | 11 scenes, 2,195 episodes | 1 scene, 199 completed episodes |
| LLM | LLaMA-7B or GPT-4-0613 | Ollama `llama3.2-vision` |
| VLM / short-edge verification | LLaVA-1.6 (Mistral-7B) | The same `llama3.2-vision` model |
| Agent camera height | Reported as `0.90 m` | Configuration file uses `0.88 m` |
| PyTorch | Author instructions specify `<=1.9` | `2.0.1+cu118` with compatibility patches |
| Execution protocol | Batch details not reported | Multiple batches using original and visualization entry points, including interruptions and reruns |
| Visualization | Original implementation | Added node, edge, and model-response panels; intended to preserve navigation behavior, but not formally proven equivalent |

In addition, [`manifests/upstream-source-commit.txt`](manifests/upstream-source-commit.txt) is currently empty. The environment's `pip-freeze` references commit `d56863c...`, but the top-level source snapshot still lacks one explicit, complete upstream commit record. Filling it in would improve provenance.

## Log and artifact audit

- The repository contains 37 logs covering batch execution, controllers, and diagnostics.
- The batch logs and per-episode result file provide 199 unique valid records; each episode is counted once.
- The Git tree contains 199 corresponding MP4 entries. This is a file-inventory check, not a frame-by-frame integrity test.
- An earlier `114–123` attempt recorded an Ollama CUDA stream-capture error. Episode `115` was later rerun successfully; the failed attempt is not counted.
- A written video proves that visualization output completed, **not that navigation succeeded**. SR, SPL, and SoftSPL must come from Habitat metrics.

## Visualization and runtime patch

The original navigation entry points remain available as:

- `SG_Nav.py`
- `scenegraph.py`

The added visualization entry points are:

- `SG_Nav_original_visual.py`
- `scenegraph_original_visual.py`

They populate the Scene Graph Nodes, Scene Graph Edges, and LLM Explanation panels. The runtime wrapper also limits Ollama to one server, one loaded model, and one parallel request, with a fixed context length of `4096`, to control VRAM usage and batch stability. See the [original-visual runtime patch](patches/SGNav_mp3d_original_visual_runtime_v2_20260831/README.md) for details.

## Repository layout

- `code/SG-Nav-original/`: upstream source snapshot and visualization entry points;
- `artifacts/logs/`: execution and diagnostic logs;
- `artifacts/logs/original_visual/`: main batch and controller logs;
- `artifacts/results/`: raw and aggregate result files;
- `artifacts/videos/`: diagnostic and original-visual videos;
- `patches/`: compatibility, diagnostic, and runtime patches;
- `environment/`: Python, Conda, CUDA, GPU, and package information;
- `manifests/`: source checksums and provenance records.

Videos are stored with Git LFS. After cloning, run:

```bash
git lfs pull
```

Matterport3D/HM3D scenes, ObjectNav episode data, and model weights are governed by their respective licenses and are not included. Obtain them from the official sources.

## Optional follow-up work

The 199 episodes provide a completed milestone for this single-scene reproduction exercise. Further research could include:

1. Pinning random seeds, model versions, the Ollama version, and the upstream commit.
2. Adding action-level traces to investigate wrong-target STOP, near-goal failure to STOP, and step-limit failures.
3. Evaluating additional MP3D scenes to assess cross-scene performance.
4. Using the paper's model configuration and all 2,195 episodes for a full benchmark comparison.

## References

- [NeurIPS 2024 paper page](https://proceedings.neurips.cc/paper_files/paper/2024/hash/098491b37deebbe6c007e69815729e09-Abstract-Conference.html)
- [Paper PDF](https://proceedings.neurips.cc/paper_files/paper/2024/file/098491b37deebbe6c007e69815729e09-Paper-Conference.pdf)
- [Official SG-Nav repository](https://github.com/bagh2178/SG-Nav)
- [SG-Nav project page](https://bagh2178.github.io/SG-Nav/)

```bibtex
@inproceedings{yin2024sgnav,
  title={SG-Nav: Online 3D Scene Graph Prompting for LLM-based Zero-shot Object Navigation},
  author={Yin, Hang and Xu, Xiuwei and Wu, Zhenyu and Zhou, Jie and Lu, Jiwen},
  booktitle={Advances in Neural Information Processing Systems},
  volume={37},
  year={2024}
}
```
