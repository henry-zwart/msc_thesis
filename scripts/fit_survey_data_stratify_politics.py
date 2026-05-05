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


def main(dem_indices: pl.DataFrame, rep_indices: pl.DataFrame):
    n_waves = dem_indices.select(pl.col("wave").unique()).shape[0]
    n_cols = len(dem_indices.columns) - 6

    # Extract dataset into (participant, wave, question) form
    def prepare_dataset(dataset):
        ds = dataset.sort(by=("participant_id", "wave"))
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

    X_dem = prepare_dataset(dem_indices)
    X_rep = prepare_dataset(rep_indices)

    ising_dem = SymmetricIsing.fit(
        X_dem,
        method=FitMethod.TIME_SERIES,
        node_labels=dem_indices.columns[6:],
        rng=RANDOM_SEED,
        self_loops=True,
    )
    ising_rep = SymmetricIsing.fit(
        X_rep,
        method=FitMethod.TIME_SERIES,
        node_labels=rep_indices.columns[6:],
        rng=RANDOM_SEED,
        self_loops=True,
    )

    # ising_dem.adj[abs(ising_dem.j) < 0.05] = False
    # ising_dem.j[abs(ising_dem.j) < 0.05] = 0.0
    #
    # ising_rep.adj[abs(ising_rep.j) < 0.05] = False
    # ising_rep.j[abs(ising_rep.j) < 0.05] = 0.0

    # fig, axes = plt.subplots(ncols=2, figsize=(15, 4), constrained_layout=True)
    fig, axes = plt.subplots(ncols=2, figsize=(14, 5), constrained_layout=True)
    ising_dem.draw(ax=axes[0], use_layout_from=ising_rep, seed=2026050116)
    axes[0].set_title("Symmetric Ising (democrat-leaning)")
    ising_rep.draw(ax=axes[1], seed=2026050116)
    axes[1].set_title("Symmetric Ising (republican-leaning)")
    fig.savefig("survey_fit_partisan.pdf", bbox_inches="tight")


def split_data_by_partisanship(
    dataset: pl.DataFrame, indices: pl.DataFrame
) -> tuple[pl.DataFrame, pl.DataFrame]:
    def filter_two_responses(df: pl.DataFrame) -> pl.DataFrame:
        """Filter to individuals with two responses."""
        return (
            df.with_columns(pl.len().over("participant_id").alias("n_obs"))
            .filter(pl.col("n_obs") == 2)
            .drop("n_obs")
        )

    left_leaning = filter_two_responses(
        dataset.filter(pl.col("pol_affiliation") > 0).select("participant_id", "wave")
    )
    right_leaning = filter_two_responses(
        dataset.filter(pl.col("pol_affiliation") < 0).select("participant_id", "wave")
    )

    left_indices = left_leaning.join(indices, how="left", on=("participant_id", "wave"))
    right_indices = right_leaning.join(
        indices, how="left", on=("participant_id", "wave")
    )

    return left_indices, right_indices


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)

    indices = (
        dataset.indices.collect()  # ty: ignore
    )

    dem_indices, rep_indices = split_data_by_partisanship(
        dataset.response.collect(),  # ty: ignore
        indices,  # ty: ignore
    )
    main(
        dem_indices.drop("politics"),
        rep_indices.drop("politics"),
    )
