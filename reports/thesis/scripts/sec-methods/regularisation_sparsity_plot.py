import matplotlib.pyplot as plt
import numpy as np

from climate_attitudes.visualisation import configure_mpl


def main():
    results = np.load("reports/thesis/results/data/methods/regularisation_sparsity.npz")
    λ = results["λ"]
    k = results["k"]
    k_mean = k.mean(axis=1)
    k_ci = k.std(ddof=1, axis=1)

    fig, ax = plt.subplots(figsize=(4, 2), constrained_layout=True)
    ax.scatter(λ, k_mean, s=10)
    ax.errorbar(λ, y=k_mean, yerr=[k_ci, k_ci])

    ax.set_xlabel(r"$\lambda$")
    ax.set_ylabel("Non-zero parameters")

    ax.set_ylim(0, None)
    ax.set_xscale("log")
    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)

    fig.savefig(
        "reports/thesis/results/figures/methods/regularisation_sparsity.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    main()
