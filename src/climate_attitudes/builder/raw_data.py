from climate_attitudes.settings import Config, InterimAsset
from climate_attitudes.builder.extract.item_columns import build_item_columns_table
from climate_attitudes.builder.extract.participant import build_participant_table
from climate_attitudes.builder.extract.response import build_response_table
from climate_attitudes.builder.extract.question import build_question_table
from climate_attitudes.builder.extract.codebook import build_codebook
from climate_attitudes.builder.extract.item import build_item_table


def extract_raw_data(config: Config):
    """Extract codebook and raw survey data into validated, normalised format."""

    codebook = build_codebook(config)
    InterimAsset.Codebook.write(codebook, config)

    item_table = build_item_table(config)
    InterimAsset.Item.write(item_table, config)

    question_table = build_question_table(config)
    InterimAsset.Question.write(question_table, config)

    columns = build_item_columns_table(config)
    InterimAsset.ItemColumns.write(columns, config)

    response_table = build_response_table(config)
    InterimAsset.Response.write(response_table, config)

    participant_table = build_participant_table(config)
    InterimAsset.Participant.write(participant_table, config)
