"""
Errors:
-------

- PID: Sometimes null.
- We also have null values in cvcc7a. Wave 3, GroupGreenInfrastructure == 1 but
    response is null.

To check:
---------

- cc_timeframe_w4new: Codebook says originally coded as Q423. Check if this also means the question was asked prior to wave 4.
- pol7_DO: Is this question ordering? Entries are of form "1|2", "2|1"
"""

# TODO: Refactor response schema into single defined object which generates
# pandera schema as required --- to avoid the multiple definitions currently
# required for each column, and simplify treatment group logic.

from __future__ import annotations
from climate_attitudes.schema.columns import (
    ConditionGroup,
    ConditionalColumn,
    GroupColumn,
)
from climate_attitudes.settings import Config, InterimAsset
from climate_attitudes.schema.constants import WAVES
import polars as pl
import polars.selectors as cs
import pandera.polars as pa
from pandera.polars import PolarsData
from .enums import (
    ResponseType,
    ParticipantType,
    Education,
    StateAbbrev,
    NaturalDisaster,
    Gender,
    StormAttribution,
    OutageAttribution,
    ClimateChangeCause,
    ClimateChangeInducedAction,
    ClimatePolicyBenefit,
    ReasonOpposeGreenInfra,
    ReasonSupportGreenInfra,
    ReasonOpposeInfra,
    ReasonSupportInfra,
    CovidPolicyFlowonPriority,
    PoliticalParty,
    PoliticalLeaning,
)


"""Columns for which Null is a valid response."""
NULLABLE_COLUMNS: list[str] = [
    "dem_male_77_TEXT",
    "attr_storm_6_TEXT",
    "attr_outage_13_TEXT",
    "cvcc8a__opp_6_TEXT",
    "cvcc8a__supp_8_TEXT",
    "cvcc8b__opp_6_TEXT",
    "cvcc8b__supp_6_TEXT",
]

# Columns requiring response re-map via subtraction by 1
RESPONSE_REMAP_SUB_1 = {
    "dem_educ",
    "attr_storm",
    "attr_outage",
    "cc2",
    "cvcc8a__opp",
    "cvcc8a__supp",
    "cvcc8b__opp",
    "cvcc8b__supp",
    "pol_party",
    "pol_lean",
}

# Columns with additional required re-maps.
# NOTE: Happens after RESPONSE_REMAP_SUB_1
RESPONSE_REMAP = {
    "dem_male": {77: 2},
    "attr_outage": {12: 11, 11: 10, 10: 9, 9: 8, 8: 7, 7: 6, 6: 5, 5: 4},
    "cc13": {77: 0},
    "cc13_apr": {77: 0},
    "pol_lean": {3: 2},
}


