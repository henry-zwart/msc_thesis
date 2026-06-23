import json
from pathlib import Path

import numpy as np
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand

np.set_printoptions(linewidth=200)

console = Console()


class ChooseRegularisationRunCommand(BaseCommand):
    full_asym_ebic_results: Path
    full_sym_ebic_results: Path
    liberal_asym_ebic_results: Path
    conservative_asym_ebic_results: Path
    output: Path

    def cli_cmd(self) -> None:
        all_results = {
            "ising": {
                "full": np.load(self.full_asym_ebic_results),
                "conservative": np.load(self.conservative_asym_ebic_results),
                "liberal": np.load(self.liberal_asym_ebic_results),
            },
            "sym_ising": {
                "full": np.load(self.full_sym_ebic_results),
            },
        }

        output = {"sym_ising": {}, "ising": {}}
        for model_type in ("sym_ising", "ising"):
            model_results = all_results[model_type]
            for subset in ("full", "conservative", "liberal"):
                if subset not in model_results:
                    continue
                results = model_results[subset]
                λs = results["λs"]
                mean_ebic = results["ebic"].mean(axis=0)
                output[model_type][subset] = λs[np.argmin(mean_ebic)]
                # Alternatively Choose maximum regularisation with |EBIC - min| < 2
                # min_ebic = mean_ebic.min()
                # candidate_idxes = np.argwhere(mean_ebic - min_ebic < 2)
                # output[model_type][subset] = λs[candidate_idxes.max()]

        with self.output.open("w") as f:
            json.dump(output, f)
