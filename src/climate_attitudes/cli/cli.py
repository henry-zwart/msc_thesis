import json
from enum import StrEnum

import numpy as np
import polars as pl
from ising.console import get_console
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
from climate_attitudes.cli import analysis as analysis_cli
from climate_attitudes.cli import visualisation as vis_cli
from climate_attitudes.dataset import Dataset
from climate_attitudes.exceptions import DatasetExistsException
from climate_attitudes.indices import IndexMethod

from .common import BaseCommand
from .info import DatasetInfoCommand, DisplayCodebookCommand, WaveInfoCommand

console = Console()


class SpinStateKind(StrEnum):
    BINARY = "binary"
    POLARITY = "polarity"
    TERNARY = "ternary"


class BuildDataCommand(BaseCommand):
    prune_error_participants: bool = False
    filter_valid: bool = False

    def cli_cmd(self) -> None:
        ds = Dataset(self.settings, schema=full_ds.schema).build(
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
                raise RuntimeError("Not supported: 'behaviour'")
            case "reduced_no_imputation":
                ds_spec = reduced_no_imputation_ds
            case _:
                raise RuntimeError(f"Unknown dataset: '{self.name}'")

        ds = (
            Dataset.load(self.settings, name="base", with_imputation=False)
            .filter_columns(ds_spec.ALL_INPUT_COLUMNS)
            .filter_waves(self.waves)
        )
        ds.schema = ds_spec.schema.post_index()

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


class CreateIsingDatasetCommand(BaseCommand):
    name: str
    force: bool = False
    kind: SpinStateKind = SpinStateKind.POLARITY
    tau: float = 0.1
    seed: int

    def cli_cmd(self) -> None:
        ds_spec = reduced_no_imputation_ds

        dataset = Dataset.load(
            self.settings,
            name="reduced_no_imputation",
            with_imputation=False,
            verbose=False,
        )
        if dataset.indices is None:
            raise RuntimeError("Shouldn't happen.")
        indices = (
            dataset.indices.collect().sort(by=("participant_id", "wave"))  # ty: ignore
        )

        _beliefs = indices.drop(
            "participant_id", "wave", *ds_spec.DEMOGRAPHIC_COLS
        ).to_numpy()
        _covariates = indices.select(*ds_spec.DEMOGRAPHIC_COLS)

        rng = np.random.default_rng(self.seed)
        _beliefs = _beliefs + rng.logistic(scale=0.1, size=_beliefs.size).reshape(
            _beliefs.shape
        )

        # Convert beliefs to desired format
        beliefs = np.full_like(_beliefs, fill_value=-99, dtype=np.int64)
        match self.kind:
            case SpinStateKind.BINARY:
                beliefs[_beliefs < -self.tau] = 0
                beliefs[_beliefs > self.tau] = 1
            case SpinStateKind.POLARITY:
                beliefs[_beliefs < -self.tau] = -1
                beliefs[_beliefs > self.tau] = 1
            case SpinStateKind.TERNARY:
                beliefs[...] = 0
                beliefs[_beliefs < -self.tau] = -1
                beliefs[_beliefs > self.tau] = 1

        # For intermediate values in BINARY and POLARITY, randomly assign to either
        # extreme
        # TODO: This could be done in a smarter way. Perhaps we can:
        # 1. Deal with missing values explicitly,
        # 2. Assign intermediate values to same value for a given individual, or
        # 3. Assign intermediate values to known value for individual when possible.
        # As first order of business, determine how often these values occur.
        if self.kind == SpinStateKind.TERNARY:
            imputed_beliefs = None
        else:
            match self.kind:
                case SpinStateKind.BINARY:
                    spin_states = (0, 1)
                case SpinStateKind.POLARITY:
                    spin_states = (-1, 1)
            rng = np.random.default_rng(self.seed)
            middle_response = beliefs == -99
            imputed_beliefs = beliefs.copy()
            imputed_beliefs[middle_response] = rng.choice(
                spin_states, size=middle_response.sum()
            )

        # Convert back into DataFrame
        belief_cols = indices.drop(
            "participant_id", "wave", *ds_spec.DEMOGRAPHIC_COLS
        ).columns
        beliefs = pl.DataFrame(dict(zip(belief_cols, beliefs.T, strict=True)))
        if imputed_beliefs is not None:
            imputed_beliefs = pl.DataFrame(
                dict(zip(belief_cols, imputed_beliefs.T, strict=True))
            )

        # Extract and standardise covariates
        covariates = (
            _covariates.select(
                pl.col("dem_male", "dem_educ", "dem_income_percep"),
                (pl.col("dem_urban") == 0).cast(int).alias("dem_urban: urban"),
                (pl.col("dem_urban") == 1).cast(int).alias("dem_urban: suburban"),
                (pl.col("dem_urban") == 2).cast(int).alias("dem_urban: rural"),
            )
            .select(pl.all().cast(pl.Float64))
            .select((pl.all() - pl.all().mean()) / pl.all().std())
        )

        # Recombine data
        base = pl.concat(
            (
                indices.select("participant_id", "wave").select(
                    pl.all().name.prefix("survey_")
                ),
                covariates.select(pl.all().name.prefix("covariate_")),
            ),
            how="horizontal",
        )
        model_data = pl.concat(
            (base, beliefs.select(pl.all().name.prefix("belief_"))), how="horizontal"
        )
        if imputed_beliefs is not None:
            model_data_imputed = pl.concat(
                (base, imputed_beliefs.select(pl.all().name.prefix("belief_"))),
                how="horizontal",
            )
        else:
            model_data_imputed = None

        # Write data
        dir = self.settings.built_assets / self.name
        if (dir / "metadata.json").exists() and not self.force:
            raise DatasetExistsException(
                f"There is already a dataset named '{self.name}' at {dir} (found "
                f"`metadata.json` file). Pass `force=True` to overwrite it."
            )
        if (dir / "metadata.json").exists() and not self.force:
            console = get_console()
            console.print(f"Overwriting existing dataset at {dir}")
        else:
            dir.mkdir(parents=True, exist_ok=True)

        model_data.write_parquet(dir / "model_data.parquet")
        if model_data_imputed is not None:
            model_data_imputed.write_parquet(dir / "model_data_imputed.parquet")

        metadata = {
            "name": self.name,
            "kind": self.kind,
            "tau": self.tau,
            "seed": self.seed,
        }
        with (dir / "metadata.json").open("w") as f:
            json.dump(metadata, f)


class CreateSubCommand(BaseModel):
    base_dataset: CliSubCommand[BuildDataCommand]
    dataset: CliSubCommand[CreateDerivedDatasetCommand]
    ising_data: CliSubCommand[CreateIsingDatasetCommand]

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
    directional_differentials: CliSubCommand[vis_cli.DirectionalDifferentialPlotCommand]
    intervention_mean_effects: CliSubCommand[vis_cli.InterventionMeanEffectsPlotCommand]
    intervention_effect_distribution: CliSubCommand[
        vis_cli.InterventionEffectDisPlotCommand
    ]
    intervention_mean_collective_effect: CliSubCommand[
        vis_cli.InterventionCollectiveEffectPlotCommand
    ]
    intervention_mean_collective_rank: CliSubCommand[
        vis_cli.InterventionCollectiveRankPlotCommand
    ]
    interaction_heatmap: CliSubCommand[vis_cli.InteractionHeatmapPlotCommand]
    regularisation_ebic: CliSubCommand[vis_cli.RegularisationEBICPlotCommand]

    def cli_cmd(self) -> None:
        CliApp.run_subcommand(self)


class AnalysisSubCommand(BaseModel):
    fit_bootstrapped: CliSubCommand[analysis_cli.FitBootstrappedModelsRunCommand]
    fit_model: CliSubCommand[analysis_cli.FitModelRunCommand]
    all_interventions: CliSubCommand[analysis_cli.AllInterventionsRunCommand]
    regularisation_ebic: CliSubCommand[analysis_cli.CompareRegularisationEBICRunCommand]
    choose_regularisation: CliSubCommand[analysis_cli.ChooseRegularisationRunCommand]

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
    analysis: CliSubCommand[AnalysisSubCommand]
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
