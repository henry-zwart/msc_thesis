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

type SpinStates = npt.NDArray[np.int64]
type Probability = npt.NDArray[np.float64]
type Indexes = npt.NDArray[np.int64]
type Covariates = npt.NDArray[np.float64]


@dataclass
class EstimationDataset:
    Y: SpinStates
    P: Probability
    row_idxes: Indexes


def state_configuration(
    _model: Ising, y: npt.NDArray[np.int64]
) -> npt.NDArray[np.int64]:
    return y


def run_one_measure(
    repeat_idx,
    intervene_idx,
    model,
    f,
    y0,
    t,
    warmup_steps,
    method,
    take_every,
):
    return (
        repeat_idx,
        intervene_idx,
        model.measure(
            f,
            y0=y0,
            t=t,
            warmup_steps=warmup_steps,
            step_method=method,
            take_every=take_every,
        ),
    )


def _fit_model[T: Ising](
    cls: type[T],
    Y: npt.NDArray[np.int64] | npt.NDArray[np.float64],
    λ: float | int | None,
    node_labels: npt.NDArray[np.str_],
    seed: np.random.Generator,
    adj: npt.NDArray[np.bool] | None,
    repeat_idx: int,
) -> tuple[int, T]:
    model = cls.fit(
        Y,
        optim_method=FitMethod.TIME_SERIES,
        update_method=UpdateMethod.SYNCHRONOUS,
        node_labels=node_labels,
        rng=np.random.default_rng(seed),
        adj=adj,
        self_loops=True,
        w=λ,
    )
    return (repeat_idx, model)


def sample_binary_datasets(
    dataset: Dataset,
    repeats: int,
    bootstrap: bool,
    scale: float,
    binarisation_kind: Literal["gaussian", "triangular"],
    rngs: list[np.random.Generator],
) -> EstimationDataset:
    Y, *_ = dataset.indices_to_numpy(
        kind="time-series",
        binarise=True,
        scale=scale,
        seed=0,
    )

    # Prepare arrays to store datasets in
    datasets_idxes = np.empty((repeats, Y.shape[0]), dtype=np.int64)
    datasets_Y = np.empty((repeats, *Y.shape), dtype=np.int64)
    datasets_P = np.empty((repeats, *Y.shape), dtype=np.float64)

    for r in range(repeats):
        # Sample binarisations
        Y, _, P, *_, row_idxes = dataset.indices_to_numpy(
            kind="time-series",
            binarise=True,
            scale=scale,
            binarisation_dist=binarisation_kind,
            seed=rngs[r],
            bootstrap=bootstrap,
        )

        datasets_Y[r] = Y
        datasets_P[r] = P
        datasets_idxes[r] = row_idxes

    return EstimationDataset(Y=datasets_Y, P=datasets_P, row_idxes=datasets_idxes)


def fit_models[T: Ising](
    datasets: EstimationDataset,
    model_type: type[T],
    adj: npt.NDArray[np.bool] | None,
    λ: float | int | None,
    node_labels: npt.NDArray[np.str_],
    rngs: list[np.random.Generator],
    intervention_delta: float,
    quiet: bool,
) -> list[T]:
    repeats, *_ = datasets.Y.shape

    # Fit models
    models_dict: dict[int, T] = {}
    with ProcessPoolExecutor() as executor:
        futures = []

        for r in range(repeats):
            futures.append(
                executor.submit(
                    _fit_model,
                    cls=model_type,
                    Y=datasets.Y[r],
                    λ=λ,
                    node_labels=node_labels,
                    seed=rngs[r],
                    adj=adj,
                    repeat_idx=r,
                )
            )

        for ft in tqdm(
            as_completed(futures),
            total=repeats,
            desc=(f"Fitting models ({model_type.__name__}; δ={intervention_delta})"),
            disable=quiet,
        ):
            r, model = ft.result()
            models_dict[r] = model

    return [models_dict[i] for i in range(len(models_dict))]


