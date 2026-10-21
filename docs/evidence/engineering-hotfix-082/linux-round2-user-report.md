# unified-marl 0.8.1 第二轮最小功能测试报告

> 结论只评价软件链路是否可运行，不宣称收敛、收益、性能或真实业务效果。状态只用：通过 / 失败 / 阻塞 / 未测试。未上传任何模型、数据或凭据。

## 1. 执行机器（与第一轮为同一台 Grok Bot 盒子，不是用户服务器）
| 项 | 值 |
|---|---|
| hostname | grok-bot-vm-494846265 |
| 系统 | Debian 13 trixie，内核 6.12.94+，x86_64 |
| Python | CPython 3.12.15（uv），项目 venv `/home/box/marl/.venv`（未改系统 Python） |
| torch | 2.6.0+cpu |
| unified-marl | 0.8.1，`/home/box/marl/.venv/lib/python3.12/site-packages/unified_marl` |
| 时间 | 2026-10-21 19:38–19:47（UTC+8） |

固定版本：CityFlow `81ee0f47659ca66177a71f81676691c58ee89184`；pybind11 子模块换为上游 v2.11.1（`8a099e44`，仅为适配 Py3.12，未改 CityFlow 源码/构建文件）；setuptools 80.10.2（构建时由 84.2.0 降级）；CityLearn 数据 v1.0.0 `b451f05cd27bf9d65f45708e3a54daa953056818`（MIT）；pandapower 2.14.10、gym 0.26.2、scipy 1.13.1、pandas 2.3.3、scikit-learn 1.9.1。

## 2. 补丁安装 — 通过
- 补丁 ZIP SHA256 `d239d1e3ce199392167c837b7c22d61ecafca94d71e907e35731c51b91743a9d` 与 .sha256 一致。
- 命令：`~/marl/.venv/bin/python ~/marl-hotfix-081/install_patch.py --bundle ~/marl` → 退出码 0；`__version__ == '0.8.1'`；`pip check` 通过。
- 日志：`logs/round2-install.log`。其中一条 `ModuleNotFoundError: hmf` 堆栈为测试者导入不存在模块的操作错误，与补丁无关。
- manifest 中 `linux_hotfix_runtime_test` 为 false（补丁作者未在 Linux 实跑）。
- 注意：`linux/install.sh --Feature powergrid` 会把核心降回 0.8.0（本轮实测 `after_installer 0.8.0`），已立即重新应用补丁并确认 0.8.1 与 pip check（`logs/round2-powergrid-install.log`）。

## 3. 仓储
命令：
```bash
set -o pipefail
RUN="$HOME/marl-test/round2-warehouse-20261021-193830"
timeout --kill-after=15s 300s "$HOME/marl/.venv/bin/python" -X utf8 -u "$HOME/marl-hotfix-081/round2_warehouse.py" --work-dir "$RUN" 2>&1 | tee "$HOME/marl-test/logs/round2-warehouse.log"
# PIPESTATUS = 0 / 0
```
| 项 | 状态 | 证据 |
|---|---|---|
| 首轮训练 | 通过 | updates=1，env_steps=4，parameter_delta_l2=0.06952，loss=0.040593 |
| Python API 恢复 | 通过 | updates=2，env_steps=8，delta=0.048635，loss=0.045143 |
| CLI 恢复 | 通过 | 与 API 完全一致；“Cannot change environment arguments” 出现 0 次 |
| 产物 | 通过 | 每个结果目录含 application.json、policy.pt、training.pt |
| 评估步数 | 通过 | episode_lengths=[4]，env_steps=4，return −0.052475 |
| 推理 | 通过 | SKU1 动作0/补货0；SKU2 动作23/补货15.8；合法，重载一致 |
| 非法恢复拒绝 | 通过 | policy-only、改 backlog、改 seed 均 ValueError |

旧 0.8.0 模型兼容（加 `--previous-run` 第一轮目录，work-dir `round2-previous-20261021-193847`，日志 `logs/round2-previous.log`，退出码 0）— **通过**：经公开 `warehouse.train` 恢复，updates 1→2，env_steps 4→8，delta 0.048635，生成新 application.json；旧文件 SHA 未变。

## 4. 交通（PPO + CityFlow）— 场景为 CityFlow 官方单路口示例
准备：`prep/traffic_install_cityflow.sh`（日志 `logs/round2-traffic-install.log`，第一次失败尝试 `round2-traffic-install-attempt1.log`）→ `prep/traffic_fetch_example.sh`（`logs/round2-traffic-fetch.log`）→ `prep/run_traffic_min.sh`。
- phase_ids 来自真实路网 lightphases：`intersection_1_1: [0,2,4,6]`（30 s、有通行链路的相位）；路网无空链路相位，不猜全红，`yellow_time=0`，相位直接切换。
- 配置由 `unified-marl-app init traffic` 生成后修改：PPO，CPU，thread_num=1，seed=1，episode_limit=8，max_updates=1，t_max=64，train_batch_size=2，train_buffer_size=4，update_rate=1；300 s 超时，全新输出目录。

