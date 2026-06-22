from pathlib import Path

import iplotx as ipx
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import numpy.typing as npt
import polars as pl
import scipy as sp
import seaborn as sns
from matplotlib import font_manager
from matplotlib.axes import Axes

from climate_attitudes.correlation import Correlation
from climate_attitudes.feature_clustering import LinkageMethod, features_linkage

DIVERGING_CMAP = sns.diverging_palette(20, 230, s=85, as_cmap=True)

# Colour-blind safe; from https://sronpersonalpages.nl/~pault/
QUALITATIVE_SCHEME = mcolors.ListedColormap(
    [
        "#4477aa",  # blue
        "#66ccee",  # cyan
        "#228833",  # green
        "#ccbb44",  # yellow
        "#ee6677",  # red
        "#aa3377",  # purple
        "#bbbbbb",  # grey
    ]
)


def configure_mpl(fonts_path: Path = Path("fonts")):
    """Configure Matplotlib style."""
    FONT_SIZES = {
        "paper": (8, 10),
        "thesis": (10, 12),
    }
    FONT_SIZE_SMALL, FONT_SIZE_DEFAULT = FONT_SIZES["thesis"]
    font_manager.fontManager.addfont(fonts_path / "LibertinusSerif-Regular.otf")
    font_manager.fontManager.addfont(fonts_path / "LibertinusSerif-Bold.otf")
    font_manager.fontManager.addfont(fonts_path / "LibertinusSerif-Semibold.otf")
    font_manager.fontManager.addfont(fonts_path / "LibertinusSerif-BoldItalic.otf")
    font_manager.fontManager.addfont(fonts_path / "LibertinusSerif-Italic.otf")

    plt.rc("font", family="Libertinus Serif")
    plt.rc("font", weight="normal")  # controls default font
    plt.rc("mathtext", fontset="stix")
    plt.rc("font", size=FONT_SIZE_DEFAULT)  # controls default text sizes
    plt.rc("axes", titlesize=FONT_SIZE_DEFAULT)  # fontsize of the axes title
    plt.rc("axes", labelsize=FONT_SIZE_DEFAULT)  # fontsize of the x and y labels
    plt.rc("figure", labelsize=FONT_SIZE_DEFAULT)
    plt.rc("figure", dpi=200)

    sns.set_context(
        "paper",
        rc={
            "axes.linewidth": 0.5,
            "font.size": 8,
            "axes.labelsize": FONT_SIZE_DEFAULT,
            "axes.titlesize": FONT_SIZE_DEFAULT,
            "xtick.major.width": 0.5,
            "ytick.major.width": 0.5,
            "ytick.minor.width": 0.4,
            "xtick.labelsize": FONT_SIZE_SMALL,
            "ytick.labelsize": FONT_SIZE_SMALL,
        },
    )


def plot_transition_matrix(
    R: npt.NDArray[np.float64],
    node_labels: list[str | int] | None = None,
    edge_threshold: float = 0.01,
    ax: Axes | None = None,
) -> Axes:
    if ax is None:
        ax = plt.gca()

    R = R.copy()

    # Set near-zero edges to zero
    R[abs(R) < edge_threshold] = 0.0

    G = nx.from_numpy_array(R, create_using=nx.DiGraph)
    layout = nx.circular_layout(G)

    edge_linewidths = {(u, v): z["weight"] for u, v, z in G.edges(data=True)}
    edge_labels = [f"{z['weight']:.2f}" for u, v, z in G.edges(data=True)]

    node_labels = node_labels or np.arange(R.shape[0])

    with ipx.style.context(["hollow", {"vertex": {"linewidth": 1}}]):
        ipx.network(
            G,
            layout=layout,
            node_labels=node_labels,
            edge_linewidth=edge_linewidths,
            edge_labels=edge_labels,
            edge_curved=True,
            margins=0.1,
            aspect="equal",
            edge_label_bbox=dict(
                edgecolor="black",
                facecolor="white",
                linewidth=0.25,
                boxstyle="round,pad=0.3",
            ),
            edge_label_rotate=True,
            ax=ax,
        )

    return ax


