import iplotx as ipx
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
import polars as pl

from climate_attitudes.dataset import Dataset
from climate_attitudes.settings import Config


def main():
    config = Config(_env_file="../../.env")

    data = Dataset.load(config)

    pids = (
        data.participant.filter(wave_1=True, wave_2=True)
        .select("participant_id")
        .collect()
        .to_series()
        .implode()
    )

    resp = (
        data.response.filter(pl.col("wave") <= 2, pl.col("participant_id").is_in(pids))
        .select(
            "participant_id",
            pl.col("wave").replace_strict({1: "wave_1", 2: "wave_2"}),
            pl.col("cc1").replace_strict({0: "No", 1: "Yes", 99: "Maybe"}),
            "cvcc4_should",
            pl.col("cc5_world").replace(99, 0),
            "cc6",
        )
        .with_columns(pl.len().over("participant_id").alias("n_waves"))
        .filter(n_waves=2)
        .collect()
    )

    columns = {
        "Climate change happening": {
            "colname": "cc1",
            "responses": ["No", "Maybe", "Yes"],
        },
        "Climate change anthropogenic ('people should act')": {
            "colname": "cvcc4_should",
            "responses": [
                "Strongly disagree",
                "Disagree",
                "Neither agree nor disagree",
                "Agree",
                "Strongly agree",
            ],
        },
        "Climate change worry": {
            "colname": "cc6",
            "responses": [
                "Not at all worried",
                "Not very worried",
                "Somewhat worried",
                "Very worried",
            ],
        },
        "Future generation harm": {
            "colname": "cc5_world",
            "responses": [
                "Don't know",
                "Not at all",
                "Only a little",
                "A moderate amount",
                "A great deal",
            ],
        },
    }

    fig, axes = plt.subplots(
        nrows=2, ncols=2, figsize=(14, 12), constrained_layout=True
    )

    pos = {
        "Climate change happening": np.array([[0, 0], [0.5, 0.87], [1, 0]]),
        "Climate change anthropogenic ('people should act')": np.array(
            [[1, 1], [0, 1], [0.5, 0.5], [0, 0], [1, 0]]
        ),
        "Climate change worry": np.array([[1, 0], [0, 0], [0, 1], [1, 1]]),
        "Future generation harm": np.array(
            [[0, 0], [1, 0], [1, 0.5], [0, 0.5], [0, 1]]
        ),
        # "Future generation harm":
        # np.array([[0.7, 0], [0, 0.45], [0, 1], [1.1, 1], [0.5, 1.5]])
    }

    for i, (dimension, dimension_metadata) in enumerate(columns.items()):
        ax = axes[i // 2, i % 2]
        colname = dimension_metadata["colname"]
        responses = dimension_metadata["responses"]

        transition_probabilities = (
            resp.pivot("wave", index="participant_id", values=colname)
            .sort(by=("wave_1", "wave_2"))
            .group_by("wave_1", "wave_2", maintain_order=True)
            .agg(pl.len().alias("count"))
            .with_columns(
                (pl.col("count") / pl.col("count").sum())
                .over("wave_1")
                .alias("transition_prob")
            )
            .pivot("wave_2", index="wave_1", values="transition_prob")
            .drop("wave_1")
            .to_numpy()
        )

        if dimension_metadata["colname"].startswith("cc5_"):
            transition_probabilities = np.hstack(
                (np.zeros(5)[:, None], transition_probabilities)
            )

        # Calculate stationary distribution
        A = np.vstack(
            (
                (
                    transition_probabilities - np.eye(transition_probabilities.shape[0])
                ).T,
                np.ones(transition_probabilities.shape[0])[None, :],
            )
        )
        b = np.zeros(transition_probabilities.shape[0] + 1)
        b[-1] = 1
        mu = np.linalg.lstsq(A, b)[0]

        transition_probabilities[transition_probabilities < 0.05] = 0

        G = nx.from_numpy_array(transition_probabilities, create_using=nx.DiGraph)
        edge_linewidth = {(u, v): 2.0 * z["weight"] for u, v, z in G.edges(data=True)}
        edge_labels = [
            f"{z['weight']:.2f}" if z["weight"] > 0.15 else None
            for u, v, z in G.edges(data=True)
        ]

        layout = pos[dimension] if dimension in pos else nx.spring_layout(G, k=1)

        with ipx.style.context(
            [
                "hollow",
                {
                    "vertex": {
                        "facecolor": mu,
                        "cmap": "Blues",
                        "alpha": 0.5,
                    },
                    "edge": {
                        "looptension": 2,
                        "loopmaxangle": 10,
                    },
                },
            ]
        ):
            network_artist = ipx.network(
                G,
                layout=layout,
                tension=1,
                edge_labels=edge_labels,
                node_labels=responses,
                edge_linewidth=edge_linewidth,
                edge_curved=True,
                aspect="equal",
                edge_label_bbox=dict(
                    edgecolor="black",
                    facecolor="white",
                    boxstyle="round,pad=0.2",
                ),
                edge_label_rotate=False,
                ax=ax,
            )[0]

            # network_artist.get_nodes().set(norm=mcolors.Normalise(0,1))

        plt.colorbar(network_artist.get_vertices(), ax=ax)

        ax.set_title(dimension)

    fig.savefig("figures/lee_transitions.pdf", dpi=300, bbox_inches="tight")


if __name__ == "__main__":
    main()
