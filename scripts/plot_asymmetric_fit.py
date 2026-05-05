from pathlib import Path

import matplotlib.pyplot as plt
from ising.evaluation import fit_round_trip
from ising.model_library import MODELS

# from climate_attitudes.visualisation import configure_mpl

RANDOM_SEED = 202604231658


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
        fig, axes = plt.subplots(ncols=2, figsize=(20, 10), constrained_layout=True)

        refit_model = fit_round_trip(model, n=N, timepoints=T)

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "asymmetric_ts"
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()

    for (size, name), model in models.items():
        model.reset(RANDOM_SEED)
        fig, axes = plt.subplots(ncols=2, figsize=(20, 10), constrained_layout=True)

        refit_model = fit_round_trip(model, n=N, timepoints=T, use_structure=False)

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        savedir = FIG_DIR / "asymmetric_ts_no_structure"
        fig.savefig(
            savedir / f"{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()


if __name__ == "__main__":
    # configure_mpl()
    main()
