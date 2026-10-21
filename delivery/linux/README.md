# unified-marl 0.7.0 — Linux x86_64 CPU 包

此包面向 **CPython 3.12、Linux x86_64、CPU**，使用 PyTorch 2.6.0+cpu。目标 Linux 系统需提供 glibc 2.28 或更新版本，以及 Python wheel 所需的常规 C/C++ 运行库。Python 解释器、`venv`/`pip` 模块和系统运行库需要预先安装；压缩包不包含解释器，也不会使用 sudo 或自动修改系统。

大多数已验依赖 wheel 随包提供并通过 SHA-256 校验。Linux x86_64 上 `huggingface-hub` 的元数据还要求 `hf-xet>=1.1.3,<2.0.0`；此单个 Linux-only 依赖未打入包，安装时会从公开 PyPI 联网安装，且没有预先锁定版本或哈希。因此接收方安装时需能访问 `https://pypi.org/simple`。其余 Python 依赖均从包内 wheelhouse 安装，不会联网解析。

支持范围是上述固定目标和包内锁定的依赖组合，不表示任意 Linux 发行版、其他 Python 版本、CUDA/GPU 或真实仿真器均受支持。

## 安装

将 ZIP 解压到可写目录，然后运行：

```bash
bash install.sh
```

安装器先校验 `manifest.json` 中每个发行文件的大小和 SHA-256，然后在此目录创建 `.venv`，以 hash 校验方式从 `wheelhouse/` 安装本地锁定依赖，并从 PyPI 联网补齐 `hf-xet`。接收方可在安装完成后查看其实际安装版本：

```bash
.venv/bin/python -X utf8 -I -c 'import importlib.metadata as m; print("hf-xet", m.version("hf-xet"))'
```

接下来安装器会运行 `pip check` 并导入核心及已验可选模块。它不会自动运行训练或冒烟测试。重复运行可识别本安装器在同一路径创建的 `.venv`；目录中已有未标记的 `.venv` 时会停止以避免覆盖。

如 Python 3.12 或 venv/pip 不可用，安装器会提示缺少项。请由系统管理员按所在发行版的常规方式预装它们，再重试；安装器不会代为安装系统包。

## 运行

`run.sh` 可从任意当前工作目录调用；相对输入与输出路径按调用时的当前目录解释：

```bash
bash "/path with spaces/unified-marl-0.7.0-linux-x86_64-cpu-py312/run.sh" --help
bash "/path with spaces/unified-marl-0.7.0-linux-x86_64-cpu-py312/run.sh" train \
  --algorithm pymarl/qmix --env toy --output-dir ./results/qmix \
  --set batch_size=2 --set buffer_size=8 --set t_max=32
```

若从解压目录运行，也可使用 `bash ./run.sh ...`。Python API 可由该目录的 `.venv/bin/python` 调用，完整示例见 `examples/README.md`。

## 可选 CPU 冒烟测试

接收方可自愿运行短 QMIX CPU 测试，覆盖一次更新、推理动作掩码、评估、保存和恢复。它只验证 CPU toy 链路，不证明真实环境表现、策略效果或收敛：

```bash
mkdir -p results
OUT="results/smoke-$(date +%Y%m%dT%H%M%S)"
.venv/bin/python -X utf8 -I smoke_test.py --output "$OUT"
```

## 数据和外部环境

没有数据集、checkpoint、预训练权重、仿真器或地图随包分发。请将自己的数据放在独立、可写且有备份的位置，并在命令中传入明确路径；目录建议见 [`data/README.md`](data/README.md)。训练结果默认写入你显式提供的输出目录。

SMAC 需要单独准备其 Python 后端、StarCraft II、地图和配置；补货、CityFlow 也需要各自的后端与任务资产。安装本包不会获取或配置这些资源。详见 `docs/SUPPORT_MATRIX.md` 和 `docs/KNOWN_ISSUES.md`。

## 验证与来源

`manifest.json` 用于发现 ZIP 解压后的损坏或内容变化。ZIP 本身的 SHA-256 应通过可信的内部渠道单独核对。许可证、来源和未确认权利记录见 `LICENSE`、`NOTICE`、`licenses/`、`docs/LICENSES.md` 与包内来源文件；这些说明不扩张任何来源的授权范围。

核心 wheel 为 `unified_marl-0.7.0-py3-none-any.whl`，源码归档为 `unified_marl-0.7.0.tar.gz`。来源中已记录的算法限制均保留在支持矩阵和已知问题文档中。