class ConditionalColumns:
    dem_male_77_TEXT = ConditionalColumn("dem_male_77_TEXT").add_cond(
        expr=pl.col("dem_male") == "Prefer to self describe"
    )
    ew_attribution = ConditionalColumn("ew_attribution").add_cond(
        expr=pl.col("ew1") != ["None of the above"]
    )
    ew_attribution_apr = ConditionalColumn("ew_attribution_apr").add_cond(
        expr=pl.col("ew1_apr") != ["None of the above"]
    )
    ew_attribution_jun = ConditionalColumn("ew_attribution_jun").add_cond(
        expr=pl.col("ew1_jun") != ["None of the above"]
    )
    ew_attribution_nov = ConditionalColumn("ew_attribution_nov").add_cond(
        expr=pl.col("ew1_nov") != ["None of the above"]
    )
    attr_storm_6_TEXT = ConditionalColumn("attr_storm_6_TEXT").add_cond(
        expr=pl.col("attr_storm").list.contains("Other (text entry)")
    )
    attr_outage_13_TEXT = ConditionalColumn("attr_outage_13_TEXT").add_cond(
        expr=pl.col("attr_outage").list.contains("Other (text entry)")
    )

    ccComp0 = ConditionalColumn("ccComp0", variant=0).add_group_cond([1, 2, 3], "WTP0")
    ccComp1 = ConditionalColumn("ccComp1", variant=1).add_group_cond([1, 2, 3], "WTP1")
    ccComp10 = (
        ConditionalColumn("ccComp10", variant=10)
        .add_group_cond(1, "WTP3")
        .add_group_cond([2, 3], "WTP10")
    )
    ccComp25 = ConditionalColumn("ccComp25", variant=25).add_group_cond(1, "WTP5")
    ccComp50 = (
        ConditionalColumn("ccComp50", variant=50)
        .add_group_cond(1, "WTP10")
        .add_group_cond([2, 3], "WTP50")
    )
    ccComp100 = ConditionalColumn("ccComp100", variant=100).add_group_cond(
        [2, 3], "WTP100"
    )

    ccSolve0 = ConditionalColumn("ccSolve0", variant=0).add_group_cond(
        [2, 3, 4], "WTP0"
    )
    ccSolve1 = ConditionalColumn("ccSolve1", variant=1).add_group_cond(
        [2, 3, 4], "WTP1"
    )
    ccSolve10 = ConditionalColumn("ccSolve10", variant=10).add_group_cond(
        [2, 3, 4], "WTP10"
    )
    ccSolve50 = ConditionalColumn("ccSolve50", variant=50).add_group_cond(
        [2, 3, 4], "WTP50"
    )
    ccSolve100 = ConditionalColumn("ccSolve100", variant=100).add_group_cond(
        [2, 3, 4], "WTP100"
    )

    ccIO = (
        ConditionalColumn("ccIO", "ccIO")
        .add_group_cond(1, ["GroupNoUSinterest", "GroupCCIO"])
        .add_group_cond([2, 4], "GroupCCIO")
    )
    ccGovt = (
        ConditionalColumn("ccGovt", "ccGovt")
        .add_group_cond(1, ["GroupNoUSinterest", "GroupCCGovt"])
        .add_group_cond([2, 4], "GroupCCGovt")
    )
    ccIOinterest = ConditionalColumn("ccIOinterest", "ccIOinterest").add_group_cond(
        1, ["GroupUSinterest", "GroupCCIO"]
    )
    ccGovtinterest = ConditionalColumn(
        "ccGovtinterest", "ccGovtinterest"
    ).add_group_cond(1, ["GroupUSinterest", "GroupCCGovt"])

    dustin_ques_64 = ConditionalColumn("dustin_ques_64", variant=64).add_group_cond(
        3, "d_ran1"
    )
    dustin_ques_256 = ConditionalColumn("dustin_ques_256", variant=256).add_group_cond(
        3, "d_ran2"
    )
    dustin_support = ConditionalColumn("dustin_support").add_cond(
        expr=pl.any_horizontal(pl.col("dustin_ques_64", "dustin_ques_256") == 1)
    )
    dustin_oppose = ConditionalColumn("dustin_oppose").add_cond(
        expr=pl.any_horizontal(pl.col("dustin_ques_64", "dustin_ques_256") == 0)
    )

    cvcc6 = (
        ConditionalColumn("cvcc6")
        .add_cond([1, 3, 4], expr=True)
        .add_group_cond(2, "Groupcvcc_5and6")
    )
    cvcc7a = (
        ConditionalColumn("cvcc7a")
        .add_group_cond(2, ["GroupGreenInfrastructure", "Groupcvcc7show"])
        .add_group_cond([1, 3], "GroupGreenInfrastructure")
    )
    cvcc7b = (
        ConditionalColumn("cvcc7b")
        .add_group_cond(2, ["GroupInfrastructure", "Groupcvcc7show"])
        .add_group_cond([1, 3], "GroupInfrastructure")
    )

    cvcc8a__opp = ConditionalColumn("cvcc8a__opp").add_cond(
        expr=pl.col("cvcc7a").is_in([1, 2])
    )
    cvcc8a__supp = ConditionalColumn("cvcc8a__supp").add_cond(
        expr=pl.col("cvcc7a").is_in([4, 5])
    )
    cvcc8a__opp_6_TEXT = ConditionalColumn("cvcc8a__opp_6_TEXT").add_cond(
        expr=pl.col("cvcc8a__opp").list.contains("Other (text entry)")
    )
    cvcc8a__supp_8_TEXT = ConditionalColumn("cvcc8a__supp_8_TEXT").add_cond(
        expr=pl.col("cvcc8a__supp").list.contains("Other (text entry)")
    )
    cvcc8b__opp = ConditionalColumn("cvcc8b__opp").add_cond(
        expr=pl.col("cvcc7b").is_in([1, 2])
    )
    cvcc8b__supp = ConditionalColumn("cvcc8b__supp").add_cond(
        expr=pl.col("cvcc7b").is_in([4, 5])
    )
    cvcc8b__opp_6_TEXT = ConditionalColumn("cvcc8b__opp_6_TEXT").add_cond(
        expr=pl.col("cvcc8b__opp").list.contains("Other (text entry)")
    )
    cvcc8b__supp_6_TEXT = ConditionalColumn("cvcc8b__supp_6_TEXT").add_cond(
        expr=pl.col("cvcc8b__supp").list.contains("Other (text entry)")
    )

    cvccAirCC = ConditionalColumn(
        "cvccAirCC", "Climate change (control)"
    ).add_group_cond(2, "GroupAirCC")
    cvccAirDemCC = ConditionalColumn(
        "cvccAirDemCC", "Climate change (Democrat)"
    ).add_group_cond([1, 2], "GroupAirDemCC")
    cvccAirRepCC = ConditionalColumn(
        "cvccAirRepCC", "Climate change (Republican)"
    ).add_group_cond([1, 2], "GroupAirRepCC")
    cvccAirHealth = ConditionalColumn(
        "cvccAirHealth", "Health (control)"
    ).add_group_cond(2, "GroupAirHealth")
    cvccAirDemHealth = ConditionalColumn(
        "cvccAirDemHealth", "Health (Democrat)"
    ).add_group_cond([1, 2], "GroupAirDemHealth")
    cvccAirRepHealth = ConditionalColumn(
        "cvccAirRepHealth", "Health (Republican)"
    ).add_group_cond([1, 2], "GroupAirRepHealth")

    cvcc10_cc = (
        ConditionalColumn("cvcc10_cc")
        .add_cond(1, expr=True)
        .add_group_cond(2, "Groupcvcc10")
    )

    cv__priority_7_TEXT = ConditionalColumn("cv__priority_7_TEXT").add_cond(
        expr=pl.col("cv__priority") == "Other policy (text entry)"
    )
    cv__priority2_7_TEXT = ConditionalColumn("cv__priority2_7_TEXT").add_cond(
        expr=pl.col("cv__priority2") == "Other policy (text entry)"
    )

    pol_lean = ConditionalColumn("pol_lean").add_cond(
        expr=pl.col("pol_party") == "Independent"
    )
    pol_vote_CVdem = (
        ConditionalColumn("pol_vote_CVdem", group="COVID (Democrat)")
        .add_cond(
            expr=pl.any_horizontal(
                pl.col("pol_party") == "Democrat",
                pl.col("pol_lean") == "Leaning Democrat",
            )
        )
        .add_group_cond(
            [1, 2, 3],
            "GroupVoteCV",
        )
    )
    pol_vote_CVrep = (
        ConditionalColumn("pol_vote_CVrep", group="COVID (Republican)")
        .add_cond(
            expr=pl.any_horizontal(
                pl.col("pol_party") == "Republican",
                pl.col("pol_lean") == "Leaning Republican",
            )
        )
        .add_group_cond(
            [1, 2, 3],
            "GroupVoteCV",
        )
    )
    pol_vote_CCdem = (
        ConditionalColumn("pol_vote_CCdem", group="Climate (Democrat)")
        .add_cond(
            expr=pl.any_horizontal(
                pl.col("pol_party") == "Democrat",
                pl.col("pol_lean") == "Leaning Democrat",
            )
        )
        .add_group_cond(
            [1, 2, 3],
            "GroupVoteCC",
        )
    )
    pol_vote_CCrep = (
        ConditionalColumn("pol_vote_CCrep", group="Climate (Republican)")
        .add_cond(
            expr=pl.any_horizontal(
                pl.col("pol_party") == "Republican",
                pl.col("pol_lean") == "Leaning Republican",
            )
        )
        .add_group_cond(
            [1, 2, 3],
            "GroupVoteCC",
        )
    )

    # Group columns
    WTP0 = GroupColumn("WTP0", [1, 2, 3, 4])
    WTP1 = GroupColumn("WTP1", [1, 2, 3, 4])
    WTP3 = GroupColumn("WTP3", 1)
    WTP5 = GroupColumn("WTP5", 1)
    WTP10 = GroupColumn("WTP10", [1, 2, 3, 4])
    WTP50 = GroupColumn("WTP50", [2, 3, 4])
    WTP100 = GroupColumn("WTP100", [2, 3, 4])

    GroupUSinterest = GroupColumn("GroupUSinterest", 1)
    GroupNoUSinterest = GroupColumn("GroupNoUSinterest", 1)

    GroupCCIO = GroupColumn("GroupCCIO", [1, 2, 4])
    GroupCCGovt = GroupColumn("GroupCCGovt", [1, 2, 4])

    d_ran1 = GroupColumn("d_ran1", 3)
    d_ran2 = GroupColumn("d_ran2", 3)

    Groupcvcc_5and6 = GroupColumn("Groupcvcc_5and6", 2)
    Groupcvcc10 = GroupColumn("Groupcvcc10", 2)
    Groupcvcc7show = GroupColumn("Groupcvcc7show", 2)

    GroupInfrastructure = GroupColumn("GroupInfrastructure", [1, 2, 3])
    GroupGreenInfrastructure = GroupColumn("GroupGreenInfrastructure", [1, 2, 3])

    GroupAirCC = GroupColumn("GroupAirCC", 2)
    GroupAirDemCC = GroupColumn("GroupAirDemCC", [1, 2])
    GroupAirRepCC = GroupColumn("GroupAirRepCC", [1, 2])
    GroupAirHealth = GroupColumn("GroupAirHealth", 2)
    GroupAirDemHealth = GroupColumn("GroupAirDemHealth", [1, 2])
    GroupAirRepHealth = GroupColumn("GroupAirRepHealth", [1, 2])

    GroupVoteCV = GroupColumn("GroupVoteCV", [1, 2, 3])
    GroupVoteCC = GroupColumn("GroupVoteCC", [1, 2, 3])

    @classmethod
    def columns(cls) -> list[ConditionalColumn]:
        return [
            getattr(ConditionalColumns, colname)
            for colname in filter(
                lambda x: not (
                    x.startswith("__") or callable(getattr(ConditionalColumns, x))
                ),
                vars(ConditionalColumns),
            )
        ]

    @classmethod
    def group_columns(cls) -> list[GroupColumn]:
        return list(filter(lambda col: isinstance(col, GroupColumn), cls.columns()))

    @classmethod
    def question_columns(cls) -> list[ConditionalColumn]:
        return list(filter(lambda col: not isinstance(col, GroupColumn), cls.columns()))

    @classmethod
    def column_names(cls) -> list[str]:
        return [
            getattr(ConditionalColumns, colname).name
            for colname in filter(
                lambda x: not (
                    x.startswith("__") or callable(getattr(ConditionalColumns, x))
                ),
                vars(ConditionalColumns),
            )
        ]


