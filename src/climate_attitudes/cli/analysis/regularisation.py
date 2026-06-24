import itertools
import json
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path
from typing import Literal

import numpy as np
import numpy.typing as npt
import polars as pl
from ising.model import FitMethod, ModelType, UpdateMethod
from tqdm import tqdm

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from ising import Ising

type SpinData = npt.NDArray[np.int64]
type CovariateData = npt.NDArray[np.float64]
type Differentials = npt.NDArray[np.float64]
type InteractionEffects = npt.NDArray[np.float64]

Γ = 0.25


def fit_model[M: Ising](
    cls: type[M],
    repeat: int,
    λ_i: int,
    λ: float,
    seed: np.int64,
    Y: SpinData,
    adj: npt.NDArray[np.bool] | None = None,
) -> tuple[tuple[int, int], M]:
    """Fit Ising model to data.

    Args:
        cls: Model type.
        repeat: Repeat number.
        λ_i: Identifier of regularisation strength.
        λ: Regularisation strength.
        seed: Random seed used to sample bootstrap dataset. `seed` + 1 is used for
            the fit model.
        Y: Observed spin states. 3D Numpy array with shape (individual, time, spin).
        X: Optional covariate data. 3D Numpy array with shape (individual, time, spin).
            If provided, baseline activations are fit as linear functions of
            individual-level covariates.
        adj: Optional adjacency matrix.

    Returns:
        Tuple containing `iden` and the fit model.
    """
    rng = np.random.default_rng(seed)
    model = cls.fit(
        y=Y,
        optim_method=FitMethod.TIME_SERIES,
        update_method=UpdateMethod.SYNCHRONOUS,
        rng=rng,
        adj=adj,
        self_loops=True,
        w=λ,
    )
    return (repeat, λ_i), model


def test_regularisation_model_fit[M: Ising](
    cls: type[M],
    dataset: Dataset,
    keep_idxes: list[int],
    λ_min: float,
    λ_max: float,
    n: int,
    repeats: int,
    non_zero_threshold: float,
    rng: np.random.Generator,
    adj: npt.NDArray[np.bool] | None = None,
    sigma: float = 0.1,
    replicates: int = 1,
    binarisation_kind: Literal["gaussian", "triangular"] = "gaussian",
    quiet: bool = False,
):
    """Fit models with varying regularisation strength. Return EBIC results.

    Args:
        cls: Model type.
        dataset: Climate beliefs dataset.
        keep_idxes: List of spin indexes to keep from Y datasets.
        λ_min: Minimum regularisation strength.
        λ_max: Maximum regularisation strength.
        n: Number of regularisation strengths to test.
        repeats: Number of bootstrapped datasets to sample.
        non_zero_threshold: Parameters with absolute value below threshold are
            considered zero.
        rng: Numpy RNG.
        sigma: Standard deviation on perturbation in binarisation.
        replicates: Number of replicated binarisations to use for each data point.
        binarisation_kind: Type of distribution to use for binarisation.
        adj: Optional adjacency matrix.
    """
    pids_full, Y_mock, _ = dataset.indices_to_numpy(
        kind="time-series",
        binarise=True,
        seed=rng,
    )
    Y_mock = Y_mock[..., keep_idxes]

    # sample_idxes = rng.choice(np.arange(m), size=(repeats, m), replace=True)
    # pids = np.empty((repeats, Y_mock.shape[0]), dtype=np.int64)
    # pids = pids_full[sample_idxes]
    Y = np.empty(
        (repeats, replicates * Y_mock.shape[0], *Y_mock.shape[1:]), dtype=np.int64
    )

    # Draw bootstrap samples
    for r in range(repeats):
        _, Y_full, _ = dataset.indices_to_numpy(
            kind="time-series",
            binarise=True,
            scale=sigma,
            seed=rng,
            binarisation_dist=binarisation_kind,
            replicates=replicates,
        )

        Y[r] = Y_full[..., keep_idxes]

    seeds = rng.integers(0, 2**32, size=repeats)

    λs = np.logspace(λ_min, λ_max, n, endpoint=True)
    ebic = np.empty((repeats, n), dtype=np.float64)
    X_mock = np.ones((Y.shape[1], Y.shape[2]), dtype=np.float64)
    with ProcessPoolExecutor() as executor:
        futures = []
        for r, λ_i in itertools.product(range(repeats), range(n)):
            futures.append(
                executor.submit(
                    fit_model,
                    cls=cls,
                    repeat=r,
                    λ_i=λ_i,
                    λ=λs[λ_i],
                    seed=seeds[r],
                    Y=Y[r],
                    adj=adj,
                )
            )

        for ft in tqdm(
            as_completed(futures),
            total=repeats * n,
            desc=f"Fitting regularised models ({cls.__name__})",
            disable=quiet,
        ):
            (r, λ_i), model = ft.result()

            # Estimate number of non-zero parameters
            k = (abs(model.h) > non_zero_threshold).sum() + (
                abs(model.j) > non_zero_threshold
            ).sum()

            # Number of observations, number of timesteps (to rescale LL)
            _, N, T, _ = Y.shape
            N /= replicates
            log_likelihood = (
                -1
                * N
                * T
                * model.time_series_nll_sync(Y[r], X_mock, model.h, model.j, model.adj)
            )
            ebic[r][λ_i] = (
                k * (np.log(N) + 2 * Γ * np.log(model.n_params)) - 2 * log_likelihood
            )

    return λs, ebic, pids_full, Y, seeds


