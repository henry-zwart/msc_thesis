from climate_attitudes.dataset import Dataset
from pathlib import Path
from pydantic import BaseModel
from pydantic_settings import (
    BaseSettings,
    CliApp,
    CliSubCommand,
    SettingsConfigDict,
)
from rich.console import Console

from climate_attitudes.settings import Config
import climate_attitudes.datasets.imputed as imp_ds
import climate_attitudes.datasets.imputed_reduced as red_ds

console = Console()


class BaseCommand(BaseSettings):
    """Base command with common settings."""

    # raw_assets_path: Path
    raw_assets: Path = Path("assets/raw")
    static_assets: Path = Path("assets/static")
    built_assets: Path = Path("assets/built")

    model_config = SettingsConfigDict(env_file=".env", env_prefix="CA_", extra="ignore")

    @property
    def settings(self) -> Config:
        """Get the settings."""
        return Config(
            raw_assets=self.raw_assets,
            static_assets=self.static_assets,
            built_assets=self.built_assets,
        )


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
            .filter_columns(ds_spec.ALL_COLS)
            .filter_at_least_one_resp(ds_spec.QUESTION_COLS)
            .cast_enum_to_int()
            .transform(*ds_spec.TRANSFORMS)
            .reverse_coding(ds_spec.REVERSE_CODING)
            .impute_viterbi(ds_spec.QUESTION_COLS)
        )
        ds.write(name=self.name, force=self.force)


class CreateSubCommand(BaseModel):
    base_dataset: CliSubCommand[BuildDataCommand]
    imputed_dataset: CliSubCommand[CreateImputedDatasetCommand]

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
