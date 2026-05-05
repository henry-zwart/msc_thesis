from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
from ising.model import FitMethod, ModelType, PairwiseInteractionSpinModel
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.schema import enums
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)

console = Console()


def prepare_dataset(
    full_dataset: pl.DataFrame,
    filter_expr: pl.Expr | None,
    seed: int,
) -> npt.NDArray[np.int64] | None:
    n_waves = full_dataset.select(pl.col("wave").unique()).shape[0]
    n_cols = len(full_dataset.columns) - 6

    # Optionally filter to rows matching a certain condition
    dataset = full_dataset
    if filter_expr is not None:
        dataset = (
            dataset.filter(filter_expr)
            .with_columns(pl.len().over("participant_id").alias("n_responses"))
            .filter(pl.col("n_responses") == n_waves)
            .drop("n_responses")
        )
    if dataset.is_empty():
        return None

    # Reshape into numpy matrix with shape (individual, observation, question)
    dataset = dataset.sort(by=("participant_id", "wave"))
    n_participants = dataset.select(pl.col("participant_id").unique()).shape[0]
    X = (
        dataset.drop("participant_id", "wave", *ds_spec.DEMOGRAPHIC_COLS)
        .to_numpy()
        .ravel()
        .reshape((n_participants, n_waves, n_cols))
    )

    # Binarise data, setting zeros to -1 or +1 uniformly
    X[X < -0.1] = -1
    X[X > 0.1] = 1
    rng = np.random.default_rng(seed)
    random_assignments = rng.choice((-1, 1), size=X.size).reshape(
        (n_participants, n_waves, n_cols)
    )
    random_assignment_idxes = (X >= -0.1) & (X <= 0.1)
    X[random_assignment_idxes] = random_assignments[random_assignment_idxes]
    X = X.astype(np.int64)
    return X


def prepare_covariates(
    full_dataset: pl.DataFrame,
) -> npt.NDArray[np.float64]:
    n_waves = full_dataset.select(pl.col("wave").unique()).shape[0]
    n_cols = len(ds_spec.DEMOGRAPHIC_COLS)

    # Optionally filter to rows matching a certain condition
    dataset = full_dataset

    # Reshape into numpy matrix with shape (individual, observation, question)
    dataset = dataset.sort(by=("participant_id", "wave"))
    n_participants = dataset.select(pl.col("participant_id").unique()).shape[0]
    X = (
        dataset.select(*ds_spec.DEMOGRAPHIC_COLS)
        .to_numpy()
        .ravel()
        .reshape((n_participants, n_waves, n_cols))
    )

    # Standardise data
    X = (X - X.mean(axis=(0, 1))) / X.std(axis=(0, 1))
    X = X.astype(np.float64)
    return X


class StratifiedIsingPlotCommand(BaseCommand):
    output: Path | None = None
    model_type: ModelType
    stratify: str
    seed: int = 202604281551

    fit_indices: bool = True

    def cli_cmd(self) -> None:
        cls = self.model_type.get_cls()

        match self.stratify:
            case "dem_male":
                cats = enums.Gender.categories
            case "dem_educ":
                cats = [
                    "<= 12th grade",
                    "HS Diploma",
                    "Some college",
                    "Assoc. degree",
                    "Bach. degree",
                    "Adv. degree",
                ]
            case "dem_urban":
                cats = enums.UrbanArea.categories
            case "dem_income_percep":
                cats = [
                    "Living comfortably",
                    "Getting by",
                    "Finding it difficult",
                    "Finding it very difficult",
                ]
            case _:
                raise RuntimeError(
                    f"Unsupported stratification column: {self.stratify}"
                )

        if not issubclass(cls, PairwiseInteractionSpinModel):
            raise RuntimeError(
                f"Stratified Ising plot only supported for models inheriting from "
                f"`PairwiseInteractionSpinModel`. Found `model-type={self.model_type}`."
            )

        configure_mpl()

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )

        if self.fit_indices:
            if dataset.indices is None:
                raise RuntimeError(
                    "`indices` are not defined for dataset 'reduced_no_imputation'"
                )
            ds = dataset.indices.collect()
        else:
            ds = dataset.response.collect()

        # For each unique value of the stratification variable, fit and plot model
        labels = [
            ds_spec.RENAME.get(colname, colname)
            for colname in ds.columns[6:]  # ty: ignore
        ]
        n_cols = 2
        n_rows = (((len(cats) + 2) - 1) // n_cols) + 1
        fig, axes = plt.subplots(
            nrows=n_rows,
            ncols=n_cols,
            figsize=(14, 5 * n_rows),
            constrained_layout=True,
        )

        # First plot the model fit on full data
        full_model = cls.fit(
            prepare_dataset(ds, None, self.seed),  # ty: ignore
            method=FitMethod.TIME_SERIES,
            node_labels=labels,
            rng=self.seed,
        )
        full_model.adj[abs(full_model.j) < 0.15] = False
        full_model.j[abs(full_model.j) < 0.15] = 0.0
        full_model.draw(ax=axes[0, 0])
        axes[0, 0].set_title(f"{cls.__name__}")

        # Then plot the model fit with demographic covariates
        covariate_model = cls.fit(
            prepare_dataset(ds, None, self.seed),  # ty: ignore
            prepare_covariates(ds),  # ty: ignore
            method=FitMethod.TIME_SERIES,
            node_labels=labels,
            rng=self.seed,
        )
        covariate_model.adj[abs(covariate_model.j) < 0.15] = False
        covariate_model.j[abs(covariate_model.j) < 0.15] = 0.0
        covariate_model.draw(ax=axes[0, 1], use_layout_from=full_model)
        print(full_model.j)
        print(covariate_model.j)
        print()
        # print(covariate_model.beta)
        axes[0, 1].set_title(f"{cls.__name__} (with covariates)")

        # Then plot the rest of the models
        for i, cat in enumerate(cats):
            row = (i + 2) // n_cols
            col = (i + 2) % n_cols
            X = prepare_dataset(ds, pl.col(self.stratify) == i, self.seed)  # ty: ignore

            if X is None:
                axes[row, col].set_title(f"{cls.__name__}: {self.stratify} == {cat}")
                axes[row, col].annotate("Insufficient data", (0, 0))
                continue
            else:
                axes[row, col].set_title(
                    f"{cls.__name__}: {self.stratify} == {cat} (n={X.shape[0]})"
                )

            model = cls.fit(
                X,
                method=FitMethod.TIME_SERIES,
                node_labels=labels,
                rng=self.seed,
            )
            model.adj[abs(model.j) < 0.15] = False
            model.j[abs(model.j) < 0.15] = 0.0
            model.draw(ax=axes[row, col], use_layout_from=full_model)

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
        else:
            plt.show()
