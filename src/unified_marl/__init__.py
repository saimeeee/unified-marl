"""Public API. Importing this package creates no environments or processes."""
__version__ = "0.8.2"


def train(*args, **kwargs):
    from .api import train as implementation
    return implementation(*args, **kwargs)


def evaluate(*args, **kwargs):
    from .api import evaluate as implementation
    return implementation(*args, **kwargs)


def load_policy(*args, **kwargs):
    from .api import load_policy as implementation
    return implementation(*args, **kwargs)

def train_reward_model(*args, **kwargs):
    from .rewards import train_reward_model as implementation
    return implementation(*args, **kwargs)

def load_reward_model(*args, **kwargs):
    from .rewards import load_reward_model as implementation
    return implementation(*args, **kwargs)


__all__ = ["train", "evaluate", "load_policy", "train_reward_model", "load_reward_model"]
