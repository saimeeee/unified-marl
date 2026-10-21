import argparse
from dataclasses import asdict
import json
import sys
import yaml


def main(argv=None):
    parser = argparse.ArgumentParser(prog="unified-marl")
    sub = parser.add_subparsers(dest="command", required=True)
    training = sub.add_parser("train")
    training.add_argument("--algorithm")
    training.add_argument("--env")
    training.add_argument("--config")
    training.add_argument("--output-dir")
    training.add_argument("--device", default="cpu")
    training.add_argument("--seed", type=int)
    training.add_argument("--resume")
    training.add_argument("--dataset")
    training.add_argument("--execution",choices=["local","zmq"],default="local")
    training.add_argument("--set", action="append", default=[], metavar="KEY=VALUE")
    evaluation = sub.add_parser("evaluate")
    evaluation.add_argument("checkpoint")
    evaluation.add_argument("--episodes", type=int, default=20)
    evaluation.add_argument("--device", default="cpu")
    evaluation.add_argument("--env")
    evaluation.add_argument("--env-args", help="YAML mapping of environment arguments")
    evaluation.add_argument("--seed", type=int)
    reward=sub.add_parser("train-reward")
    reward.add_argument("--model",required=True)
    reward.add_argument("--dataset",required=True)
    reward.add_argument("--updates",type=int,default=100)
    reward.add_argument("--batch-size",type=int,default=32)
    reward.add_argument("--output-dir")
    reward.add_argument("--device",default="cpu")
    reward.add_argument("--seed",type=int,default=1)
    reward.add_argument("--mode",choices=["preference","diverse"],default="preference")
    reward.add_argument("--config",help="YAML containing model_config and dataset_options mappings")
    inference=sub.add_parser("zmq-infer")
    inference.add_argument("--endpoint",required=True)
    inference.add_argument("--device",default="cpu")
    inference.add_argument("--idle-timeout",type=float,default=45)
    sampling=sub.add_parser("zmq-sample")
    sampling.add_argument("--trainer-endpoint",required=True)
    sampling.add_argument("--worker-id",type=int,required=True)
    sampling.add_argument("--job-id",required=True)
    sampling.add_argument("--timeout-ms",type=int,default=10000)
    args = parser.parse_args(argv)
    try:
        if args.command == "train":
            from .api import train
            overrides = {}
            for value in args.set:
                if "=" not in value:
                    raise ValueError("--set must be KEY=VALUE")
                key, value = value.split("=", 1)
                overrides[key] = yaml.safe_load(value)
            result = train(args.algorithm, args.env, device=args.device, seed=args.seed, output_dir=args.output_dir,
                           config=args.config, overrides=overrides, resume=args.resume, dataset=args.dataset,execution=args.execution)
        elif args.command=="zmq-infer":
            from .execution.inference import inference_worker
            inference_worker(args.endpoint,dict(inference_device=args.device,startup_timeout_s=args.idle_timeout,allow_remote=True))
            print(json.dumps(dict(role="inference",status="stopped")))
            return 0
        elif args.command=="zmq-sample":
            from .execution.sampler import sampler_worker
            sampler_worker(args.trainer_endpoint,args.worker_id,dict(job_id=args.job_id,timeout_ms=args.timeout_ms,allow_remote=True))
            print(json.dumps(dict(role="sampler",status="stopped")))
            return 0
        elif args.command == "train-reward":
            from .rewards import train_reward_model
            from .config import read_yaml
            settings=read_yaml(args.config) if args.config else {}
            result=train_reward_model(args.model,args.dataset,updates=args.updates,batch_size=args.batch_size,
                output_dir=args.output_dir,device=args.device,seed=args.seed,mode=args.mode,**settings)
        else:
            from .api import evaluate
            result = evaluate(args.checkpoint, episodes=args.episodes, device=args.device,
                              env=args.env, env_args=yaml.safe_load(args.env_args) if args.env_args else None, seed=args.seed)
        print(json.dumps(asdict(result), ensure_ascii=False, indent=2, allow_nan=False))
        return 0
    except (ValueError, RuntimeError, ImportError, OSError) as exc:
        print(f"unified-marl: {exc}", file=sys.stderr)
        return 1
    except Exception as exc:
        print(f"unified-marl: {type(exc).__name__}: {exc}",file=sys.stderr)
        return 1
