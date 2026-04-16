"""Estimate data requirements to fit symmetric discrete spin model.

Investigates how the number of samples required to reach a given level of model fit
vary with the size of a discrete spin model (number of spins), or its structure
(parameter intensity, structure of couplings).
"""

import itertools
from concurrent.futures import ProcessPoolExecutor, as_completed
from dataclasses import dataclass

import numpy as np
import numpy.typing as npt
import polars as pl
from ising.evaluation import round_trip
from ising.model import Ising
from tqdm import tqdm


@dataclass
class RoundTripRunResult:
    run_id: int
    n: int
    dataset_size: int
    repeat: int
    h_intensity: int | float
    j_intensity: int | float
    bic: int | float
    max_prob_dist: float
    max_param_dist: float
    relative_entropy: float
    log_likelihood: float


def sample_field_terms(
    n: int, intensity: float, rng: np.random.Generator
) -> npt.NDArray[np.float64]:
    """Sample local field parameters with specified intensity.

    Currently just samples values from [-1,1] interval, and multiplies by
    the intensity value.

    Args:
        n: Model size (number of spins).
        intensity: Controls magnitude of local field parameter values.
        rng: Numpy random number generator.

    Returns:
        1D Numpy array of local field parameter values.
    """
    return (2 * rng.random(n) - 1) * intensity


def sample_interaction_terms(
    n: int, intensity: float, rng: np.random.Generator
) -> npt.NDArray[np.float64]:
    """Sample interactions parameters with specified intensity.

    Currently just samples values from [-1,1] interval, and multiplies by
    the intensity value.

    Args:
        n: Model size (number of spins).
        intensity: Controls magnitude of interaction parameter values.
        rng: Numpy random number generator.

    Returns:
        2D Numpy array of interaction parameter values, in upper triangular
        form.
    """
    j = (2 * rng.random((n, n)) - 1) * intensity
    return np.triu(j, k=1)


def run_one_round_trip(args):
    run_id, n, h_intensity, j_intensity, dataset_size, repeat = args
    rng = np.random.default_rng(202604151116 + run_id)
    h = sample_field_terms(n, h_intensity, rng)
    j = sample_interaction_terms(n, j_intensity, rng)
    base_model = Ising(n=n, field=h, coupling=j)
    base_model.rng = rng
    round_trip_res = round_trip(base_model, dataset_size)
    result = RoundTripRunResult(
        run_id,
        n,
        dataset_size,
        repeat,
        h_intensity,
        j_intensity,
        round_trip_res.fit_metrics.bic,
        round_trip_res.fit_metrics.max_probability_dist,
        round_trip_res.fit_metrics.max_param_dist,
        round_trip_res.fit_metrics.relative_entropy,
        round_trip_res.fit_metrics.log_likelihood,
    )
    return result


def main():
    PARALLEL = True

    # N: npt.NDArray[np.int64] = np.arange(2, 10, 2, dtype=np.int64)
    N: npt.NDArray[np.int64] = np.array([3, 6, 9], dtype=np.int64)
    INTENSITY: npt.NDArray[np.float64] = np.array([0.0, 0.25, 1.0])

    SAMPLES: npt.NDArray[np.int64] = np.arange(500, 9000, 1000, dtype=np.int64)

    REPEATS: int = 15

    # Skip h_intensity = j_intensity = 0
    run_params = filter(
        lambda params: not np.isclose(max(params[1:3]), 0),
        itertools.product(N, INTENSITY, INTENSITY, SAMPLES, range(REPEATS)),
    )
    run_params = itertools.product(N, INTENSITY, INTENSITY, SAMPLES, range(REPEATS))

    results = dict(
        run_id=[],
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

    if PARALLEL:
        with ProcessPoolExecutor() as executor:
            futures = []
            for run_id, params in enumerate(run_params):
                futures.append(
                    executor.submit(
                        run_one_round_trip,
                        (run_id,) + params,
                    )
                )

            desc = "Running analysis: round-trip data requirements"
            for ft in tqdm(as_completed(futures), desc=desc, total=len(futures)):
                res = ft.result()
                results["run_id"].append(res.run_id)
                results["n"].append(res.n)
                results["samples"].append(res.dataset_size)
                results["repeat"].append(res.repeat)
                results["h_intensity"].append(res.h_intensity)
                results["j_intensity"].append(res.j_intensity)
                results["bic"].append(res.bic)
                results["max_prob_dist"].append(res.max_prob_dist)
                results["max_param_dist"].append(res.max_param_dist)
                results["relative_entropy"].append(res.relative_entropy)
                results["log_likelihood"].append(res.log_likelihood)
    else:
        for run_id, params in enumerate(
            tqdm(
                run_params,
                total=REPEATS * len(N) * len(SAMPLES) * len(INTENSITY) * len(INTENSITY),
            )
        ):
            try:
                res = run_one_round_trip((run_id,) + params)
            except:
                print(params)
                raise
            results["run_id"].append(res.run_id)
            results["n"].append(res.n)
            results["samples"].append(res.dataset_size)
            results["repeat"].append(res.repeat)
            results["h_intensity"].append(res.h_intensity)
            results["j_intensity"].append(res.j_intensity)
            results["bic"].append(res.bic)
            results["max_prob_dist"].append(res.max_prob_dist)
            results["max_param_dist"].append(res.max_param_dist)
            results["relative_entropy"].append(res.relative_entropy)
            results["log_likelihood"].append(res.log_likelihood)

    pl.DataFrame(results).write_parquet("results/data/round_trip.parquet")


if __name__ == "__main__":
    main()
