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

RANDOM_SEED = 20260607


def main(df: pl.DataFrame, labels: list[str]):
    var_contemporaneous = Correlation.VAR_CONTEMPORANEOUS.calculate(
        df, assume_centered=True, regularised=True
    )
    var_temporal = Correlation.VAR_TEMPORAL.calculate(
        df, assume_centered=True, regularised=True
    )

    linkage_contemp = linkage(
        squareform(1 - np.abs(var_contemporaneous), checks=False), method="average"
    )
    order_contemp = leaves_list(linkage_contemp)

    var_contemporaneous = var_contemporaneous[order_contemp][:, order_contemp]
    var_temporal = var_temporal[order_contemp][:, order_contemp]
    labels_contemp = np.asarray(labels)[order_contemp]
    labels_temporal = np.asarray(labels)[order_contemp]

    var_contemporaneous[np.diag_indices_from(var_contemporaneous)] = 0.0
    mask_contemporaneous = np.triu(np.ones_like(var_contemporaneous, dtype=np.bool))
    fig, axes = plt.subplots(
        ncols=2,
        figsize=(5, 4),
        constrained_layout=True,
        sharey=True,
        gridspec_kw=dict(
            width_ratios=[
                var_contemporaneous.shape[-1] - 1,
                var_contemporaneous.shape[-1],
            ]
        ),
    )
    mask_contemporaneous[np.abs(var_contemporaneous) < 0.05] = 1
    sns.heatmap(
        var_contemporaneous[:, :-1],
        mask=mask_contemporaneous[:, :-1],
        center=0,
        cmap=DIVERGING_CMAP,
        vmin=-0.4,
        vmax=0.4,
        linewidths=1,
        cbar=False,
        annot_kws={"fontsize": 8},
        square=True,
        fmt=".1f",
        annot=True,
        ax=axes[0],
    )
    mask_temporal = np.zeros_like(var_temporal, dtype=np.bool)
    mask_temporal[np.abs(var_temporal) < 0.05] = 1
    sns.heatmap(
        var_temporal,
        mask=mask_temporal,
        center=0,
        cmap=DIVERGING_CMAP,
        vmin=-0.4,
        vmax=0.4,
        linewidths=1,
        cbar=False,
        annot_kws={"fontsize": 8},
        square=True,
        fmt=".1f",
        annot=True,
        ax=axes[1],
    )

    for ax in axes:
        ax.tick_params(axis="both", labelsize=10, length=0)

    axes[0].set_xticks(
        np.arange(len(labels_contemp) - 1) + 0.5,
        labels_contemp[:-1],
        rotation=90,
    )
    axes[1].set_xticks(
        np.arange(len(labels_temporal)) + 0.5,
        labels_temporal,
        rotation=90,
    )
    axes[0].set_yticks(np.arange(len(labels_contemp)) + 0.5, labels_contemp, rotation=0)

    axes[0].set_title("Contemporaneous")
    axes[1].set_title("Temporal")
    fig.savefig(
        "reports/thesis/results/figures/dataset/reduced_subset_var.pdf",
        bbox_inches="tight",
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

    main(data, labels)
