from climate_attitudes.dataset import Dataset
from climate_attitudes.builder.raw_data import extract_raw_data
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


class ExtractRawDataCommand(BaseCommand):
    def cli_cmd(self) -> None:
        extract_raw_data(self.settings)


class BuildDataCommand(BaseCommand):
    def cli_cmd(self) -> None:
        ds = Dataset(self.settings).build()
        ds.write()


class CAData(
    BaseModel,
    cli_parse_args=True,
    cli_exit_on_error=False,
    cli_use_class_docs_for_groups=True,
    cli_kebab_case=True,
):
    """Climate attitudes dataset CLI."""

    extract: CliSubCommand[ExtractRawDataCommand]
    build: CliSubCommand[BuildDataCommand]

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
