# 0.8.0 工程应用交付补充

按用户最新授权实现 warehouse / traffic / powergrid 三个应用方向，新增统一API、业务决策映射、模板和中文说明；核心版本0.8.0。原383条记录保留并新增10条，共393条。新代码仅做静态/参数/构建检查，用户自行实验，未跑任何训练、仿真或真实场景验证。与0.7.0相比，新增库存环境和原生CityFlow适配，并以独立bounded_ppo补电网连续动作；不声称迁移前后算法等价或原动态实验已完成。

实际命令：`.venv-release/Scripts/python.exe -X utf8 -B tools/check_engineering_package.py`，退出0：287个Python源码AST、8个模板、应用导入、CLI帮助及新文档链接通过；记录保留来源旧字符串\A的SyntaxWarning。没有创建环境或训练。安装包构建/归档状态以dist/internal/engineering-delivery-build.json和发布回执为准；待完成构建和GitHub发布后补充实际结果。

构建与归档已完成：Windows ZIP 306,714,441字节，Linux ZIP 281,317,969字节；wheel 581,348字节，sdist 840,189字节。`tools/build_engineering_delivery.py`、setuptools.build_meta.build_sdist、`tools/prepare_engineering_release.py` 与发布器 `--local-cache` 的9附件逐字节重建校验通过。源码目录外目标安装并导入0.8.0、导出4个仓储模板并检查参数通过；未运行平台安装脚本或训练。首次构建发现Windows platform_machine大小写标记错误，修正为CPython AMD64后成功；`python -m build`无可执行模块，改用已安装的setuptools后端构建，无需安装新工具。GitHub Release仍待远端发布确认。

用户侧入口：[工程指南](APPLICATIONS_GUIDE.md)、[实现报告](ENGINEERING_REPORT.md)、[安装说明](ENGINEERING_DISTRIBUTION.md)。电网只覆盖来源case33bw，CityFlow/电网真实资产和行业预训练模型不随包提供。

以下为0.7.0及以前的历史记录，测试通过状态不外推0.8.0新增能力。

---

# 项目进度与实际验证记录