EXPERIMENT_CONDITION_COLUMNS = [
    # ccIO, ccGovt, ccIOinterest, ccGovtinterest
    ConditionGroup(
        "cc_global_response",
        ConditionalColumns.ccIO,
        ConditionalColumns.ccGovt,
        ConditionalColumns.ccIOinterest,
        ConditionalColumns.ccGovtinterest,
    ),
    ConditionGroup(
        "ccCompensation",
        ConditionalColumns.ccComp0,
        ConditionalColumns.ccComp1,
        ConditionalColumns.ccComp10,
        ConditionalColumns.ccComp25,
        ConditionalColumns.ccComp50,
        ConditionalColumns.ccComp100,
    ),
    ConditionGroup(
        "ccSolving",
        ConditionalColumns.ccSolve0,
        ConditionalColumns.ccSolve1,
        ConditionalColumns.ccSolve10,
        ConditionalColumns.ccSolve50,
        ConditionalColumns.ccSolve100,
    ),
    ConditionGroup(
        "dustin_question",
        ConditionalColumns.dustin_ques_64,
        ConditionalColumns.dustin_ques_256,
    ),
    ConditionGroup(
        "cvcc_infrastructure_policy",
        ConditionalColumns.cvcc7a,
        ConditionalColumns.cvcc7b,
        allow_null=True,
    ),
    ConditionGroup(
        "cvcc_clean_air_policy",
        ConditionalColumns.cvccAirCC,
        ConditionalColumns.cvccAirDemCC,
        ConditionalColumns.cvccAirRepCC,
        ConditionalColumns.cvccAirHealth,
        ConditionalColumns.cvccAirDemHealth,
        ConditionalColumns.cvccAirRepHealth,
        allow_null=True,
    ),
    ConditionGroup(
        "pol_vote_support",
        ConditionalColumns.pol_vote_CVdem,
        ConditionalColumns.pol_vote_CCdem,
        ConditionalColumns.pol_vote_CVrep,
        ConditionalColumns.pol_vote_CCrep,
        allow_multiple_groups=True,
    ),
]