class CompareRegularisationEBICRunCommand(BaseCommand):
    output: Path
    adjacency: Path | None = None
    model_type: ModelType

    subset: Literal["full", "conservative", "liberal"] = "full"

    min: float = -4
    max: float = -1
    n: int = 30
    repeats: int = 100
    replicates: int = 1
    non_zero_threshold: float = 1e-2

    sigma: float | None = None
    sigma_path: Path | None = None

    binarisation_kind: Literal["gaussian", "triangular"] = "gaussian"

    seed: int = 202606191106

    quiet: bool = False

    def cli_cmd(self) -> None:
        rng = np.random.default_rng(self.seed)
        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )
        adj = np.load(self.adjacency) if self.adjacency is not None else None

        keep_idxes = [0, 1, 2, 3, 4, 5, 6, 7]
        if self.subset != "full":
            if self.subset == "conservative":
                dataset = dataset.filter(pl.col("pol_ideology") <= -1).filter_no_nulls()
            elif self.subset == "liberal":
                dataset = dataset.filter(pl.col("pol_ideology") >= 1).filter_no_nulls()
            keep_idxes = [0, 1, 2, 3, 4, 6, 7]

        model_cls = self.model_type.get_cls()
        if not issubclass(model_cls, Ising):
            raise ValueError(
                f"Unsupported model_type: '{self.model_type}'. Expected 'ising' "
                f"or 'sym_ising'."
            )

        sigma = self.sigma
        if sigma is None:
            if self.sigma_path is None:
                sigma = 0.1
            else:
                with self.sigma_path.open("r") as f:
                    try:
                        sigma: float = json.load(f)["sigma"]
                    except KeyError as err:
                        raise KeyError(
                            f"Binarisation sigma results file '{self.sigma_path}' has "
                            f"invalid format. Does not include key 'sigma'."
                        ) from err
                    except:
                        raise

        λs, ebic, pids, Y, seeds = test_regularisation_model_fit(
            model_cls,
            dataset,
            keep_idxes,
            self.min,
            self.max,
            self.n,
            self.repeats,
            self.non_zero_threshold,
            rng,
            adj,
            sigma,
            self.replicates,
            self.binarisation_kind,
            self.quiet,
        )

        np.savez_compressed(
            self.output,
            λs=λs,
            ebic=ebic,
            pids=pids,
            Y=Y,
            sigma=sigma,
            seeds=seeds,
            replicates=self.replicates,
            binarisation_kind=self.binarisation_kind,
            main_seed=self.seed,
        )
