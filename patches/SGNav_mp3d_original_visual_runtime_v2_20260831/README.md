# SG-Nav MP3D 轻量原版可视化运行补丁

## 目的

这个版本用于替代高频诊断版运行，目标是尽量回到作者原始执行方式，同时补全原版
视频中一直为空的三个面板：

- Scene Graph Nodes
- Scene Graph Edges
- LLM Explanation

它不会覆盖 `SG_Nav.py` 或 `scenegraph.py`，只新增：

- `SG_Nav_original_visual.py`
- `scenegraph_original_visual.py`

## 与作者原版相比的变化

导航相关逻辑保持不变，包括 GLIP 检测、SAM/GroundingDINO 场景图、LLM/VLM
调用、FMM 规划、动作、STOP 条件和 Habitat 指标。新增部分仅为：

1. 把原算法已经生成的节点、边和最近一次模型回复写入视频；
2. 可视化文本最多每 5 个导航步重建一次，模型回复发生时立即更新；
3. 增加 `--episode_start` 与 `--num_episodes`；
4. 将视频写入独立的 `experiment_0_original_visual` 目录。

这个版本移除了旧诊断版中每次目标检测的 GPU→CPU 强制同步、规划 JSON、场景图
JSON 和高频文本变化日志。它不会为了填充面板额外调用 Ollama。

## Episode 6 变慢的判断

Episode 6 的高 CPU/GPU 占用主要来自作者原算法：每个导航步执行检测、分割、3D
映射和场景图更新；出现新节点时，`update_edge()` 会对许多新边串行调用 Ollama
VLM/LLM。复杂 episode 的调用次数会远多于短 episode，因此速度不能仅按前五个
episode 外推。

旧诊断版的高频同步和日志会进一步放大开销，但不是全部原因。此次 Episode 6 的
直接性能异常已定位为 Ollama server 使用了 `CONTEXT 32768`：模型占用约 16 GB，
只能以约 `18% CPU / 82% GPU` 的方式运行，CPU 参与推理后速度明显下降。启动脚本
现在固定 `OLLAMA_CONTEXT_LENGTH=4096`，并会自动重启不符合该配置的旧 server。
正常加载后，`ollama ps` 应显示 `CONTEXT 4096`，通常约 11 GB、`100% GPU`。

## 安装

把整个补丁目录上传到：

```text
/root/autodl-tmp/Habitat/downloads/SGNav_mp3d_original_visual_runtime_v2_20260831
```

然后执行：

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate /root/autodl-tmp/Habitat/envs/sgnav
bash /root/autodl-tmp/Habitat/downloads/SGNav_mp3d_original_visual_runtime_v2_20260831/install.sh
```

安装器会验证原始文件哈希，且不会修改原始文件。

## 推荐运行方式

一次只运行 Episode 6：

```bash
bash /root/autodl-tmp/Habitat/downloads/SGNav_mp3d_original_visual_runtime_v2_20260831/run_episodes.sh 6 1
```

连续运行 Episode 6 至 10（只初始化一次 Python 模型，整体效率更高）：

```bash
bash /root/autodl-tmp/Habitat/downloads/SGNav_mp3d_original_visual_runtime_v2_20260831/run_episodes.sh 6 5
```

建议先用 `6 1` 验证，再决定是否批量。脚本会：

- 拒绝与另一个 SG-Nav 进程并行运行；
- 只保留一个 Ollama server；
- 用 `KEEP_ALIVE=-1` 避免运行中卸载进入 `Stopping...`；
- 固定 Ollama 上下文为 4096，避免模型部分卸载到 CPU；
- 启动 Python 前释放上一次 Ollama runner 的显存；
- 不执行模型预热；
- Python 结束后释放 Ollama 模型显存；
- 为每次运行生成独立日志。

视频目录：

```text
/root/autodl-tmp/Habitat/projects/SG-Nav-original/data/visualization/experiment_0_original_visual/[0:1]/video/
```

## 监控

另开一个终端执行：

```bash
tail -f /root/autodl-tmp/Habitat/logs/mp3d_original_visual_006_006.log
```

```bash
/root/autodl-tmp/Habitat/tools/ollama-v0.24.0/bin/ollama ps
```

首次发生 Ollama 调用后，应确认输出为 `CONTEXT 4096` 和 `100% GPU`。若仍显示
`32768` 或 CPU/GPU 混合运行，不要继续该轮实验，应停止并用本脚本重新启动。

```bash
nvidia-smi
```

如果日志仍在更新，不要因为 GPU/CPU 使用率高而停止。若日志超过 10 分钟没有任何
新内容，再检查 Ollama 状态与进程数量。