最新发布状态：已发布 [v0.7.0-internal.1](https://github.com/saimeeee/unified-marl/releases/tag/v0.7.0-internal.1)，仓库仍为 private。9 个附件的远端大小和 SHA-256 全部核对一致；[发布任务](https://github.com/saimeeee/unified-marl/actions/runs/39558172643) 通过。发布提交 a92d0bea9a6acb44e5576ab81d43ac152b6d2c3e，文档提交 21dcb4a8014351c4a18a92b0d0e10de1be67932c。下文准备/发布中的文字保留为过程记录；机器回执在 docs/releases/v0.7.0-internal.1.verification.json。

日期：2026-10-21，用户时区 UTC+08:00。

**当前核心版本 0.7.0；阶段 7 之后按用户授权新增 Windows x64 与 Linux x86_64 的内部 CPU / CPython 3.12 安装包。Windows 本机全新环境安装及短训练验收通过；Linux 按最新要求只准备文件、不执行 Linux 功能测试。未宣称所有原实验、真实环境、跨机、GPU 或策略效果完成。可选 Web/K8s 未执行。**

## 内部分发补充交付

### GitHub 后续发布准备

用户另行授权将两版安装包及说明上传原私有仓库。中文 USER_GUIDE.md、首页入口和 `docs/releases/v0.7.0-internal.1.md` 发布说明已完成；两版 ZIP、核心 wheel/sdist、说明和验证材料共 9 个附件已核对哈希。GitHub 插件已恢复并核对 private/main，通过提交自动发布流程生成 `v0.7.0-internal.1` Release；流程及边界见 GITHUB_RELEASE.md。是否已发布以 Actions/Release 实际结果和后续回执为准，不把源码提交或发布材料准备冒充附件已上传。两份 ZIP 在本机仅重建文件后的哈希与交付原件完全一致，没有新增 Linux 运行测试。

- `dist/internal/unified-marl-0.7.0-windows-x64-cpu-py312-offline.zip`：完整离线依赖，307,140,455 字节，77 个清单文件、36 个 wheel。接收方预装 CPython 3.12 x64，在解压目录运行 install.ps1，自动创建独立 venv。Windows 11 / Python 3.12.14 / torch 2.6.0+cpu 已实际全新安装，QMIX 两次更新、动作掩码、模型加载/评估、恢复至三次更新通过；重复安装、异目录 CLI、依赖导入和损坏检测通过。
- Windows 中间过深目录曾触发 PyTorch 260 字符路径限制，失败日志保留。已补安装前清晰拒绝，最终在较短中文/空格目录通过；不修改系统长路径设置。显式 -X utf8 处理隔离启动下的编码。最终功能包验收后只更新两份跨平台说明，脚本、wheel、示例和运行文件与已验包逐字节相同，刷新证据见 INTERNAL_WINDOWS_REPORT.md。
- `dist/internal/unified-marl-0.7.0-linux-x86_64-cpu-py312.zip`：混合依赖版，281,863,343 字节，65 个清单文件、35 个 wheel。已准备 Linux 平台依赖和安装/调用脚本，目标 x86_64 / CPython 3.12 / glibc >= 2.28 / CPU。唯一本机未下载项 hf-xet 按 requirements-network.txt 在接收方从 PyPI 补齐，不能称完整离线；不在本机绕过用户对其下载的拒绝。
- Linux 遵从用户『准备好就行，不用测试』，未运行 Linux、仿真或训练测试；仅核对分发文件、目标 wheel 标签和元数据约束。安装脚本也不自动训练，接收方可手动运行 smoke_test.py。详见 INTERNAL_LINUX_REPORT.md。
- 两版使用同一个原始 0.7.0 核心 wheel；354 个运行时源码/资源与当前 src 字节一致。Python 解释器、系统运行库、真实数据、模型、原始交付和本机 venv 不打入包。原 383 行迁移清单及全部算法限制不变，没有新增“算法迁移通过”项。
- 使用说明为 INTERNAL_DISTRIBUTION.md。Windows 原始证据在 `.work/win-final/validation.json`，文件级汇总为 dist/internal/archive-verification.json、windows-verification.json 和 SHA256SUMS.txt；构建器与模板在 tools/build_*_internal_delivery.py 和 delivery。未上传本次新分发包至外部仓库。

以下第 1—7 阶段记录保留为历史，不代表本次进行了相同训练重跑。

## 第 7 阶段交付结果

- 原 379 行全部保留，增加 4 项共 383 行。301 行有本地验证且限定范围，78 行本阶段范围内仍未验收，4 行属于已约定的可选阶段 8；行数含组件和配置，不能计作算法数。逐文件来源追踪与 SHA-256 另在 MIGRATION_TRACEABILITY.csv、包内 PROVENANCE.json。
- 新接通 hierarchical_vdac_fixed 的固定组 critic 更新，旧 uint8 掩码与不存在的 target_mf_policy 明确适配；全 VDAC actor/高层调度仍未接通。补验 BC/rnn_ns、old QMIX/mlp、old QMIX/mlp_ns 三个可用 Agent 变体，有原损失对照、真实数据、保存恢复证据。四个失败 HMF 实验重新运行，具体堆栈保留。
- 评估新增显式种子、恢复调用方 RNG、切换环境时重建参数；配置错误与离线恢复时被忽略的参数改为明确拒绝。六奖励模型 `for_training=True` 下一次固定批次更新与连续更新一致，包含优化器/调度器/额外未注册层/RNG；不声称 diverse 高层课程完整恢复。
- 接入 ZMQ 独立周期快照评估，单个待执行任务、跳过忙时触发、有限超时/错误清理；不宣称复刻旧永久共享缓冲 ABI 或支持远程评估。全部 220 项测试通过，14 条来源保留警告；初始掩码对照失败原因及修复记录保留。
- 新建 `.venv-release`，基础依赖下源码目录外 12 条链路通过；真实缺少的 4 类功能依赖只让对应功能报错。随后追加可选依赖，28 条链路通过，包含 3m 真实数据更新、六奖励模型、本机 ZMQ sync/async、端口重绑和周期评估。独立 `.venv-sdist` 的源码包重建/安装与示例证据见验收报告及 sdist-validation.json。
- wheel/源码包包含配置资源、许可/来源说明；源码包另含中文文档、最小示例和验证工具，排除训练模型、大数据及缓存。PyMARL Apache 与实际发现的易开源/ZMQ MIT 已保留，其他来源总体授权仍待确认；未对外发布。
- 真实 SMAC、补货、CityFlow 的实际工厂调用均因缺后端/资产失败，没有被 toy、模拟契约或离线数据更新替代。无跨机、GPU、其他 OS/版本、长期收敛结果。没有改动全局 Python 或原始交付。

交付入口：[验收报告](VALIDATION_REPORT.md)、[支持范围](SUPPORT_MATRIX.md)、[全部未通过项](KNOWN_ISSUES.md)、[许可核查](LICENSES.md)、[中文示例](../examples/README.md)。实际命令、退出码与哈希以 `evidence/stage7` 及 `dist/SHA256SUMS.txt` 为准。

---

## 第 6 阶段历史结果

- execution 层拆分训练/协调、环境采样、参数副本推理、通信和数据边界检查，复用已验证的 SADMA 类、EpisodeBatch 与来源 ReplayBuffer/损失。没有执行旧分布式入口代替包内迁移。
- managed 模式以 Windows spawn 启动自有采样/推理子进程；独立 trainer/infer/sample CLI 角色也在同机回环通过。单一 Learner，不修改全局启动方式；不依赖 Linux shell/fork 或 Pod 环境变量。
- SADMA Q/VDN 支持 ZMQ sync/async；普通 PPO 仅 sync，async 必须显式 use_vtrace=true。其他 PyMARL、RODE/HMF、离线/偏好算法不自动接入 ZMQ。逐配置已验与仅允许的组合见 STAGE6_REPORT.md。
- 新 protocol=1 使用 JSON/数值帧，不使用网络 pickle。检查 job/schema/request/session/t、dtype/shape/有限性、动作/掩码/onehot、隐藏状态、旧概率、版本及奖励/终止时间摘要。旧 InferClient 二进制 ABI 不兼容，来源仍有审计记录。
- 参数 snapshot 包含 actor 与必要 critic，按版本和 SHA-256 摘要确认；多个推理副本同版本摘要一致。每个 worker 一个在途回合和 RPC，HWM/回放/消息/等待期限有界；单会话超时不被其他 worker 活动掩盖。
- 完整 196 项测试通过（原 149 项加 47 新项）；两组 snapshot 推理对照和一组旧行为概率 V-trace 原损失/更新对照误差为 0。异常/停滞、空连接超时、端口占用启动失败、context 权限错误、正常停止和端口重绑均通过预期检查。
- 独立 .venv-check 0.6.0 包在源码目录外完成 7 配置 sync、王版 Q async、显式 V-trace PPO async，共 9 路各 2 次有效更新、保存加载/评估、端口重绑；恢复至第 3 次更新通过。QMIX/PPO 两个 managed CLI 通过；独立三角色启动在完整测试中通过，均不算跨机。
- 6 个代表回归通过：本地 PyMARL QMIX、SADMA PPO、RODE-HMF、HMF MFQ，以及真实 3m 数据上的 BC/CPL。真实数据更新不替代仿真器或策略效果验证。
- env_steps 为已确认执行的转移，不含 reset 和纯推理；完整/接受/丢弃回合及部分确认步单列。预算停止会排空在途回合，可能超出一个批次。恢复保留 Learner/回放/计数，worker RNG、外部仿真器和异步调度不保证逐步复现。
- 正常任务没有 forced 进程；故障训练明确记录 FAILED 并退出自有进程，测试 PASS 只表示错误报告/清理符合预期。强制终止不能承诺后端 close；外部角色关闭确认与超时单列。
- 当前协调端串行处理 Learner 更新与推理 RPC，async 表示无跨 worker 回合屏障及滞后回放；全面计算重叠、动态 infer_batch_size>1、vector worker、吞吐加速、原持续 EvaluateWorker、旧 IPC SharedBuffer、多 Learner 未迁移/未验。
- 所有网络测试为 Windows 本机 127.0.0.1；pyzmq 25.1.2 / libzmq 4.3.4。默认工具沙箱禁止创建 ZMQ context，已在任务授权提升后运行本机验证；没有修改防火墙/全局环境或连接远程主机。跨机、Linux、GPU、真实仿真器及效果未通过。
- 清单 379 行，新增执行模式/跨机验证列，历史未记录项不追溯标通过；原 1228 条来源/资源与 36 条通信源码哈希不变（重叠，不相加计唯一文件数）。运行源、wheel 与独立安装文件一致；两个项目环境 pip check 通过。开发可编辑安装元数据也同步为 0.6.0。

完整证据与命令：[第 6 阶段报告](STAGE6_REPORT.md)；启动/消息/配置：[ZMQ 协议](ZMQ_PROTOCOL.md)。机器记录为 `evidence/stage6/tests.xml`、`installed_validation.json`、`summary.json`、`final_verification.json`，以及独立角色、故障与 3 组来源对照 JSON。下一步等待用户指定第 7 阶段，不自动继续。

---

## 第 5 阶段历史结果

- 比较王思哲、易才润开源/闭源/ZMQ 四份 SADMA，选王思哲实际算法类为主，保留易才润两套配置；开源/ZMQ 对比的 48 份文件逐字节相同。王/易核心训练方法 AST 一致，超参数、保存加载和环境 Runner 差异分别记录。
- 可调用 sadma/qmix、sadma/ppo、显式 sadma/vdn、sadma_yi/qmix、sadma_yi/ppo、sadma_yi_closed/qmix、sadma_yi_closed/ppo。7 个配置不是 7 个独立算法；易开源 qmix 默认实际为 VDN Mixer。MADDPG Policy 文件为空，保留阻塞。
- 接入来源 Policy/Controller/Agent/Mixer/Critic 与原 ReplayBuffer，统一 EpisodeBatch 字段及时间位置。Q 保留回放；PPO 消费当前版本的新轨迹，保留 log-prob、critic 值、hidden 和策略版本，mini_epochs 后清空，拒绝旧版本回放。
- 完整 149 项测试通过（新增 37 项，此前 112 项均通过）；13 个配置/分支源码对照在已测输入下输出、损失及更新后网络最大误差为 0。MLP、独立/中心 critic、state、vtrace/dual_clip、Q-lambda 分支均有短更新证据。
- 推理与完整 checkpoint 分开；7 个配置的已完成更新 toy 边界恢复与连续训练逐项一致，包含目标网络/ValueNorm/优化器/LR/策略版本/Q 回放。待消费 PPO 回合记录后丢弃；外部仿真器内部状态及旧 .pth 文件夹兼容未验证。
- 独立 .venv-check 安装 0.5.0 wheel，在源码目录外验证 7 配置各 2 次更新、加载/评估与恢复至第 3 次更新；QMIX/PPO 两 CLI 通过。代表回归为 PyMARL QMIX、RODE-HMF、HMF MFQ 的 toy 训练和 BC/CPL 的真实 3m 离线训练，共 5 项。
- 同进程连续两任务和异常关闭通过；独立安装连续任务中 21 个采集/评估环境全部关闭，子进程前后均为 0。单环境本地同步路径不使用 ZMQ；本机验收环境未安装 pyzmq。
- SMAC/补货共享延迟工厂；SADMA 补货从后端读 horizon，原忽略字段保留为 metadata，模拟后端 PPO 个体奖励更新通过；CityFlow 模拟后端 Q 更新/close 契约通过。实际 SMAC、ReplenishmentEnv、cityflowenv 均缺失，未通过真实训练评估。
- PowerGrid 是连续动作，明确拒绝离散化；规格已写 float-action/高斯概率/边界/推理/checkpoint 扩展方案，实现仍阻塞。检查的交付没有默认 powergrid/data，当前环境也没有 pandapower。
- 保留原 PPO 的 GAE 终止 bootstrap、熵项自归一化、递归 LR 和 padding 标准化等行为；兼容修复与算法缺陷分别说明，不把来源一致当作理论正确。GPU、收敛性、胜率和长期稳定性未验证。
- 369 行清单已更新，保留阶段 4 快照；1228 条原始来源哈希和 192 条本次 SADMA 对比记录不变（有重叠，不相加计数）。运行源/配置、wheel 和独立安装文件一致；两个项目环境 pip check 通过，无全局环境修改。

详细结论和命令：[第 5 阶段报告](STAGE5_REPORT.md)；选型依据：[版本比较](SADMA_VERSION_SELECTION.md)。机器证据：`evidence/stage5/tests.xml`、13 份 `parity-*.json`、`installed_validation.json`、`summary.json`、`final_verification.json`。此处为阶段 5 历史快照，最新进度以上方阶段 6 为准。

---

## 第 4 阶段历史结果

- 以源码注册和实际调用为准迁移 ICQ-MA、old_src 及嵌入 MAPT 奖励闭包；保留来源命名空间。普通离线 BC 和偏好 CPL 为首条真实数据闭环，没有以独立执行旧 main 替代。
- 17 个策略配置/变体完成真实 3m 数据短更新、推理保存加载及恢复训练；并非 17 种独立算法。其中 CW/OW globalRM 只验证基础 TD 方法，完整交互奖励编排仍未接通。
- 6 种奖励模型（MR、NMR、PrefTransformer、MultiPrefTransformerDivide、old_global、old_reward_global）完成真实数据更新、预测及保存加载；另验证多标签 diverse 的初始轮次，后续课程不能视为通过。
- 统一 EpisodeDataset/DataBatch/PreferenceBatch，显式前后半配对与独立 masks/lengths。团队奖励、个体预测奖励和四类标签保留原语义；字段别名转换拒绝冲突，不复制团队奖励/终止冒充个体字段。
- 训练由 training_updates 推进，env_steps/episodes 为 0；数据、更新数、调度 horizon、评估频率与输出位置可配置。奖励 CLI 和策略 CLI 均在源码目录之外调用新安装包通过。
- 112 项完整测试通过，包含此前 59 项；17 个策略与 7 个奖励/模式的来源对照通过，更新后网络/预测误差为 0、损失最大绝对误差约 5.96e-8。12 份真实轨迹文件小批读取通过，参数更新实际使用 3m；其他地图仅完成读取。
- 独立 .venv-check 安装 0.4.0 wheel，在源码目录外执行 17 配置各 2 次更新、恢复至第 3 次更新、6 模型及 diverse 初始更新；原 PyMARL QMIX toy 回归通过。真实 SMAC 评估实际调用被缺失后端阻塞，未用 toy 代替。
- NMR 首段预测复用、PrefTransformer 未注册层/优化器遗漏、diverse 后续空筛选等来源问题保留并有测试；额外保存 PrefTransformer 未注册层权重，不修改原训练目标。来源一致不等于来源数学正确。
- hacpl/maicpl/maidpo 缺 Learner；BCQ 风格 QLearner 与实际 Controller 输出不兼容；ACPL 配置不完整；old_src 的参考策略、个体终止/agent_state 及局部奖励协议缺失；联合训练、PER、完整历史采集流程和备用组件未完成。详见报告和逐行清单。
- 清单 361 行，新增合成测试、真实数据与策略效果验证列；真实环境和效果没有标为通过。1228 条来源哈希不变；两个项目环境 pip check 通过；没有改动全局 Python 或参考代码。

完整命令、实际结果和未迁移项：[第 4 阶段报告](STAGE4_REPORT.md)。机器证据：`evidence/stage4/tests.xml`、24 个 `parity-*.json`、`installed_validation.json`、`summary.json`、`final_verification.json`。此处为阶段 4 历史快照，后续进度以上方阶段 5 为准。

---

## 第 3 阶段历史结果

- 发行包 0.3.0；RODE/RODE-HMF、8 个 RGHMF 基线/配置、13 个 HMF 算法/固定分组变体可从统一 API 调用。没有用独立运行旧 main 替代迁移。
- 完整 59 项测试通过；角色 2 项和 HMF 13 项共 15 份来源对照，已验证输入下的关键输出/损失/更新后参数误差为 0。阶段 2 的 21 项测试保留并通过。
- 独立 .venv-check 安装 wheel，在源码目录外验证 24 条链路（23 新项和原 PyMARL QMIX），各完成 2 次有效参数更新及评估；CLI 和两个环境的 pip check 通过。
- roles/role_avail_actions/agent_Q/MFQ mean_actions 的时间位置、终止/截断、掩码、角色周期、均场计算、更新调度通过本地检查；完整状态恢复与连续 toy 训练逐项一致，范围为回合边界、聚类前。
- 补货适配器已实现，仅通过模拟后端契约检查。真实 SMAC 与 ReplenishmentEnv 均因缺少后端/资产明确报错，未通过真实训练评估；GPU 未验证。
- HMF 剩余 5 个实验文件分别有构造参数、mask 类型、输入维度、未赋值常量或同策略采样协议阻塞。动态 IPC/K-means、RODE 扩角色后的训练、q 角色变体仍未完成。
- 原 RODE-HMF 优化器遗漏和 IPC 广播损失等数学行为保留并列明。迁移一致不代表这些来源实现理论正确。
- 350 行清单已更新；1228 条来源源码/资源哈希不变；没有改动全局 Python 环境。验证生成的原目录 bytecode 缓存已清除，后续测试禁写缓存。

完整实现、已执行命令、结果、来源问题和具体剩余项：[第 3 阶段报告](STAGE3_REPORT.md)。机器证据：`evidence/stage3/summary.json`、`tests.xml`、`installed_validation.json`。此处为阶段 3 结束时快照，后续状态以上方阶段 4 结果为准。

---

## 第 2 阶段历史结果

- 已交付可安装包、train/evaluate/load_policy、CLI、五个原版基线、beta 配置、单环境和 spawn 并行采样、推理与完整训练 checkpoint。
- 21 项测试通过；五算法网络输出、损失与一次更新后参数对照误差均为 0。
- 独立 .venv-check 安装 wheel 后，源码目录之外调用 8 个算法/配置，各完成 2 次有效更新和评估；pip check 通过。
- 确定性 toy 的 QMIX 回合边界恢复与连续训练逐项一致。该结论不扩展为外部仿真器精确恢复。
- 当前验证栈 Python 3.12.14 / torch 2.6.0+cpu / NumPy 1.26.4 / PyYAML 6.0.2。没有改动全局/应用 Python 包。
- 原始来源 1228 条哈希复核一致；初始矩阵保存在 evidence/stage1_matrix.csv。迁移矩阵当前 345 行（含新增共享能力）。
- SMAC/SC2 未安装或配置，真实 SMAC 调用明确失败；GPU 和其他 Python 版本尚未验证。

完整命令、证据和限制：[第 2 阶段报告](STAGE2_REPORT.md)。当时按用户授权继续第 3 阶段，当前结论以上方第 3 阶段结果为准。

---

以下是第 1 阶段历史快照，其中“当前”“未创建环境”“所有条目 NOT_STARTED”等表述仅对应第 1 阶段结束时，不覆盖以上最新进度。

## 已交付

- `WORK_ORDER.md`：后续执行规则。
- `INTEGRATION_SPEC.md`：范围、接口草案、数据和模型状态约定、验收标准。
- `MIGRATION_MATRIX.csv`：340 行来源追踪；含配置、组件、数据及服务，不是 340 个独立算法。
- `PLAN.md`：阶段依赖、第一条训练链路及各阶段阻塞。
- `CODE_AUDIT.md`：入口、注册表、版本差异、依赖、数据、保存加载和服务边界。
- `evidence/`：机器可读检查证据。
- `tools/audit_sources.py`、`tools/build_migration_inventory.py`：可重复的盘点与清单构建工具；`tools/verify_stage1.py`：本阶段资料一致性复核。它们不实现算法包。

## 实际检查环境

| 项目 | 实际结果 | 证据 |
|---|---|---|
| AGENTS.md | 指定工作区祖先和子目录未发现 | host_checks.json |
| PATH Python | WindowsApps/python.exe 可定位但无法启动 | host_checks.json |
| 可用盘点解释器 | 应用附带 Python 3.12.14 | environment.json |
| NumPy / pandas | 发现发行版 2.3.5 / 3.0.1；NumPy 在组件检查中实际导入 | environment.json、component_smoke.json |
| torch | find_spec 不存在；原入口实际报缺 torch 或先缺其他依赖 | environment.json、baseline_probes.json |
| yaml / sacred / zmq | 当前解释器未发现 | environment.json |
| SMAC / PySC2 / Gym / ReplenishmentEnv | 当前解释器未发现 | environment.json |
| cityflow / cityflowenv / pandapower | 当前解释器未发现 | environment.json |
| transformers / wandb / tensorboard | 当前解释器未发现 | environment.json |
| GPU 硬件 | RTX 3070 Ti Laptop，8192 MiB，驱动 592.82 | environment.json，nvidia-smi 输出 |
| CUDA 可执行训练 | 未验证；无 torch，nvcc 不在 PATH，常见 Toolkit 目录未找到 | host_checks.json |
| SC2 | SC2PATH 未设置，常见安装位置未找到；未穷举磁盘 | host_checks.json |
| Docker / kubectl | CLI 存在；daemon、context、集群未测试 | host_checks.json |
| Go | 当前 PATH 未发现 | host_checks.json |

GPU 驱动输出的 CUDA Version 13.1 表示驱动可支持的 CUDA 版本信息，不等于已安装 Toolkit 或 PyTorch 可用 CUDA。发行包可发现也不等于 import 和功能测试通过。

未安装、卸载或升级全局/应用 Python 包；未创建训练虚拟环境；未启动服务、外部 API 或训练 worker。

## 已运行命令及结果

下列命令已实际执行；项目相对路径均以工作区为 cwd。完整原入口 argv、cwd、返回码和 traceback 保存于 baseline_probes.json。

```powershell
python --version
# 失败：WindowsApps 执行别名无法启动，系统无法访问此文件。

nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
# 成功：NVIDIA GeForce RTX 3070 Ti Laptop GPU, 592.82, 8192 MiB

& 'C:\Users\71919\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -B '.\unified-marl\tools\audit_sources.py'
# exit 0：615 个 Python 文件静态解析；1218 个源/资源文件哈希；139 个配置；220 条注册赋值。

& 'C:\Users\71919\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -B '.\unified-marl\tools\build_migration_inventory.py'
# exit 0：340 行迁移矩阵；3 个未注册 Learner 配置；18 个数据归档元数据；组件检查通过。

& 'C:\Users\71919\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -B '.\unified-marl\tools\verify_stage1.py'
# exit 0：6 个核心文档、340 行有效清单、1228 条来源哈希、JSON、文档链接与阶段状态检查通过。
```

脚本输出中文时，PowerShell 会话可临时设置 `$env:PYTHONIOENCODING='utf-8'` 与 `[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new()`；证据 JSON 文件自身均为 UTF-8。

### 原项目入口探测

所有命令都使用上述应用 Python，带 `-B` 与 PYTHONDONTWRITEBYTECODE，timeout 20 秒；因为缺 torch/sacred，均在导入阶段退出，没有进行训练。

| 来源 | 入口参数（相对于该项目根） | 返回码 | 首个实际阻塞 |
|---|---|---:|---|
| pymarl | main.py --config=qmix --env-config=sc2 with env_args.map_name=3m use_cuda=False t_max=1 | 1 | sacred |
| wang_rghmf | main.py --config=rode_hmf --env-config=sc2 with env_args.map_name=3m use_cuda=False t_max=1 | 1 | sacred |
| wang_hmf | main_replenishment.py --help | 1 | yaml |
| wang_sadma | entry.py --help | 1 | torch |
| yi_sadma_closed | entry.py --help | 1 | torch |
| yi_sadma_open | entry.py --help | 1 | torch |
| yi_sadma_zmq | entry.py --help | 1 | torch |
| kou_old | main.py --config=qmix --env-config=sc2 with use_cuda=False t_max=1 | 1 | sacred |
| kou_icq | main.py --config=offpg_smac --env-config=sc2 with use_cuda=False t_max=1 | 1 | sacred |

`--help` 探测仅检查入口是否可加载，不能算训练基线。补齐首个依赖后仍可能有其他错误；没有把当前失败解释为“仅缺这一个包”。

### 当前实际可运行的原组件链路

应用 Python → NumPy → 原始 PyMARL `components/epsilon_schedules.py` → DecayThenFlatSchedule。

线性与指数两种 schedule，分别检查 t=0、50、100、200，共 8 组值；检查范围 [0.05,1]、起点和衰减终点，均通过。结果为原组件冒烟，不代表训练基线，也不代表统一包已实现。

### 源码、版本与数据验证

- 615 个 Python 文件静态解析通过，不代表 API 兼容。
- 1218 个主体源/资源文件在原入口探测前后 SHA-256 一致，changed_files 为空；另有 10 个说明/依赖/外层工具等补充文件哈希。最终复核全部 1228 条哈希记录仍一致。
- Yi open 与 Yi ZMQ public 的 51 个盘点文件逐字节一致。
- Wang 与 Yi closed 的共同 38 个 Python 文件：1 个字节相同，37 个字节不同；其中 27 个 AST 相同。不能用 37 直接表示 37 个算法行为差异。
- 数据 18 个，3,736,627,170 字节；归档目录和字符串指令读取通过；张量内容未反序列化。真实数据 schema/损失/训练均未通过验证。

`evidence/final_validation.json` 为资料一致性复核结果，不是算法测试报告。`verify_stage1.py` 的阶段断言仅适用于第 1 阶段快照，第 2 阶段开始后需按新的实际进度更新验证方式，不能为了旧断言通过而删除实现。

## 尚未通过的验收项与具体阻塞

| 编号 | 阻塞 | 影响与后续阶段 |
|---|---|---|
| B01 | 当前无可用训练 Python 环境；PATH 别名失效，应用环境无 torch/yaml/sacred | 阶段 2 先建隔离环境，不能照装旧锁文件 |
| B02 | 当前会话未发现 SC2/SMAC，外部仿真器与数据不齐 | 真实环境验证未通过；按算法逐个接入 |
| B03 | HACPL/MAICPL/MAIDPO 有配置但缺已注册实现 | 阶段 4 追踪来源，保留阻塞，不虚构算法 |
| B04 | old_src、ICQ-MA 和同名 QMIX 存在真实接口/目标差异 | 逐项适配与固定输入对照，不按名字合并 |
| B05 | 来源硬编码路径和多级偏好标签，张量形状尚未读取 | 阶段 4 首先映射本地 3m 数据并核实语义 |
| B06 | Yi SADMA 保存加载不足；ICQ run.py 保存分支未接到 Learner | 阶段 4/5 补齐端到端 checkpoint，禁止只建目录算保存成功 |
| B07 | HMF 8 个算法文件未确认直接 main 初始化入口；SADMA MADDPG 未注册 | 阶段 3/5 核实，矩阵保留为 UNWIRED_EXPERIMENT |
| B08 | 无本机/跨机器 ZMQ 基线；外部服务与集群未启动 | 阶段 6/8 单独验证；CLI 存在不代表服务可用 |

## 下一步

等待用户发送第 2 阶段。目标是先建立项目隔离环境，打通原版 QMIX 的小型确定性环境训练→参数更新→保存→加载→评估，再增加真实 SMAC 3m 验证。当前没有一条已通过的强化学习训练链路。

迁移矩阵中所有条目保持 NOT_STARTED，实现/本地/真实环境验证列均为 NO；本阶段工具和原组件检查的成功不得传播为算法迁移完成。
