from pathlib import Path

import iplotx as ipx
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import polars.selectors as cs

from climate_attitudes import configure_mpl
from climate_attitudes.correlation import Correlation
from climate_attitudes.dataset import Dataset

# from climate_attitudes.datasets import reduced as ds_spec
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import (
    DIVERGING_CMAP,
)

FONT_PATH = Path("fonts")
configure_mpl(FONT_PATH)


def plot_corr_network(df, corr, threshold: float = 0.05, directed: bool = False):
    group_lookup = {
        "politics": "Politics",
        "extreme_weather": "Extreme weather",
        "self_efficacy": "Self Efficacy",
        "climate_impacts": "Climate Impacts",
        "climate_policy": "Climate Policy",
        # "climate_behaviour": "Climate Behaviour",
    }

    fig, ax = plt.subplots(figsize=(4.5, 2), constrained_layout=True)
    fig, ax = plt.subplots(figsize=(2.5, 3), constrained_layout=True)

    # Generate a mask for the upper triangle
    if not directed:
        mask = np.triu(np.ones_like(corr, dtype=bool), k=1)
    else:
        mask = np.full_like(corr, fill_value=False, dtype=bool)

    # If `mask_below` set, reset square colour below abs value to zero
    mask[abs(corr) < threshold] = True

    # Remove questions where only diagonal is unmasked
    keep_idxes = (2 * mask.shape[1] - (mask.sum(axis=1) + mask.sum(axis=0))) > 2
    corr = corr[keep_idxes][:, keep_idxes]
    mask = mask[keep_idxes][:, keep_idxes]
    _node_labels = np.asarray(df.columns)[keep_idxes]
    node_labels = []
    for col in np.asarray(df.columns)[keep_idxes]:
        if col in group_lookup:
            node_labels.append(group_lookup[col])
        elif col in ds_spec.RENAME:
            node_labels.append(ds_spec.RENAME[col])
        else:
            raise RuntimeError(f"Could not find display name for column {col}")
    node_labels = np.asarray(node_labels)

    # ======== Network
    adj = corr
    adj[np.diag_indices_from(adj)] = 0
    adj[mask] = 0
    if directed:
        G = nx.from_numpy_array(adj, create_using=nx.DiGraph)
    else:
        G = nx.from_numpy_array(adj)

    edge_linewidths = {(u, v): z["weight"] * 9 for u, v, z in G.edges(data=True)}
    edge_colours = [z["weight"] for u, v, z in G.edges(data=True)]
    edge_labels = [f"{z['weight']:.1f}" for u, v, z in G.edges(data=True)]
    layout = nx.forceatlas2_layout(G, gravity=0.3, scaling_ratio=5, seed=202603)

    with ipx.style.context(
        [
            "hollow",
            {
                "vertex": {
                    "linewidth": 0.3,
                    "label": dict(hpadding=23, vpadding=5),
                },
                "edge": {
                    "color": edge_colours,
                    "alpha": 1,
                    "cmap": DIVERGING_CMAP,
                    "norm": mcolors.Normalise(vmin=-0.5, vmax=0.5),
                },
            },
        ]
    ):
        _ = ipx.network(
            G,
            layout=layout,
            tension=1,
            edge_labels=edge_labels,
            node_labels=list(node_labels),
            edge_linewidth=edge_linewidths,
            edge_curved=False,
            # aspect="equal",
            margins=0.0,
            edge_label_bbox=dict(
                edgecolor="black",
                facecolor="white",
                linewidth=0.25,
                boxstyle="round,pad=0.3",
            ),
            edge_label_rotate=True,
            vertex_facecolor="white",
            vertex_zorder=3,
            # node_label_size=6,
            # edge_label_size=4,
            node_label_size=3.5,
            edge_label_size=3,
            ax=ax,
        )[0]

    # fig.suptitle("Partial correlation (GLASSO regularisation)")
    return fig


def main():
    config = Config(_env_file=".env")
    # dataset_no_std = Dataset.load(config, name="reduced", with_imputation=True)
    dataset_no_std = Dataset.load(
        config, name="reduced_no_imputation", with_imputation=False
    )
    dataset = dataset_no_std.standardise(cs.exclude(*ds_spec.SURVEY_COLS))
    indices = dataset.indices.collect()  # ty: ignore

    corr = Correlation.PARTIAL_GLASSO.calculate(indices, assume_centered=True)  # ty: ignore
    fig = plot_corr_network(indices.drop("participant_id", "wave"), corr, threshold=0.1)  # ty: ignore
    fig.savefig(
        "presentations/april-enlens-talk/figures/partial-correlation-network.pdf",
        bbox_inches="tight",
    )


if __name__ == "__main__":
    main()
