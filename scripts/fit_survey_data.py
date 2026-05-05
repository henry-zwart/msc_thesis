import matplotlib.pyplot as plt
import numpy as np
import polars as pl
from ising.model import FitMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising, SymmetricIsing

np.set_printoptions(linewidth=200)

RANDOM_SEED = 202604272006


def main(indices: pl.DataFrame):
    n_participants = indices.select(pl.col("participant_id").unique()).shape[0]
    n_waves = indices.select(pl.col("wave").unique()).shape[0]
    n_cols = len(indices.columns) - 6

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

    node_labels = [
        ds_spec.RENAME.get(colname, colname) for colname in indices.columns[6:]
    ]

    print(node_labels)

    symmetric_ising = SymmetricIsing.fit(
        y,
        method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        self_loops=True,
    )
    asymmetric_ising = Ising.fit(
        y,
        method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        self_loops=True,
    )

    symmetric_ising.adj[abs(symmetric_ising.j) < 0.15] = False
    symmetric_ising.j[abs(symmetric_ising.j) < 0.15] = 0.0
    asymmetric_ising.adj[abs(asymmetric_ising.j) < 0.15] = False
    asymmetric_ising.j[abs(asymmetric_ising.j) < 0.15] = 0.0

    # print("Symmetric")
    # symmetric_bootstraps = SymmetricIsing.bootstrap(
    #     X, method=FitMethod.TIME_SERIES, r=100
    # )
    # print(symmetric_ising.h)
    # print(np.std(np.array([m.h for _, m in symmetric_bootstraps]), ddof=1, axis=0))
    #
    # print(symmetric_ising.j)
    # print(np.std(np.array([m.j for _, m in symmetric_bootstraps]), ddof=1, axis=0))
    #
    # print("Asymmetric")
    # asymmetric_bootstraps = Ising.bootstrap(X, method=FitMethod.TIME_SERIES, r=100)
    # print(asymmetric_ising.h)
    # print(np.std(np.array([m.h for _, m in asymmetric_bootstraps]), ddof=1, axis=0))
    #
    # print(asymmetric_ising.j)
    # print(np.std(np.array([m.j for _, m in asymmetric_bootstraps]), ddof=1, axis=0))

    # Calculate difference in

    # fig, axes = plt.subplots(ncols=2, figsize=(15, 4), constrained_layout=True)
    fig, ax = plt.subplots(figsize=(7, 4), constrained_layout=True)
    asymmetric_ising.draw(ax=ax, use_layout_from=symmetric_ising)
    ax.set_title("Asymmetric Ising")
    fig.savefig("survey_fit_asymm.pdf", bbox_inches="tight")
    fig, ax = plt.subplots(figsize=(7, 4), constrained_layout=True)
    symmetric_ising.draw(ax=ax)
    ax.set_title("Symmetric Ising")
    fig.savefig("survey_fit_symm.pdf", bbox_inches="tight")


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    indices = (
        dataset.indices.collect()  # ty: ignore
    )
    main(indices)  # ty: ignore