class ClimateAttitudesNullResponses:
    ignore_columns = ["start_date", "end_date"]

    @classmethod
    def validate(cls, response: pl.LazyFrame, config: Config):
        """
        Should have:

        response not null <==>  question in wave &
                                question shown to respondent type &
                                question conditions satisfied

        or equivalently:

        response is null  <==>  question not in wave |
                                question not shown to participant type |
                                question conditions not satisfied

        1. Check not in wave, or to participant type ==> response is null
        2. Check question conditions not satisfied ==> response is null
        3. For unconditional questions, check response is null ==> not in wave OR not shown to participant type
        4. For conditional questions, check response is null ==> not in wave OR not shown to participant type OR conditions not met.

        """

        # Remove unnecessary non-question survey/metadata columns
        response = response.drop(cls.ignore_columns)

        # Check (question not in wave ==> response is null)
        cls.validate_null_if_not_in_wave(response, config)

        # Check (conditions not satisfied ==> response is null)
        cls.validate_null_if_conditions_not_met(response, config)

        # Check unconditional (response is null ==> not shown)
        cls.validate_unconditional_shown_implies_not_null(response, config)

        # Check conditional (response is null ==> not shown)
        cls.validate_conditional_shown_implies_not_null(response, config)

    @classmethod
    def join_response_to_question_long(
        cls, response: pl.LazyFrame, config: Config
    ) -> pl.LazyFrame:
        """Convert wide response to long format by question; join Question table."""
        # Load data
        item_columns = InterimAsset.ItemColumns.scan(config)
        question = InterimAsset.Question.scan(config)

        # Select columns corresponding to questions, and relevant metadata
        question_columns = (
            item_columns.filter(
                pl.col("column_name").is_in(response.collect_schema().names())
            )
            .select("column_name")
            .collect()
            .to_series()
        )
        response = response.select(
            "response_id",
            "participant_id",
            "wave",
            "participant_type",
            *question_columns,
        )

        # Convert list columns to string so we can unpivot on them
        response = response.with_columns(
            cs.list().cast(pl.List(pl.String)).list.join(",")
        )

        # Unpivot response to long format, with one row per question
        response_long = response.unpivot(
            index=["response_id", "participant_id", "wave", "participant_type"],
            variable_name="column_name",
            value_name="response",
        )

        # Get associated item name and id for each column
        response_long = response_long.join(item_columns, on="column_name", how="left")

        # Join against Question table so we can identify conditions to show question
        question = InterimAsset.Question.scan(config)
        return response_long.join(
            question.select(
                "question_id",
                "item_name",
                "item_id",
                "wave",
                "participant_type",
            ),
            on=("item_name", "wave", "participant_type"),
            how="left",
        )

    @classmethod
    def validate_null_if_not_in_wave(
        cls,
        response: pl.LazyFrame,
        config: Config,
    ):
        """Ensure (question not in wave) ==> (response is null)."""

        response = cls.join_response_to_question_long(response, config)

        # Question ID is null if question is not asked in given wave
        not_in_wave = response.filter(pl.col("question_id").is_null())

        # Find items, waves for which responses are not null (potential errors)
        items_not_null = (
            not_in_wave.filter(pl.col("response").is_not_null())
            .select("column_name", "item_id", "wave")
            .unique()
            .group_by("column_name")
            .agg(pl.col("item_id").first(), pl.col("wave").unique().sort())
        ).collect()

        if not items_not_null.is_empty():
            print(
                "One or more columns failed check: 'not in wave ==> response is null':"
            )
            for colname, _, waves in items_not_null.sort(by="item_id").iter_rows():
                print(f"  - {waves}: {colname}")
            print()

    @classmethod
    def validate_null_if_conditions_not_met(
        cls,
        response: pl.LazyFrame,
        config: Config,
    ):
        """Ensure response null for conditional questions when cond not satisfied.

        Can be either a question which is conditionally shown based on a respondent's
        answers to other questions, or one which is shown according to experimental
        condition.
        """
        failed_checks = []

        for column in ConditionalColumns.columns():
            cond_not_met = response.filter(~column.condition())
            waves_not_null = (
                cond_not_met.filter(pl.col(column.name).is_not_null())
                .select(pl.col("wave").unique().sort())
                .collect()
                .to_series()
            )
            if not waves_not_null.is_empty():
                failed_checks.append((column.name, waves_not_null.to_list()))

        if failed_checks:
            print(
                "One or more conditional columns failed check: 'condition not "
                "satisfied ==> response is null':"
            )
            for colname, waves in failed_checks:
                print(f"  - {waves}: {colname}")
            print()

    @classmethod
    def validate_unconditional_shown_implies_not_null(
        cls,
        response: pl.LazyFrame,
        config: Config,
    ):
        """Ensure displayed unconditional questions have non-null responses."""
        response = cls.join_response_to_question_long(
            response.drop(*ConditionalColumns.column_names()),
            config,
        )

        # Filter out cases where question not shown:
        displayed_questions = response.filter(
            pl.col("question_id").is_not_null(),
        )

        # Find items, waves for which responses are null (potential errors)
        items_null = (
            displayed_questions.filter(pl.col("response").is_null())
            .select("column_name", "item_id", "wave")
            .unique()
            .group_by("column_name")
            .agg(pl.col("item_id").first(), pl.col("wave").unique().sort())
            # Disregard items where null is okay
            .filter(~pl.col("column_name").is_in(NULLABLE_COLUMNS))
        ).collect()

        if not items_null.is_empty():
            print(
                "One or more columns failed check: 'question displayed ==> "
                "response is not null':"
            )

            for colname, _, waves in items_null.sort(by="item_id").iter_rows():
                print(f"  - {waves}: {colname}")
            print()

    @classmethod
    def validate_conditional_shown_implies_not_null(
        cls,
        response: pl.LazyFrame,
        config: Config,
    ):
        """Ensure displayed conditional questions have non-null responses."""
        item_columns = InterimAsset.ItemColumns.scan(config)
        question = (
            InterimAsset.Question.scan(config)
            .select(
                "item_name",
                "question_id",
                "wave",
                "participant_type",
            )
            .join(item_columns, on="item_name", how="left")
        )

        failed_checks = []
        for column in ConditionalColumns.columns():
            # Disregard items where null is okay
            if column.name in NULLABLE_COLUMNS:
                continue

            cond_met = response.filter(column.condition())

            # Join on question to filter out waves/participants not asked
            if column.name not in question.collect_schema().get_names():
                raise RuntimeError(
                    f"Column `{column.name}` not found in item column table."
                )
            displayed = (
                cond_met.select("wave", column.name, "participant_type")
                .join(
                    question.filter(pl.col("column_name") == column.name),
                    on=("wave", "participant_type"),
                    how="left",
                )
                .filter(
                    pl.col("question_id").is_not_null(),
                )
            )

            waves_null = (
                displayed.filter(pl.col(column.name).is_null())
                .select(pl.col("wave").unique().sort())
                .collect()
                .to_series()
            )
            if not waves_null.is_empty():
                failed_checks.append((column.name, waves_null.to_list()))

        if failed_checks:
            print(
                "One or more conditional columns failed check: 'question displayed "
                "==> response is not null':"
            )
            for colname, waves in failed_checks:
                print(f"  - {waves}: {colname}")
            print()


