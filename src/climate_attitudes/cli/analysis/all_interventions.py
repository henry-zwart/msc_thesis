import itertools
from concurrent.futures import ProcessPoolExecutor, as_completed
from functools import partial
from pathlib import Path

import numpy as np
import numpy.typing as npt
from ising.model import FitMethod, ModelType
from tqdm import tqdm

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from ising import Ising


def s_i(_model: Ising, y: npt.NDArray[np.int64], i: int) -> np.int64:
    return y[i]


def run_one_measure(
    repeat_idx,
    target_idx,
    intervene_idx,
    model,
    f,
    y0,
    X,
    t,
    warmup_steps,
    method,
    take_every,
):
    return (
        repeat_idx,
        target_idx,
        intervene_idx,
        model.measure(
            f,
            y0=y0,
            X=X,
            t=t,
            warmup_steps=warmup_steps,
            method=method,
            take_every=take_every,
        ),
    )


def fit_model[T: Ising](
    cls: type[T],
    Y: npt.NDArray[np.int64],
    X: npt.NDArray[np.float64] | None,
    node_labels: npt.NDArray[np.str_],
    seed: np.random.Generator,
    adj: npt.NDArray[np.bool] | None,
    repeat_idx: int,
) -> tuple[int, T]:
    model = cls.fit(
        Y,
        X=X,
        method=FitMethod.TIME_SERIES,
        node_labels=node_labels,
        rng=np.random.default_rng(seed),
        adj=adj,
        self_loops=True,
    )
    return (repeat_idx, model)


def run_intervention_experiment(
    dataset: Dataset,
    measure_time: int,
    repeats: int,
    adj: npt.NDArray[np.bool] | None,
    node_labels: npt.NDArray[np.str_],
    model_type: type[Ising],
    use_covariates: bool,
    intervention_delta: float,
    rng: np.random.Generator,
    quiet: bool,
) -> tuple[
    npt.NDArray[np.float64],
    npt.NDArray[np.int64],
    npt.NDArray[np.float64],
    npt.NDArray[np.float64],
    npt.NDArray[np.float64],
]:
    _, Y, X = dataset.indices_to_numpy(kind="time-series", binarise=True, seed=rng)
    X = X if use_covariates else None
    M = Y.shape[0]
    T = Y.shape[1]
    N = Y.shape[-1]
    dummy_model = model_type.fit(
        Y,
        X,
        method=FitMethod.TIME_SERIES,
        adj=adj,
        self_loops=True,
        rng=rng,
    )
    measurements = np.zeros(
        (M, repeats, measure_time, N, N),
        dtype=np.float64,
    )
    checks = np.zeros(
        (M, repeats, N, N),
        dtype=np.float64,
    )
    params = np.zeros((repeats, dummy_model.n_params), dtype=np.float64)
    datasets_Y = np.zeros((repeats, M, T, N), dtype=np.int64)
    rngs = rng.spawn(repeats)
    seeds = np.asarray([_rng.integers(0, 2**32).item() for _rng in rngs])

    # Fit models
    models = [dummy_model] * repeats
    with ProcessPoolExecutor() as executor:
        futures = []

        for r in range(repeats):
            _, Y, _ = dataset.indices_to_numpy(
                kind="time-series",
                binarise=True,
                seed=rngs[r],
            )
            datasets_Y[r] = Y

            futures.append(
                executor.submit(
                    fit_model,
                    cls=model_type,
                    Y=Y,
                    X=X,
                    node_labels=node_labels,
                    seed=rngs[r],
                    adj=adj,
                    repeat_idx=r,
                )
            )

        for ft in as_completed(futures):
            r, model = ft.result()
            models[r] = model
            params[r] = model.param_vector()

    # Run intervention experiments
    with ProcessPoolExecutor() as executor:
        futures = []
        for r in range(repeats):
            Y = datasets_Y[r]
            model = models[r]

            for intervene_idx, target_idx in itertools.product(range(N), range(N)):
                f = partial(s_i, i=target_idx)
                model.reset(rngs[r])
                if X is None:
                    intervention_offset = np.array([intervention_delta])
                else:
                    intervention_offset = np.array(
                        [[intervention_delta] + ([0.0] * X.shape[-1])]
                    )
                int_model = model.intervene(
                    spins=np.array([intervene_idx]),
                    field_offset=intervention_offset,
                    seed=rngs[r],
                )
                futures.append(
                    executor.submit(
                        run_one_measure,
                        r,
                        target_idx,
                        intervene_idx,
                        int_model,
                        f,
                        y0=Y[:, -1, :],
                        X=X[:, -1, :] if X is not None else None,
                        t=measure_time,
                        warmup_steps=0,
                        method="parallel",
                        take_every=1,
                    )
                )

        for ft in tqdm(
            as_completed(futures),
            total=(repeats * Y.shape[-1] ** 2),
            desc=(
                f"Pairwise interventions ({model_type.__name__}; "
                f"δ={intervention_delta}; covariates={use_covariates})"
            ),
            disable=quiet,
        ):
            repeat_idx, target_idx, intervene_idx, res = ft.result()
            measurements[:, repeat_idx, :, target_idx, intervene_idx] = res.y[:, 0]
            checks[:, repeat_idx, target_idx, intervene_idx] = res.check[:, 0]

    return seeds, datasets_Y, params, measurements, checks