| 项 | 状态 | 证据 |
|---|---|---|
| 依赖 | 通过 | venv 中 `cityflow.Engine` 可用 |
| 配置检查 | 通过 | `unified-marl-app check` 退出 0 |
| 真实环境启动 | 通过 | 官方路网，1 线程 |
| 更新 | 通过 | updates=1，env_steps=16，loss 0.2171（有限），4 次 Adam step，最大参数变化 5.03e-4 |
| 推理 | 通过 | 引擎真实车道计数 → 动作1/相位2；重载一致，CLI act 一致（退出 0） |
| 评估 | 通过 | Python 与 CLI（退出 0）：episode_lengths=[8]，env_steps=8，return −260 |

运行：`round2-traffic-20261021-194620/`，日志 `logs/round2-traffic-20261021-194620.log`，驱动退出码 0。0.8.0 上的早先运行 `round2-traffic-20261021-193844` 已被取代。

## 5. 电网（bounded_ppo + case33bw）— 公开 CityLearn v1 Climate_Zone_1 替代数据
仓库文档只给出 SADMA 源码来源，未给出原实验数据位置，因此使用公开数据。准备：`prep/powergrid_fetch_convert.py`（`logs/round2-powergrid-fetch.log`，来源及每个文件 SHA 见 `prep/assets/powergrid/PROVENANCE.json`）→ 安装依赖并重打补丁 → `prep/check_assets.sh`（`logs/round2-check-assets.log`）→ `prep/run_powergrid_min.sh`。

数据/配置调整（未新增或修改任何物理数值）：
1. `building_attributes.json` 中非法 JSON 数字 `0.` 规范为 `0.0`（值不变）。
2. `pv_curtail`、`pv_phi` 动作标志设为 false（CityLearn v1 无此控制，包要求五个标志显式存在）。
3. 关闭打包环境无法生成的状态（t_out_pred_12h/24h、rh_out*、diffuse*、direct 预测、carbon_intensity 等）。
4. 关闭 `net_electricity_consumption` 状态（见缺陷 F1）。
5. `building_ids` 限定为 1,2,5,6,7,8,9；**建筑 3、4 缺 dhw_storage，动作顺序不一致，已排除。**

配置：CPU，seed=1，单环境，updates=1，horizon=4，episodes_per_update=1，mini_epochs=1，episode_limit=4；300 s 超时。

| 项 | 状态 | 证据 |
|---|---|---|
| 依赖 | 通过 | install.sh --Feature powergrid 退出 0；重打补丁后 0.8.1，pip check 通过 |
| 配置检查 | 通过 | `check` 退出 0 |
| 真实环境启动 | 通过 | 真实 pandapower 潮流，无潮流异常 |
| 更新 | 通过 | updates=1，critic_loss 5.5e-4，actor_loss 1.7e-7（有限），1 次优化步，最大参数变化 3.0e-4 |
| 推理 | 通过 | 真实观测 [192,1716] → 动作 [192,3]（cooling_storage, dhw_storage, electrical_storage），有限、在 [−1,1] 内、重复一致 |
| 评估 | 通过 | Python 与 CLI（退出 0）完成 1 回合，return −0.0519，episode_lengths=[3] |

运行：`round2-powergrid-20261021-194233/`，日志 `logs/round2-powergrid-20261021-194233.log`，驱动退出码 0，约 206 s。之前失败尝试保留：`194108`（缺 pv 动作标志）、`194126`（不支持的状态）、`194156`（F1）。

## 6. 发现
- **F1 — 失败（包缺陷，未修补）**：启用 `net_electricity_consumption` 时，`energy_models.set_state_space` 中 `self.pv_installed * self.weather.data["solar_gen"]` 是 Python list×int（列表重复），对有光伏的建筑报 `(35040,)` vs `(876000,)` 广播 ValueError。日志 `logs/round2-powergrid-20261021-194156.log`。
- **F2 — 未测试（待作者确认，未判定通过或失败）**：episode_limit=4 时训练只采集 3 个环境步，评估长度 [3]。
- N1：`install.sh --Feature powergrid` 会降回核心 0.8.0，之后必须重新应用 0.8.1 补丁。
- N2：CityFlow 构建将 venv 中 setuptools 由 84.2.0 降到 80.10.2。

## 7. 与第一轮比较（第一轮为同一盒子上的早先报告 `TEST_REPORT.md`，非本轮复现）
| 项 | 第一轮 | 第二轮 |
|---|---|---|
| 仓储 Python API 恢复 | 失败 | 通过 |
| 仓储 CLI 恢复 | 失败 | 通过 |
| 旧 0.8.0 模型兼容 | 未测试 | 通过 |
| 评估步数 | 未报告 | 通过，[4]/4 |
| 非法恢复拒绝 | 通过（仅 policy.pt） | 通过（policy-only / backlog / seed） |
| 交通 | 阻塞 | 通过（官方示例） |
| 电网 | 阻塞 | 通过（公开 CityLearn 替代数据，含上述调整；F1 失败、F2 未测试待作者确认） |

## 8. 脚本
`prep/`：traffic_install_cityflow.sh、traffic_fetch_example.sh、run_traffic_min.sh、traffic_min_driver.py、powergrid_fetch_convert.py、run_powergrid_min.sh、powergrid_min_driver.py、check_assets.sh、README.md。
