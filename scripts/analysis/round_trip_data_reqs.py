"""Estimate data requirements to fit symmetric discrete spin model.

Investigates how the number of samples required to reach a given level of model fit
vary with the size of a discrete spin model (number of spins), or its structure
(parameter intensity, structure of couplings).
"""

import itertools

import numpy as np
import numpy.typing as npt
import polars as pl
from ising.evaluation import round_trip
from ising.model import Ising
from tqdm import tqdm


def sample_field_terms(
    n: int, intensity: float, rng: np.random.Generator
) -> npt.NDArray[np.float64]:
    """Sample local field parameters with specified intensity.

    Currently just samples values from [0,1] interval, and multiplies by
    the intensity value.

    Args:
        n: Model size (number of spins).
        intensity: Controls magnitude of local field parameter values.
        rng: Numpy random number generator.

    Returns:
        1D Numpy array of local field parameter values.
    """
    return rng.random(n) * intensity


def sample_interaction_terms(
    n: int, intensity: float, rng: np.random.Generator
) -> npt.NDArray[np.float64]:
    """Sample interactions parameters with specified intensity.

    Currently just samples values from [0,1] interval, and multiplies by
    the intensity value.

    Args:
        n: Model size (number of spins).
        intensity: Controls magnitude of interaction parameter values.
        rng: Numpy random number generator.

    Returns:
        2D Numpy array of interaction parameter values, in upper triangular
        form.
    """
    j = rng.random((n, n)) * intensity
    return np.triu(j, k=1)


def main():
    N: npt.NDArray[np.int64] = np.arange(2, 8, 2, dtype=np.int64)
    INTENSITY: npt.NDArray[np.float64] = np.array([0.25, 1.0])
    # INTENSITY: npt.NDArray[np.float64] = np.linspace(0.2, 1.0, 9, endpoint=True)

    SAMPLES: npt.NDArray[np.int64] = np.arange(500, 3000, 1000, dtype=np.int64)

    REPEATS: int = 10

    rng = np.random.default_rng(202604131628)

    exp_configs = itertools.product(N, INTENSITY, INTENSITY, SAMPLES, range(REPEATS))

    results = dict(
        n=[],
        samples=[],
        repeat=[],
        h_intensity=[],
        j_intensity=[],
        bic=[],
        max_prob_dist=[],
        max_param_dist=[],
        relative_entropy=[],
        log_likelihood=[],
    )

    n_iters = len(N) * len(INTENSITY) * len(INTENSITY) * len(SAMPLES) * REPEATS
    for n, h_intensity, j_intensity, dataset_size, repeat in tqdm(
        exp_configs, total=n_iters
    ):
        h = sample_field_terms(n, h_intensity, rng)
        j = sample_interaction_terms(n, j_intensity, rng)
        round_trip_res = round_trip(
            Ising(n=n, field=h, coupling=j),
            dataset_size,
            glauber_kwargs=dict(tol=1e-2, iter_steps=10_000),
        )

        results["n"].append(n)
        results["samples"].append(dataset_size)
        results["repeat"].append(repeat)
        results["h_intensity"].append(h_intensity)
        results["j_intensity"].append(j_intensity)
        results["bic"].append(round_trip_res.fit_metrics.bic)
        results["max_prob_dist"].append(round_trip_res.fit_metrics.max_probability_dist)
        results["max_param_dist"].append(round_trip_res.fit_metrics.max_param_dist)
        results["relative_entropy"].append(round_trip_res.fit_metrics.relative_entropy)
        results["log_likelihood"].append(round_trip_res.fit_metrics.log_likelihood)

    pl.DataFrame(results).write_parquet("results/data/round_trip.parquet")


if __name__ == "__main__":
    main()
