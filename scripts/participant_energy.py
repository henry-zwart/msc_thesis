from dataclasses import dataclass

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
from ising.model import FitMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising, SymmetricIsing

np.set_printoptions(linewidth=200)

RANDOM_SEED = 202604272006


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


def main(y: npt.NDArray[np.int64], node_labels: list[str]):
    node_labels = [ds_spec.RENAME.get(colname, colname) for colname in node_labels]
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

    # Make adj symmetric version for symmetric Ising
    symm_adj = adj.copy()
    symm_adj = symm_adj | symm_adj.T
    symm_adj[np.tril_indices_from(symm_adj, k=-1)] = False
    symmetric_ising = SymmetricIsing.fit(
        y,
        method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        # adj=symm_adj,
        self_loops=True,
    )
    asymmetric_ising = Ising.fit(
        y,
        method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        # adj=adj,
        self_loops=True,
    )

    # symmetric_ising.adj[abs(symmetric_ising.j) < 0.15] = False
    # symmetric_ising.j[abs(symmetric_ising.j) < 0.15] = 0.0
    # asymmetric_ising.adj[abs(asymmetric_ising.j) < 0.15] = False
    # asymmetric_ising.j[abs(asymmetric_ising.j) < 0.15] = 0.0

    fig, ax = plt.subplots(figsize=(7, 4), constrained_layout=True)
    asymmetric_ising.draw(ax=ax, use_layout_from=symmetric_ising)  # vlim_j=(-1.6, 1.6))
    ax.set_title("Asymmetric Ising")
    fig.savefig("survey_fit_asymm.pdf", bbox_inches="tight")
    fig, ax = plt.subplots(figsize=(7, 4), constrained_layout=True)
    symmetric_ising.draw(ax=ax)  # , vlim_j=(-1.6, 1.6))
    ax.set_title("Symmetric Ising")
    fig.savefig("survey_fit_symm.pdf", bbox_inches="tight")


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    indices = (
        dataset.indices.collect()  # ty: ignore
    )
    model_data = prepare_model_data(indices)  # ty: ignore
    main(model_data.beliefs, model_data.belief_names)
