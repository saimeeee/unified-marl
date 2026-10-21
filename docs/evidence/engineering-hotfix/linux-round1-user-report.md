# unified-marl 0.8.0 工程版 最小功能验证报告

测试时间：2026-10-21（UTC+8）。测试机：Grok Bot 盒子（非用户服务器）。范围：最小功能验证，CPU、单进程、seed=1；不做收敛实验，结论只针对软件能否跑通，不代表算法效果或业务收益。

## 1. 环境

| 项 | 实际值 |
|---|---|
| OS | Debian GNU/Linux 13 (trixie) 13.7，内核 6.12.94+ |
| 架构 | x86_64 |
| CPU | Intel(R) Xeon(R) Processor，8 核（1 socket，1 线程/核） |
| 内存/磁盘 | 15 GiB（无 swap）；/ 128G，可用 121G |
| 系统 Python | /usr/bin/python3 → 3.13.5（未改动） |
| 安装用 Python | uv 管理的 CPython 3.12.15（~/.local/share/uv/python/...，仅经 ~/marl-test/py312bin/python3.12 暴露给安装器） |
| .venv Python | ~/marl/.venv/bin/python 3.12.15 |
| 关键依赖 | unified-marl 0.8.0（site-packages 安装，非源码路径）、torch 2.6.0+cpu、numpy 1.26.4、PyYAML 6.0.2、gym 0.26.2、cloudpickle 3.1.1；cityflow/pandapower/pandas 未安装 |
| CUDA | torch.cuda.is_available() = False，device=cpu |

安装：Linux ZIP SHA256 abd0c5ce…cb33 校验通过；`bash linux/install.sh --Feature core` 与 `--Feature warehouse` 均 exit 0，pip check 无冲突。

## 2. 仓储补货 MFVFD

数据说明：使用 `init warehouse` 模板自带 2 个智能体、4 个周期的合成示例 CSV（仅示格式，非真实业务数据）。测试 YAML 仅改 t_max=32、max_updates=1、batch_size=2、buffer_size=32，其余与模板一致。

| 项目 | 状态 | 证据/说明 |
|---|---|---|
| 安装/依赖 | 通过 | `--Feature warehouse` exit 0，新增 gym/gym-notices/cloudpickle |
| 配置检查 | 通过 | `check` exit 0，status=configuration_checked，算法 wang_hmf/mfvfd，环境 inventory |
| 环境启动 | 通过 | 内置 inventory 后端（本版新增，非原 ReplenishmentEnv） |
| 有效参数更新及证据 | 通过 | updates=1，env_steps=4；loss=0.040593，mf_loss=0.000200；优化器钩子：2 次 Adam step，参数最大变化 5.0e-4，参数/梯度无 NaN/Inf；parameter_delta_l2=0.0695 |
| 模型保存加载 | 通过 | policy.pt 222,699 B、training.pt 617,202 B、application.json、application-result.json；新进程 load_policy 成功 |
| 推理动作合法性 | 通过 | WH1_SKU1：idx 0，0.0×10=0.0，min(0,100-20-0)=0.0；WH1_SKU2：idx 23，3.16×5=15.8，min(15.8,80-10-0)=15.8；动作空间 34 |
| 确定性 | 通过 | 同进程两次加载、3 个独立进程输出完全一致 |
| 短评估 | 通过 | `evaluate --episodes 1` exit 0，return=-0.044826；输出不含步数字段 |
| CLI act | 通过 | 与 Python API 结果完全一致 |
| 恢复训练（warehouse API / CLI） | 失败 | `ValueError: Cannot change environment arguments during resume`：training.pt 中 env_args 被核心层注入 seed=1，应用层恢复时传入的 env_args 不含 seed，严格相等检查失败（包缺陷，未修改源码） |
| policy.pt 作为恢复输入 | 通过 | 按文档被拒绝：`Resume requires training.pt, not a policy-only checkpoint` |

诊断备注（不计入通过项）：用底层核心 API `unified_marl.train(resume=training.pt, overrides={"max_updates":2})` 恢复成功，updates 1→2、env_steps 4→8，2 次 Adam step 参数有变化且无 NaN/Inf；输出不含 application*.json。

路径：结果 `results/warehouse_mfvfd_20261021_172442/`，恢复诊断 `results/warehouse_mfvfd_resume_core_20261021_172746/`；日志 `logs/step2_*.log`、`logs/step3_*.log`；脚本 `scripts/step2_warehouse_train.py`、`scripts/step3_*.py`。

## 3. 交通控制 PPO + CityFlow

| 项目 | 状态 | 证据/说明 |
|---|---|---|
| 安装/依赖 | 阻塞 | `import cityflow` → ModuleNotFoundError；PyPI 无 cityflow（pip download exit 1）；盒内无安装或 wheel；按要求未从源码编译 |
| 配置检查 | 阻塞 | `check` exit 1：`roadnetFile ... /home/box/marl-test/traffic/roadnet.json` 不存在 |
| 环境启动/参数更新/保存加载/推理/评估/恢复 | 未测试 | 前置条件缺失 |

缺失：CityFlow 原生模块（需源码构建进 .venv）、roadnet.json/flow.json、按真实路网填写的 phase_ids / yellow_phase_ids（yellow_time>0 时需要 availableRoadLinks 为空的全红相位，否则设 yellow_time=0）。日志 `logs/step4_*.log`。

## 4. 电网建筑用能 bounded_ppo + case33bw

| 项目 | 状态 | 证据/说明 |
|---|---|---|
| 数据 | 阻塞 | 盒内（~、/workspace、/tmp、~/marl 及 site-packages）未找到 weather_data.csv、solar_generation_1kW.csv、building_attributes.json、Building_<Type>.csv、buildings_state_action_space.json；包不携带，未伪造 |
| 配置检查 | 阻塞 | `check` exit 1：`FileNotFoundError: env_args.data_path: /home/box/marl-test/powergrid/assets/Climate_Zone_1` |
| 安装/依赖 | 未测试 | 按计划数据齐全后才执行 `--Feature powergrid`；pandapower/pandas 当前未安装 |
| 其余项 | 未测试 | 前置条件缺失 |

期望路径（相对 powergrid.yaml）：`assets/Climate_Zone_1/{weather_data.csv, solar_generation_1kW.csv, building_attributes.json, Building_<Building_Type>.csv}`、`assets/buildings_state_action_space.json`（建筑 ID 需与属性文件一致）。日志 `logs/step5_*.log`。

## 5. 其他说明

- 每次导入 gym 都会打印 “Gym has been unmaintained since 2022 …” 弃用警告，不影响本次运行。
- `evaluate` 输出只有 returns/return_mean/return_std，没有步数。
- 恢复训练 overrides 必须写成 `training.max_updates`；写成 `max_updates` 会报 Unknown application config keys。

## 6. 结论

1. 全链路通过：仓储 MFVFD（安装→检查→1 次有效更新→保存→加载推理→确定性→短评估→CLI act），但应用层恢复训练失败。
2. 部分通过：仓储方向整体（恢复训练失败）；交通、电网均阻塞，未进入训练。
3. 仍需：修复应用层 resume 的 env_args seed 不一致；交通需 CityFlow 构建 + 路网/流量 + 相位映射；电网需真实气候/建筑数据后再装 powergrid 依赖。
4. 一键重跑已通过项：`bash ~/marl-test/rerun_passed.sh`（已实测 exit 0，日志 logs/step6_rerun.log）。

本报告只评价软件可运行性，不涉及收敛或业务收益。
