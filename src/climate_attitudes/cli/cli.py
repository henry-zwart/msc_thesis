from climate_attitudes.cli.visualisation.response_eventplot import (
    ResponseEventPlotCommand,
)
from climate_attitudes.dataset import Dataset
from pydantic import BaseModel
from pydantic_settings import (
    CliApp,
    CliSubCommand,
)
from rich.console import Console
from .common import BaseCommand
from .info import DatasetInfoCommand, WaveInfoCommand

import climate_attitudes.datasets.imputed as imp_ds
import climate_attitudes.datasets.imputed_reduced as red_ds

console = Console()


class BuildDataCommand(BaseCommand):
    prune_error_participants: bool = False
    filter_valid: bool = False

    def cli_cmd(self) -> None:
        ds = Dataset(self.settings).build(
            self.prune_error_participants,
            self.filter_valid,
        )
        ds.write(force=True)


class CreateImputedDatasetCommand(BaseCommand):
    name: str
    force: bool = False

    def cli_cmd(self) -> None:
        match self.name:
            case "ds1":
                ds_spec = imp_ds
            case "ds1_5":
                ds_spec = red_ds
            case _:
                raise RuntimeError(f"Unknown dataset: '{self.name}'")

        ds = (
            Dataset.load(self.settings)
            .filter_columns(ds_spec.ALL_INPUT_COLUMNS)
            .filter_at_least_one_resp(ds_spec.INPUT_QUESTION_COLUMNS)
            .cast_enum_to_int()
            .transform(*ds_spec.TRANSFORMS)
            .reverse_coding(ds_spec.REVERSE_CODING)
            .impute_viterbi(ds_spec.VITERBI_IMPUTE_COLS)
            .impute_fill(ds_spec.FILL_IMPUTE_COLS)
        )

        # wtp_solve_model = WTPModel(ds.response.collect(), col="ccSolving", k=5)
        # wtp_solve_model.sample()
        # wtp_solve = wtp_solve_model.wtp(ds.response.collect())
        #
        # wtp_compensation_model = WTPModel(
        #     ds.response.collect(), col="ccCompensation", k=5
        # )
        # wtp_compensation_model.sample()
        # wtp_compensation = wtp_compensation_model.wtp(ds.response.collect())
        #
        # ds.response = ds.response.with_columns(
        #     wtp_solve=wtp_solve, wtp_compensation=wtp_compensation
        # ).drop(
        #     "ccSolving",
        #     "ccCompensation",
        #     "Variant_ccSolving",
        #     "Variant_ccCompensation",
        #     "dem_age",
        #     "dem_income",
        # )

        ds.write(name=self.name, force=self.force)


class CreateSubCommand(BaseModel):
    base_dataset: CliSubCommand[BuildDataCommand]
    imputed_dataset: CliSubCommand[CreateImputedDatasetCommand]

    def cli_cmd(self) -> None:
        CliApp.run_subcommand(self)


class InfoSubCommand(BaseModel):
    dataset: CliSubCommand[DatasetInfoCommand]
    wave: CliSubCommand[WaveInfoCommand]

    def cli_cmd(self) -> None:
        CliApp.run_subcommand(self)


class PlotSubCommand(BaseModel):
    response_events: CliSubCommand[ResponseEventPlotCommand]

    def cli_cmd(self) -> None:
        CliApp.run_subcommand(self)


class CAData(
    BaseModel,
    cli_parse_args=True,
    cli_exit_on_error=False,
    cli_use_class_docs_for_groups=True,
    cli_kebab_case=True,
):
    """Climate attitudes dataset CLI."""

    build: CliSubCommand[BuildDataCommand]
    create: CliSubCommand[CreateSubCommand]
    info: CliSubCommand[InfoSubCommand]
    plot: CliSubCommand[PlotSubCommand]

    def cli_cmd(self):
        """Run the CLI application."""
        CliApp.run_subcommand(self)


def main():
    CliApp.run(CAData)
    # try:
    #     CliApp.run(CAData)
    # except KeyboardInterrupt:
    #     console.print("\n[yellow]Operation cancelled by user[/yellow]")
    #     sys.exit(1)
    # except Exception as e:
    #     console.print(f"[bold red]Unexpected error: {e}[/bold red]")
    #     sys.exit(1)


if __name__ == "__main__":
    main()
