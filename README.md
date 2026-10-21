# unified-marl

以 PyMARL 架构整合三份 MARL 交付的 Python 包。当前交付版本 **0.7.0**：原版 PyMARL 基线、王思哲角色与均场算法、寇谦离线/偏好策略和奖励模型，以及 SADMA 本地/ZMQ 训练。调用名称包含配置和实现变体，不代表独立算法数。真实数据更新与真实环境效果分别记录。

使用前查阅 [中文示例](examples/README.md)、[支持清单](docs/SUPPORT_MATRIX.md)、[验收报告](docs/VALIDATION_REPORT.md) 和 [已知问题](docs/KNOWN_ISSUES.md)。全部 383 项迁移记录保留，包含未通过项；阶段结束不代表全部原实验、环境或平台服务已经迁移。

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

## 王思哲算法

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

## 寇谦离线与偏好学习

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
