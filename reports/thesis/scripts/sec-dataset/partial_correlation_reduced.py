import iplotx as ipx
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import networkx as nx
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
    corr = Correlation.PARTIAL_GLASSO.calculate(df)
    pcorr = Correlation.PARTIAL_GLASSO.calculate(df)
    _linkage = linkage(squareform(1 - np.abs(corr), checks=False), method="average")
    idx_order = leaves_list(_linkage)
    corr = corr[idx_order][:, idx_order]
    pcorr = pcorr[idx_order][:, idx_order]
    labels = np.asarray(labels)[idx_order]
    mask = np.triu(np.ones_like(corr, dtype=np.bool))
    mask[abs(corr) < 0.05] = 1
    fig, axes = plt.subplots(
        ncols=2,
        figsize=(5.77, 2.5),
        constrained_layout=True,
        gridspec_kw={"width_ratios": [2.3, 3.42]},
    )
    sns.heatmap(
        corr,
        mask=mask,
        center=0,
        cmap=DIVERGING_CMAP,
        vmin=-0.5,
        vmax=0.5,
        cbar=False,
        linewidths=1,
        annot_kws={"fontsize": 7},
        square=True,
        fmt=".1f",
        annot=True,
        ax=axes[0],
    )
    axes[0].set_xticks(
        np.arange(len(labels) - 1) + 0.5,
        labels[:-1],
        rotation=35,
        horizontalalignment="right",
    )
    axes[0].set_yticks(np.arange(len(labels) - 1) + 1.5, labels[1:], rotation=0)
    axes[0].tick_params(axis="both", labelsize=7, length=0)

    # Plot as network as well
    adj = pcorr.copy()
    adj[np.abs(adj) < 0.05] = 0.0
    adj[np.diag_indices_from(adj)] = 0.0
    # adj[mask] = 0.0
    G = nx.from_numpy_array(adj)
    edge_linewidths = {(u, v): abs(z["weight"]) * 6 for u, v, z in G.edges(data=True)}
    edge_colours = [np.sign(z["weight"]) for *_, z in G.edges(data=True)]
    layout = nx.forceatlas2_layout(G, gravity=2, weight="weight", seed=RANDOM_SEED)

    with ipx.style.context(
        [
            "hollow",
            {
                "vertex": {"linewidth": 0, "label": {"fontsize": 7}},
                "edge": {
                    "color": edge_colours,
                    "alpha": 1,
                    "cmap": DIVERGING_CMAP,
                    "norm": mcolors.Normalize(vmin=-1.0, vmax=1.0),
                },
            },
        ]
    ):
        ipx.network(
            G,
            layout=layout,
            tension=1,
            node_labels=labels,
            edge_linewidth=edge_linewidths,
            edge_curved=False,
            # aspect="equal",
            margins=0.1,
            edge_label_bbox=dict(
                edgecolor="black",
                facecolor="white",
                linewidth=0.25,
                boxstyle="round,pad=0.3",
            ),
            edge_label_rotate=True,
            vertex_facecolor="white",
            vertex_zorder=3,
            ax=axes[1],
        )[0]

    fig.savefig(
        "reports/thesis/results/figures/dataset/reduced_subset_partial_corr.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
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
