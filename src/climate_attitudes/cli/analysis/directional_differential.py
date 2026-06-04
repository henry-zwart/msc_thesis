from pathlib import Path

import numpy as np
import numpy.typing as npt
from ising.model import FitMethod

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from ising import Ising

type SpinData = npt.NDArray[np.int64]
type CovariateData = npt.NDArray[np.float64]


def sample_with_replacement(
    Y: SpinData, X: CovariateData, rng: np.random.Generator
) -> tuple[SpinData, CovariateData]:
    sample_idxes = rng.choice(np.arange(Y.shape[0]), size=Y.shape[0], replace=True)
    return (Y[sample_idxes], X[sample_idxes])


def measure_directional_differentials(
    dataset: Dataset,
    rng: np.random.Generator,
    adj: npt.NDArray[np.bool] | None = None,
    use_covariates: bool = True,
) -> npt.NDArray[np.float64]:
    """Calculate differences in directional interaction effects for fit model.

    Args:
        dataset: Climate beliefs dataset.
        rng: Numpy RNG.
        adj: Optional adjacency matrix.
        use_covariates: Fit model with covariate-dependent spin thresholds.

    Returns:
        2D matrix of directional effect differentials. Element at index (i,j) is
        $J_{i,j} - J_{j,i}$, where $J_{i,j}$ is the causal interaction effect of
        spin $i$ on spin $j$.
    """
    # Binarise dataset, convert to numpy
    _, Y, X = dataset.indices_to_numpy(
        kind="time-series",
        binarise=True,
        seed=rng,
    )

    # Draw bootstrap samples
    Y, X = sample_with_replacement(Y, X, rng)

    # Fit model
    model = Ising.fit(
        y=Y,
        X=X if use_covariates else None,
        method=FitMethod.TIME_SERIES,
        rng=rng,
        adj=adj,
        self_loops=True,
    )

    # Calculate differences in directional effects
    diffs = np.triu(model.j) - np.triu(model.j.T)

    return diffs


class DirectionalDifferentialRunCommand(BaseCommand):
    output: Path
    adjacency: Path | None = None
    seed: int = 202606031023
    use_covariates: bool = False

    repeats: int = 100
    quiet: bool = False

    def cli_cmd(self) -> None:
        rng = np.random.default_rng(self.seed)
        rngs = rng.spawn(self.repeats)

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )

        adj = np.load(self.adjacency) if self.adjacency is not None else None

        diffs = np.stack(
            [
                measure_directional_differentials(
                    dataset,
                    _rng,
                    adj,
                    self.use_covariates,
                )
                for _rng in rngs
            ]
        )

        np.save(self.output, diffs)
