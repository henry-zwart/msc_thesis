from climate_attitudes.builder.schema import (
    ClimateAttitudesSchema,
    DISPLAY_LOGIC_COLUMNS,
    GROUP_COLUMNS,
    NULL_ERROR_COLUMNS,
    ClimateAttitudesNullResponses,
)
import polars as pl
import polars.selectors as cs
from climate_attitudes.settings import Config, RawDataFile, BuiltAsset


def remove_null_pids(lf: pl.LazyFrame) -> pl.LazyFrame:
    return lf.filter(pl.col("PID").is_not_null())


def clean_schema(lf: pl.LazyFrame) -> pl.LazyFrame:
    return (
        lf
        # Replace "dots" with double underscore for Python compatibility
        .rename(lambda column_name: column_name.replace(".", "__"))
        # Manual replacements
        .rename(
            {
                "WAVE": "wave",
                "PID": "participant_id",
                "StartDate": "start_date",
                "EndDate": "end_date",
            }
        )
        .with_columns(cs.integer().cast(pl.Int64))
        .with_columns(
            pl.col("wave").cast(pl.Int64),
            pl.col("participant_id").cast(pl.Int64),
            pl.col("dem_age").cast(pl.Int64),
            pl.col("start_date", "end_date").str.strptime(
                pl.Datetime, format="%-m/%-d/%y %R", strict=True
            ),
        )
    )


def filter_columns(lf: pl.LazyFrame) -> pl.LazyFrame:
    keep_cols = list(ClimateAttitudesSchema.build_schema_().columns.keys())
    return lf.select(*keep_cols)


def nullify_empty_strings(lf: pl.LazyFrame) -> pl.LazyFrame:
    cols = [
        "dem_male_77_TEXT",
        "ew1",
        "ew1_apr",
        "ew1_jun",
        "ew1_nov",
        "attr_storm_6_TEXT",
        "attr_outage_13_TEXT",
        "cc13",
        "cc13_apr",
        "cvcc8a__opp",
        "cvcc8a__supp",
        "cvcc8a__opp_6_TEXT",
        "cvcc8a__supp_8_TEXT",
        "cv__priority_7_TEXT",
        "cv__priority2_7_TEXT",
    ]
    return lf.with_columns(
        pl.col(cols).replace("", None),
    )


def split_multichoice_strings(lf: pl.LazyFrame) -> pl.LazyFrame:
    cols = [
        "ew1",
        "ew1_apr",
        "ew1_jun",
        "ew1_nov",
        "attr_storm",
        "attr_outage",
        "cc13",
        "cc13_apr",
        "cc_policybenefit",
        "cvcc8a__opp",
        "cvcc8a__supp",
    ]
    return lf.with_columns(
        pl.col(cols).str.split(",").list.eval(pl.element().cast(pl.Int64))
    )


def filter_out_problem_participants(response: pl.LazyFrame, config: Config):
    """Remove participants who respond to "repeating-only" questions on first survey."""
    problem_participants = (
        unpivot_response_with_question_metadata(
            response.drop(
                "start_date", "end_date", *DISPLAY_LOGIC_COLUMNS, GROUP_COLUMNS
            ),
            config,
        )
        .filter(
            # New respondent responds to repeating-only question
            (
                pl.col("is_new_participant")
                & ~pl.col("new_participants")
                & pl.col("response").is_not_null()
            )
            |
            # Repeating respondent responds to new-only question
            (
                ~pl.col("is_new_participant")
                & ~pl.col("repeating_participants")
                & pl.col("response").is_not_null()
            )
        )
        .select(pl.col("participant_id").unique(maintain_order=True))
    )

    # Remove those participants' responses from data
    return response.join(problem_participants, on="participant_id", how="anti")


def load_w1_to_5_response_data(config: Config) -> pl.LazyFrame:
    lf = RawDataFile.Waves1to5Responses.scan(config)

    lf = filter_columns(lf)

    # Column transformations
    lf = nullify_empty_strings(lf)
    lf = split_multichoice_strings(lf)

    # Validate schema
    return ClimateAttitudesSchema.validate(lf)


