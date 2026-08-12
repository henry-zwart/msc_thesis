from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from climate_attitudes.visualisation import configure_mpl

np.set_printoptions(linewidth=200)

console = Console()


class RegularisationEBICPlotCommand(BaseCommand):
    asym_results: Path
    sym_results: Path
    z: float = 1.96
    output: Path | None = None

    def cli_cmd(self) -> None:
        configure_mpl()

        labels = ("Symmetric", "Asymmetric")
        colours = ("tab:blue", "tab:orange")
        all_results = (
            np.load(self.sym_results),
            np.load(self.asym_results),
        )

        fig, ax = plt.subplots(figsize=(5.25, 2), constrained_layout=True)

        for label, results, colour in zip(labels, all_results, colours, strict=True):
            λs = results["λs"]
            ebic = results["ebic"] - results["ebic"][:, 0][:, None]
            ebic_mean = ebic.mean(axis=0)
            # ebic_ci = self.z * ebic.std(axis=0, ddof=1) / np.sqrt(ebic.shape[0])

            # Plot means: line and scatter markers
            ax.plot(λs, ebic_mean, linewidth=1.5, color=colour, label=label)
            ax.scatter(λs, ebic_mean, s=5, linewidths=1.5, clip_on=False)
            # ax.errorbar(λs, ebic_mean, yerr=[ebic_ci, ebic_ci], capsize=4)

        ax.set_xscale("log")
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.set_xlabel(r"$\lambda$")
        ax.set_ylabel(r"$\Delta$EBIC")
        λ_min = min(all_results[0]["λs"].min(), all_results[1]["λs"].min())
        λ_max = max(all_results[0]["λs"].max(), all_results[1]["λs"].max())
        ax.set_xlim(λ_min, λ_max)

        ax.legend(
            ncol=2,
            loc="lower center",
            bbox_to_anchor=(0.5, 1.0),
            # fontsize=8,
            handlelength=1,
            # columnspacing=0.5,
            # labelspacing=0.2,
            frameon=False,
        )

        if self.output:
            fig.savefig(self.output, bbox_inches="tight")
            fig.savefig(str(self.output).replace(".pdf", ".png"), bbox_inches="tight")
        else:
            plt.show()
