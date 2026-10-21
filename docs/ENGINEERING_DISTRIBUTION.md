# 工程版分发说明

工程版为 `unified-marl 0.8.0`，面向 Windows x64 与 Linux x86_64、CPython 3.12、CPU。包内包含本地项目 wheel、该平台已经验证的内部依赖 wheelhouse、工程指南、应用模板与示例，以及文件 SHA-256 manifest。Python 运行时不随包提供。

Windows ZIP 为 `unified-marl-0.8.0-windows-x64-cpu-py312-engineering.zip`；Linux ZIP 为 `unified-marl-0.8.0-linux-x86_64-cpu-py312-engineering.zip`。下载后先核对同目录的 `.zip.sha256`，解压到短且可写的路径，再执行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows\install.ps1
.\windows\run.ps1 --help
```

```bash
bash linux/install.sh
bash linux/run.sh --help
```

Linux 基础安装使用包内的精确依赖锁，不联网。可通过 `bash linux/install.sh --Feature reward` 安装奖励模型功能；该功能会从 PyPI 补齐 Linux 专用的 `hf-xet`。`--Feature role`、`--Feature hmf` 和 `--Feature distributed` 从包内 wheelhouse 安装对应依赖。仓储的 `--Feature warehouse` 会安装 `hmf`（MFVFD）依赖；`--Feature warehouse-role` 同时安装 `hmf` 与 `role`（RODE-HMF）依赖。工程应用依赖按功能独立处理：`bash linux/install.sh --Feature powergrid` 在包内带有 `requirements-powergrid.txt` 时联网安装 pandapower 依赖；交通功能的 CityFlow 需要按 [交通指南](TRAFFIC_GUIDE.md) 从外部源码构建。基础安装不会联网安装这些可选依赖。

`install` 只创建包内 `.venv`、安装依赖并检查包导入，不会启动训练、仿真或实验。`run` 将参数原样传给 `unified-marl-app`，例如 `windows/run.ps1 --help` 或 `bash linux/run.sh --help`。应用选择和参数以 [应用指南](APPLICATIONS_GUIDE.md) 为准。

该交付由 `tools/build_engineering_delivery.py` 从已存在的 `dist/internal` Windows/Linux 0.7.0 wheelhouse 重用依赖，并在本机从源码构造 0.8.0 通用 wheel；构建器不下载依赖。生成物位于 `dist/unified_marl-0.8.0-py3-none-any.whl` 和 `dist/internal/`。包内 `manifest.json` 对每个文件记录大小与 SHA-256，ZIP 旁的 `.zip.sha256` 校验归档本身。旧分发构建器保持独立。

该说明描述分发格式和安装流程，不代表工程应用已经通过真实模拟器、真实数据或训练实验验收。工程版会包含应用指南与模板；运行前请按各自指南准备外部模拟器、依赖和输入数据。