def plot_corr_network(
    df: pl.DataFrame,
    kind: Correlation = Correlation.PEARSON,
    mask_below: float | None = None,
):
    fig, ax = plt.subplots(figsize=(15, 15), constrained_layout=True)

    corr = kind.calculate(df)

    # Generate a mask for the upper triangle
    mask = np.triu(np.ones_like(corr, dtype=bool), k=1)

    # If `mask_below` set, reset square colour below abs value to zero
    if mask_below:
        mask[abs(corr) < mask_below] = True

    # Remove questions where only diagonal is unmasked
    keep_idxes = (2 * mask.shape[1] - (mask.sum(axis=1) + mask.sum(axis=0))) > 2
    corr = corr[keep_idxes][:, keep_idxes]
    mask = mask[keep_idxes][:, keep_idxes]
    node_labels = np.asarray(df.columns)[keep_idxes]

    # ======== Network
    adj = corr
    adj[np.diag_indices_from(adj)] = 0
    adj[mask] = 0
    G = nx.from_numpy_array(adj)
    edge_linewidths = {(u, v): z["weight"] * 4 for u, v, z in G.edges(data=True)}
    edge_colours = [z["weight"] for u, v, z in G.edges(data=True)]
    edge_labels = [f"{z['weight']:.2f}" for u, v, z in G.edges(data=True)]
    layout = nx.forceatlas2_layout(G, gravity=2)

    with ipx.style.context(
        [
            "hollow",
            {
                "vertex": {
                    "linewidth": 1,
                },
                "edge": {
                    "color": edge_colours,
                    "alpha": 1,
                    "cmap": DIVERGING_CMAP,
                    "norm": mcolors.Normalize(vmin=-1, vmax=1),
                },
            },
        ]
    ):
        network_artist = ipx.network(
            G,
            layout=layout,
            tension=1,
            edge_labels=edge_labels,
            node_labels=node_labels,
            edge_linewidth=edge_linewidths,
            edge_curved=True,
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
            ax=ax,
        )[0]
        fig.colorbar(
            network_artist.get_edges(),
            shrink=0.6,
            aspect=30,
            ax=ax,
        )

    fig.suptitle("Partial correlation")


def plot_corr(
    df: pl.DataFrame,
    kind: Correlation = Correlation.PEARSON,
    mask_below: float | None = None,
    mask_above: float | None = None,
    only_lower: bool = True,
    fmt: str = ".1f",
    ax: Axes | None = None,
):
    ax = ax or plt.gca()

    corr = kind.calculate(df)

    # Remove survey metadata columns
    found_cols = []
    for col in ("wave", "participant_id"):
        if col in df.columns:
            found_cols.append(col)
    if found_cols:
        df = df.clone().drop(*found_cols)

    # Generate a mask for the upper triangle
    if only_lower:
        mask = np.triu(np.ones_like(corr, dtype=bool), k=1)
    else:
        mask = np.full_like(corr, fill_value=False, dtype=bool)

    # If `mask_below` set, reset square colour below abs value to zero
    if mask_below:
        mask[abs(corr) < mask_below] = True
    if mask_above:
        mask[abs(corr) >= mask_above] = True
        mask[np.diag_indices_from(mask)] = False
    if mask_below and mask_above and mask_below >= mask_above:
        raise ValueError(
            f"mask_above should be greater than mask_below: {mask_above} < {mask_below}"
        )

    # Remove questions where only diagonal is unmasked
    keep_idxes = (2 * mask.shape[1] - (mask.sum(axis=1) + mask.sum(axis=0))) > 2
    corr = corr[keep_idxes][:, keep_idxes]
    mask = mask[keep_idxes][:, keep_idxes]
    labels = np.asarray(df.columns)[keep_idxes]

    # Draw the heatmap with the mask and correct aspect ratio
    sns.heatmap(
        corr,
        mask=mask,
        cmap=DIVERGING_CMAP,
        fmt=fmt,
        annot=True,
        center=0,
        square=True,
        linewidths=0.5,
        cbar_kws={"shrink": 0.8, "aspect": 30},
        ax=ax,
    )

    # labels = df.columns
    ax.set_xticks(
        np.arange(len(labels)) + 0.5,
        labels=labels,
        rotation=35,
        horizontalalignment="right",
    )

    ax.set_yticks(np.arange(len(labels)) + 0.5, labels=labels, rotation=0)

    title = f"Pairwise {str(kind)}"
    ax.set_title(title)
    return corr, labels


