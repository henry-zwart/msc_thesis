from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
from matplotlib.axes import Axes

from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)


def plot_diffs(
    J_cons: npt.NDArray[np.float64],
    J_lib: npt.NDArray[np.float64],
    labels: npt.NDArray[np.str_],
    ax: Axes,
):
    N = 7
    J_cons[np.abs(J_cons) < 1e-2] = 0
    J_lib[np.abs(J_lib) < 1e-2] = 0
    diffs = (J_lib - J_cons).reshape((-1, N, N))
    median = np.median(diffs, axis=0)

    # positive_idxes = np.where(
    #     (
    #         median > 0
    #         # | np.eye(N, dtype=np.bool)
    #         # | (np.triu(np.ones((N, N), dtype=np.bool)) & (median == 0))
    #     )
    # )
    lo, hi = np.percentile(diffs, (5, 95), axis=0)

    median_flat = median.flatten()
    sort_idxes = np.argsort(median_flat)[::-1]
    median_flat = median_flat[sort_idxes]
    lo_flat = lo.flatten()[sort_idxes]
    hi_flat = hi.flatten()[sort_idxes]
    ax.scatter(
        median_flat,
        np.arange(N**2),
        color="k",
        s=10,
        zorder=5,
        label="Median difference",
    )
    marker, _, bar = ax.errorbar(
        median_flat,
        np.arange(N**2),
        xerr=np.array([median_flat - lo_flat, hi_flat - median_flat]),
        ls="none",
        zorder=3,
        ecolor="tab:blue",
        label="90% CI",
    )
    plt.setp(bar[0], capstyle="round")
    marker.set_fillstyle("none")
    bar[0].set_linewidth(5)
    bar[0].set_alpha(0.5)
    ax.axvline(x=0, linestyle="dashed", linewidth=0.75, color="gray", zorder=1)

    colnames = [ds_spec.RENAME.get(colname, colname) for colname in labels]
    max_label_len = 0
    for i in range(N):
        max_label_len = max(max_label_len, len(colnames[i]))
    max_left_len = max_right_len = max_label_len

    ylabels = [[] for _ in range(N)]
    for i in range(N):
        for j in range(N):
            c1 = colnames[i]
            c2 = colnames[j]
            ylabels[i].append(f"{c1:>{max_left_len}} → {c2:<{max_right_len}}")

    ylabels = np.asarray(ylabels).flatten()[sort_idxes]

    ax.set_yticks(
        np.arange(len(ylabels)), ylabels, fontfamily="Libertinus Mono", fontsize=8
    )

    ax.set_ylim(-0.5, len(ylabels) - 0.5)
    for i in range(len(ylabels)):
        ax.axhline(y=i, linewidth=0.1, color="k", linestyle="solid")

    ax.set_xlabel(
        r"Edge difference ($\boldsymbol{J}_\text{Liberal} - "
        r"\boldsymbol{J}_\text{Conservative}$)"
    )
    ax.spines.top.set_visible(False)
    ax.spines.right.set_visible(False)

    ax.legend(
        ncol=2,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.0),
        # fontsize=8,
        # handlelength=1,
        # columnspacing=0.5,
        # labelspacing=0.2,
        frameon=False,
    )


if __name__ == "__main__":
    configure_mpl()
    fig, ax = plt.subplots(figsize=(5.77, 6), constrained_layout=True)
    DATA_PATH = Path("reports/thesis/results/data/model")
    con_data = np.load(DATA_PATH / "ideology_bootstrapped_fit/conservative.npz")
    lib_data = np.load(DATA_PATH / "ideology_bootstrapped_fit/liberal.npz")
    labels = np.delete(ds_spec.schema.post_index().get_short_names("measurement"), 5)
    plot_diffs(con_data["params"][:, 7:], lib_data["params"][:, 7:], labels, ax)
    # fig.supylabel(r"Edge $\{i,j\}$")
    # axes[0].set_title("Conservative")
    # axes[1].set_title("Liberal")
    # axes[1].legend()
    #     loc="lower center",
    #     bbox_to_anchor=(0.75, 1.1),
    #     ncols=1,
    #     frameon=True,
    # )
    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/model_fit/ideology_edge_diffs.{ext}",
            bbox_inches="tight",
        )