class BaseSchema(pa.DataFrameModel):
    class Config:
        ordered = True
        strict = True


class OutputCodebookSchema(BaseSchema):
    codebook_name: str
    item_name: str
    item_id: pl.UInt32
    question_text: str
    response_type: ResponseType  # ty: ignore (not handling Polars Enum)
    response_schema: str = pa.Field(nullable=True)
    display_logic: str = pa.Field(nullable=True)
    response_requirements: str = pa.Field(nullable=True)
    randomization: str = pa.Field(nullable=True)
    note: str = pa.Field(nullable=True)
    w1_new: bool
    w2_new: bool
    w2_rep: bool
    w3_new: bool
    w3_rep: bool
    w4_new: bool
    w4_rep: bool
    w5_new: bool
    w5_rep: bool


class OutputItemColumnsSchema(BaseSchema):
    item_id: pl.UInt32
    item_name: str
    column_name: str


class OutputItemSchema(BaseSchema):
    item_id: pl.UInt32
    item_name: str
    codebook_name: str
    category: str = pa.Field(nullable=True)
    is_demographic: bool
    has_error: bool
    ideology_operational: bool
    ideology_symbolic: bool
    lee_2025_cc_happening: bool
    lee_2025_cc_human: bool
    lee_2025_cc_worried: bool
    lee_2025_personal_harm: bool
    lee_2025_future_gen_harm: bool
    lee_2025_fossil_fuel_reduction: bool
    lee_2025_renewable_energy: bool
    lee_2025_govt_priority: bool


