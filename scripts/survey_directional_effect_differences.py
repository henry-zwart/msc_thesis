import matplotlib.pyplot as plt
import numpy as np
import polars as pl
from ising.model import FitMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising

np.set_printoptions(linewidth=200)

RANDOM_SEED = 202604272006


def main(indices: pl.DataFrame):
    BOOTSTRAP_REPEATS = 100

    n_participants = indices.select(pl.col("participant_id").unique()).shape[0]
    n_waves = indices.select(pl.col("wave").unique()).shape[0]
    n_cols = len(indices.columns) - 6

    print(indices.columns[6:])

    # Extract dataset into (participant, wave, question) form
    y = (
        indices.sort(by=("participant_id", "wave"))
        .drop("participant_id", "wave", *ds_spec.DEMOGRAPHIC_COLS)
        .to_numpy()
        .ravel()
        .reshape((n_participants, n_waves, n_cols))
    )

    # Binarise data.
    y[y < -0.1] = -1
    y[y > 0.1] = 1

    # Set zeros to -1 or +1 uniformly
    rng = np.random.default_rng(RANDOM_SEED)
    random_assignments = rng.choice((-1, 1), size=y.size).reshape(
        (n_participants, n_waves, n_cols)
    )
    random_assignment_idxes = (y >= -0.1) & (y <= 0.1)
    y[random_assignment_idxes] = random_assignments[random_assignment_idxes]
    y = y.astype(np.int64)

    # symmetric_ising.adj[abs(symmetric_ising.j) < 0.15] = False
    # symmetric_ising.j[abs(symmetric_ising.j) < 0.15] = 0.0
    # asymmetric_ising.adj[abs(asymmetric_ising.j) < 0.15] = False
    # asymmetric_ising.j[abs(asymmetric_ising.j) < 0.15] = 0.0

    asymmetric_bootstraps = Ising.bootstrap(
        r=BOOTSTRAP_REPEATS,
        y=y,
        method=FitMethod.TIME_SERIES,
        rng=RANDOM_SEED,
        self_loops=True,
    )

    # Estimate difference in directional effects
    j_diffs = np.array(
        [
            np.triu(_model.j) - np.triu(_model.j.T)
            for *_, _model in asymmetric_bootstraps
        ]
    )
    mean_diff = j_diffs.mean(axis=0)
    ci = 1.97 * np.std(j_diffs, axis=0) / np.sqrt(BOOTSTRAP_REPEATS)

    fig, ax = plt.subplots(figsize=(5, 6), constrained_layout=True)

    # Scatter means
    n = y.shape[-1]
    mean_diffs_flat = mean_diff[np.triu_indices_from(mean_diff, k=1)]
    ci_flat = ci[np.triu_indices_from(ci, k=1)]
    ax.scatter(
        mean_diffs_flat,
        np.arange(n * (n - 1) // 2),
        color="k",
        s=14,
        zorder=5,
        label="Mean effect difference",
    )

    # Show ci interval as red shaded region
    marker, _, bar = ax.errorbar(
        mean_diffs_flat,
        np.arange(n * (n - 1) // 2),
        xerr=np.array([ci_flat, ci_flat]),
        ls="none",
        zorder=3,
        color="tab:red",
        label="95% CI",
    )
    plt.setp(bar[0], capstyle="round")
    marker.set_fillstyle("none")
    bar[0].set_alpha(0.5)
    bar[0].set_linewidth(5)

    # Draw 0.0 as dashed
    ax.axvline(x=0, linestyle="dashed", linewidth=0.75, color="gray", zorder=1)

    ylabels = []
    colnames = [ds_spec.RENAME.get(colname, colname) for colname in indices.columns[6:]]
    for i in range(n - 1):
        for j in range(i + 1, n):
            c1 = colnames[i]
            c2 = colnames[j]
            ylabels.append(f"{c1} -> {c2}")

    ax.set_yticks(np.arange(len(ylabels)), ylabels)

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

    fig.savefig("directional_effect_diffs.pdf", bbox_inches="tight")
    plt.show()


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    indices = (
        dataset.indices.collect()  # ty: ignore
    )
    main(indices)  # ty: ignore