class AllInterventionsRunCommand(BaseCommand):
    output: Path
    adjacency: Path | None = None
    model_type: ModelType
    seed: int = 202605261452
    use_covariates: bool = False

    repeats: int = 30
    measure_time: int = 5
    intervention_delta: float = 0.5
    quiet: bool = False

    def cli_cmd(self) -> None:
        # output_path_seeds = self.output_dir / "seeds.npy"
        # output_path_measure = self.output_dir / "measure.npy"
        # output_path_check = self.output_dir / "check.npy"
        # output_path_params = self.output_dir / "params.npy"
        # output_path_datasets_Y = self.output_dir / "datasets_Y.npy"
        # output_path_datasets_X = self.output_dir / "datasets_X.npy"

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

        rng = np.random.default_rng(self.seed)
        seeds, Ys, params, measurements, checks = run_intervention_experiment(
            dataset,
            self.measure_time,
            self.repeats,
            adj,
            node_labels,
            model_cls,
            self.use_covariates,
            self.intervention_delta,
            rng,
            self.quiet,
        )

        # save_files = dict(
        #     seeds=seeds,
        #     Y=Ys,
        #     params=params,
        #     checks=checks,
        #     measurements=measurements,
        # )
        _, Y0, X = dataset.indices_to_numpy(kind="time-series")
        if self.use_covariates:
            # save_files["X"] = X
            np.savez_compressed(
                self.output,
                seeds=seeds,
                Y0=Y0,
                Y=Ys,
                X=X,
                labels=node_labels,
                params=params,
                checks=checks,
                measurements=measurements,
            )
        else:
            np.savez_compressed(
                self.output,
                seeds=seeds,
                Y0=Y0,
                Y=Ys,
                labels=node_labels,
                params=params,
                checks=checks,
                measurements=measurements,
            )

        # np.savez_compressed(
        #     self.output,
        #     **save_files,
        # )

        # # Save random seeds used for each repeat
        # np.save(output_path_seeds, seeds)
        #
        # # Save data used to fit models
        # np.save(output_path_datasets_Y, Ys)
        # *_, X = dataset.indices_to_numpy(kind="time-series")
        # if X is not None:
        #     np.save(output_path_datasets_X, X)
        #
        # # Save fit model parameters
        # np.save(output_path_params, params)
        #
        # # Save RNG checks; check that each counterfactual uses same RNG
        # np.save(output_path_check, checks)
        #
        # # Save measured system states
        # np.save(output_path_measure, measurements)
