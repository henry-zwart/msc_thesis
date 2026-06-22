import json
from pathlib import Path

import numpy as np
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand

np.set_printoptions(linewidth=200)

console = Console()


class ChooseRegularisationRunCommand(BaseCommand):
    asym_ebic_results: Path
    sym_ebic_results: Path
    output: Path

    def cli_cmd(self) -> None:
        all_results = (
            np.load(self.sym_ebic_results),
            np.load(self.asym_ebic_results),
        )
        labels = ("sym_ising", "ising")

        output = {}
        for label, results in zip(labels, all_results, strict=True):
            λs = results["λs"]
            mean_ebic = results["ebic"].mean(axis=0)
            # best_idx = np.argmin(mean_ebic)
            min_ebic = mean_ebic.min()
            # Choose maximum regularisation with |EBIC - min| < 2
            candidate_idxes = np.argwhere(mean_ebic - min_ebic < 2)
            output[label] = λs[candidate_idxes.max()]

            # best_λ = λs[best_idx]
            # output[label] = best_λ

        with self.output.open("w") as f:
            json.dump(output, f)
