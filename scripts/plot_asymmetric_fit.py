from pathlib import Path

import matplotlib.pyplot as plt
from ising.evaluation import round_trip
from ising.model_library.three import MODELS

# from climate_attitudes.visualisation import configure_mpl


def main():
    N = 1500
    T = 2

    FIG_DIR = Path("results/figures")

    for name, model in MODELS.items():
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = round_trip(model, n=N, timepoints=T).model

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        size = model.size
        fig.savefig(
            FIG_DIR / f"toy_model_fit_with_structure/{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()

    for name, model in MODELS.items():
        fig, axes = plt.subplots(ncols=2, figsize=(10, 5), constrained_layout=True)

        refit_model = round_trip(model, n=N, timepoints=T, use_structure=False).model

        # Draw original model
        model.draw(ax=axes[0])
        axes[0].set_title("Original model")

        # Draw refit model
        refit_model.draw(ax=axes[1], use_layout_from=model)
        axes[1].set_title("Fit model")

        size = model.size
        fig.savefig(
            FIG_DIR / f"toy_model_fit_without_structure/{name}_n{size}.pdf",
            dpi=200,
            bbox_inches="tight",
        )
        plt.close()


if __name__ == "__main__":
    # configure_mpl()
    main()
