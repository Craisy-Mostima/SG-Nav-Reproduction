# SG-Nav 原版 STOP 原因诊断

这个诊断包不会覆盖 `SG_Nav.py`，只在同一目录新增：

```text
SG_Nav_diagnostic.py
```

导航动作、阈值、目标选择、FMM 路径和 Habitat 指标都保持不变。新增内容仅把程序已经计算出的状态输出为 `[SG-Nav Diagnostic]` 日志。

## 上传和安装

把整个压缩包上传到：

```text
/root/autodl-tmp/Habitat/downloads/
```

在云端终端执行：

```bash
cd /root/autodl-tmp/Habitat/downloads
tar -xf SGNav_original_stop_diagnostic_20260826.tar

source /root/miniconda3/etc/profile.d/conda.sh
conda activate /root/autodl-tmp/Habitat/envs/sgnav

bash /root/autodl-tmp/Habitat/downloads/SGNav_original_stop_diagnostic_20260826/install.sh
```

安装程序会先核对官方 `SG_Nav.py` 的 SHA256。如果官方文件发生过变化，安装会直接停止。安装成功后，官方文件仍保持原哈希：

```text
902ea13508c74c1323dfc5f198148819e9e757bdc50bf38345f5987f6a953284
```

## 运行一个 MP3D 诊断 episode

先确认 Ollama 服务正常，然后执行：

```bash
cd /root/autodl-tmp/Habitat/projects/SG-Nav-original
mkdir -p /root/autodl-tmp/Habitat/logs

python -u SG_Nav_diagnostic.py \
  --split_l 0 \
  --split_r 1 \
  --visualize \
  2>&1 | tee /root/autodl-tmp/Habitat/logs/mp3d_original_episode_001_stop_diagnostic.log
```

本项目当前的最小 MP3D 数据已经把第一个场景限制为一个 episode，因此该命令结束后会回到终端提示符。

## 提取关键诊断结果

```bash
grep -F '[SG-Nav Diagnostic]' \
  /root/autodl-tmp/Habitat/logs/mp3d_original_episode_001_stop_diagnostic.log
```

重点查看最后一条 `return_stop`：

- `max_steps_500`：达到官方 500 步上限；
- `random_goal_retry_limit_20`：连续 20 次都找不到有效随机目标/路径；
- `planner_stop_after_target_found`：检测系统认为已找到目标，并且 FMM 认为已经抵达内部目标；
- `planner_returned_stop`：规划器返回 STOP，但当时没有稳定目标标记。

`target_detection` 会同时记录目标标签、GLIP 分数、边界框和边界框中心的深度。

## 恢复

不需要恢复官方文件，因为它从未被修改。如果不再需要诊断版，只需删除：

```bash
rm /root/autodl-tmp/Habitat/projects/SG-Nav-original/SG_Nav_diagnostic.py
```