def plot_corr_with_dendro(
    df: pl.DataFrame,
    kind: Correlation = Correlation.PEARSON,
    dendro_method: str = "ward",
    x_categories: list[str] | npt.NDArray[np.str_] | None = None,
    y_categories: list[str] | npt.NDArray[np.str_] | None = None,
    y_vars: list[str] | None = None,
    figsize: tuple[int, int] | tuple[float, float] | None = None,
    no_cbar: bool = False,
    row_cluster: bool = False,
    regularised: bool = False,
):
    corr = kind.calculate(df, regularised=regularised)

    # Remove survey metadata columns
    found_cols = []
    for col in ("wave", "participant_id"):
        if col in df.columns:
            found_cols.append(col)
    if found_cols:
        df = df.clone().drop(*found_cols)

    x_labels = np.asarray(df.columns)
    y_labels = np.asarray(df.columns)

    # If y_vars specified, select the required rows
    if y_vars is None or (isinstance(y_vars, np.ndarray) and y_vars.size == 0):
        keep_idxes = np.arange(len(y_labels))
    else:
        keep_idxes: npt.NDArray[np.int64] = np.asarray(
            [i for i, label in enumerate(y_labels) if label in y_vars]
        )
        if len(keep_idxes) != len(y_vars):
            raise RuntimeError("Could not find one or more y_var columns in df.")

    corr = corr[keep_idxes]
    y_labels = y_labels[keep_idxes]

    if x_categories is not None:
        x_categories = np.asarray(x_categories)
    if y_categories is not None:
        y_categories = np.asarray(y_categories)[keep_idxes]

    # Determine figure size if not specified.
    # - Each cell needs ~0.25
    # - Labels need ~0.5
    # cell_length = 0.25
    # label_length = 0.5
    cell_length = 0.125
    label_length = 0.25
    if figsize is None:
        height = corr.shape[0] * cell_length + label_length
        width = corr.shape[1] * cell_length + label_length
        figsize = (width, height)

    category_pal = sns.husl_palette(5, s=0.45)
    category_lut = dict(
        zip(
            map(
                str,
                [
                    "Belief",
                    "Attitude",
                    "Behaviour",
                    "Demographic",
                    "External factor",
                ],
            ),
            category_pal,
            strict=True,
        )
    )
    if x_categories is not None:
        x_category_colours = np.asarray([category_lut[c] for c in x_categories])
    else:
        x_category_colours = None
    if y_categories is not None:
        y_category_colours = np.asarray([category_lut[c] for c in y_categories])
    else:
        y_category_colours = None

    mask = abs(corr) < 0.01 if kind == Correlation.PARTIAL_GLASSO else None
    mask = None

    if not row_cluster:
        cm = sns.clustermap(corr, method=dendro_method, row_cluster=False)
        col_order = cm.dendrogram_col.reordered_ind
        ordered_cols = x_labels[col_order]
        row_order = [i for i, label in enumerate(y_labels) if label in ordered_cols]
        row_order = sorted(
            row_order, key=lambda i: np.where(ordered_cols == y_labels[i])[0][0]
        )
        plt.close(cm.fig)
        corr = corr[row_order]
        y_labels = y_labels[row_order]
        if y_category_colours is not None:
            y_category_colours = y_category_colours[row_order]

    if no_cbar:
        g = sns.clustermap(
            corr,
            mask=mask,
            center=0,
            cmap=DIVERGING_CMAP,
            row_colors=y_category_colours,
            col_colors=x_category_colours,
            vmin=-1,
            vmax=1,
            method=dendro_method,
            dendrogram_ratio=(0.1, 0.2),
            cbar_pos=None,
            # linewidths=0.75,
            linewidths=0.35,
            figsize=figsize,
            fmt=".1f",
            annot=True,
            row_cluster=row_cluster,
            annot_kws={"size": 3.5},
            tree_kws={"linewidths": 0.25},
        )
    else:
        g = sns.clustermap(
            corr,
            mask=mask,
            center=0,
            cmap=DIVERGING_CMAP,
            row_colors=y_category_colours,
            col_colors=x_category_colours,
            vmin=-1,
            vmax=1,
            method=dendro_method,
            dendrogram_ratio=(0.1, 0.2),
            cbar_pos=(-0.1, 0.32, 0.03, 0.2),
            linewidths=0.75,
            figsize=figsize,
            fmt=".1f",
            annot=True,
            row_cluster=row_cluster,
        )

    x_labels = x_labels[g.dendrogram_col.reordered_ind]
    y_labels = y_labels[g.dendrogram_row.reordered_ind] if row_cluster else y_labels

    g.ax_heatmap.set_xticks(
        np.arange(len(x_labels)) + 0.5,
        x_labels,
        rotation=45,
        horizontalalignment="right",
    )
    g.ax_heatmap.set_yticks(np.arange(len(y_labels)) + 0.5, y_labels, rotation=0)
    g.ax_heatmap.tick_params(axis="both", labelsize=4, width=0.25, length=1)

    if y_vars is None and row_cluster:
        g.ax_row_dendrogram.remove()


def plot_feature_dendro(
    df: pl.DataFrame,
    method: LinkageMethod = LinkageMethod.SINGLE,
    ax: Axes | None = None,
):
    ax = ax or plt.gca()

    X = df.to_numpy()
    linkage_mat = features_linkage(X, method=method)
    sp.cluster.hierarchy.dendrogram(
        linkage_mat,
        labels=df.columns,
        orientation="right",
        ax=ax,
        leaf_font_size=4,
    )
    plt.setp(ax.collections, linewidth=0.5)

    ax.set_xticks([])

    for spine in ax.spines.values():
        spine.set_visible(False)
