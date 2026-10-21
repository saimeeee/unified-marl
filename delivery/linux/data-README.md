# 数据与运行产物放置

本包不包含训练数据、checkpoint、预训练权重、缓存或仿真器资产。请将这些文件放在由接收方管理的独立目录，并在每次运行时明确传入路径。不要依赖包安装目录或调用时的当前目录自动查找数据。

例如，数据位于带空格路径时，用引号传入：

```bash
bash "/opt/team tools/unified-marl-0.7.0-linux-x86_64-cpu-py312/run.sh" \
  train --algorithm kou/bc --dataset "/srv/marl data/3m.th" \
  --output-dir "/srv/marl runs/bc-demo" --set training_updates=2
```

相对输出目录按运行命令所在的当前目录解释。每次训练请提供新的输出目录；已有输出目录会被拒绝，以免覆盖结果。`examples/make_demo_data.py` 可以生成明确标记的合成 toy 数据，用于接口示例，不代表真实仿真数据。

使用 SMAC、补货或 CityFlow 时，后端程序、地图、配置和任务数据必须由接收方另行准备，并遵循 `docs/SUPPORT_MATRIX.md` 与 `docs/KNOWN_ISSUES.md` 中的限制。安装包不会下载、修改或启动这些外部环境。
