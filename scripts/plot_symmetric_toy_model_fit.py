from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from ising.model import FitMethod
from ising.model_library.three import MODELS

from ising import Ising, SymmetricIsing

# from climate_attitudes.visualisation import configure_mpl


def asym_to_sym_round_trip(
    model: Ising,
    n: int,
    glauber_kwargs: dict | None = None,
    fit_method: FitMethod = FitMethod.TIME_SERIES,
    timepoints: int | None = None,
    use_structure: bool = True,
) -> SymmetricIsing:
    """Run round-trip model fitting on Ising, but fitting symmetric Ising.

    Round-trip model fitting consists in drawing samples from a pre-specified
    discrete spin model, and using these samples to fit a new spin model.

    Args:
        model: An asymmetric Ising model.
        n: Number of samples to use to fit the round-trip model.
        glauber_kwargs: Additional parameters passed to `sample_glauber`.
        fit_method: Method to use for parameter reconstruction.
        timepoints: Number of timepoints to use when doing time-series parameter
            reconstruction.
        use_structure: Provide the original model structure to the new model.

    Returns:
        A SymmetricIsing model fit on samples generated from the true asymmetric
        Ising model.
    """
    # Draw samples from the base model
    match fit_method:
        case FitMethod.MAXIMUM_LIKELIHOOD:
            samples = model.sample(n_samples=n, **(glauber_kwargs or {}))
        case FitMethod.TIME_SERIES:
            if timepoints is None:
                raise ValueError(
                    "`timepoints=None` not permitted for time-series fitting."
                )
            elif timepoints < 2:
                raise ValueError(f"`timepoints` must be >= 2. Found {timepoints=}.")
            samples = model.sample_trajectories(
                n_individuals=n, n_samples=timepoints, **(glauber_kwargs or {})
            )

    # Construct symmetric (upper-triangular) adjacency matrix from provided asym one
    adj = np.triu(model.adj | model.adj.T, k=1)

    # Fit new model
    return SymmetricIsing.fit(
        samples,
        fit_method,
        adj=adj if use_structure else None,
    )


def main():
    N = 1500
    T = 2

    FIG_DIR = Path("results/figures")

    for name, model in MODELS.items():
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = asym_to_sym_round_trip(model, n=N, timepoints=T)

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "toy_model_fit_sym_with_structure"
        size = model.size
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()

    for name, model in MODELS.items():
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = asym_to_sym_round_trip(model, n=N, timepoints=T)

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "toy_model_fit_sym_without_structure"
        size = model.size
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()


if __name__ == "__main__":
    # configure_mpl()
    main()
