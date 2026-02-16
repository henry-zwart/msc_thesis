import os
import polars as pl
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.axes import Axes
import numpy as np


def draw_tree_recursive(
    root: tuple[float, float],
    branch_length: float,
    leaf_dist: float,
    levels: int,
    ax: Axes,
):
    dx = branch_length
    dy = leaf_dist * 2 ** (levels - 2)

    x, y = root

    ax.plot([x, x, x + dx], [y, y + dy, y + dy], colour="blue", linewidth=1)
    ax.plot(
        [x, x, x + dx], [y, y - dy, y - dy], colour="k", linewidth=1, linestyle="dotted"
    )

    if levels > 1:
        # top tree
        draw_tree_recursive((x + dx, y + dy), branch_length, leaf_dist, levels - 1, ax)
        # bottom tree
        draw_tree_recursive((x + dx, y - dy), branch_length, leaf_dist, levels - 1, ax)


def draw_tree(branch_length: float, leaf_dist: float, levels: int, ax=None):
    ax = ax or plt.gca()

    draw_tree_recursive((0, 0), branch_length, leaf_dist, levels, ax)

    for spine in ax.spines.values():
        spine.set_visible(False)

    ax.set_yticks([])
    ax.set_xticks(
        [level + branch_length / 2 for level in range(levels)],
        labels=[f"W{i}" for i in range(1, levels + 1)],
    )
    ax.tick_params(length=0)


def count_wave_combo_participants(participant):
    # For each combination wave participation options, count occurrences
    all_combinations = (
        pl.DataFrame({"wave_1": [True, False]})
        .join(pl.DataFrame({"wave_2": [True, False]}), how="cross")
        .join(pl.DataFrame({"wave_3": [True, False]}), how="cross")
        .join(pl.DataFrame({"wave_4": [True, False]}), how="cross")
        .join(pl.DataFrame({"wave_5": [True, False]}), how="cross")
    )
    combination_counts = all_combinations.join(
        (
            participant.select(pl.col(r"^wave_\d$"))
            .group_by(pl.all())
            .agg(pl.len().alias("n_participants"))
            .sort(
                by=["wave_1", "wave_2", "wave_3", "wave_4", "wave_5"], descending=True
            )
        ),
        how="left",
        on=["wave_1", "wave_2", "wave_3", "wave_4", "wave_5"],
    ).with_columns(pl.col("n_participants").fill_null(0))
    return combination_counts


def plot_wave_participation(participant):
    # Plot the tree
    fig, ax = plt.subplots(figsize=(6, 7))
    branch_length = 1
    leaf_dist = 1
    levels = 5
    draw_tree(branch_length, leaf_dist, levels, ax)

    # Annotate each path with number of participants
    participant_counts = (
        count_wave_combo_participants(participant)
        .select("n_participants")
        .to_series()
        .to_list()
    )

    # x position is number of levels * branch length, plus a little
    x = levels * branch_length + 0.1
    # y positions evenly spaced (dist 1) on either side of 0, with 2**waves leaves, minus a little
    ys = (
        np.linspace(2 ** (levels - 1) - 0.5, -(2 ** (levels - 1)) + 0.5, 2**levels)
        - 0.3
    )

    for i, (count, y) in enumerate(zip(participant_counts, ys)):
        ax.annotate(f"({31 - i:0>5b}): {count}", (x, y))

    ax.set_xlim(0, levels + 1.5)

    return fig, ax


def main():
    assets = os.getenv("CA_BUILT_ASSETS")
    if assets is None:
        raise RuntimeError(
            "No environment variable `CA_BUILT_ASSETS` found for assets directory."
        )
    else:
        participant = pl.read_parquet(Path(assets) / "participant.parquet")

    fig, ax = plot_wave_participation(participant)
    plt.show()


if __name__ == "__main__":
    main()
