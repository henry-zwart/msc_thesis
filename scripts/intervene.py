from functools import partial

import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import polars as pl
from ising.model import FitMethod

from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.settings import Config
from climate_attitudes.visualisation import configure_mpl
from ising import Ising

np.set_printoptions(linewidth=200)

RANDOM_SEED = 202604272006


def s_i(_model: Ising, y: npt.NDArray[np.int64], i: int) -> np.int64:
    return y[i]


def main(indices: pl.DataFrame):
    n_participants = indices.select(pl.col("participant_id").unique()).shape[0]
    n_waves = indices.select(pl.col("wave").unique()).shape[0]
    n_cols = len(indices.columns) - 6

    # Extract dataset into (participant, wave, question) form
    y = (
        indices.sort(by=("participant_id", "wave"))
        .drop("participant_id", "wave", *ds_spec.DEMOGRAPHIC_COLS)
        .to_numpy()
        .ravel()
        .reshape((n_participants, n_waves, n_cols))
    )

    # Binarise data.
    y[y < -0.1] = -1
    y[y > 0.1] = 1

    # Set zeros to -1 or +1 uniformly
    rng = np.random.default_rng(RANDOM_SEED)
    random_assignments = rng.choice((-1, 1), size=y.size).reshape(
        (n_participants, n_waves, n_cols)
    )
    random_assignment_idxes = (y >= -0.1) & (y <= 0.1)
    y[random_assignment_idxes] = random_assignments[random_assignment_idxes]
    y = y.astype(np.int64)

    node_labels = np.array(
        [ds_spec.RENAME.get(colname, colname) for colname in indices.columns[6:]],
        dtype=np.str_,
    )

    model = Ising.fit(
        y,
        method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=RANDOM_SEED,
        self_loops=True,
    )

    model.reset(RANDOM_SEED + 1)
    T = 50
    f = partial(s_i, i=1)
    outcome = model.measure(f, y0=y[:, -1, :], t=T, repeats=30, warmup_steps=0)
    mean_outcome = outcome.mean(axis=(0, 1))

    _, axes = plt.subplots(nrows=2, figsize=(3, 4), constrained_layout=True)
    ts = np.arange(T)
    axes[0].plot(ts, mean_outcome, label="No intervention")

    for delta in (0.5, 1.0):
        model.reset(RANDOM_SEED + 1)
        imodel = model.intervene(
            spins=np.array(["Weather worry"]),
            field_offset=np.array([delta]),
            seed=RANDOM_SEED,
        )
        imodel.reset(RANDOM_SEED + 1)

        ioutcome = imodel.measure(f, y0=y[:, -1, :], t=T, repeats=30, warmup_steps=0)

        mean_ioutcome = ioutcome.mean(axis=(0, 1))

        axes[0].plot(ts, mean_ioutcome, label=f"$h_{{\\text{{w.worry}}}} + {delta}$")
        axes[1].plot(ts, (ioutcome - outcome).mean(axis=(0, 1)))

    axes[0].axhline(0, linestyle="dashed", linewidth=0.5)
    axes[0].set_xlim(0, T)
    axes[0].set_ylim(-1.1, 1.1)
    axes[0].spines["top"].set_visible(False)
    axes[0].spines["right"].set_visible(False)
    axes[0].set_xlabel("Time")
    axes[0].set_ylabel(r"$\langle s_{\text{cc.anthro}}\rangle$")

    axes[0].legend()

    axes[1].axhline(0, linestyle="dashed", linewidth=0.5)
    axes[1].set_xlim(0, T)
    axes[1].set_ylim(-1.1, 1.1)
    axes[1].spines["top"].set_visible(False)
    axes[1].spines["right"].set_visible(False)
    axes[1].set_xlabel("Time")
    axes[1].set_ylabel(r"$\langle s^i_5 - s_5\rangle$")

    plt.show()

    imodel.adj[abs(imodel.j) < 0.15] = False
    imodel.j[abs(imodel.j) < 0.15] = 0.0
    imodel.draw()
    plt.show()


if __name__ == "__main__":
    configure_mpl()
    config = Config(_env_file=".env")
    dataset = Dataset.load(config, name="reduced_no_imputation", with_imputation=False)
    indices = (
        dataset.indices.collect()  # ty: ignore
    )
    main(indices)  # ty: ignore
