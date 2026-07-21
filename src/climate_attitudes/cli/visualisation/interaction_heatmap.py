from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from ising.model import ModelType
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from climate_attitudes.visualisation import DIVERGING_CMAP, configure_mpl
from ising import Ising

np.set_printoptions(linewidth=200)

console = Console()


class InteractionHeatmapPlotCommand(BaseCommand):
    model: Path
    output: Path | None = None
    model_type: ModelType

    def cli_cmd(self) -> None:
        configure_mpl()

        model_cls = self.model_type.get_cls()
        if not issubclass(model_cls, Ising):
            raise ValueError(
                f"Unsupported model_type: '{self.model_type}'. Expected 'ising' "
                f"or 'sym_ising'."
            )

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )
        labels = dataset.schema.get_short_names(kind="measurement")
        model_fit = np.load(self.model)

        # Get column indices, in case only a subset of cols were fit
        col_idxes = model_fit["col_idxes"]
        labels = [label for i, label in enumerate(labels) if i in col_idxes]

        # Determine number of covariates used for baseline activations
        k = model_fit["X"].shape[-1] if "X" in model_fit else 0

        # Extract interaction effect matrices from params
        params = model_fit["params"]
        # repeats = bootstrap_params.shape[0]
        # n = model_cls.unpack_params(bootstrap_params[0], k=k)[1].shape[0]
        # J = np.empty((repeats, n, n), dtype=np.float64)
        # for r in range(repeats):
        #     J[r] = model_cls.unpack_params(bootstrap_params[r], k=k)[1]
        J = model_cls.unpack_params(params, k=k)[1]
        J[abs(J) < 1e-2] = 0

        # Calculate mean interaction effect and CI
        # J_mean = J.mean(axis=0)
        # print(J_mean[0, 7])
        # J_ci = 1.97 * np.std(J, axis=0, ddof=1) / np.sqrt(repeats)
        # J_mean[(J_mean - J_ci < 0) & (J_mean + J_ci > 0)] = 0.0

        fig, ax = plt.subplots(figsize=(4, 3.7), constrained_layout=True)
        ax.set_aspect("equal")
        # Set vlim to max non-diag
        non_diag_J = J.copy()
        non_diag_J[np.diag_indices_from(non_diag_J)] = 0.0
        # vlim = np.abs(non_diag_J).max()
        vlim = 0.35
        # vlim = np.percentile(abs(J_mean), 90)
        sns.heatmap(
            J,
            annot=True,
            fmt=".2f",
            linewidth=1,
            cmap=DIVERGING_CMAP,
            center=0.0,
            vmin=-vlim,
            vmax=vlim,
            ax=ax,
            cbar_kws=dict(fraction=0.05, pad=0.04),
        )
        ax.set_yticks(np.arange(len(labels)) + 0.5, labels, rotation=0)
        ax.set_xticks(
            np.arange(len(labels)) + 0.5,
            labels,
            rotation=90,
            # horizontalalignment="right",
        )

        # ax.legend(
        #     ncol=2,
        #     loc="lower center",
        #     bbox_to_anchor=(0.5, 1.0),
        #     # fontsize=8,
        #     # handlelength=1,
        #     # columnspacing=0.5,
        #     # labelspacing=0.2,
        #     frameon=False,
        # )

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
            fig.savefig(str(self.output).replace(".pdf", ".png"), bbox_inches="tight")
        else:
            plt.show()
