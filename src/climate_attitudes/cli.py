from climate_attitudes.builder.item_columns import build_item_columns_table
from climate_attitudes.builder.participant import build_participant_table
from climate_attitudes.builder.response import build_response_table
from climate_attitudes.builder.question import build_question_table
from climate_attitudes.builder.codebook import build_codebook
from climate_attitudes.builder.item import build_item_table
from pathlib import Path
from pydantic import BaseModel
from pydantic_settings import (
    BaseSettings,
    CliApp,
    CliSubCommand,
    SettingsConfigDict,
)
from rich.console import Console

from climate_attitudes.settings import Config, BuiltAsset

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


class BuildCodebookCommand(BaseCommand):
    def cli_cmd(self) -> None:
        codebook = build_codebook(self.settings)
        codebook.write_parquet(BuiltAsset.Codebook.filepath(self.settings))


class BuildItemCommand(BaseCommand):
    def cli_cmd(self) -> None:
        item_table = build_item_table(self.settings)
        BuiltAsset.Item.write(item_table, self.settings)


class BuildQuestionCommand(BaseCommand):
    def cli_cmd(self) -> None:
        question_table = build_question_table(self.settings)
        BuiltAsset.Question.write(question_table, self.settings)


class BuildItemColumnsCommand(BaseCommand):
    def cli_cmd(self) -> None:
        columns = build_item_columns_table(self.settings)
        BuiltAsset.ItemColumns.write(columns, self.settings)


class BuildParticipantCommand(BaseCommand):
    def cli_cmd(self) -> None:
        participant_table = build_participant_table(self.settings)
        BuiltAsset.Participant.write(participant_table, self.settings)


class BuildResponseCommand(BaseCommand):
    def cli_cmd(self) -> None:
        response_table = build_response_table(self.settings)
        BuiltAsset.Response.write(response_table, self.settings)


class BuildCommand(BaseModel):
    """Extract, clean, and build climate attitudes dataset."""

    codebook: CliSubCommand[BuildCodebookCommand]
    item: CliSubCommand[BuildItemCommand]
    question: CliSubCommand[BuildQuestionCommand]
    item_columns: CliSubCommand[BuildItemColumnsCommand]
    participant: CliSubCommand[BuildParticipantCommand]
    response: CliSubCommand[BuildResponseCommand]

    def cli_cmd(self):
        """Run the CLI application."""
        CliApp.run_subcommand(self)


class CAData(
    BaseModel,
    cli_parse_args=True,
    cli_exit_on_error=False,
    cli_use_class_docs_for_groups=True,
    cli_kebab_case=True,
):
    """Climate attitudes dataset CLI."""

    build: CliSubCommand[BuildCommand]

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
