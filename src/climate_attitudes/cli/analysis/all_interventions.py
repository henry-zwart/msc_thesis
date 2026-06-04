import itertools
from concurrent.futures import ProcessPoolExecutor, as_completed
from functools import partial
from pathlib import Path

import numpy as np
import numpy.typing as npt
from ising.model import FitMethod, ModelType, PairwiseInteractionSpinModel
from tqdm import tqdm

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from ising import Ising


def s_i(_model: Ising, y: npt.NDArray[np.int64], i: int) -> np.int64:
    return y[i]


def run_one_measure(
    target_idx,
    intervene_idx,
    model,
    f,
    y0,
    X,
    t,
    repeats,
    warmup_steps,
    method,
    take_every,
):
    return (
        target_idx,
        intervene_idx,
        model.measure(
            f,
            y0=y0,
            X=X,
            t=t,
            repeats=repeats,
            warmup_steps=warmup_steps,
            method=method,
            take_every=take_every,
        ),
    )


def run_intervention_experiment(
    Y: npt.NDArray[np.int64],
    X: npt.NDArray[np.float64] | None,
    measure_time: int,
    repeats: int,
    model: PairwiseInteractionSpinModel,
    intervention_delta: float,
    seed: int,
    quiet: bool,
) -> tuple[npt.NDArray[np.float64], npt.NDArray[np.float64]]:
    if model.node_labels is None:
        raise RuntimeError("Model node_labels should not be None")
    measurements = np.zeros(
        (Y.shape[0], repeats, model.node_labels.size, model.node_labels.size),
        dtype=np.float64,
    )
    checks = np.zeros(
        (Y.shape[0], repeats, model.node_labels.size, model.node_labels.size),
        dtype=np.float64,
    )
    with ProcessPoolExecutor() as executor:
        futures = []
        for intervene_idx, target_idx in itertools.product(
            range(Y.shape[-1]), range(Y.shape[-1])
        ):
            if intervene_idx == target_idx:
                continue
            f = partial(s_i, i=target_idx)
            model.reset(seed)
            if X is None:
                intervention_offset = np.array([intervention_delta])
            else:
                intervention_offset = np.array(
                    [[intervention_delta] + ([0.0] * X.shape[-1])]
                )
            intervention_model = model.intervene(
                spins=np.array([intervene_idx]),
                field_offset=intervention_offset,
                seed=seed + 1,
            )
            futures.append(
                executor.submit(
                    run_one_measure,
                    target_idx,
                    intervene_idx,
                    intervention_model,
                    f,
                    y0=Y[:, -1, :],
                    X=X[:, -1, :] if X is not None else None,
                    t=measure_time,
                    repeats=repeats,
                    warmup_steps=0,
                    method="parallel",
                    take_every=1,
                )
            )

        for ft in tqdm(
            as_completed(futures),
            total=(Y.shape[-1] ** 2 - Y.shape[-1]),
            disable=quiet,
        ):
            target_idx, intervene_idx, res = ft.result()
            measurements[..., target_idx, intervene_idx] = res.y[:, :, -1]
            checks[..., target_idx, intervene_idx] = res.check

    return measurements, checks


class AllInterventionsRunCommand(BaseCommand):
    output_dir: Path
    adjacency: Path | None = None
    model_type: ModelType
    seed: int = 202605261452
    use_covariates: bool = False

    repeats: int = 30
    measure_time: int = 5
    intervention_delta: float = 0.5
    quiet: bool = False

    def cli_cmd(self) -> None:
        # Ensure we treat path as the measurement path, rather than rng checks
        # This is required when calling this command from Make using grouped targets.
        # output_path_measure = self.output_dir / "measure"
        # output_path_check = self.output_dir / "check"
        # output_path_params = self.output_dir / "params"
        # output_path_datasets = self.output_dir / "datasets"

        if "check" in str(self.output):
            self.output = Path(str(self.output).replace("check", "measure"))

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )

        _, Y, X = dataset.indices_to_numpy(
            kind="time-series",
            binarise=True,
            seed=self.seed,
        )

        if not self.use_covariates:
            X = None

        node_labels = np.asarray(dataset.schema.get_short_names(kind="measurement"))

        if self.adjacency is not None:
            adj = np.load(self.adjacency)
            if self.model_type.get_cls().SYMMETRIC:
                adj = adj | adj.T
                adj[np.tril_indices_from(adj, k=-1)] = False
        else:
            adj = None

        model = self.model_type.get_cls().fit(
            Y,
            X=X,
            method=FitMethod.TIME_SERIES,
            node_labels=node_labels,
            rng=self.seed,
            adj=adj,
            self_loops=True,
        )

        if not isinstance(model, PairwiseInteractionSpinModel):
            raise ValueError(
                f"Unsupported model_type: '{self.model_type}'. Expected 'ising' "
                f"or 'sym_ising'."
            )

        measurements, checks = run_intervention_experiment(
            Y,
            X,
            self.measure_time,
            self.repeats,
            model,
            self.intervention_delta,
            self.seed,
            self.quiet,
        )

        np.save(Path(str(self.output).replace("_measure.npy", "_check.npy")), checks)
        np.save(self.output, measurements)
