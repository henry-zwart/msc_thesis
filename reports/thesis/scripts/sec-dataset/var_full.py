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
    var_contemporaneous = Correlation.VAR_CONTEMPORANEOUS.calculate(
        df,
        assume_centered=True,  # regularised=True
    )
    var_temporal = Correlation.VAR_TEMPORAL.calculate(
        df,
        assume_centered=True,  # regularised=True
    )

    linkage_contemp = linkage(
        squareform(1 - np.abs(var_contemporaneous), checks=False), method="average"
    )
    order_contemp = leaves_list(linkage_contemp)
    # linkage_temporal = linkage(
    #     squareform(1 - var_temporal, checks=False), method="average"
    # )
    # order_temporal = leaves_list(linkage_temporal)

    var_contemporaneous = var_contemporaneous[order_contemp][:, order_contemp]
    var_temporal = var_temporal[order_contemp][:, order_contemp]
    labels_contemp = np.asarray(labels)[order_contemp]
    labels_temporal = np.asarray(labels)[order_contemp]

    var_contemporaneous[np.diag_indices_from(var_contemporaneous)] = 0.0
    mask_contemporaneous = np.triu(np.ones_like(var_contemporaneous, dtype=np.bool))
    fig, axes = plt.subplots(
        ncols=2,
        figsize=(5.77, 5),
        constrained_layout=True,
        sharey=True,
        gridspec_kw=dict(
            width_ratios=[
                var_contemporaneous.shape[-1] - 1,
                var_contemporaneous.shape[-1],
            ]
        ),
    )
    cbar_ax_contemp = axes[0].inset_axes([0.75, 1.05, 0.25, 0.03])
    cbar_ax_contemp.tick_params(labelsize=7, length=2)
    mask_contemporaneous[np.abs(var_contemporaneous) < 0.05] = 1
    sns.heatmap(
        var_contemporaneous[:, :-1],
        mask=mask_contemporaneous[:, :-1],
        center=0,
        cmap=DIVERGING_CMAP,
        vmin=-0.4,
        vmax=0.4,
        cbar_ax=cbar_ax_contemp,
        cbar_kws=dict(
            use_gridspec=False,
            location="top",
            pad=0.01,
            shrink=0.25,  # anchor=(0.6, 0.5)
        ),
        linewidths=1,
        # annot_kws={"fontsize": 4},
        square=True,
        # fmt=".1f",
        # annot=True,
        ax=axes[0],
    )
    cbar_ax_contemp.set_xticks([-0.4, 0, 0.4])
    cbar_ax_temporal = axes[1].inset_axes([0.75, 1.05, 0.25, 0.03])
    cbar_ax_temporal.tick_params(labelsize=7, length=2)
    mask_temporal = np.zeros_like(var_temporal, dtype=np.bool)
    mask_temporal[np.abs(var_temporal) < 0.05] = 1
    sns.heatmap(
        var_temporal,
        mask=mask_temporal,
        center=0,
        cmap=DIVERGING_CMAP,
        vmin=-0.4,
        vmax=0.4,
        cbar=True,
        # cbar_kws=dict(aspect=30),
        cbar_ax=cbar_ax_temporal,
        cbar_kws=dict(
            use_gridspec=False,
            location="top",
            pad=0.01,
            shrink=0.25,  # anchor=(0.6, 0.5)
        ),
        linewidths=1,
        # annot_kws={"fontsize": 4},
        square=True,
        # fmt=".1f",
        # annot=True,
        ax=axes[1],
    )
    cbar_ax_temporal.set_xticks([-0.4, 0.0, 0.4])

    for ax in axes:
        ax.tick_params(axis="both", labelsize=7.5, length=0)

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
    # axes[1].set_yticks(
    #     np.arange(len(labels_temporal) - 1) + 1.5, labels_temporal[1:], rotation=0
    # )

    axes[0].set_title("Contemporaneous")
    axes[1].set_title("Temporal")
    fig.savefig(
        "reports/thesis/results/figures/dataset/full_subset_var.pdf",
        bbox_inches="tight",
        transparent=True,
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
