from __future__ import annotations

import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import scipy as sp
from ising.model import FitMethod, UpdateMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising

RANDOM_SEED = 202607181646


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


def main(P: npt.NDArray[np.float64], λ: float):
    M = P.shape[0]
    K = 10
    eval_idx_sets = np.array_split(rng.choice(np.arange(M), size=M, replace=False), K)
    buckets = np.linspace(-1, 1, 11)
    # buckets = np.array([-1, -0.5, 0, 0.5, 1])

    prob_bins_eval = np.zeros((M, 8), dtype=np.float64)
    bin_edges = sp.stats.norm.cdf(buckets / sigma)
    bin_centres = bin_edges[:-1] + np.diff(bin_edges) / 2
    n_bins = bin_edges.size - 1

    p_activation_all = np.zeros((M, 8), dtype=np.float64)

    # Fit models, record mean probability per bin
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

        p_activation = activation_prob_given_prev_binarisation_p(P_eval[:, 0], cv_model)
        prob_bins_eval[eval_idx_sets[k]] = np.argmax(
            (p_activation[:, :, None] < bin_edges[1:]), axis=-1
        )
        p_activation_all[eval_idx_sets[k]] = p_activation

    mean_binarisation_prob = np.full((8, n_bins), fill_value=np.nan)
    for spin in range(8):
        for _bin in range(n_bins):
            in_bin_eval = prob_bins_eval[:, spin] == _bin
            if in_bin_eval.sum() > 0:
                mean_binarisation_prob[spin, _bin] = P[in_bin_eval, 1, spin].mean()

    fig, axes = plt.subplots(
        ncols=4,
        nrows=2,
        figsize=(5.77, 3.25),
        constrained_layout=True,
        sharex=True,
        sharey=True,
    )
    labels = schema.post_index().get_short_names("measurement")

    for i, ax in enumerate(axes.flatten()):
        ax.plot(
            bin_centres, mean_binarisation_prob[i], "o-", markersize=3, linewidth=0.75
        )
        ax.plot([0, 1], [0, 1], linestyle="dashed", linewidth=0.35, color="k")

        ax.set_aspect("equal")
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)

        ax.spines.top.set_visible(False)
        ax.spines.right.set_visible(False)
        ax.set_title(labels[i], fontsize=9)
        ax.set_xticks([0, 0.5, 1])
        ax.set_yticks([0, 0.5, 1])

    fig.supxlabel(
        r"Transition probability: $P(S_i^{t+1} = +1 \mid \boldsymbol{S}^{t})$"
    )
    fig.supylabel(r"Mean Bin. probability: $P(S_i^{t+1} = +1)$", y=0.55)

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/transition_reliability.{ext}",
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
