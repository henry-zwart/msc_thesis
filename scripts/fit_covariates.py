from dataclasses import dataclass

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
import polars.selectors as cs
from ising.model import FitMethod

from climate_attitudes.cli.visualisation.stratified_ising import (
    prepare_covariates,
    prepare_dataset,
)
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising

RANDOM_SEED = 2026050616


@dataclass
class ModelData:
    covariates: npt.NDArray[np.float64]
    beliefs: npt.NDArray[np.int64]
    covariate_names: list[str]
    belief_names: list[str]


def prepare_model_data(data: pl.DataFrame) -> ModelData:
    n_waves = data.select(pl.col("survey_wave").unique()).shape[0]
    covariate_names = [
        col[len("covariate_") :]
        for col in data.select(cs.starts_with("covariate_")).columns
    ]
    belief_names = [
        col[len("belief_") :] for col in data.select(cs.starts_with("belief_")).columns
    ]

    covariates = (
        data.select(cs.starts_with("covariate_"))
        .to_numpy()
        .ravel()  # Unwrap into 1D array
        .reshape(
            (-1, n_waves, len(covariate_names))
        )  # Reshape into (participant, wave, covariate)
    )

    beliefs = (
        data.select(cs.starts_with("belief_"))
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


def main_old(ds: pl.DataFrame) -> None:
    # For each unique value of the stratification variable, fit and plot model
    labels = [ds_spec.RENAME.get(colname, colname) for colname in ds.columns[6:]]

    fig, axes = plt.subplots(ncols=2, nrows=2, figsize=(14, 8), constrained_layout=True)

    # Plot the model fit zero/avg covariates
    covariate_model = Ising.fit(
        prepare_dataset(ds, None, RANDOM_SEED),  # ty: ignore
        prepare_covariates(ds),
        method=FitMethod.TIME_SERIES,
        node_labels=labels,
        self_loops=True,
        rng=RANDOM_SEED,
    )

    covariate_model.draw(
        ax=axes[0, 0],
        seed=RANDOM_SEED,
        vlim_h=(-1, 1),
        vlim_j=(-1.6, 1.6),
    )
    axes[0, 0].set_title("Mean model")

    covariate_model.draw(
        ax=axes[0, 1],
        X=np.array([-1.0, 1.0, 1.0, 1.0, -1.0, -1.0]),
        # X=np.array([-1.0, -1.0, 1.0, -1.0, 1.0, -1.0]),
        use_layout_from=covariate_model,
        seed=RANDOM_SEED,
        vlim_h=(-1, 1),
        vlim_j=(-1.6, 1.6),
    )
    axes[0, 1].set_title("(Female, high education, high income perception, urban)")
    # axes[0, 1].set_title("(Female, low education, high income perception, suburban)")

    covariate_model.draw(
        ax=axes[1, 0],
        X=np.array([1.0, -1.0, -1.0, -1.0, -1.0, 1.0]),
        # X=np.array([1.0, 1.0, -1.0, 1.0, -1.0, -1.0]),
        use_layout_from=covariate_model,
        seed=RANDOM_SEED,
        vlim_h=(-1, 1),
        vlim_j=(-1.6, 1.6),
    )
    axes[1, 0].set_title("(Male, low education, low income perception, rural)")
    # axes[1, 0].set_title("(Male, high education, low income perception, urban)")

    fig.savefig("covariate_fit.pdf", bbox_inches="tight")


def main(
    y: npt.NDArray[np.int64], X: npt.NDArray[np.float64], node_labels: list[str]
) -> None:
    # For each unique value of the stratification variable, fit and plot model
    labels = [ds_spec.RENAME.get(colname, colname) for colname in node_labels]

    fig, axes = plt.subplots(ncols=2, nrows=2, figsize=(14, 8), constrained_layout=True)

    # Plot the model fit zero/avg covariates
    covariate_model = Ising.fit(
        y,
        X,
        method=FitMethod.TIME_SERIES,
        node_labels=labels,
        self_loops=True,
        rng=RANDOM_SEED,
    )

    covariate_model.draw(
        ax=axes[0, 0],
        seed=RANDOM_SEED,
        vlim_h=(-1, 1),
        vlim_j=(-1.6, 1.6),
    )
    axes[0, 0].set_title("Mean model")

    covariate_model.draw(
        ax=axes[0, 1],
        X=np.array([-1.0, 1.0, 1.0, 1.0, -1.0, -1.0]),
        # X=np.array([-1.0, -1.0, 1.0, -1.0, 1.0, -1.0]),
        use_layout_from=covariate_model,
        seed=RANDOM_SEED,
        vlim_h=(-1, 1),
        vlim_j=(-1.6, 1.6),
    )
    axes[0, 1].set_title("(Female, high education, high income perception, urban)")
    # axes[0, 1].set_title("(Female, low education, high income perception, suburban)")

    covariate_model.draw(
        ax=axes[1, 0],
        X=np.array([1.0, -1.0, -1.0, -1.0, -1.0, 1.0]),
        # X=np.array([1.0, 1.0, -1.0, 1.0, -1.0, -1.0]),
        use_layout_from=covariate_model,
        seed=RANDOM_SEED,
        vlim_h=(-1, 1),
        vlim_j=(-1.6, 1.6),
    )
    axes[1, 0].set_title("(Male, low education, low income perception, rural)")
    # axes[1, 0].set_title("(Male, high education, low income perception, urban)")

    fig.savefig("covariate_fit_no_intermediates.pdf", bbox_inches="tight")


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    indices = (
        dataset.indices.collect()  # ty: ignore
    )
