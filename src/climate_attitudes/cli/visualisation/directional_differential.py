from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.dataset import Dataset
from climate_attitudes.datasets import reduced_no_imputation as ds_spec
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)

console = Console()


class DirectionalDifferentialPlotCommand(BaseCommand):
    measurements: Path
    output: Path | None = None

    def cli_cmd(self) -> None:
        configure_mpl()

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )

        labels = dataset.schema.get_short_names(kind="measurement")

        measurements = np.load(self.measurements)
        mean_diff = measurements.mean(axis=0)
        ci = (
            1.97 * np.std(measurements, axis=0, ddof=1) / np.sqrt(measurements.shape[0])
        )

        fig, ax = plt.subplots(figsize=(5, 6), constrained_layout=True)

        # Scatter means
        n = measurements.shape[-1]
        mean_diffs_flat = mean_diff[np.triu_indices_from(mean_diff, k=1)]
        ci_flat = ci[np.triu_indices_from(ci, k=1)]
        ax.scatter(
            mean_diffs_flat,
            np.arange(n * (n - 1) // 2),
            color="k",
            s=14,
            zorder=5,
            label="Mean effect difference",
        )

        # Show ci interval as red shaded region
        marker, _, bar = ax.errorbar(
            mean_diffs_flat,
            np.arange(n * (n - 1) // 2),
            xerr=np.array([ci_flat, ci_flat]),
            ls="none",
            zorder=3,
            color="tab:red",
            label="95% CI",
        )
        plt.setp(bar[0], capstyle="round")
        marker.set_fillstyle("none")
        bar[0].set_alpha(0.5)
        bar[0].set_linewidth(5)

        # Draw 0.0 as dashed
        ax.axvline(x=0, linestyle="dashed", linewidth=0.75, color="gray", zorder=1)

        ylabels = []
        colnames = [ds_spec.RENAME.get(colname, colname) for colname in labels]
        for i in range(n - 1):
            for j in range(i + 1, n):
                c1 = colnames[i]
                c2 = colnames[j]
                ylabels.append(f"{c1} -> {c2}")

        ax.set_yticks(np.arange(len(ylabels)), ylabels)

        ax.legend(
            ncol=2,
            loc="lower center",
            bbox_to_anchor=(0.5, 1.0),
            # fontsize=8,
            # handlelength=1,
            # columnspacing=0.5,
            # labelspacing=0.2,
            frameon=False,
        )

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
        else:
            plt.show()
