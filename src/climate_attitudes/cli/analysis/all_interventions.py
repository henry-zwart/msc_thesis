import json
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

import numpy as np
import numpy.typing as npt
from ising.model import FitMethod, ModelType, UpdateMethod
from tqdm import tqdm

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from ising import Ising

# def s_i(_model: Ising, y: npt.NDArray[np.int64], i: int) -> np.int64:
#     return y[i]


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
    X,
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
            X=X,
            t=t,
            warmup_steps=warmup_steps,
            step_method=method,
            take_every=take_every,
        ),
    )


def fit_model[T: Ising](
    cls: type[T],
    Y: npt.NDArray[np.int64],
    X: npt.NDArray[np.float64] | None,
    λ: float | int | None,
    node_labels: npt.NDArray[np.str_],
    seed: np.random.Generator,
    adj: npt.NDArray[np.bool] | None,
    repeat_idx: int,
) -> tuple[int, T]:
    model = cls.fit(
        Y,
        X=X,
        optim_method=FitMethod.TIME_SERIES,
        update_method=UpdateMethod.SYNCHRONOUS,
        node_labels=node_labels,
        rng=np.random.default_rng(seed),
        adj=adj,
        self_loops=True,
        w=λ,
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
    λ: float | int | None,
    rng: np.random.Generator,
    scale: float,
    quiet: bool,
    bootstrap: bool,
) -> tuple[
    npt.NDArray[np.float64],
    npt.NDArray[np.int64],
    npt.NDArray[np.float64] | None,
    npt.NDArray[np.int64],
    npt.NDArray[np.float64],
    npt.NDArray[np.float64],
    npt.NDArray[np.float64],
]:
    _, Y, X = dataset.indices_to_numpy(
        kind="time-series", binarise=True, scale=scale, seed=rng
    )
    X = X if use_covariates else None
    M = Y.shape[0]
    T = Y.shape[1]
    N = Y.shape[-1]
    dummy_model = model_type.fit(
        Y,
        X,
        optim_method=FitMethod.TIME_SERIES,
        update_method=UpdateMethod.SYNCHRONOUS,
        adj=adj,
        self_loops=False,
        rng=rng,
    )
    measurements = np.zeros(
        (M, repeats, measure_time, N, N),
        dtype=np.float64,
    )
    checks = np.zeros(
        (M, repeats, N),
        dtype=np.float64,
    )
    params = np.zeros((repeats, dummy_model.n_params), dtype=np.float64)
    datasets_Y = np.zeros((repeats, M, T, N), dtype=np.int64)
    datasets_X = (
        np.zeros((repeats, M, T, X.shape[-1]), dtype=np.float64)
        if X is not None
        else None
    )
    dataset_idxes = np.empty((repeats, M), dtype=np.int64)
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
            if bootstrap:
                idxes = rngs[r].choice(np.arange(M), size=M, replace=True)
                datasets_Y[r] = Y[idxes]
                dataset_idxes[r] = idxes
                if X is not None and datasets_X is not None:
                    datasets_X[r] = X[idxes]
            else:
                datasets_Y[r] = Y
                dataset_idxes[r] = np.arange(M)
                if X is not None and datasets_X is not None:
                    datasets_X[r] = X

            futures.append(
                executor.submit(
                    fit_model,
                    cls=model_type,
                    Y=datasets_Y[r],
                    X=datasets_X[r] if datasets_X is not None else X,
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
            desc=(
                f"Fitting models ({model_type.__name__}; "
                f"δ={intervention_delta}; covariates={use_covariates})"
            ),
            disable=quiet,
        ):
            r, model = ft.result()
            models[r] = model
            params[r] = model.param_vector()

    # Run intervention experiments
    with ProcessPoolExecutor() as executor:
        futures = []
        for r in range(repeats):
            Y = datasets_Y[r]
            X = datasets_X[r] if datasets_X is not None else None
            model = models[r]

            for intervene_idx in range(N):
                f = state_configuration
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
            total=(repeats * Y.shape[-1]),
            desc=(
                f"Pairwise interventions ({model_type.__name__}; "
                f"δ={intervention_delta}; covariates={use_covariates})"
            ),
            disable=quiet,
        ):
            repeat_idx, intervene_idx, res = ft.result()
            measurements[:, repeat_idx, :, :, intervene_idx] = res.y[:, 0]
            checks[:, repeat_idx, intervene_idx] = res.check[:, 0]

    return seeds, datasets_Y, datasets_X, dataset_idxes, params, measurements, checks


class AllInterventionsRunCommand(BaseCommand):
    output: Path
    adjacency: Path | None = None
    model_type: ModelType
    seed: int = 202605261452
    use_covariates: bool = False

    repeats: int = 30
    measure_time: int = 5
    intervention_delta: float = 0.5

    sigma: float | None = None
    sigma_path: Path | None = None

    lam: float | None = None
    lam_path: Path | None = None

    bootstrap: bool = False

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

        rng = np.random.default_rng(self.seed)
        seeds, Ys, Xs, idxes, params, measurements, checks = (
            run_intervention_experiment(
                dataset,
                self.measure_time,
                self.repeats,
                adj,
                node_labels,
                model_cls,
                self.use_covariates,
                self.intervention_delta,
                lam,
                rng,
                sigma,
                self.quiet,
                self.bootstrap,
            )
        )

        # save_files = dict(
        #     seeds=seeds,
        #     Y=Ys,
        #     params=params,
        #     checks=checks,
        #     measurements=measurements,
        # )
        _, Y0, X0 = dataset.indices_to_numpy(kind="time-series")
        if self.use_covariates:
            if Xs is None:
                raise RuntimeError("Xs should not be None for use_covariates=True")
            # save_files["X"] = X
            np.savez_compressed(
                self.output,
                seeds=seeds,
                Y0=Y0,
                X0=X0,
                Y=Ys,
                X=Xs,
                dataset_idxes=idxes,
                labels=node_labels,
                params=params,
                checks=checks,
                λ=lam if lam is not None else 0.0,
                sigma=sigma,
                measurements=measurements,
            )
        else:
            np.savez_compressed(
                self.output,
                seeds=seeds,
                Y0=Y0,
                Y=Ys,
                dataset_idxes=idxes,
                labels=node_labels,
                params=params,
                checks=checks,
                λ=lam if lam is not None else 0.0,
                sigma=sigma,
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
