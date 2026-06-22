from dataclasses import dataclass

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
from ising.model import FitMethod, UpdateMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising, SymmetricIsing

np.set_printoptions(linewidth=200)

RANDOM_SEED = 202604272006
RANDOM_SEED = 202606031418


@dataclass
class ModelData:
    covariates: npt.NDArray[np.float64]
    beliefs: npt.NDArray[np.int64]
    covariate_names: list[str]
    belief_names: list[str]


def prepare_model_data(data: pl.DataFrame) -> ModelData:
    n_waves = data.select(pl.col("wave").unique()).shape[0]
    covariate_names = ds_spec.DEMOGRAPHIC_COLS
    belief_names = data.drop("participant_id", "wave", *covariate_names).columns

    # Sort data
    data = data.sort(by=("participant_id", "wave"))

    covariates = (
        data.select(*covariate_names)
        .to_numpy()
        .ravel()  # Unwrap into 1D array
        .reshape(
            (-1, n_waves, len(covariate_names))
        )  # Reshape into (participant, wave, covariate)
    )

    beliefs = (
        data.select(*belief_names)
        .to_numpy()
        .ravel()  # Unwrap into 1D array
        .reshape(
            (-1, n_waves, len(belief_names))
        )  # Reshape into (participant, wave, covariate)
    )

    # Binarise beliefs, adding noise to binarise smoothly
    rng = np.random.default_rng(RANDOM_SEED)
    ζ = rng.normal(scale=0.1, size=beliefs.size).reshape(beliefs.shape)
    beliefs = np.where(beliefs + ζ > 0.0, 1, -1).astype(np.int64)

    return ModelData(
        covariates=covariates,
        beliefs=beliefs,
        covariate_names=covariate_names,
        belief_names=belief_names,
    )


def main_old(indices: pl.DataFrame):
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
        w=1,
    )
    asymmetric_ising = Ising.fit(
        y,
        method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        self_loops=True,
        w=1,
    )

    symmetric_ising.adj[abs(symmetric_ising.j) < 0.01] = False
    symmetric_ising.j[abs(symmetric_ising.j) < 0.01] = 0.0
    asymmetric_ising.adj[abs(asymmetric_ising.j) < 0.01] = False
    asymmetric_ising.j[abs(asymmetric_ising.j) < 0.01] = 0.0

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
    asymmetric_ising.draw(ax=ax, use_layout_from=symmetric_ising, vlim_j=(-1.6, 1.6))
    ax.set_title("Asymmetric Ising")
    fig.savefig("survey_fit_asymm.pdf", bbox_inches="tight")
    fig, ax = plt.subplots(figsize=(7, 4), constrained_layout=True)
    symmetric_ising.draw(ax=ax, vlim_j=(-1.6, 1.6))
    ax.set_title("Symmetric Ising")
    fig.savefig("survey_fit_symm.pdf", bbox_inches="tight")


def main(y: npt.NDArray[np.int64], node_labels: list[str] | npt.NDArray[np.str_]):
    node_labels = np.asarray(
        [ds_spec.RENAME.get(colname, colname) for colname in node_labels]
    )
    adj = np.array(
        [
            [1, 1, 1, 0, 0, 0, 1, 1],
            [1, 1, 1, 0, 0, 0, 1, 1],
            [0, 1, 1, 1, 1, 1, 1, 1],
            [0, 0, 0, 1, 0, 0, 0, 0],
            [0, 0, 1, 1, 1, 0, 0, 0],
            [0, 0, 1, 0, 0, 1, 0, 1],
            [0, 0, 1, 1, 1, 1, 1, 0],
            [1, 0, 1, 0, 0, 1, 1, 1],
        ],
        dtype=np.bool,
    )
    adj = np.full((8, 8), fill_value=True, dtype=np.bool)
    adj[7] = False
    adj[7, 7] = True

    # Subset Y
    y = y[..., [0, 1, 2, 4, 5, 6, 7]]
    node_labels = node_labels[[0, 1, 2, 4, 5, 6, 7]]

    # Make adj symmetric version for symmetric Ising
    # symm_adj = adj.copy()
    # symm_adj = symm_adj | symm_adj.T
    # symm_adj[np.tril_indices_from(symm_adj, k=-1)] = False
    symmetric_ising = SymmetricIsing.fit(
        y,
        optim_method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        update_method=UpdateMethod.SYNCHRONOUS,
        # adj=symm_adj,
        self_loops=True,
        w=None,
    )
    # print(symmetric_ising.h)
    # print(symmetric_ising.j)
    asymmetric_ising = Ising.fit(
        y,
        optim_method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        update_method=UpdateMethod.SYNCHRONOUS,
        # adj=adj,
        self_loops=True,
        w=None,
    )
    # asymmetric_ising.j[abs(asymmetric_ising.j) < 0.05] = 0.0
    # symmetric_ising.j[abs(symmetric_ising.j) < 0.05] = 0.0
    # asymmetric_ising.j[np.diag_indices_from(asymmetric_ising.j)] = 0
    # symmetric_ising.j[np.diag_indices_from(symmetric_ising.j)] = 0

    # symmetric_ising.adj[abs(symmetric_ising.j) < 0.15] = False
    # symmetric_ising.j[abs(symmetric_ising.j) < 0.15] = 0.0
    # asymmetric_ising.adj[abs(asymmetric_ising.j) < 0.15] = False
    # asymmetric_ising.j[abs(asymmetric_ising.j) < 0.15] = 0.0

    fig, ax = plt.subplots(figsize=(7, 4), constrained_layout=True)
    asymmetric_ising.draw(
        ax=ax,
        use_layout_from=symmetric_ising,  # , vlim_j=(-0.3, 0.3)
    )  # vlim_j=(-1.6, 1.6))
    ax.set_title("Asymmetric Ising")
    fig.savefig("survey_fit_asymm.pdf", bbox_inches="tight")
    fig.savefig("survey_fit_asymm.png", bbox_inches="tight")
    fig, ax = plt.subplots(figsize=(7, 4), constrained_layout=True)
    symmetric_ising.draw(ax=ax)  # , vlim_j=(-1.6, 1.6))
    ax.set_title("Symmetric Ising")
    fig.savefig("survey_fit_symm.pdf", bbox_inches="tight")
    fig.savefig("survey_fit_symm.png", bbox_inches="tight")


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    _, Y, _ = dataset.indices_to_numpy(
        kind="time-series", binarise=True, seed=RANDOM_SEED
    )
    labels = dataset.schema.get_short_names(kind="measurement")
    main(Y, labels)
