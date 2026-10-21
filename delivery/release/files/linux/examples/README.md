# Linux 示例

这些示例使用隔离环境中安装的包；它们不需要从源码目录启动，也不包含真实训练数据或仿真器资产。请在每次运行时选择新的输出目录。

```bash
.venv/bin/python -X utf8 -I examples/online.py --output ./results/demo-online
.venv/bin/python -X utf8 -I examples/inference.py ./results/demo-online/first/policy.pt
bash ./run.sh evaluate ./results/demo-online/first/policy.pt --episodes 2 --seed 7
```

生成合成离线数据并运行离线/奖励模型示例：

```bash
.venv/bin/python -X utf8 -I examples/make_demo_data.py ./data/demo.th
.venv/bin/python -X utf8 -I examples/offline.py --dataset ./data/demo.th --output ./results/demo-bc
.venv/bin/python -X utf8 -I examples/reward.py --dataset ./data/demo.th --output ./results/demo-reward
```

`demo.th` 只是接口演示用的合成 toy 数据，不是 SMAC 或其他真实环境数据。ZMQ 示例需本包的 `[distributed]` 依赖（已包含）并使用本机回环；本包只有 Windows 本机 ZMQ 运行证据，Linux 下不据此宣称实机支持。真实环境所需后端与数据由接收方另行准备，详见 `docs/SUPPORT_MATRIX.md`。
