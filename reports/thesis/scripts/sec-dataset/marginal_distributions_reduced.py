import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars.selectors as cs
import seaborn as sns

from climate_attitudes import configure_mpl
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.settings import Config

RANDOM_SEED = 20260607


def main(X: npt.NDArray[np.float64], labels: list[str]):
    fig, axes = plt.subplots(
        nrows=2, ncols=4, figsize=(5, 2.3), sharey=True, constrained_layout=True
    )

    bins = [
        [-1.5, -0.5, 0.5, 1.5],
        [-2, 0, 2],
        [-4 / 3, -2 / 3, 0, 2 / 3, 4 / 3],
        [-4 / 3, -2 / 3, 0, 2 / 3, 4 / 3],
        [-4 / 3, -2 / 3, 0, 2 / 3, 4 / 3],
        [-1.25, -0.75, -0.25, 0.25, 0.75, 1.25],
        [-1.25, -0.75, -0.25, 0.25, 0.75, 1.25],
        [-1.25, -0.75, -0.25, 0.25, 0.75, 1.25],
    ]
    for i in range(8):
        ax = axes[i // 4, i % 4]
        sns.histplot(
            X[:, i],
            bins=bins[i],
            # binwidth=0.5,
            stat="density",
            shrink=0.28 * (len(bins[i]) - 1) / 2,
            ax=ax,
        )
        ax.set_title(labels[i], fontsize=10)
        ax.spines.top.set_visible(False)
        ax.spines.right.set_visible(False)

    for ext in ("png", "pdf"):
        fig.savefig(
            f"reports/thesis/results/figures/dataset/marginal_distributions.{ext}",
            bbox_inches="tight",
            transparent=True,
        )


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(
        config, name="reduced_no_imputation", with_imputation=False, verbose=False
    )
    schema = schema.post_index()
    survey_cols = schema.get_cols("survey")
    labels = schema.get_short_names("measurement")
    if dataset.indices is None:
        raise RuntimeError("This shouldn't happen")
    data = (
        dataset.indices.select(*survey_cols, *schema.get_cols("measurement"))
        .with_columns(cs.exclude(*survey_cols) / cs.exclude(*survey_cols).abs().max())
        .collect()
    )

    main(data.drop(*survey_cols).to_numpy(), labels)
