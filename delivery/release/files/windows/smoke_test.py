"""Short CPU install check: update, policy reload, evaluation and training resume."""
import argparse
from dataclasses import asdict
import json
import math
from pathlib import Path
import platform
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True, help='A new result directory')
    args = parser.parse_args()
    output = Path(args.output).resolve()
    output.mkdir(parents=True, exist_ok=False)
    import numpy as np
    import torch
    import unified_marl
    from unified_marl import train, evaluate, load_policy
    from unified_marl.envs import make_env
    torch.set_num_threads(1)
    if unified_marl.__version__ != '0.7.0':
        raise RuntimeError('Unexpected unified_marl version')
    if not Path(unified_marl.__file__).resolve().is_relative_to(Path(sys.prefix).resolve()):
        raise RuntimeError('Package was not imported from the installed environment')
    if torch.version.cuda is not None:
        raise RuntimeError('This delivery requires the CPU PyTorch build')
    result = train('pymarl/qmix', 'toy', seed=7, device='cpu', output_dir=output/'train',
                   overrides={'batch_size': 2, 'buffer_size': 8, 'rnn_hidden_dim': 16,
                              't_max': 40, 'max_updates': 2})
    assert result.updates == 2 and result.parameter_delta_l2 > 0
    assert math.isfinite(result.metrics['loss'])
    assert Path(result.checkpoint).is_file() and Path(result.training_checkpoint).is_file()
    policy = load_policy(result.checkpoint)
    env = make_env('toy', **policy.config['env_args'])
    try:
        env.reset()
        obs, available = env.get_obs(), np.asarray(env.get_avail_actions())
        action = np.asarray(policy.act(obs, available))
        assert available[np.arange(len(action)), action].all()
        policy.reset()
        np.testing.assert_array_equal(action, policy.act(obs, available))
    finally:
        env.close()
    evaluation = evaluate(result.checkpoint, episodes=2, seed=7)
    assert all(math.isfinite(value) for value in evaluation.returns)
    resumed = train(resume=result.training_checkpoint, output_dir=output/'resume',
                    overrides={'max_updates': 3})
    assert resumed.updates == 3 and resumed.parameter_delta_l2 > 0
    report = {'status': 'PASS', 'version': unified_marl.__version__, 'python': sys.version,
              'platform': platform.platform(), 'torch': torch.__version__,
              'package': unified_marl.__file__, 'train': asdict(result),
              'evaluation': asdict(evaluation), 'resumed': asdict(resumed),
              'scope': 'CPU toy only; no real simulator, GPU, remote network or policy quality claim'}
    (output/'report.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    print(json.dumps({'status': 'PASS', 'report': str(output/'report.json')}, ensure_ascii=True))


if __name__ == '__main__':
    main()
