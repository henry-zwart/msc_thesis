from __future__ import annotations

from pathlib import Path

import numpy as np
from ising.model import ModelType

from climate_attitudes.cli.common import BaseCommand

np.set_printoptions(linewidth=200)


class AllInterventionsPlotCommand(BaseCommand):
    output: Path | None = None

    model_type: ModelType
    stratify: str
    seed: int = 202604281551

    fit_indices: bool = True

    def cli_cmd(self) -> None: ...
