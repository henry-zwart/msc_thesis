import matplotlib.pyplot as plt
import numpy as np
import polars as pl
from ising.model import FitMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import SymmetricIsing

np.set_printoptions(linewidth=200)

RANDOM_SEED = 202604272006


def main(indices: pl.DataFrame):
    n_waves = indices.select(pl.col("wave").unique()).shape[0]
    n_cols = len(indices.columns) - 6

    # Extract dataset into (participant, wave, question) form
    def prepare_dataset(filter_expr: pl.Expr | None = None):
        if filter_expr is not None:
            ds = (
                indices.filter(filter_expr)
                .with_columns(pl.len().over("participant_id").alias("n_responses"))
                .filter(pl.col("n_responses") == n_waves)
                .drop("n_responses")
            )
        else:
            ds = indices
        ds = ds.sort(by=("participant_id", "wave"))
        n_participants = ds.select(pl.col("participant_id").unique()).shape[0]
        X = (
            ds.drop("participant_id", "wave", *ds_spec.DEMOGRAPHIC_COLS)
            .to_numpy()
            .ravel()
            .reshape((n_participants, n_waves, n_cols))
        )

        # Binarise data.
        X[X < -0.1] = -1
        X[X > 0.1] = 1

        # Set zeros to -1 or +1 uniformly
        rng = np.random.default_rng(RANDOM_SEED)
        random_assignments = rng.choice((-1, 1), size=X.size).reshape(
            (n_participants, n_waves, n_cols)
        )
        random_assignment_idxes = (X >= -0.1) & (X <= 0.1)
        X[random_assignment_idxes] = random_assignments[random_assignment_idxes]
        X = X.astype(np.int64)
        return X

    X = prepare_dataset()
    ising = SymmetricIsing.fit(
        X,
        method=FitMethod.TIME_SERIES,
        node_labels=indices.columns[6:],
        rng=RANDOM_SEED,
    )

    X_male = prepare_dataset(pl.col("dem_male") == 1)
    ising_male = SymmetricIsing.fit(
        X_male,
        method=FitMethod.TIME_SERIES,
        node_labels=indices.columns[6:],
        rng=RANDOM_SEED,
    )
    X_female = prepare_dataset(pl.col("dem_male") == 0)
    ising_female = SymmetricIsing.fit(
        X_female,
        method=FitMethod.TIME_SERIES,
        node_labels=indices.columns[6:],
        rng=RANDOM_SEED,
    )

    ising.adj[abs(ising.j) < 0.15] = False
    ising.j[abs(ising.j) < 0.15] = 0.0

    ising_male.adj[abs(ising_male.j) < 0.15] = False
    ising_male.j[abs(ising_male.j) < 0.15] = 0.0

    ising_female.adj[abs(ising_female.j) < 0.15] = False
    ising_female.j[abs(ising_female.j) < 0.15] = 0.0

    # fig, axes = plt.subplots(ncols=2, figsize=(15, 4), constrained_layout=True)
    fig, axes = plt.subplots(
        ncols=2, nrows=2, figsize=(14, 10), constrained_layout=True
    )
    ising.draw(ax=axes[0, 0], use_layout_from=ising_female)
    axes[0, 0].set_title("Symmetric Ising")
    ising_male.draw(ax=axes[0, 1], use_layout_from=ising_female)
    axes[0, 1].set_title("Symmetric Ising (male only)")
    ising_female.draw(ax=axes[1, 1])
    axes[1, 1].set_title("Symmetric Ising (female only)")
    fig.savefig("survey_fit_symm_gender.pdf", bbox_inches="tight")


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    indices = (
        dataset.indices.collect()  # ty: ignore
    )
    main(indices)  # ty: ignore
