# unified-marl 0.8.0 工程分发报告

本报告对应已准备的 Windows/Linux 工程安装包、通用 wheel 与 sdist。安装包内的 `manifest.json` 已逐文件核对 SHA-256 和字节数；发布准备器只处理既有构建产物，不下载依赖、不安装环境、不运行应用或训练。

## 核心发布物

| 文件 | 字节数 | SHA-256 |
|---|---:|---|
| `unified-marl-0.8.0-windows-x64-cpu-py312-engineering.zip` | 306714441 | `9019dc89968306b22d8ffba8cf8c71f9c52abceebb7f3373f05b5422d56b211b` |
| `unified-marl-0.8.0-linux-x86_64-cpu-py312-engineering.zip` | 281317969 | `abd0c5ce38baec98e87e04e71dfd565e4c017c315463c231c926b6f56d97cb33` |
| `unified_marl-0.8.0-py3-none-any.whl` | 581348 | `c9a978fbbd6972705b9c03903af2cc6c915c4b6ef1c8f8e25263e07c5e085b67` |
| `unified_marl-0.8.0.tar.gz` | 840189 | `18db6229567dd7b69a364e76c6470ce3da6620826464af04e3332748fd3b1b4f` |

## 工程模板与功能依赖

`engineering-templates-and-guides.zip` 汇集应用模板、指南及随包功能需求文件；其 SHA-256 为 `ee7c4070376d110a8881d9c8d5d4aaad6e99d0f01be886fbe1b80e079c4a9a71`，大小为 31440 字节。

基础安装只使用包内核心依赖。仓储 MFVFD 需要 HMF；RODE-HMF 还需要 role 组件。交通仿真依赖单独构建/安装 CityFlow；电网仿真依赖 pandapower 等功能包并需联网安装。奖励模型的 Linux `hf-xet` 补充项只在用户选择 reward 功能时由目标环境联网安装。

安装与运行命令见包内 `docs/ENGINEERING_DISTRIBUTION.md` 和各应用指南。所有安装脚本均不自动启动训练。
