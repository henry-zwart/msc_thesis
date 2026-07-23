from __future__ import annotations

import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import seaborn as sns
from ising.model import FitMethod, UpdateMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising

RANDOM_SEED = 202607181707


def binarisation_entropy(p: npt.NDArray[np.float64]) -> npt.NDArray[np.float64]:
    return -(p * np.log2(p) + (1 - p) * np.log2(1 - p))


def activation_prob_given_binary_prev(
    prev: npt.NDArray[np.int64], model: Ising
) -> npt.NDArray[np.float64]:
    X = np.ones(prev.shape[0])
    heff = model.parallel_glauber_theta_batch(prev, X, model.h, model.j, model.adj)
    p = np.exp(heff - np.log(2 * np.cosh(heff)))
    return p


def activation_prob_given_prev_binarisation_p(
    prev_p: npt.NDArray[np.float64], model: Ising
) -> npt.NDArray[np.float64]:
    # Create array where rows are all possible model configurations
    N = model.size
    S = (2 * ((np.arange(1 << N)[:, None] >> np.arange(N)) & 1) - 1).astype(np.float64)

    # Calculate probability that binarisation yields each configuration
    bin_p = np.empty((prev_p.shape[0], 2**N), dtype=np.float64)
    for m in range(prev_p.shape[0]):
        bin_p[m] = np.exp(
            np.log((1 - S) / 2 * (1 - prev_p[m]) + (1 + S) / 2 * prev_p[m]).sum(axis=-1)
        )

    # Calculate activation probability of next state given each initial binarisation
    conditional_next_activation_prob = activation_prob_given_binary_prev(S, model)

    # For each individual, calculate total activation probability of next state
    next_activation_prob = np.exp(
        np.log(bin_p)[..., None] + np.log(conditional_next_activation_prob)
    ).sum(axis=1)
    return next_activation_prob


def expected_excess_sampling_surprise(
    bin_p: npt.NDArray[np.float64],
    model: Ising,
) -> npt.NDArray[np.float64]:
    if bin_p.shape[1] != 2:
        raise ValueError(f"Expected bin_p with two data points, found {bin_p.shape[1]}")
    prev_bin_p, next_bin_p = np.swapaxes(bin_p, 0, 1)

    conditional_activation_prob = activation_prob_given_prev_binarisation_p(
        prev_bin_p,
        model,
    )

    # Calculate expected surprise when expecting model samples but observing data
    cross_entropy = -(1 - next_bin_p) * np.log2(
        1 - conditional_activation_prob
    ) - next_bin_p * np.log2(conditional_activation_prob)

    # Calculate the expected _excess_ surprise by subtracting binarisation entropy
    next_obs_entropy = binarisation_entropy(next_bin_p)
    expected_excess_surprise = cross_entropy - next_obs_entropy
    return expected_excess_surprise


def main(P: npt.NDArray[np.float64], λ: float):
    M = P.shape[0]
    K = 10
    eval_idx_sets = np.array_split(rng.choice(np.arange(M), size=M, replace=False), K)

    kl_diffs_eval = []

    for k in range(K):
        mask_eval = np.ones(M, dtype=bool)
        mask_eval[eval_idx_sets[k]] = False
        P_train = P[mask_eval]
        P_eval = P[eval_idx_sets[k]]

        cv_model = Ising.fit(
            y=P_train,
            optim_method=FitMethod.TIME_SERIES,
            update_method=UpdateMethod.SYNCHRONOUS,
            rng=rng.spawn(1)[0],
            adj=None,
            self_loops=True,
            w=λ,
        )
        cv_model_null = Ising.fit(
            y=P_train,
            optim_method=FitMethod.TIME_SERIES,
            update_method=UpdateMethod.SYNCHRONOUS,
            rng=rng.spawn(1)[0],
            adj=np.eye(8, dtype=np.bool),
            self_loops=True,
            w=λ,
        )
        kl_diffs_eval.append(
            expected_excess_sampling_surprise(P_eval, cv_model).mean(axis=-1)
            - expected_excess_sampling_surprise(P_eval, cv_model_null).mean(axis=-1)
        )

    # Plot distribution of differences and ECDF
    fig, axes = plt.subplots(
        ncols=2, figsize=(5, 1.5), constrained_layout=True, sharex=True
    )

    for i, res in enumerate(kl_diffs_eval):
        sns.kdeplot(
            res,
            ax=axes[0],
            clip=(None, None),
            color="tab:orange",
            linewidth=0.5,
            label="Holdout" if i == 0 else None,
        )

    for i, res in enumerate(kl_diffs_eval):
        sns.ecdfplot(
            res,
            ax=axes[1],
            color="tab:orange",
            linewidth=0.5,
            label="Holdout" if i == 0 else None,
            clip_on=False,
        )

    # ax.set_xlim(0, None)
    for ax in axes:
        ax.spines.top.set_visible(False)
        ax.spines.right.set_visible(False)

    axes[0].set_title("PDF")
    axes[1].set_title("ECDF")

    fig.supxlabel("Relative entropy difference (fully-connected $-$ null)")

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/kl_difference_dist.{ext}",
            bbox_inches="tight",
        )


if __name__ == "__main__":
    configure_mpl()
    rng = np.random.default_rng(RANDOM_SEED)

    config = Config(_env_file=".env")
    dataset = Dataset.load(
        config,
        name="reduced_no_imputation",
        with_imputation=False,
        verbose=False,
    )

    sigma_path = Path("reports/thesis/results/data/methods/binarisation_sigma.json")
    lambda_path = Path(
        "reports/thesis/results/data/model_fit/optimised_regularisation.json"
    )

    with sigma_path.open("r") as f:
        sigma = json.load(f)["sigma"]

    with lambda_path.open("r") as f:
        reg_results = json.load(f)
        λ = reg_results["ising"]["full"]

    _, _, P, *_ = dataset.indices_to_numpy(
        kind="time-series",
        binarise=True,
        scale=sigma,
        seed=rng,
        binarisation_dist="gaussian",
    )
    main(P, λ)
