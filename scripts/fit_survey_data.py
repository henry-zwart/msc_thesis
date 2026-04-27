import numpy as np
import polars as pl
import polars.selectors as cs
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
    n_cols = len(indices.columns) - 2

    # Extract dataset into (participant, wave, question) form
    X = (
        indices.sort(by=("participant_id", "wave"))
        .drop("participant_id", "wave")
        .to_numpy()
        .ravel()
        .reshape((n_participants, n_waves, n_cols))
    )

    # Binarise data. Set zeros to -1 or +1 uniformly
    # NOTE: There are no zeros -- check, are we centring on response zero, or mean?
    X[X < 0] = -1
    X[X > 0] = 1
    X = X.astype(np.int64)

    symmetric_ising = SymmetricIsing.fit(
        X,
        method=FitMethod.TIME_SERIES,
        node_labels=indices.columns[2:],
        rng=RANDOM_SEED,
    )
    asymmetric_ising = Ising.fit(
        X,
        method=FitMethod.TIME_SERIES,
        node_labels=indices.columns[2:],
        rng=RANDOM_SEED,
    )

    symmetric_ising.j[abs(symmetric_ising.j) < 0.1] = 0.0
    asymmetric_ising.j[abs(asymmetric_ising.j) < 0.1] = 0.0

    print("Symmetric")
    symmetric_bootstraps = SymmetricIsing.bootstrap(
        X, method=FitMethod.TIME_SERIES, r=100
    )
    print(symmetric_ising.h)
    print(np.std(np.array([m.h for _, m in symmetric_bootstraps]), ddof=1, axis=0))

    print(symmetric_ising.j)
    print(np.std(np.array([m.j for _, m in symmetric_bootstraps]), ddof=1, axis=0))

    print("Asymmetric")
    asymmetric_bootstraps = Ising.bootstrap(X, method=FitMethod.TIME_SERIES, r=100)
    print(asymmetric_ising.h)
    print(np.std(np.array([m.h for _, m in asymmetric_bootstraps]), ddof=1, axis=0))

    print(asymmetric_ising.j)
    print(np.std(np.array([m.j for _, m in asymmetric_bootstraps]), ddof=1, axis=0))

    # Calculate difference in

    print(indices.columns[2:])

    # fig, axes = plt.subplots(ncols=2, figsize=(15, 4), constrained_layout=True)
    # symmetric_ising.draw(ax=axes[0])
    # asymmetric_ising.draw(ax=axes[1], use_layout_from=symmetric_ising)
    # axes[0].set_title("Symmetric Ising")
    # axes[1].set_title("Asymmetric Ising")
    #
    # plt.show()


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset_no_std = Dataset.load(
        config, name="reduced_no_imputation", with_imputation=False
    )
    dataset = dataset_no_std.standardise(cs.exclude(*ds_spec.SURVEY_COLS))
    indices = dataset.indices.collect().with_columns(-pl.col("politics"))  # ty: ignore
    print(indices)
    main(indices)
