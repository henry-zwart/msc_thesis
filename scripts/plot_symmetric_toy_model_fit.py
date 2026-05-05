from pathlib import Path

import matplotlib.pyplot as plt
from ising.evaluation._round_trip import fit_round_trip
from ising.model import FitMethod
from ising.model_library import MODELS

from ising import SymmetricIsing

# from climate_attitudes.visualisation import configure_mpl

RANDOM_SEED = 202604231652


def main():
    N = 1500
    T = 2

    FIG_DIR = Path("results/figures")

    models = {
        (size, name): model
        for size, models in MODELS.items()
        for name, model in models.items()
    }

    for (size, name), model in models.items():
        model.reset(RANDOM_SEED)
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = fit_round_trip(model, n=N, timepoints=T)

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "symmetric_ts"
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()

    for (size, name), model in models.items():
        model.reset(RANDOM_SEED)
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = fit_round_trip(
            model,
            n=N,
            timepoints=T,
            fit_method=FitMethod.TIME_SERIES,
            model_type=SymmetricIsing,
            use_structure=False,
        )

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "symmetric_ts_no_structure"
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()

    # Fit cross-sectionally
    for (size, name), model in models.items():
        model.reset(RANDOM_SEED)
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = fit_round_trip(
            model,
            n=N * 2,
            fit_method=FitMethod.MAXIMUM_LIKELIHOOD,
            glauber_kwargs=dict(take_every=True),
            model_type=SymmetricIsing,
        )

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "symmetric_cs"
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()

    for (size, name), model in models.items():
        model.reset(RANDOM_SEED)
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = fit_round_trip(
            model,
            n=N * 2,
            fit_method=FitMethod.MAXIMUM_LIKELIHOOD,
            use_structure=False,
            glauber_kwargs=dict(take_every=True),
            model_type=SymmetricIsing,
        )

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "symmetric_cs_no_structure"
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()


if __name__ == "__main__":
    # configure_mpl()
    main()