def run_interventions[T: Ising](
    datasets: EstimationDataset,
    models: list[T],
    measure_time: int,
    intervention_delta: float,
    rngs: list[np.random.Generator],
    quiet: bool,
) -> tuple[
    npt.NDArray[np.int64],
    npt.NDArray[np.int64],
    npt.NDArray[np.float64],
]:
    repeats, M, *_, N = datasets.Y.shape

    # Prepare results arrays
    measurements = np.zeros(
        (repeats, M, measure_time, N, N),
        dtype=np.int64,
    )
    checks = np.zeros(
        (repeats, M, N),
        dtype=np.float64,
    )

    # Record initial RNG sample for each repeat (rng)
    seeds = np.asarray([_rng.integers(0, 2**32).item() for _rng in rngs])

    f = state_configuration
    intervention_offset = np.array([intervention_delta])

    with ProcessPoolExecutor() as executor:
        futures = []
        for repeat in range(repeats):
            model = models[repeat]

            for intervene_idx in range(N):
                model.reset(seeds[repeat])
                int_model = model.intervene(
                    spins=np.array([intervene_idx]),
                    field_offset=intervention_offset,
                    seed=np.random.default_rng(seeds[repeat]),
                )
                int_model.reset(seeds[repeat])

                Y = datasets.Y[repeat]

                futures.append(
                    executor.submit(
                        run_one_measure,
                        repeat,
                        intervene_idx,
                        int_model,
                        f,
                        y0=Y[:, -1, :],
                        t=measure_time,
                        warmup_steps=0,
                        method="parallel",
                        take_every=1,
                    )
                )

        for ft in tqdm(
            as_completed(futures),
            total=(repeats * datasets.Y.shape[-1]),
            desc=(
                f"Pairwise interventions ({type(models[0]).__name__}; "
                f"δ={intervention_delta})"
            ),
            disable=quiet,
        ):
            repeat_idx, intervene_idx, res = ft.result()
            # NOTE: I've swapped the intervene and target indexes now. Intervene is
            # first.
            measurements[repeat_idx, :, :, intervene_idx] = res.y[:, 0]
            checks[repeat_idx, :, intervene_idx] = res.check[:, 0]

    return seeds, measurements, checks


class AllInterventionsRunCommand(BaseCommand):
    output: Path
    adjacency: Path | None = None
    model_type: ModelType
    seed: int = 202605261452

    repeats: int = 30
    measure_time: int = 5
    intervention_delta: float = 0.5

    sigma: float | None = None
    sigma_path: Path | None = None

    lam: float | None = None
    lam_path: Path | None = None

    bootstrap: bool = False
    marginalise: bool = False
    binarisation_kind: Literal["gaussian", "triangular"] = "gaussian"

    quiet: bool = False

    def cli_cmd(self) -> None:
        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )

        node_labels = np.asarray(dataset.schema.get_short_names(kind="measurement"))

        if self.adjacency is not None:
            adj = np.load(self.adjacency)
            if self.model_type.get_cls().SYMMETRIC:
                adj = adj | adj.T
                adj[np.tril_indices_from(adj, k=-1)] = False
        else:
            adj = None

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

        main_rng = np.random.default_rng(self.seed)
        rngs = main_rng.spawn(self.repeats)
        binary_datasets = sample_binary_datasets(
            dataset=dataset,
            repeats=self.repeats,
            bootstrap=self.bootstrap,
            scale=sigma,
            binarisation_kind=self.binarisation_kind,
            rngs=rngs,
        )

        # If marginalise = True and bootstrap = False, only need to fit one model
        if self.marginalise and not self.bootstrap:
            model = model_cls.fit(
                y=binary_datasets.P[0],
                optim_method=FitMethod.MARGINALISED,
                update_method=UpdateMethod.SYNCHRONOUS,
                adj=adj,
                self_loops=True,
                w=lam,
                rng=0,
            )
            models = [model.clone(_rng) for _rng in rngs]
        else:
            models = fit_models(
                datasets=binary_datasets,
                model_type=model_cls,
                adj=adj,
                λ=lam,
                node_labels=node_labels,
                rngs=rngs,
                intervention_delta=self.intervention_delta,
                quiet=self.quiet,
            )

        params = np.asarray([m.param_vector() for m in models], dtype=np.float64)

        seeds, measurements, checks = run_interventions(
            datasets=binary_datasets,
            models=models,
            measure_time=self.measure_time,
            intervention_delta=self.intervention_delta,
            rngs=rngs,
            quiet=self.quiet,
        )

        Y0, *_ = dataset.indices_to_numpy(kind="time-series")
        np.savez_compressed(
            self.output,
            seeds=seeds,
            Y0=Y0,
            Y=binary_datasets.Y,
            dataset_idxes=binary_datasets.row_idxes,
            binarisation_kind=self.binarisation_kind,
            labels=node_labels,
            params=params,
            checks=checks,
            λ=lam if lam is not None else 0.0,
            sigma=sigma,
            measurements=measurements,
            marginalise=self.marginalise,
        )
