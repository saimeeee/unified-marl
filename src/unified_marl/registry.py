"""Validated PyMARL algorithm bundles; components cannot be mixed arbitrarily."""
ALGORITHMS = {
    "qmix": ("q_learner", "qmix", "q", "epsilon_greedy"),
    "vdn": ("q_learner", "vdn", "q", "epsilon_greedy"),
    "iql": ("q_learner", None, "q", "epsilon_greedy"),
    "coma": ("coma_learner", None, "pi_logits", "multinomial"),
    "qtran": ("qtran_learner", "qtran_base", "q", "epsilon_greedy"),
}
WANG_ROLES = {
    "rode": ("rode_learner", "qmix", "q", "soft_epsilon_greedy"),
    "rode_hmf": ("rode_hmf_learner", "vdn", "q", "soft_epsilon_greedy"),
}
HMF_ALGORITHMS = {
    "dqn", "vdn", "qmix", "mfq", "mfvfd", "hierarchical", "hierarchical_vdn",
    "hierarchical_vdn_IPC", "hierarchical_vdn_without_high_level", "maddpg",
    "hierarchical_vdn_copy_fixed", "hierarchical_vdn_meanq", "hierarchical_vdn_k_means_fixed",
    "hierarchical_vdac_fixed",
}


def algorithm_config_name(name):
    if name.startswith("wang_hmf/"):
        if name.split("/", 1)[1] not in HMF_ALGORITHMS:
            raise ValueError(f"Unsupported fixed-group HMF algorithm {name!r}")
        return name
    if name.startswith("wang/"):
        short = name.split("/", 1)[1]
        if short in WANG_ROLES:
            return "wang/" + short
        if short in ALGORITHMS or short in {"qmix_beta", "vdn_beta", "iql_beta"}:
            return "wang/" + short
        raise ValueError(f"Unsupported Wang RGHMF algorithm {short!r}")
    if name.startswith("pymarl/"):
        name = name.split("/", 1)[1]
    base = name.removesuffix("_beta")
    if base not in ALGORITHMS or (name.endswith("_beta") and base not in {"qmix", "vdn", "iql"}):
        raise ValueError(f"Unsupported algorithm {name!r}; available: {', '.join(ALGORITHMS)}")
    return name