class OutputQuestionSchema(BaseSchema):
    question_id: pl.UInt32
    item_id: pl.UInt32
    item_name: str
    codebook_name: str
    wave: int = pa.Field(isin=WAVES)
    participant_type: ParticipantType  # ty: ignore
    response_type: ResponseType  # ty: ignore
    response_schema: str = pa.Field(nullable=True)
    question_text: str


class OutputParticipantSchema(BaseSchema):
    participant_id: pl.UInt32
    wave_joined: int = pa.Field(isin=WAVES)
    wave_1: bool
    wave_2: bool
    wave_3: bool
    wave_4: bool
    wave_5: bool


class OutputResponseSchema(BaseSchema):
    response_id: pl.UInt32
    wave: int = pa.Field(isin=WAVES)
    participant_id: pl.UInt32
    participant_type: ParticipantType  # ty: ignore
    start_date: pl.Datetime
    end_date: pl.Datetime

    # Demographic columns
    dem_stcount_1: int  # State
    dem_stcount_1_char: StateAbbrev  # ty: ignore
    dem_stcount_2: int  # County
    dem_stcount_2_char: str
    dem_zip: str  # Zip code
    dem_educ: Education  # ty: ignore
    dem_male: Gender  # ty: ignore
    dem_male_77_TEXT: str = pa.Field(nullable=True)
    dem_age: int = pa.Field(gt=0, le=99)
    dem_income: int = pa.Field(isin=[1, 2, 3, 4, 5, 6])

    # Extreme weather
    ew1: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew1_apr: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew1_jun: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew1_nov: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew_attribution: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_apr: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_jun: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_nov: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew5: int = pa.Field(isin=[1, 2, 3, 4])
    attr_storm: pl.List(StormAttribution) = pa.Field(nullable=True)  # ty: ignore
    attr_storm_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    attr_outage: pl.List(OutageAttribution) = pa.Field(nullable=True)  # ty: ignore
    attr_outage_13_TEXT: str = pa.Field(
        nullable=True
    )  # Non-null only if response is 13
    # TODO: ew_attr_fires_drag: Drag-and-drop

    # ===== Climate change (cc) columns =====
    # Climate change happening
    cc1: int = pa.Field(isin=[0, 1, 99], nullable=True)

    # Climate change causes/anthropogenic CC
    cc2: ClimateChangeCause = pa.Field(nullable=True)  # ty: ignore

    # Climate change is a scam
    cc_scam: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Seriousness of climate change problem
    cc3: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Current harms from climate change
    cc4_world: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_wealthcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_poorcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_wealthUS: int = pa.Field(isin=[1, 2, 3, 4, 99])
    cc4_poorUS: int = pa.Field(isin=[1, 2, 3, 4, 99])
    cc4_comm: int = pa.Field(isin=[1, 2, 3, 4, 99])
    cc4_person: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_famheal: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)
    cc4_famecon: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)
    cc4_raceUS: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Total impact of climate change on participant and family
    cc_impact_1: int = pa.Field(in_range=(0, 10), nullable=True)

    # Learn to live with CC vs. target with interventions until 'gone'
    cc_endemic: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Future generation harm from climate change
    cc5_world: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_wealthcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_poorcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_wealthUS: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_poorUS: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_comm: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)

    # Level of worry about climate change
    cc6: int = pa.Field(isin=[1, 2, 3, 4])

    # Should <PERSON/ENTITY> be doing more/less to address current and future CC
    cc7_pres: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_cong: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_gov: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_local: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_ordcoun: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_ordcomm: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_corp: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_epa: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_fema: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_IO: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Support for data collection policy concerning personal emissions
    cc8: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # How much should <PERSON/ENTITY> be doing to address current and future CC
    cc8_pres: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_cong: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_gov: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_ordinary: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_corp: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_epa: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_fema: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_IO: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_otherctry: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # How often think about/discuss climate change in last month
    cc_think: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Threat assessments of climate change
    cc9_globecon: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_globstab: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_USecon: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_commday: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_famheal: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_famecon: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # Willingness to pay X amt. for policy to compensate climate-affected communities
    ccComp100: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccComp50: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccComp25: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccComp10: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccComp1: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccComp0: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Willingness to pay X amt. for policy to response to/solve climate-affected communities
    ccSolve100: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccSolve50: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccSolve10: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccSolve1: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccSolve0: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Support US financially supporting international orgs launch global response to fight climate change
    ccIO: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccIOinterest: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Support US financially supporting other countries to launch global response to fight climate change
    ccGovt: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    ccGovtinterest: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Support international climate agreement committing US (and others) to reduce carbon emissions
    cc_ica: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # Support $10B for climate change investments
    cc_fedinvest: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # If an international agreement is made to reduce emissions, what commitments should US make relative to other countries
    cc_commit: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # Policy support
    cc_pol_RE__research: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Renewables research
    cc_pol_tax: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Tax on fuel production
    cc_pol_car: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Stronger standards for auto manufacturers
    cc_pol_subs: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Rebates/subsidies for buying energy-efficient vehicles/solar

    # Capacity, through own actions, to avoid CC-related death
    cc11: int = pa.Field(in_range=(1, 7), nullable=True)

    # Actions taken due to current/future CC impacts
    cc13: pl.List(ClimateChangeInducedAction) = pa.Field(nullable=True)  # ty: ignore
    cc13_apr: pl.List(ClimateChangeInducedAction) = pa.Field(nullable=True)  # ty: ignore

    # behaviors taken to help address CC
    cc_behavior_meat: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_travel: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_activ: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_discuss: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_evacuate: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_move: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # behaviors taken in last week to limit impact on CC
    cc_behaviorchange: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # Support climate-related policies
    cc_policy_cars: int = pa.Field(in_range=(1, 7), nullable=True)
    cc_policy_re: int = pa.Field(in_range=(1, 7), nullable=True)
    cc_policy_house: int = pa.Field(in_range=(1, 7), nullable=True)
    cc_policy_risk: int = pa.Field(in_range=(1, 7), nullable=True)

    # Expected benefit from climate related policies
    cc_policybenefit: pl.List(ClimatePolicyBenefit) = pa.Field(nullable=True)  # ty: ignore

    # Climate change as policy issue vs. individual responsibility
    cc_resp_action: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Timeframe to mitigate catastrophic climate change
    cc_timeframe_w4new: int = pa.Field(
        isin=[1, 2, 3, 4, 5, 6, 9, 7, 8, 10], nullable=True
    )
    cc_timeframe: int = pa.Field(isin=[2, 3, 4, 5, 6, 7, 8, 1], nullable=True)

    # Policy support: reduce fossil fuel use, with cost to households
    dustin_ques_64: int = pa.Field(isin=[0, 1], nullable=True)
    dustin_ques_256: int = pa.Field(isin=[0, 1], nullable=True)
    dustin_support: int = pa.Field(isin=[1, 2, 3], nullable=True)
    dustin_oppose: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # ==== COVID-19 / Climate-change =====
    # behavior change (experienced during COVID-19 pandemic), to reduce emissions
    cvcc4_personal: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)  # Intention
    cvcc4_will: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Expectation (of others)
    cvcc4_should: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Attitude/normative view

    # Importance of individual action on climate change
    cvcc6: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Policy support: large-scale green infrastructure plan
    cvcc7a: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvcc7b: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvcc8a__opp: pl.List(ReasonOpposeGreenInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8a__supp: pl.List(ReasonSupportGreenInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8a__opp_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    cvcc8a__supp_8_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 8
    cvcc8b__opp: pl.List(ReasonOpposeInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8b__supp: pl.List(ReasonSupportInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8b__opp_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    cvcc8b__supp_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6

    # Policy support: reducing emissions to reduce impact of future pandemics
    cvccAirDemHealth: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvccAirRepHealth: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvccAirHealth: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Policy support: reducing emissions to reduce impact of global warming/climate change
    cvccAirDemCC: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvccAirRepCC: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvccAirCC: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Scientists with appropriate expertise should guide climate change response
    cvcc9_cc: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Optimism that climate change can be solved with technological solutions
    cvcc10_cc: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Prioritise issues: COVID-19 policies that could help address other issues.
    cv__priority: CovidPolicyFlowonPriority = pa.Field(nullable=True)  # ty: ignore
    cv__priority2: CovidPolicyFlowonPriority = pa.Field(nullable=True)  # ty: ignore
    cv__priority_7_TEXT: str = pa.Field(nullable=True)
    cv__priority2_7_TEXT: str = pa.Field(nullable=True)

    # ==== US political issues =====
    # How much of a threat is global warming/climate change
    pol_threat_cc: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # Strict environmental laws: hurt economy vs. worth the cost
    pol7: int = pa.Field(isin=[1, 2])

    # Political identification
    pol_party: PoliticalParty  # ty: ignore
    pol_lean: PoliticalLeaning = pa.Field(nullable=True)  # ty: ignore

    # Would proposal of climate policies make you more or less likely to support a political candidate
    pol_vote_CCdem: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    pol_vote_CCrep: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    pol_vote_CVdem: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    pol_vote_CVrep: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # ===== Experiment conditions =====
    # Willingness to pay (ccComp, ccSolve)
    WTP100: bool = pa.Field(nullable=True)
    WTP50: bool = pa.Field(nullable=True)
    WTP10: bool = pa.Field(nullable=True)
    WTP5: bool = pa.Field(nullable=True)
    WTP3: bool = pa.Field(nullable=True)
    WTP1: bool = pa.Field(nullable=True)
    WTP0: bool = pa.Field(nullable=True)

    # dustin_ques_64, dustin_ques_256
    d_ran1: bool = pa.Field(nullable=True)
    d_ran2: bool = pa.Field(nullable=True)

    # ccIO, ccIOinterest, ccGovt, ccGovtinterest
    GroupCCIO: bool = pa.Field(nullable=True)
    GroupCCGovt: bool = pa.Field(nullable=True)
    GroupUSinterest: bool = pa.Field(nullable=True)
    GroupNoUSinterest: bool = pa.Field(nullable=True)

    # cvcc5 and cvcc6
    Groupcvcc_5and6: bool = pa.Field(nullable=True)

    # cvcc7 and cvcc8
    Groupcvcc7show: bool = pa.Field(nullable=True)
    GroupGreenInfrastructure: bool = pa.Field(nullable=True)
    GroupInfrastructure: bool = pa.Field(nullable=True)

    # cvccAir<X>Health
    GroupAirDemHealth: bool = pa.Field(nullable=True)
    GroupAirRepHealth: bool = pa.Field(nullable=True)
    GroupAirHealth: bool = pa.Field(nullable=True)

    # cvccAir<X>CC
    GroupAirDemCC: bool = pa.Field(nullable=True)
    GroupAirRepCC: bool = pa.Field(nullable=True)
    GroupAirCC: bool = pa.Field(nullable=True)

    # cvcc10
    Groupcvcc10: bool = pa.Field(nullable=True)

    # Political leaning (pol_vote_CC<X>)
    GroupVoteCC: bool = pa.Field(nullable=True)
    GroupVoteCV: bool = pa.Field(nullable=True)

    @pa.dataframe_check
    def singlechoice_valid_selection(cls, df: PolarsData) -> pl.LazyFrame:
        """Check all single-choice responses are valid according to codebook.

        For each column, and each pair of (waves, valid options) per column,
        ensure that (unless the value is null), the selected option is in
        the set of valid options for those waves.
        """
        item_singlechoice_options = [
            (
                "cc4_world",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4], [1, 2, 3, 4]),
                ],
            ),
            (
                "cc4_wealthUS",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4, 5], [1, 2, 3, 4]),
                ],
            ),
            (
                "cc4_poorUS",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4, 5], [1, 2, 3, 4]),
                ],
            ),
            (
                "cc4_comm",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4, 5], [1, 2, 3, 4]),
                ],
            ),
            (
                "cc5_world",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4], [1, 2, 3, 4]),
                ],
            ),
            (
                "cc5_wealthUS",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4], [1, 2, 3, 4]),
                ],
            ),
            (
                "cc5_poorUS",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4], [1, 2, 3, 4]),
                ],
            ),
            (
                "cc5_comm",
                [
                    ([1], [1, 2, 3, 4, 99]),
                    ([2, 3, 4], [1, 2, 3, 4]),
                ],
            ),
            (
                "cv__priority",
                [
                    ([2], [1, 2, 3, 4, 5, 7, 6]),
                    ([3], [1, 2, 3, 4, 5, 8, 7, 6]),
                    ([4], [1, 2, 3, 4, 5, 8, 9, 7, 6]),
                ],
            ),
            (
                "cv__priority2",
                [
                    ([2], [0, 1, 2, 3, 4, 5, 7]),
                ],
            ),
        ]

        # Cast enums to int temporarily so we can specify above conds with ints
        return df.lazyframe.with_columns(cs.enum().cast(pl.Int64)).select(
            *[
                pl.any_horizontal(
                    *[
                        pl.col(col_name).is_null()
                        | (
                            pl.col("wave").is_in(waves)
                            & pl.col(col_name).is_in(wave_options)
                        )
                        for waves, wave_options in item_options
                    ]
                ).alias(col_name)
                for col_name, item_options in item_singlechoice_options
            ]
        )

    @pa.dataframe_check
    def multichoice_valid_selection(cls, df: PolarsData) -> pl.LazyFrame:
        """Check all multichoice selections are valid according to codebook.

        For each column, and each pair of (waves, valid options) per column,
        ensure that (unless the value is null), all selected options are in
        the set of valid options for those waves.
        """
        item_multichoice_options = [
            (
                "ew1",
                [
                    ([1, 2, 3, 4], [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]),
                    ([5], [1, 2, 3, 4, 5, 6, 7, 8, 10, 9, 0]),
                ],
            ),
            (
                "ew1_apr",
                [
                    ([2], [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]),
                ],
            ),
            (
                "ew1_jun",
                [
                    ([3], [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]),
                ],
            ),
            (
                "ew1_nov",
                [
                    ([4], [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]),
                ],
            ),
            (
                "attr_storm",
                [
                    ([4], [0, 1, 2, 3, 4, 5]),
                ],
            ),
            (
                "attr_outage",
                [
                    ([4], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]),
                ],
            ),
            (
                "cc13",
                [
                    ([1], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]),
                    ([2, 3, 4], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]),
                ],
            ),
            (
                "cc13_apr",
                [
                    ([2], [0, 2, 3, 4, 5, 6, 7, 8, 13, 10, 11, 14, 12]),
                ],
            ),
            (
                "cc_policybenefit",
                [
                    ([5], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0]),
                ],
            ),
            (
                "cvcc8a__opp",
                [
                    ([1], [0, 1, 2, 3, 4, 5]),
                ],
            ),
            (
                "cvcc8a__supp",
                [
                    ([1], [0, 1, 2, 3, 4, 5, 6, 7]),
                ],
            ),
            (
                "cvcc8b__opp",
                [
                    ([1], [0, 1, 2, 3, 4, 5]),
                ],
            ),
            (
                "cvcc8b__supp",
                [
                    ([1], [0, 1, 2, 3, 4, 5]),
                ],
            ),
        ]

        # Cast enums to int temporarily so we can specify above conds with ints
        return df.lazyframe.with_columns(
            cs.list(cs.enum()).list.eval(pl.element().cast(pl.Int64))
        ).select(
            *[
                pl.any_horizontal(
                    *[
                        pl.col(col_name).is_null()
                        | (
                            pl.col("wave").is_in(waves)
                            & pl.col(col_name)
                            .list.eval(pl.element().is_in(wave_options))
                            .list.all()
                        )
                        for waves, wave_options in item_options
                    ]
                ).alias(col_name)
                for col_name, item_options in item_multichoice_options
            ]
        )
