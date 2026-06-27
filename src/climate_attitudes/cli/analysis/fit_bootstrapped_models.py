import json
from concurrent.futures import ProcessPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import numpy.typing as npt
from ising.model import FitMethod, ModelType, UpdateMethod
from tqdm import tqdm

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from ising import Ising

type SpinData = npt.NDArray[np.int64]
type Probability = npt.NDArray[np.float64]
type CovariateData = npt.NDArray[np.float64]
type Differentials = npt.NDArray[np.float64]
type InteractionEffects = npt.NDArray[np.float64]


@dataclass
class BootstrapFitResults[M: Ising]:
    seeds: npt.NDArray[np.int64]
    sample_idxes: npt.NDArray[np.int64]
    Y: SpinData
    P: Probability
    X: CovariateData | None
    models: list[M]


def fit_model[M: Ising](
    cls: type[M],
    iden: int,
    seed: np.int64,
    Y: SpinData,
    X: CovariateData | None = None,
    adj: npt.NDArray[np.bool] | None = None,
    w: float | None = None,
    marginalise: bool = False,
) -> tuple[int, M]:
    """Sample a bootstrap dataset, and fit an Ising model on it.

    Args:
        cls: Model type.
        iden: Identifier, used to distinguish this function call from others when
            running in parallel.
        seed: Random seed used to sample bootstrap dataset. `seed` + 1 is used for
            the fit model.
        Y: Observed spin states. 3D Numpy array with shape (individual, time, spin).
        X: Optional covariate data. 3D Numpy array with shape (individual, time, spin).
            If provided, baseline activations are fit as linear functions of
            individual-level covariates.
        adj: Optional adjacency matrix.
        w: Optional regularisation parameter.

    Returns:
        Tuple containing `iden` and the fit model.
    """
    rng = np.random.default_rng(seed)
    model = cls.fit(
        y=Y,
        X=X,
        optim_method=FitMethod.MARGINALISED if marginalise else FitMethod.TIME_SERIES,
        update_method=UpdateMethod.SYNCHRONOUS,
        rng=rng,
        adj=adj,
        self_loops=True,
        w=w,
    )
    return (iden, model)


def fit_bootstrap_models[M: Ising](
    cls: type[M],
    dataset: Dataset,
    repeats: int,
    rng: np.random.Generator,
    adj: npt.NDArray[np.bool] | None = None,
    λ: float | int | None = None,
    use_covariates: bool = True,
    scale: float = 0.1,
    binarisation_kind: Literal["gaussian", "triangular"] = "gaussian",
    marginalise: bool = False,
    quiet: bool = False,
) -> BootstrapFitResults[M]:
    """Fit models on bootstrapped datasets.

    Args:
        cls: Model type.
        dataset: Climate beliefs dataset.
        repeats: Number of bootstrapped datasets to sample.
        rng: Numpy RNG.
        adj: Optional adjacency matrix.
        λ: Regularisation strength.
        use_covariates: Fit model with covariate-dependent spin thresholds.
        quiet: Disable progress bars.

    Returns:
        BootstrapFitResults object, containing random seeds used for each bootstrap
        repeat, the bootstrap dataset samples, and the fit models.
    """
    Y_mock, X_mock, *_ = dataset.indices_to_numpy(kind="time-series")
    Y = np.empty((repeats, *Y_mock.shape), dtype=np.int64)
    P = np.empty((repeats, *Y_mock.shape), dtype=np.float64)
    row_idxes = np.empty((repeats, Y_mock.shape[0]), dtype=np.int64)
    X = None
    if use_covariates:
        X = np.empty((repeats, *X_mock.shape), dtype=np.float64)

    for repeat in range(repeats):
        Y_r, X_r, P_r, _, row_idxes_r = dataset.indices_to_numpy(
            kind="time-series",
            binarise=True,
            scale=scale,
            binarisation_dist=binarisation_kind,
            bootstrap=True,
            seed=rng,
        )

        row_idxes[repeat] = row_idxes_r

        Y[repeat] = Y_r
        P[repeat] = P_r

        if X is not None:
            X[repeat] = X_r

    seeds = rng.integers(0, 2**32, size=repeats)

    models_dict: dict[int, M] = {}
    with ProcessPoolExecutor() as executor:
        futures = []
        for r in range(repeats):
            futures.append(
                executor.submit(
                    fit_model,
                    cls,
                    r,
                    seeds[r],
                    P[r] if marginalise else Y[r],
                    X[r] if X is not None else None,
                    adj,
                    w=λ,
                    marginalise=marginalise,
                )
            )

        for ft in tqdm(
            as_completed(futures),
            total=repeats,
            desc=f"Fitting bootstrapped models ({cls.__name__})",
            disable=quiet,
        ):
            iden, model = ft.result()
            models_dict[iden] = model

    models = [models_dict[i] for i in range(repeats)]

    return BootstrapFitResults(
        seeds=seeds,
        sample_idxes=row_idxes,
        Y=Y,
        P=P,
        X=X,
        models=models,
    )


class FitBootstrappedModelsRunCommand(BaseCommand):
    output: Path
    adjacency: Path | None = None
    model_type: ModelType
    seed: int = 202606031023
    use_covariates: bool = False

    sigma: float | None = None
    sigma_path: Path | None = None

    lam: float | None = None
    lam_path: Path | None = None

    binarisation_kind: Literal["gaussian", "triangular"]

    repeats: int = 100
    marginalise: bool = False
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

        model_cls = self.model_type.get_cls()
        if not issubclass(model_cls, Ising):
            raise ValueError(
                f"Unsupported model_type: '{self.model_type}'. Expected 'ising' "
                f"or 'sym_ising'."
            )

        lam = self.lam
        if lam is None:
            if self.lam_path is None:
                print(
                    "Warning: No regularisation strength or path to optimised "
                    "resularisation results specified. "
                )
            else:
                with self.lam_path.open("r") as f:
                    try:
                        lam: float = json.load(f)[str(self.model_type)]["full"]
                    except KeyError as err:
                        raise KeyError(
                            f"Did not find optimised regularisation strength for "
                            f"model type '{self.model_type}' in file "
                            f"'{self.lam_path}'"
                        ) from err
                    except:
                        raise

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

        bootstrap_results = fit_bootstrap_models(
            model_cls,
            dataset,
            self.repeats,
            rng,
            adj,
            lam,
            self.use_covariates,
            sigma,
            self.binarisation_kind,
            self.marginalise,
            self.quiet,
        )

        params = np.empty(
            (self.repeats, bootstrap_results.models[0].n_params),
            dtype=np.float64,
        )

        for r in range(self.repeats):
            params[r] = bootstrap_results.models[r].param_vector()

        if bootstrap_results.X is not None:
            np.savez_compressed(
                self.output,
                seeds=bootstrap_results.seeds,
                sample_idxes=bootstrap_results.sample_idxes,
                Y=bootstrap_results.Y,
                X=bootstrap_results.X,
                λ=lam if lam is not None else 0.0,
                sigma=sigma,
                binarisation_kind=self.binarisation_kind,
                marginalise=self.marginalise,
                params=params,
            )
        else:
            np.savez_compressed(
                self.output,
                seeds=bootstrap_results.seeds,
                sample_idxes=bootstrap_results.sample_idxes,
                Y=bootstrap_results.Y,
                λ=lam if lam is not None else 0.0,
                sigma=sigma,
                binarisation_kind=self.binarisation_kind,
                marginalise=self.marginalise,
                params=params,
            )
