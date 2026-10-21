# unified-marl

[中文使用说明书](docs/USER_GUIDE.md) · [下载安装包（Releases）](https://github.com/saimeeee/unified-marl/releases/tag/v0.7.0-internal.1) · [支持范围](docs/SUPPORT_MATRIX.md) · [已知问题](docs/KNOWN_ISSUES.md)

**给同事安装使用，请从 Releases 下载对应 Windows 或 Linux ZIP，按包内 README 安装。** GitHub 自动生成的源码 ZIP 不包含平台依赖。接收方需要预先安装 CPython 3.12；Windows 版依赖完整离线，Linux 版安装时联网补齐 hf-xet。两版均为 CPU 版本，Python 解释器、真实数据和仿真器另行提供。

以 PyMARL 架构整合三份 MARL 交付的 Python 包。当前交付版本 **0.7.0**：原版 PyMARL 基线、RODE／RODE-HMF 与均场算法、离线／偏好策略和奖励模型，以及 SADMA 本地／ZMQ 训练。调用名称包含配置和实现变体，不代表独立算法数。真实数据更新与真实环境效果分别记录。

使用前查阅 [中文示例](examples/README.md)、[支持清单](docs/SUPPORT_MATRIX.md)、[验收报告](docs/VALIDATION_REPORT.md) 和 [已知问题](docs/KNOWN_ISSUES.md)。全部 383 项迁移记录保留，包含未通过项；阶段结束不代表全部原实验、环境或平台服务已经迁移。

内部发给同事安装使用，优先使用 `dist/internal` 中按系统区分的 CPU / CPython 3.12 ZIP：Windows 完整离线，Linux 在接收方安装时联网补齐 hf-xet。接收方先准备对应 Python，再解压运行安装脚本；无须原始交付目录或 GitHub。Python 解释器、真实数据和仿真器不随包提供。详见 [内部安装说明](docs/INTERNAL_DISTRIBUTION.md) 及每版 ZIP 内 README；Linux 按用户要求只准备文件，未运行 Linux 功能测试。

## 算法介绍与支持状态

以下使用算法原名，括号内姓名表示**本项目收到的交付来源，不表示算法的原创作者**。同一算法可能有多个来源实现，分别保留调用名；调用名中的 `wang/`、`kou/` 等是已有 API 命名空间。此处按 28 个算法／方法家族介绍，配置、历史变体和内嵌代码不等于都已完成迁移。

“本地可用”表示记录范围内已完成有效参数更新、保存加载等验证；在线算法主要使用确定性 toy 环境，离线／偏好算法另有真实 3m 数据短更新。真实 SMAC、补货与 CityFlow 训练效果尚未验证。详见 [支持范围](docs/SUPPORT_MATRIX.md) 和 [未完成项](docs/KNOWN_ISSUES.md)。

### DQN（王思哲）

作用：学习离散动作的价值，选择预期回报较高的动作，可作为补货等离散决策任务的基础对照。

状态：本地可用，调用 `wang_hmf/dqn`；实际补货环境尚未验证。

### IQL — Independent Q-Learning（王思哲；另含原版 PyMARL）

作用：每个智能体分别学习自己的动作价值，用于建立不使用团队价值混合网络的协作基线。

状态：本地可用，调用 `pymarl/iql`；交付配置另见 `wang/iql`。与下文离线 Implicit Q-Learning 区分。

### VDN（王思哲、易才润；另含原版 PyMARL）

作用：将各智能体的价值相加得到团队价值，用团队奖励训练分散执行的协作策略。

状态：本地可用，代表调用为 `pymarl/vdn`、`wang_hmf/vdn`、`sadma/vdn`。易才润开源 SADMA 的 `sadma_yi/qmix` 配置实际使用 VDN Mixer。

### QMIX（王思哲、易才润、寇谦；另含原版 PyMARL）

作用：通过混合网络把个体价值组合成团队价值，兼顾集中训练与各智能体独立选动作。

状态：`pymarl/qmix`、`wang_hmf/qmix`、SADMA Q 实现及历史离线 `kou_old/qmix` 已有本地证据。同名实现不互相替代；ICQ-MA 目录中另一套行为约束 Q 实现缺少匹配 Controller，尚不可用。

### QTRAN（王思哲；另含原版 PyMARL）

作用：通过联合价值与个体价值之间的约束，学习团队协作与分散动作选择之间的关系。

状态：本地可用，调用 `pymarl/qtran`；交付配置另见 `wang/qtran`。

### COMA（王思哲；另含原版 PyMARL）

作用：比较某个智能体当前动作与其他可选动作的团队价值，估计其贡献，缓解团队奖励难以分配的问题。

状态：本地可用，调用 `pymarl/coma`；使用新采集轨迹，不能按普通离策略回放使用。

### QPLEX（寇谦）

作用：通过更丰富的团队优势价值分解表达智能体协作关系，可作为 QMIX 类方法的对照。

状态：离线调用 `kou_old/qplex` 可用；`kou_old/qplex_w_globalRM` 可读取已训练的团队奖励模型。

### Weighted QMIX — CW-QMIX／OW-QMIX（寇谦）

作用：在 QMIX 类价值拟合中对样本加权，减少不合适的联合动作估计对训练的影响。

状态：`kou_old/cw_qmix`、`kou_old/ow_qmix` 离线更新可用；同名 globalRM 变体仅基础 TD 更新通过，完整在线奖励交互未接通。

### PPO（王思哲、易才润）

作用：利用新采集轨迹训练策略，通过限制策略变化幅度控制更新，用作策略梯度基线。

状态：`sadma/ppo`、`sadma_yi/ppo`、`sadma_yi_closed/ppo` 本地同步可用；ZMQ 同步通过，异步必须显式启用 V-trace。当前接入的是离散动作路径。

### MADDPG（王思哲）

作用：通过集中式价值评估指导各智能体策略更新，用于研究多智能体之间相互影响的决策。

状态：`wang_hmf/maddpg` 的来源离散动作路径本地可用；SADMA 中同名 Policy 文件为空，未迁移为可用算法，也未据此声明通用连续动作支持。

### MFQ（王思哲）

作用：用其他智能体的平均行为概括交互信息，降低大量智能体两两建模的复杂度。

状态：`wang_hmf/mfq` 本地可用；HMF 来源动作选择器没有通用可用动作掩码处理。

### MFVFD（王思哲）

作用：结合均场信息与价值分解，学习大规模智能体之间的团队协作。

状态：`wang_hmf/mfvfd` 本地可用；真实补货任务与长期效果未验证。

### Hierarchical／HMF 系列（王思哲）

作用：将智能体组织为层级或分组，通过组内及组间信息进行协作，面向大规模补货等任务。

状态：部分完成。`wang_hmf/hierarchical`、`hierarchical_vdn` 等默认路径及若干固定分组变体可用；动态分组、高层调度和完整 VDAC actor 流程未接通。Hierarchical-QMIX、独立 IPC、ROMA 等实验仍有来源错误，不能把固定组验证当作整个系列完成。

### MFAC（王思哲）

作用：将均场交互信息用于 Actor-Critic 策略学习，探索大规模多智能体策略优化。

状态：不可用。来源存在缺失 critic／optimizer 接口、参数及训练代码错误，尚无有效统一训练链路。

### RODE（王思哲）

作用：先选择角色，再依据角色对应的动作空间决策，让不同智能体形成分工。

状态：部分完成，调用 `wang/rode`；聚类前训练与保存恢复通过，动态扩角色后的完整训练和恢复尚未通过。

### RODE-HMF（王思哲）

作用：将角色分工与分层均场信息结合，用于具有分组交互的大规模协作。

状态：部分完成，调用 `wang/rode_hmf`；聚类前路径可运行，动态扩角色及后续完整流程仍未验收，来源优化器等问题保留记录。

### BC — Behavior Cloning（寇谦）

作用：直接模仿已有数据中的动作，建立无需在线探索的离线策略基线。

状态：`kou/bc` 可用，已有真实 3m 数据短更新；另验证了 `rnn_ns` Agent 变体。

### ICQ-MA（寇谦）

作用：从固定的多智能体轨迹中学习协作策略，约束离线策略学习中的数据外动作估计。

状态：`kou/icq_ma` 可用，已有真实数据短更新；不据此声明全部来源离线训练扩展已接通。

### CQL（寇谦）

作用：使用保守价值目标抑制离线数据之外动作的过高估计，降低离线策略利用错误价值的风险。

状态：`kou/cql` 基础离线路径可用；moderate-CQL、PER 及 e2e 等扩展未验收。

### IQL — Implicit Q-Learning（寇谦）

作用：从固定数据学习价值及策略，减少离线学习对数据之外动作评估的依赖。

状态：`kou/iql` 可用，已有真实数据短更新；与 Independent Q-Learning 是不同算法。

### CPL（寇谦）

作用：根据两段轨迹谁更好的偏好标签，直接优化策略的动作概率。

状态：`kou/cpl` 可用；读取显式偏好对、有效长度和掩码，按训练更新次数推进。

### DPPO（寇谦）

作用：此交付实现使用轨迹对的偏好标签及动作概率构建目标，直接训练符合偏好的策略。

状态：`kou/dppo` 可用；不能将其名称解释为此处的 ZMQ 分布式 PPO。

### MADPO／MADPO-AUX（寇谦）

作用：利用多智能体轨迹偏好及个体奖励信息分配学习权重；AUX 是附加辅助训练的变体。

状态：`kou/madpo`、`kou/madpo_aux` 可用，但必须提供真实 `agent_reward`，不能复制团队奖励来代替。

### BCMAPT（寇谦）

作用：将行为模仿与个体奖励加权结合，在已有轨迹上训练偏向较好行为的策略。

状态：`kou/bcmapt` 可用，同样需要真实个体奖励字段。

### Pref-QMIX（寇谦）

作用：将轨迹偏好约束加入 QMIX 类价值学习，使学习结果反映轨迹之间的优劣关系。

状态：不可用。两份历史版本缺少实际参考策略、个体终止或 agent_state／局部奖励协议，未完成统一训练接入。

### HAPPO（寇谦交付内嵌 MAPT 库）

作用：通过依次更新各智能体的策略协调团队学习，适合研究不同智能体具有不同策略的协作任务。

状态：尚未迁移；源码存在于内嵌库，不属于当前可调用支持项。

### HATRPO（寇谦交付内嵌 MAPT 库）

作用：结合智能体顺序更新与信赖域约束，控制协作策略每轮变化的幅度。

状态：尚未迁移；不能因为内嵌源码存在就视为可用。

### MAT 系列（寇谦交付内嵌 MAPT 库）

作用：使用 Transformer 表达智能体之间的依赖与联合决策关系。

状态：策略训练尚未迁移。当前只接入该库实际使用的奖励模型及其必要依赖。

## 奖励模型介绍与支持状态

奖励模型用于把轨迹或偏好转换成奖励评分，与上述策略算法分别统计。下列六个分支均有真实 3m 数据短更新、预测及保存加载证据；这不等于奖励质量或最终策略效果已验证。

### MR（寇谦）

作用：根据轨迹偏好训练奖励网络，为后续离线策略提供评分信号。

状态：训练、预测及完整训练状态加载已验证；调用 `train_reward_model("MR", ...)`。

### NMR（寇谦）

作用：使用另一种奖励网络结构拟合轨迹偏好，作为奖励建模对照。

状态：可调用 `"NMR"`。原损失复用第一段轨迹预测的问题保留；部分相同掩码输入可能导致梯度抵消，不能视为该问题已修复。

### PrefTransformer（寇谦）

作用：使用 Transformer 建模轨迹时间关系，从偏好标签学习奖励评分。

状态：可调用 `"PrefTransformer"`。来源存在未注册网络层未进入优化器、推理仍有 dropout 的问题；保存补全权重，不等于修正了原训练语义。

### MultiPrefTransformerDivide（寇谦）

作用：结合团队、跨轨迹个体及轨迹内排序标签，学习分解到智能体的奖励。

状态：基础训练、预测与加载可用，调用 `"MultiPrefTransformerDivide"`；diverse 课程只验证初始阶段，后续可能筛出空样本池，完整课程及恢复未通过。

### old_global（寇谦）

作用：使用历史全局奖励模型从偏好中学习团队奖励，可供离线策略消费。

状态：调用 `"old_global"`，全局奖励训练、预测及恢复更新通过；个体／局部奖励方法未迁移。

### old_reward_global（寇谦）

作用：提供另一条历史全局奖励建模分支，保留其自身的奖励训练与预测语义。

状态：调用 `"old_reward_global"`，全局模式已验证；参考策略标签生成及个体／局部流程未完成。

## 安装

在项目隔离 Python 环境中安装。CPU PyTorch 可按其[官方历史版本说明](https://pytorch.org/get-started/previous-versions/)安装，例如本项目验证使用 torch 2.6.0 CPU。

```powershell
python -m pip install torch==2.6.0 --index-url https://download.pytorch.org/whl/cpu
python -m pip install .
```

开发安装使用 `pip install -e .`；发行包位于 dist。当前验证环境为 Windows / Python 3.12.14 / torch 2.6.0+cpu / NumPy 1.26.4 / PyYAML 6.0.2。其他版本未声称通过。

直接安装交付包：

```powershell
python -m venv .venv
.venv/Scripts/python.exe -m pip install ./dist/unified_marl-0.7.0-py3-none-any.whl
# 按需要选择功能，避免修改全局环境：
.venv/Scripts/python.exe -m pip install "./dist/unified_marl-0.7.0-py3-none-any.whl[role,hmf,reward,distributed]"
```

包的 Python/依赖元数据是安装约束，不代表已验兼容范围；已验版本以验收报告为准。wheel 不含数据、checkpoint、缓存和外部仿真器。源码包另含中文文档、示例与验证工具；原始源码对照测试需要用户保留的参考目录，正常包调用不需要它们。

角色算法额外安装 `pip install ".[role]"`；HMF 额外安装 `pip install ".[hmf]"`。两类依赖按选择的算法加载。HMF 当前明确只支持 CPU。

奖励模型额外安装 `pip install ".[reward]"`，使用交付中的 transformers 4.53.0 和 ml-collections 1.1.0。仅创建本地配置与网络，不下载预训练权重。普通离线策略训练无需奖励模型依赖。

## 最小训练与评估

```python
from unified_marl import train, evaluate, load_policy

result = train(
    algorithm="pymarl/qmix", env="toy", output_dir="./results/my-first-run",
    overrides={"batch_size": 2, "buffer_size": 8, "t_max": 32},
)
print(result.updates, result.metrics, result.checkpoint)
print(evaluate(result.checkpoint, episodes=2))
policy = load_policy(result.checkpoint)
# 每个回合先 policy.reset()；随后 policy.act(obs, avail_actions)。
```

toy 是确定性测试环境，验证参数更新和接口，不代表 SMAC 或实际场景效果。已有运行输出目录会被拒绝，避免覆盖模型。

```powershell
unified-marl train --algorithm pymarl/qmix --env toy --output-dir ./results/qmix `
  --set batch_size=2 --set buffer_size=8 --set t_max=32
unified-marl evaluate ./results/qmix/policy.pt --episodes 2
```

COMA 使用新鲜 rollout，不使用离策略回放；batch_size 必须等于 batch_size_run。默认 COMA 使用 8 个并行环境，短验证可同时设 batch_size=2、batch_size_run=2、buffer_size=8。在 Windows 脚本中调用 parallel runner 时，入口放在 `if __name__ == '__main__':` 内。

## 配置和输出

配置优先级为：公共默认 < 算法 YAML < 环境 YAML < 用户配置 < overrides < 显式 Python 调用参数（如 env_args、seed、device）。嵌套 overrides 支持 env_args.episode_limit；CLI --set 的值使用 YAML 标量语法。算法组件组合会校验。

每次训练写出 config.json、metrics.jsonl、result.json、policy.pt、training.pt。TrainResult 返回这些路径、更新数、环境步数和 agent 参数变化量。

- policy.pt：推理所需配置、维度和完整 Controller 状态，包含角色网络、动作编码器和角色动作空间。
- training.pt：额外包含在线/目标网络、Mixer/Critic/Attention、优化器、更新计数、回放内容、全局 RNG 和选择器调度状态。

```python
continued = train(resume=result.training_checkpoint, output_dir="./results/continued", overrides={"t_max": 64})
```

恢复发生在回合边界。确定性 toy 的 QMIX 恢复已与连续训练逐项对照；外部仿真器内部状态不在该格式中，不能据此承诺真实仿真逐步精确恢复。policy.pt 不能作为继续训练状态加载。

## RODE、RODE-HMF 与 HMF 调用

`wang/rode_hmf` 和 `wang/rode` 使用统一 EpisodeBatch、Runner、Controller、Learner 和 checkpoint。`wang/qmix` 等保留交付配置；与原版逐文件相同的基线网络复用核心实现。HMF 来源的 QMIX 使用 `wang_hmf/qmix`，与这两类分别注册。

```python
result = train("wang/rode_hmf", "toy", output_dir="./results/rode-hmf",
    overrides={"runner": "episode", "batch_size_run": 1, "batch_size": 2,
               "buffer_size": 8, "role_interval": 2, "t_max": 16, "max_updates": 2})
print(evaluate(result.checkpoint, episodes=2))
```

HMF 可调用名：`wang_hmf/` 加 `dqn`、`vdn`、`qmix`、`mfq`、`mfvfd`、`hierarchical`、`hierarchical_vdn`、`hierarchical_vdn_IPC`、`hierarchical_vdn_without_high_level`、`maddpg`、`hierarchical_vdn_copy_fixed`、`hierarchical_vdn_meanq`、`hierarchical_vdn_k_means_fixed`。末三项来自缺少主入口分支的实验文件，已验证默认固定分组更新；`*_fixed` 不包含动态聚类调度。

```python
result = train("wang_hmf/mfq", "toy", env_args={"n_agents": 4, "mask_actions": False},
    output_dir="./results/mfq", overrides={"batch_size": 4, "buffer_size": 32,
        "hidden_dim": 16, "n_heads": 2, "embed_dim": 8, "t_max": 16, "max_updates": 2,
        "hmf_norm_rewards": False, "hmf_steps_per_update": 1, "hmf_num_batch": 1})
```

该短验证显式关闭奖励标准化并缩短更新间隔。HMF 默认保留入口的每 84 环境步更新、每次 2 个 minibatch 和探索率衰减。原 HMF 动作选择器没有可用动作掩码；遇到非法动作会明确失败，不能通过此接口承诺任意掩码环境支持。

HMF 默认按来源将时间上限算作 done；如需在截断处继续 bootstrap，显式设置 `hmf_bootstrap_time_limits=True`。PyMARL/RODE 保留各自原有的 timeout bootstrap 规则。

补货环境使用 `env="replenishment"`。需要外部 `ReplenishmentEnv`、真实任务配置和数据；`env_args.task_type` 指定任务，`update_config` 递归传入后端配置，`backend_args` 原样传给后端工厂，可提供其实际支持的外部路径参数。适配器保留 34 档补货动作、默认 21 天 horizon、团队奖励缩放 1e4、观测补齐。尚未完成真实补货训练，种子是否被后端消费也未验证。

RODE 的 SC2 专用动作聚类及动态扩角色之后的完整训练尚未通过；RODE-HMF 的均场网络优化器遗漏、IPC 损失广播等来源问题按原样保留。详细限制和 5 个未接通实验的具体原因见 [第 3 阶段报告](docs/STAGE3_REPORT.md)。

## SMAC

SMAC 按需导入。需要独立安装 SMAC、PySC2、StarCraft II 和地图，并配置 SC2PATH。基础包和 toy 不依赖它们。

```powershell
unified-marl train --algorithm pymarl/qmix --env sc2 --output-dir ./results/sc2 `
  --set env_args.map_name=3m --set batch_size=2 --set t_max=100
```

当前机器尚未完成真实 SMAC 短训练；安装或启动失败会明确报错，不会回退成 toy。

## 离线与偏好学习调用

普通离线训练：`kou/bc`、`kou/icq_ma`、`kou/iql`、`kou/cql`。偏好训练：`kou/cpl`、`kou/dppo`、`kou/madpo`、`kou/madpo_aux`、`kou/bcmapt`。后 3 项需要真实个体奖励 `agent_reward`，不能用团队奖励复制得到。

```python
from unified_marl import train, train_reward_model, load_reward_model

data = "D:/marl-data/3m.th"  # 替换为用户自己的数据路径；发行包不包含数据。
run = train("kou/bc", dataset=data, output_dir="./results/offline-bc",
    overrides={"training_updates": 2, "off_batch_size": 4,
               "dataset_options.max_length": 12})
pref = train("kou/cpl", dataset=data, output_dir="./results/offline-cpl",
    overrides={"training_updates": 2, "off_batch_size": 4,
               "dataset_options.max_length": 12})
print(run.updates, run.env_steps)  # 2, 0：不创建环境或伪造在线步数。
```

```powershell
unified-marl train --algorithm kou/cpl --dataset "G:/path/to/data.th" `
  --output-dir ./results/cpl --set training_updates=2 --set off_batch_size=4
```

数据通过 `EpisodeDataset` 加载，action/actions、avail_action/avail_actions 等别名转换后检查冲突、动作、掩码和奖励形状。提供的文件采用前后半段配对，`labels=1` 表示偏好后一段；支持显式 pair_indices。global_labels、between_labels 和 in_labels 单独保存，不能混用；标签侧文件仅在 dataset_options.labels_path 显式给出时加载。另已验证 `kou/bc` 的 `agent=rnn_ns`、`kou_old/qmix` 的 `agent=mlp` 和 `agent=mlp_ns` 配置变体，需显式设置 `hidden_dim`；不据此承诺任意 Agent/Learner 组合可用。

`off_batch_size` 沿用源入口的“两段轨迹总数”，偏好对数为其一半。原生 Learner 的时间参数使用更新索引；训练预算为 training_updates，调度周期为 schedule_updates，评估频率为 eval_interval_updates。默认不评估；周期环境评估必须显式提供 env/env_args，数据训练本身不创建仿真器。

old_src 中的 `kou_old/qmix`、`qplex`、`cw_qmix`、`ow_qmix` 已支持记录轨迹更新。`qmix_w_globalRM` 和 `qplex_w_globalRM` 可通过 reward_model_checkpoint 读取已训练的团队奖励，写入独立 reward_hat；CW/OW 的 globalRM 文件目前只验证了基础 TD 方法，完整在线奖励采集/无监督阶段尚未接入。

## 奖励模型

```python
reward = train_reward_model("MR", data, updates=2, batch_size=4,
    output_dir="./results/reward-mr", dataset_options={"max_length": 12})
model = load_reward_model(reward.checkpoint)
# model.predict(EpisodeDataset(...).batch([0, 1]))
```

支持 MR、NMR、PrefTransformer、MultiPrefTransformerDivide，以及 old_global、old_reward_global 两种历史全局奖励模型。MultiPrefTransformerDivide 可用 `mode="diverse"` 消费全局、跨轨迹个体和轨迹内排序标签，并执行原 KL 信任筛选。`batch_size` 在奖励训练中表示偏好对数。

`predict(..., mode="source_offline")` 保留源离线预测后处理：MR/NMR/PrefTransformer 输出团队标量（源代码在个体维取均值），MultiPrefTransformerDivide 输出个体奖励，历史全局模型输出团队奖励。`mode="native"` 明确请求网络的个体输出。不会为对齐形状自动求和或复制奖励。现有 3m 个体奖励文件只有 60 个时间位置，需要显式限制训练窗口，不能补造第 61 格奖励。

源 NMR 有复用第一段预测的问题；PrefTransformer 的 GPT2 blocks 未注册到原优化器且推理仍含随机 dropout。迁移保留这些训练行为，额外保存遗漏的层权重；相同随机状态下可核对加载预测。多标签信任筛选后续轮次可能选不到样本，会明确停止。详细通过项和未迁移项见 [第 4 阶段报告](docs/STAGE4_REPORT.md)。

```powershell
unified-marl train-reward --model MR --dataset "G:/path/to/data.th" `
  --updates 2 --batch-size 4 --output-dir ./results/reward-mr
```

## SADMA 本地同步训练

`sadma/qmix` 与 `sadma/ppo` 以王思哲交付的真实训练实现为主；`sadma/vdn` 为显式 VDN Mixer 变体。`sadma_yi/qmix`、`sadma_yi/ppo` 保留易才润开源配置，`sadma_yi_closed/qmix`、`sadma_yi_closed/ppo` 保留闭源配置。易才润开源的 qmix 配置实际使用 VDN Mixer，不能因调用名就认定网络相同。开源/ZMQ 两份比对文件逐字节相同，不重复计为算法。

```python
from unified_marl import train, evaluate, load_policy

for name in ["sadma/qmix", "sadma/ppo"]:
    result = train(name, "toy", output_dir="./results/" + name.replace("/", "-"),
        overrides={"train_batch_size": 2, "train_buffer_size": 8, "update_rate": 1,
                   "hidden_dim": 16, "t_max": 40, "max_updates": 2})
    print(result.metrics, evaluate(result.checkpoint, episodes=2))
    policy = load_policy(result.checkpoint)
    policy.reset()  # 每个新回合调用。
```

```powershell
unified-marl train --algorithm sadma/ppo --env toy --output-dir ./results/sadma-cli `
  --set train_batch_size=2 --set train_buffer_size=8 --set update_rate=1 `
  --set t_max=40 --set max_updates=2
```

Q 学习使用来源 episodic ReplayBuffer；PPO 收集当前策略的新回合、保存旧动作 log-prob/原始 critic 值，完成 mini_epochs 后消费并清空，不回放旧策略轨迹。t_max 是实际采样预算，max_steps 是原学习率衰减 horizon，两者分开；实际环境步数不包含 reset。完整训练状态保留优化器、目标网络/ValueNorm、计数器和 Q 回放；已完成更新的回合边界恢复在 toy 逐项对照通过，尚未消费的 PPO 回合会记录数量并丢弃，外部仿真器状态不保存。

本阶段运行器每个采集器一个环境，本地同步运行，不创建 ZMQ 连接。支持离散动作；连续动作 powergrid 明确阻塞，所需浮点动作 schema 扩展写入规格，未强行离散化。SMAC/补货仍是可选外部后端；CityFlow 延迟加载其 cityflowenv/引擎与地图。真实环境均未验证。PPO 原 GAE 对终止 bootstrap 的处理、熵项自归一化和递归学习率衰减等行为保留，不能将来源一致解释为算法正确或已收敛。详情见 [第 5 阶段报告](docs/STAGE5_REPORT.md)。

## SADMA ZMQ 执行

可选依赖安装 `pip install ".[distributed]"`，使用来源指定的 pyzmq 25.1.2。基础包和本地训练按需加载，不要求安装 ZMQ。

```powershell
unified-marl train --algorithm sadma/qmix --env toy --execution zmq `
  --config examples/zmq_managed.yaml --output-dir ./results/zmq-qmix
```

Windows Python 脚本必须将调用放在 `if __name__ == "__main__":` 保护内；完整脚本见 examples/stage6_zmq.py。采样、推理为独立 spawn 进程，默认只监听回环地址，退出时有界关闭并回收。设备、seed、worker 数、endpoint、超时和高水位均在 zmq 配置中明确。

QMix/VDN 支持 ZMQ sync/async；普通 PPO 支持 sync。PPO async 必须显式设置 `--set zmq.mode=async --set use_vtrace=true`，保留来源旧概率、版本和 V-trace 回放语义。其他来源的算法尚未接到 ZMQ，不按同名算法自动启用。

独立角色启动示例（同机三个终端，依次启动推理、训练、采样）：

```powershell
unified-marl zmq-infer --endpoint tcp://127.0.0.1:18401 --idle-timeout 60
```

```powershell
unified-marl train --algorithm sadma/qmix --env toy --execution zmq `
  --config examples/zmq_roles.yaml --output-dir ./results/zmq-roles
```

```powershell
unified-marl zmq-sample --trainer-endpoint tcp://127.0.0.1:18400 `
  --worker-id 0 --job-id local-demo --timeout-ms 30000
```

只在指定端口空闲时使用固定端口示例；managed 默认自动分配。三个角色需相同版本/协议、job_id 和兼容环境；修改地址并不代表已经跨机器验证。本机多进程及独立角色回环路径已验证，没有远程主机、真实环境或 GPU 验证。默认 Codex 沙箱禁止创建 ZMQ context，本次本机测试通过授权提升执行；普通终端仍受本机网络策略约束。

输出新增 execution-started.json、execution-events.jsonl 和 execution.json，记录已确认样本数、策略版本/参数摘要、正常停止或失败、进程关闭和强制终止情况。正常结束会排空在途回合，采样预算可能超出一个在途批次；恢复保留 Learner/回放，但不承诺重新启动 worker 后逐步完全相同。详见 [第 6 阶段报告](docs/STAGE6_REPORT.md) 与 [协议和执行约定](docs/ZMQ_PROTOCOL.md)。

## 来源和后续阶段

原版 PyMARL 的 Apache-2.0 与易才润 SADMA 开源/ZMQ 版的 MIT 许可文件已保留；王思哲、寇谦及易才润闭源配置的授权仍待确认，不能把同名或相似代码自动置于另一份许可证下。详见 [许可与来源](docs/LICENSES.md)、NOTICE 和包内 PROVENANCE.json。本轮在第 7 阶段完成交付验收后停止，Web/K8s 是未执行的可选第 8 阶段。

## 0.7.0 收尾补充

- `wang_hmf/hierarchical_vdac_fixed` 接通来源固定组 critic 更新；只转换旧 uint8 掩码，并跳过来源中不存在的 mf_policy 目标更新。没有新增策略网络，也没有接通原高层/VDAC actor 调度。
- `evaluate(..., seed=7)` 及 CLI `--seed` 支持指定种子，评估后恢复调用方的 Python/NumPy/PyTorch RNG。切换环境时先加载目标环境参数，再覆盖 env_args，并核对 checkpoint 维度。
- `load_reward_model(path, for_training=True)` 要求 reward-training.pt，恢复优化器、调度器、计数、额外未注册层与 RNG；六种模型的固定偏好批次下一次更新与连续更新一致。高层 diverse 信任池/课程恢复仍未实现。
- ZMQ 设置 `evaluation_interval_updates=1` 可启用独立快照评估，`evaluation_episodes=2`、`evaluation_timeout_s=45` 可配置。一次最多一个评估任务，忙时跳过并记录；评估故障/超时明确失败并清理。它不复刻旧永久 EvaluateWorker/共享缓冲 ABI。
- 嵌套覆盖键冲突、非法 seed/线程数以及离线恢复时被忽略的替代 config/algorithm 现会明确拒绝。

- [执行约定](WORK_ORDER.md)
- [当前状态](docs/STATUS.md)
- [整合规格](docs/INTEGRATION_SPEC.md)
- [源码盘点](docs/CODE_AUDIT.md)
- [迁移矩阵](docs/MIGRATION_MATRIX.csv)
- [阶段计划](docs/PLAN.md)
