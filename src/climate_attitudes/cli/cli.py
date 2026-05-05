from pydantic import BaseModel
from pydantic_settings import (
    CliApp,
    CliSubCommand,
)
from rich.console import Console

import climate_attitudes.datasets.behaviour as behaviour_ds
import climate_attitudes.datasets.full as full_ds
import climate_attitudes.datasets.reduced as reduced_ds
import climate_attitudes.datasets.reduced_no_imputation as reduced_no_imputation_ds
from climate_attitudes.cli import visualisation as vis_cli
from climate_attitudes.dataset import Dataset
from climate_attitudes.indices import IndexMethod

from .common import BaseCommand
from .info import DatasetInfoCommand, DisplayCodebookCommand, WaveInfoCommand

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


class CreateDerivedDatasetCommand(BaseCommand):
    name: str
    with_imputation: bool = False
    with_indices: bool = False
    index: IndexMethod
    centre_columns: bool = True
    force: bool = False
    filter_null: bool = False
    waves: list[int] = [1, 2, 3, 4, 5]
    sample: bool = False

    def cli_cmd(self) -> None:
        match self.name:
            case "full":
                ds_spec = full_ds
            case "reduced":
                ds_spec = reduced_ds
            case "behaviour":
                ds_spec = behaviour_ds
            case "reduced_no_imputation":
                ds_spec = reduced_no_imputation_ds
            case _:
                raise RuntimeError(f"Unknown dataset: '{self.name}'")

        ds = (
            Dataset.load(self.settings, name="base", with_imputation=False)
            .filter_columns(ds_spec.ALL_INPUT_COLUMNS)
            .filter_waves(self.waves)
        )

        if self.sample:
            ds.response = ds.response.collect().sample(fraction=0.35).lazy()  # ty: ignore

        if self.filter_null:
            ds = ds.filter_no_nulls()
        else:
            ds = ds.filter_at_least_one_resp(ds_spec.INPUT_QUESTION_COLUMNS)

        ds = (
            ds.cast_enum_to_int()
            .transform(*ds_spec.TRANSFORMS)
            .reverse_coding(ds_spec.REVERSE_CODING)
        )

        if not self.filter_null and self.with_imputation:
            ds = ds.impute_viterbi(ds_spec.VITERBI_IMPUTE_COLS).impute_fill(
                ds_spec.FILL_IMPUTE_COLS
            )

        if self.with_indices:
            ds = ds.compute_indices(ds_spec.GROUPS, self.index, self.centre_columns)

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
    dataset: CliSubCommand[CreateDerivedDatasetCommand]

    def cli_cmd(self) -> None:
        CliApp.run_subcommand(self)


class InfoSubCommand(BaseModel):
    codebook: CliSubCommand[DisplayCodebookCommand]
    dataset: CliSubCommand[DatasetInfoCommand]
    wave: CliSubCommand[WaveInfoCommand]

    def cli_cmd(self) -> None:
        CliApp.run_subcommand(self)


class PlotSubCommand(BaseModel):
    response_events: CliSubCommand[vis_cli.ResponseEventPlotCommand]
    interresponse_times: CliSubCommand[vis_cli.InterResponseTimePlotCommand]
    stratified_model: CliSubCommand[vis_cli.StratifiedIsingPlotCommand]

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
