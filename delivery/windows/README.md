# unified-marl 内部使用包：Windows x64 / CPU / CPython 3.12

本目录可压缩发送给同事，不需要原始交付目录、GitHub、网页或服务器。核心版本 0.7.0，包含 role、hmf、reward、distributed 的已验证依赖。安装过程只使用 wheelhouse，禁止联网，不修改全局 Python。

## 接收方准备

- Windows x64；本机实际验收 Windows 11，其他 Windows 版本没有实机验收。
- 预先安装 CPython 3.12 x64（本次验收为 3.12.14），必须包含 venv/pip。Python 安装程序未随包提供。
- 如 PyTorch 导入报告缺少系统 DLL，需要由接收方安装匹配的 Microsoft Visual C++ 运行库；本脚本不修改系统运行库。
- 建议至少 3 GB 可用空间。不要从 ZIP 内直接运行；先解压到普通可写文件夹，支持中文和空格，但目录不能过深。PyTorch 含较长文件名；安装前会估算路径，过长时提前停止，请换到较短的可写目录（如 D:\marl），无需本脚本修改系统长路径设置。
- CPU 版不要求 CUDA，不包含 GPU 依赖；不适用于 ARM64、32 位或其他 Python 主次版本。

## 安装和最小使用

打开 PowerShell，进入解压目录：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
# 找不到 Python 时显式指定。此策略仅作用于本次进程，不修改系统执行策略：
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -PythonPath "C:\Python312\python.exe"
powershell -NoProfile -ExecutionPolicy Bypass -File .\run.ps1 --help
powershell -NoProfile -ExecutionPolicy Bypass -File .\run.ps1 train --algorithm pymarl/qmix --env toy --output-dir .\results\my-qmix --set batch_size=2 --set buffer_size=8 --set t_max=32
.\.venv\Scripts\python.exe examples\online.py --output .\results\online-demo
```

安装默认跑一次 QMIX 参数更新、动作掩码、保存、加载、评估及恢复检查，报告在 results/install-check-*/report.json；此检查只用 toy。新训练应选择新的输出目录，避免覆盖已有模型。

离线和偏好示例（这里只生成明确标记的 toy 合成数据）：

```powershell
.\.venv\Scripts\python.exe examples\make_demo_data.py .\data\demo.th
.\.venv\Scripts\python.exe examples\offline.py --dataset .\data\demo.th --output .\results\bc
.\.venv\Scripts\python.exe examples\offline.py --algorithm kou/cpl --dataset .\data\demo.th --output .\results\cpl
.\.venv\Scripts\python.exe examples\reward.py --dataset .\data\demo.th --output .\results\reward
```

Python 中可直接 `from unified_marl import train, evaluate, load_policy`。请使用本目录 .venv 的 Python；也可以让自己的项目用同一解释器，不需要复制源码或修改 sys.path。完整 API/分布式例子见 examples 和 docs。

## 搬运和边界

发原 ZIP 或未安装的解压目录。不要复制创建后的 .venv；它绑定安装路径。换电脑或搬目录后，重新从 ZIP 解压安装。重复运行原位置的安装脚本是允许的。

真实数据放 data 或任意目录，通过参数指定；输出目录自行指定。包不包含真实数据、训练模型、SMAC/StarCraft II、ReplenishmentEnv 或 CityFlow。真实环境须另行准备资产和后端。安装成功不等于所有原始算法、真实仿真或收敛效果通过；支持子集与全部限制见 docs/SUPPORT_MATRIX.md、KNOWN_ISSUES.md。

原许可和来源说明保留在 licenses、LICENSE 和 NOTICE 中，方便内部追踪。无需搭建账号、授权或联网管理系统。
