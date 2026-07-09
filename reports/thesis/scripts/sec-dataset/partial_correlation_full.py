import matplotlib.pyplot as plt
import numpy as np
import polars as pl
import polars.selectors as cs
import seaborn as sns
from scipy.cluster.hierarchy import leaves_list, linkage
from scipy.spatial.distance import squareform

from climate_attitudes import configure_mpl
from climate_attitudes.correlation import Correlation
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets.reduced_no_imputation import schema
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import (
    DIVERGING_CMAP,
)


def main(df: pl.DataFrame, labels: list[str]):
    corr = Correlation.PARTIAL.calculate(df)
    _linkage = linkage(squareform(1 - np.abs(corr), checks=False), method="average")
    idx_order = leaves_list(_linkage)
    corr = corr[idx_order][:, idx_order]
    labels = np.asarray(labels)[idx_order]
    mask = np.triu(np.ones_like(corr, dtype=np.int64))
    mask[abs(corr) < 0.05] = True
    fig, ax = plt.subplots(figsize=(4.25, 4.25), constrained_layout=True)
    sns.heatmap(
        corr,
        mask=mask,
        center=0,
        cmap=DIVERGING_CMAP,
        vmin=-0.5,
        vmax=0.5,
        cbar=False,
        linewidths=1,
        annot_kws={"fontsize": 7.5},
        square=True,
        fmt=".1f",
        annot=True,
        ax=ax,
    )
    ax.set_xticks(
        np.arange(len(labels)) + 0.5,
        labels,
        rotation=35,
        horizontalalignment="right",
    )
    ax.set_yticks(np.arange(len(labels)) + 0.5, labels, rotation=0)
    ax.tick_params(axis="both", labelsize=7.5, length=0)
    fig.savefig(
        "reports/thesis/results/figures/dataset/full_subset_partial_corr.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    schema = schema.pre_index()
    survey_cols = schema.get_cols("survey")
    labels = schema.get_short_names("measurement")
    resp = (
        dataset.response.select(*survey_cols, *schema.get_cols("measurement"))
        .with_columns(cs.exclude(*survey_cols) / cs.exclude(*survey_cols).abs().max())
        .collect()
    )

    main(resp, labels)
