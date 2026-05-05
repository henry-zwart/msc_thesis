import matplotlib.pyplot as plt
import numpy as np
import polars as pl
import seaborn as sns

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)


# RANDOM_SEED = 202604272006
def main(data):
    n_participants = data.select(pl.col("participant_id").unique()).shape[0]
    n_waves = data.select(pl.col("wave").unique()).shape[0]
    n_cols = len(data.columns) - 6
    y = (
        data.sort(by=("participant_id", "wave"))
        .drop("participant_id", "wave", *ds_spec.DEMOGRAPHIC_COLS)
        .to_numpy()
        .ravel()
        .reshape((n_participants, n_waves, n_cols))
    )

    state_diff = np.diff(y, axis=1)[:, 0, :].T

    fig, ax = plt.subplots(constrained_layout=True)
    for i, colname in enumerate(data.columns[6:]):
        sns.kdeplot(
            state_diff[i],
            label=ds_spec.RENAME.get(colname, colname),
            fill=True,
            alpha=0.4,
            ax=ax,
        )
    ax.legend()

    fig.savefig("direction_of_change.pdf", bbox_inches="tight")


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    indices = (
        dataset.indices.collect()  # ty: ignore
    )
    main(indices)
