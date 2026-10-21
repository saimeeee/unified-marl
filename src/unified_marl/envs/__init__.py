"""Environment factories import optional simulators only when selected."""
from .multiagentenv import MultiAgentEnv


def _toy(**kwargs):
    from .toy import CoordinationEnv
    return CoordinationEnv(**kwargs)


def _sc2(**kwargs):
    from .smac import make_smac
    return make_smac(**kwargs)


def _replenishment(**kwargs):
    from .replenishment import ReplenishmentAdapter
    return ReplenishmentAdapter(**kwargs)


def _cityflow(**kwargs):
    from .cityflow import CityFlowAdapter
    return CityFlowAdapter(**kwargs)


def _inventory(**kwargs):
    from .inventory import InventoryEnv
    return InventoryEnv(**kwargs)


def _traffic_engine(**kwargs):
    from .traffic_engine import CityFlowEngineEnv
    return CityFlowEngineEnv(**kwargs)


REGISTRY = {"inventory": _inventory, "traffic_engine": _traffic_engine, "toy": _toy, "sc2": _sc2, "replenishment": _replenishment, "cityflow": _cityflow}


def make_env(name, **kwargs):
    try:
        factory = REGISTRY[name]
    except KeyError:
        raise ValueError(f"Unknown environment {name!r}") from None
    return factory(**kwargs)