def unpivot_response_with_question_metadata(
    response: pl.LazyFrame, config: Config
) -> pl.LazyFrame:
    question = BuiltAsset.Question.scan(config)
    return (
        response.with_columns(
            (
                (pl.col("wave") == pl.col("wave").min().over("participant_id")).alias(
                    "is_new_participant"
                )
            )
        )
        # Convert list columns to string so we can unpivot them
        .with_columns(cs.list().cast(pl.List(pl.String)).list.join(","))
        .unpivot(
            index=["participant_id", "wave", "is_new_participant"],
            variable_name="item_name",
            value_name="response",
        )
        # Join Question on item_name and wave
        .join(
            question.select(
                "question_id",
                "item_name",
                "wave",
                "new_participants",
                "repeating_participants",
            ),
            on=("item_name", "wave"),
            how="left",
        )
    )


def resolve_schema_errors(response: pl.LazyFrame, config: Config) -> pl.LazyFrame:
    """Resolve errors in response data, which don't match codebook.

    For instance, ew1 column contains both null and [0] ("none of the above") responses
    for valid waves and respondents. We correct these cases to [0].
    """
    ...
    return response
    # return (
    #         response
    #     .with_columns(
    #         pl.when
    #     )
    # )


def validate_resp_null_when_question_not_asked(response: pl.LazyFrame, config: Config):
    assert (
        unpivot_response_with_question_metadata(
            response.drop("start_date", "end_date", GROUP_COLUMNS),
            config,
        )
        .select(
            (
                # Response should be None when question_id null (not asked in wave)
                (pl.col("question_id").is_not_null() | pl.col("response").is_null())
                |
                # Or when question is only for new participants, but participant repeating
                (~pl.col("repeating_participants") & ~pl.col("is_new_participant"))
                |
                # Or when question is only for repeating participants, but participant new
                (~pl.col("new_participants") & pl.col("is_new_participant"))
            ).alias("asked_in_wave")
        )
        .select(pl.col("asked_in_wave").all())
        .collect()
        .item()
    )


