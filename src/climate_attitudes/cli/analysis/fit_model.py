import json
from pathlib import Path
from typing import Literal

import numpy as np
import numpy.typing as npt
import polars as pl
from ising.model import FitMethod, ModelType, UpdateMethod

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from ising import Ising

type SpinData = npt.NDArray[np.int64]
type CovariateData = npt.NDArray[np.float64]
type Differentials = npt.NDArray[np.float64]
type InteractionEffects = npt.NDArray[np.float64]


class FitModelRunCommand(BaseCommand):
    output: Path
    adjacency: Path | None = None
    model_type: ModelType
    use_covariates: bool = False

    filter_column: str | None = None
    filter_value: int | None = None
    filter_le: int | None = None
    filter_ge: int | None = None

    exclude_column: list[str] | None = None

    lam: float | None = None
    lam_path: Path | None = None

    sigma: float | None = None
    sigma_path: Path | None = None

    marginalise: bool = True

    binarisation_kind: Literal["gaussian", "triangular"] = "gaussian"

    seed: int = 202606031023

    quiet: bool = False

    def cli_cmd(self) -> None:
        rng = np.random.default_rng(self.seed)
        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )
        if self.filter_column is not None:
            if (
                self.filter_value is None
                and self.filter_le is None
                and self.filter_ge is None
            ):
                raise ValueError(
                    f"Found --filter-column '{self.filter_column}' with no value "
                    f"specified. Provide a value with one of --filter-value, "
                    f"--filter-le or --filter-ge."
                )
            if self.filter_value is not None:
                dataset = dataset.filter(
                    pl.col(self.filter_column) == self.filter_value
                ).filter_no_nulls()
            elif self.filter_le is not None:
                dataset = dataset.filter(
                    pl.col(self.filter_column) <= self.filter_le
                ).filter_no_nulls()
            else:
                dataset = dataset.filter(
                    pl.col(self.filter_column) >= self.filter_ge
                ).filter_no_nulls()

        exclude_idxes = []
        colnames = dataset.schema.get_short_names("measurement")
        if self.exclude_column:
            for colname in self.exclude_column:
                exclude_idxes.append(colnames.index(colname))
        keep_idxes = [i for i in range(len(colnames)) if i not in exclude_idxes]

        adj = np.load(self.adjacency) if self.adjacency is not None else None
        if adj is not None:
            adj = adj[keep_idxes][:, keep_idxes]

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

        Y, X, P, *_ = dataset.indices_to_numpy(
            kind="time-series",
            binarise=True,
            scale=sigma,
            seed=rng,
            binarisation_dist=self.binarisation_kind,
        )

        Y = Y[..., keep_idxes]

        if not self.use_covariates:
            X = None

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

        fit_method = (
            FitMethod.MARGINALISED if self.marginalise else FitMethod.TIME_SERIES
        )
        model = model_cls.fit(
            y=P if self.marginalise else Y,
            optim_method=fit_method,
            update_method=UpdateMethod.SYNCHRONOUS,
            rng=rng,
            adj=adj,
            self_loops=True,
            w=lam,
        )

        params = model.param_vector()

        if X is not None:
            np.savez_compressed(
                self.output,
                seeds=self.seed,
                Y=Y,
                P=P,
                X=X,
                λ=lam if lam is not None else 0.0,
                sigma=sigma,
                params=params,
                marginalise=self.marginalise,
                binarisation_kind=self.binarisation_kind,
                col_idxes=keep_idxes,
            )
        else:
            np.savez_compressed(
                self.output,
                seeds=self.seed,
                Y=Y,
                P=P,
                λ=lam if lam is not None else 0.0,
                sigma=sigma,
                params=params,
                marginalise=self.marginalise,
                binarisation_kind=self.binarisation_kind,
                col_idxes=keep_idxes,
            )
