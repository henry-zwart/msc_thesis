from pathlib import Path
from typing import Any

import iplotx as ipx
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import numpy.typing as npt
import seaborn as sns
from ising.model import ModelType
from ising.visualisation import DIVERGING_CMAP2
from matplotlib import cm
from matplotlib.axes import Axes
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from climate_attitudes.visualisation import configure_mpl
from ising import Ising

np.set_printoptions(linewidth=200)

console = Console()


def unpack_model[M: Ising](
    cls: type[M],
    params: npt.NDArray[np.float64],
    labels: list[str],
) -> M:
    h, j = cls.unpack_params(params, k=0)
    return cls(field=h, coupling=j, self_loops=True, rng=0, node_labels=labels)


def draw_network(G: nx.Graph, vlim_h: float, vlim_j: float, layout, ax: Axes):
    ipx_style: dict[str, dict[str, Any]] | list[str | dict[str, dict[str, Any]]] = {
        "vertex": {
            "size": "label",
            "edgecolor": "black",
            "linewidth": 0.5,
            "facecolor": "#FFFFFF",
            # "label": dict(hpadding=23, vpadding=30, color="black", size=8),
            "label": dict(color="black", size=6, hpadding=20),
            "zorder": 7,
            "alpha": 1.0,
        },
        "edge": {
            "alpha": 1,
            "color": "#BBBBBB",
            "zorder": 1,
            "shrink": 7,
            "arrow": {
                "width": 3,
            },
        },
    }
    edge_linewidths = {
        (u, v): np.sqrt(abs(z["j"] * 3)) for u, v, z in G.edges(data=True)
    }

    vmin, vmax = -vlim_h, vlim_h
    node_colour_norm = mcolors.Normalize(vmin=vmin, vmax=vmax)
    ipx_style["vertex"]["facecolor"] = DIVERGING_CMAP2(
        node_colour_norm([z["h"] for _, z in G.nodes(data=True)])
    )

    vmin, vmax = -vlim_j, vlim_j
    ipx_style["edge"]["color"] = [z["j"] for *_, z in G.edges(data=True)]
    # cmap = DIVERGING_CMAP
    cmap = sns.color_palette("RdBu", as_cmap=True)
    ipx_style["edge"]["cmap"] = cmap
    ipx_style["edge"]["norm"] = mcolors.Normalize(vmin=vmin, vmax=vmax)

    vertex_labels = [z["label"] for _, z in G.nodes(data=True)]

    ipx_style = ["hollow", ipx_style]

    network_artist = ipx.network(
        G,
        layout=layout,
        vertex_labels=vertex_labels,
        edge_curved=True,
        edge_linewidth=edge_linewidths,
        margin=0.1,
        style=ipx_style,
        ax=ax,
    )[0]

    return network_artist


class NetworkIdeologyPlotCommand(BaseCommand):
    conservative_model: Path
    liberal_model: Path
    output: Path | None = None
    model_type: ModelType

    seed: int = 202606230923

    def cli_cmd(self) -> None:
        configure_mpl()

        model_cls = self.model_type.get_cls()
        if not issubclass(model_cls, Ising):
            raise ValueError(
                f"Unsupported model_type: '{self.model_type}'. Expected 'ising' "
                f"or 'sym_ising'."
            )

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )
        labels = dataset.schema.get_abbrevs(kind="measurement")
        conservative_model_fit = np.load(self.conservative_model)
        liberal_model_fit = np.load(self.liberal_model)

        # Get column indices, in case only a subset of cols were fit
        col_idxes = conservative_model_fit["col_idxes"]
        labels = [label for i, label in enumerate(labels) if i in col_idxes]

        # Extract interaction effect matrices from params
        conservative_model = unpack_model(
            model_cls,
            conservative_model_fit["params"],
            labels,
        )
        liberal_model = unpack_model(
            model_cls,
            liberal_model_fit["params"],
            labels,
        )

        conservative_model.adj[abs(conservative_model.j) < 5e-2] = False
        conservative_model.j[abs(conservative_model.j) < 5e-2] = 0
        liberal_model.adj[abs(liberal_model.j) < 5e-2] = False
        liberal_model.j[abs(liberal_model.j) < 5e-2] = 0

        # Ignore self-loops
        conservative_model.adj[np.diag_indices_from(conservative_model.adj)] = False
        liberal_model.adj[np.diag_indices_from(liberal_model.adj)] = False

        G_cons = conservative_model.to_networkx()
        G_lib = liberal_model.to_networkx()
        labels = [
            "Real",
            "Human",
            "Worry CC",
            "Oth Worry CC ",
            "Worry W",
            "Impact",
            "Action",
        ]
        for node, label in enumerate(labels):
            G_cons.nodes[node]["label"] = label
            G_lib.nodes[node]["label"] = label

        fig, axes = plt.subplots(ncols=2, figsize=(5.77, 2.5), constrained_layout=True)
        # ax.set_aspect("equal")

        layout = nx.spring_layout(
            G_cons,
            weight=None,
            k=3,
            seed=self.seed,
        )

        draw_network(G_cons, 0.5, 0.5, layout, axes[0])
        artist = draw_network(G_lib, 0.5, 0.5, layout, axes[1])

        edge_cbar = fig.colorbar(
            artist.get_edges(),
            shrink=0.8,
            aspect=30,
            ax=axes[1],
        )
        vmin, vmax = artist.get_edges().get_clim()
        edge_cbar.set_ticks(
            [
                np.round(vmin, 2),
                0.0,
                np.round(vmax, 2),
            ]
        )
        edge_cbar.ax.set_title(r"$J$", pad=5)
        edge_cbar.ax.tick_params(
            which="both",
            length=0,
            pad=5,
        )

        node_colour_norm = mcolors.Normalize(vmin=-0.5, vmax=0.5)
        vertex_cbar = fig.colorbar(
            cm.ScalarMappable(norm=node_colour_norm, cmap=DIVERGING_CMAP2),
            shrink=0.8,
            aspect=30,
            ax=axes[1],
        )
        if node_colour_norm.vmin is None or node_colour_norm.vmax is None:
            raise RuntimeError("This shouldn't happen")
        vertex_cbar.set_ticks([])
        # vertex_cbar.set_ticks(
        #     [
        #         0.0,
        #         np.round(node_colour_norm.vmax, 2),
        #     ]
        # )
        vertex_cbar.ax.set_title(r"$h$", pad=5)
        # vertex_cbar.ax.tick_params(
        #     which="both",
        #     length=0,
        #     pad=1,
        # )

        axes[0].set_title("Conservative")
        axes[1].set_title("Liberal")

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
            fig.savefig(str(self.output).replace(".pdf", ".png"), bbox_inches="tight")
        else:
            plt.show()