def validate_resp_not_null_when_question_asked(response: pl.LazyFrame, config: Config):
    """Check that responses are not null when participants should have answered.

    Conditions:
    - Question asked in given wave
    - Question presented to new (returning) participants and respondent is new
        (returning)
    - Question display logic is satisfied
    """
    response = response.drop("start_date", "end_date")

    # First check columns with no display logic requirements
    assert (
        (
            unpivot_response_with_question_metadata(
                response.drop(*NULL_ERROR_COLUMNS, *DISPLAY_LOGIC_COLUMNS),
                config,
            )
            .filter(
                # Filter out rows corresponding to waves where Q not asked
                pl.col("question_id").is_not_null(),
                # Filter out rows with new respondents where question only for repeat
                ~(pl.col("is_new_participant") & ~pl.col("new_participants")),
                # Filter out rows with repeating respondents where question only for new
                ~(~pl.col("is_new_participant") & ~pl.col("repeating_participants")),
            )
            # Check all responses not null
            .select(pl.col("response").is_not_null().all())
        )
        .collect()
        .item()
    )

    # Then check column-specific display logic
    # Prepare response for repeated unpivots
    response = (
        response.with_columns(
            (pl.col("wave") == pl.col("wave").min().over("participant_id")).alias(
                "is_new_participant"
            )
        )
        # Convert list columns to string so we can unpivot them
        .with_columns(cs.list().cast(pl.List(pl.String)).list.join(","))
    )

    question = BuiltAsset.Question.scan(config).select(
        "item_name", "wave", "new_participants", "repeating_participants"
    )

    def check_conditional_item_not_null(item_name: str, condition: pl.Expr):
        return (
            response.filter(condition)
            .select("wave", "is_new_participant", item_name)
            .join(question.filter(pl.col("item_name") == item_name), on="wave")
            .filter(
                (pl.col("is_new_participant") & pl.col("new_participants"))
                | (~pl.col("is_new_participant") & pl.col("repeating_participants"))
            )
            .select(pl.col(item_name).is_not_null().all())
            .collect()
            .item()
        ) & (
            response.filter(~condition)
            .select("wave", "is_new_participant", item_name)
            .join(question.filter(pl.col("item_name") == item_name), on="wave")
            .filter(
                (pl.col("is_new_participant") & pl.col("new_participants"))
                | (~pl.col("is_new_participant") & pl.col("repeating_participants"))
            )
            .select(pl.col(item_name).is_null().all())
            .collect()
            .item()
        )

    # TODO: Also require null when condition not met.
    item_conditions = {
        "ew_attribution": pl.col("ew1") != "0",
        "ew_attribution_apr": pl.col("ew1_apr") != "0",
        "ew_attribution_jun": pl.col("ew1_jun") != "0",
        "ew_attribution_nov": pl.col("ew1_nov") != "0",
        "ccComp100": pl.col("WTP100") == 1,
        "ccComp50": ((pl.col("WTP50") == 1) & (pl.col("wave") != 1))
        | ((pl.col("WTP10") == 1) & (pl.col("wave") == 1)),
        "ccComp25": pl.col("WTP5") == 1,
        "ccComp10": ((pl.col("WTP10") == 1) & (pl.col("wave") != 1))
        | ((pl.col("WTP3") == 1) & (pl.col("wave") == 1)),
        "ccComp1": pl.col("WTP1") == 1,
        "ccComp0": pl.col("WTP0") == 1,
        "ccSolve100": pl.col("WTP100") == 1,
        "ccSolve50": pl.col("WTP50") == 1,
        "ccSolve10": pl.col("WTP10") == 1,
        "ccSolve1": pl.col("WTP1") == 1,
        "ccSolve0": pl.col("WTP0") == 1,
        "ccIO": (pl.col("GroupCCIO") == 1)
        & ((pl.col("wave") > 1) | (pl.col("GroupNoUSinterest") == 1)),
        "ccIOinterest": pl.all_horizontal(pl.col("GroupCCIO", "GroupUSinterest") == 1),
        "ccGovt": (pl.col("GroupCCGovt") == 1)
        & ((pl.col("wave") > 1) | (pl.col("GroupNoUSinterest") == 1)),
        "ccGovtinterest": pl.all_horizontal(
            pl.col("GroupCCGovt", "GroupUSinterest") == 1
        ),
        "dustin_support": pl.any_horizontal(
            pl.col("dustin_ques_64", "dustin_ques_256") == 1
        ),
        "dustin_oppose": pl.any_horizontal(
            pl.col("dustin_ques_64", "dustin_ques_256") == 0
        ),
        "cvcc6": (pl.col("wave") == 1) | (pl.col("Groupcvcc_5and6") == 1),
        # "cvcc7a": (pl.col("GroupGreenInfrastructure") == 1) # NOTE: Broken.
        # & ((pl.col("wave") != 2) | (pl.col("Groupcvcc7show") == 1)),
        "cvcc8a__opp": pl.col("cvcc7a").is_in([1, 2]),
        "cvcc8a__supp": pl.col("cvcc7a").is_in([4, 5]),
        "cvccAirDemHealth": pl.col("GroupAirDemHealth") == 1,
        "cvccAirRepHealth": pl.col("GroupAirRepHealth") == 1,
        "cvccAirHealth": pl.col("GroupAirHealth") == 1,
        "cvccAirDemCC": pl.col("GroupAirDemCC") == 1,
        "cvccAirRepCC": pl.col("GroupAirRepCC") == 1,
        "cvccAirCC": pl.col("GroupAirCC") == 1,
        "cvcc10_cc": (pl.col("wave") != 2) | (pl.col("Groupcvcc10") == 1),
        "pol_lean": pl.col("pol_party") == 3,
        "pol_vote_CCdem": (pl.col("GroupVoteCC") == 1)
        & pl.any_horizontal(pl.col("pol_party", "pol_lean") == 2),
        "pol_vote_CCrep": (pl.col("GroupVoteCC") == 1)
        & pl.any_horizontal(pl.col("pol_party", "pol_lean") == 1),
    }

    for item_name, condition in item_conditions.items():
        assert check_conditional_item_not_null(item_name, condition), (
            f"Conditional column {item_name} has unexpected response values."
        )


def build_response_table(
    config: Config,
) -> pl.DataFrame:
    response = load_w1_to_5_response_data(config)
    response = resolve_schema_errors(response, config)
    validate_resp_null_when_question_not_asked(response, config)
    validate_resp_not_null_when_question_asked(response, config)
    ClimateAttitudesNullResponses.validate(response, config)
    return response.collect()
