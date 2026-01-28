"""
Errors:
-------

- PID: Sometimes null.
- Null values where there shouldn't be: ew1, ew1_apr, ew1_jun, cc_impact_1, cc5_world,
    cc5_wealthUS, cc5_poorUS, cc5_comm, cc_pol_RE__research, cc_pol_tax, cc_pol_car,
    cc_pol_subs, cc11, cc13, cc13_apr, cc_behaviorchange, dustin_ques_64,
    dustin_ques_256, cv__priority2
- We also have null values in cvcc7a. Wave 3, GroupGreenInfrastructure == 1 but
    response is null.
- ew1: Responses contain both null and "0" (none of the above) responses. On closer
    inspection, at least some of the null respondents responded to the ew1_apr or
    ew1_jun questions instead, even though these are only for repeating participants,
    and these respondents had no prior recorded waves. Filtering out any
    participants whose first recorded wave has a response to a "repeating-only"
    question, and vice-versa, fixes all of the above columns except: cc_impact_1,
    cc_behaviorchange, dustin_ques_64, dustin_ques_256.
- cc13: Codebook says both variants asked in wave 1 (note that only first variant
    options are observed in wave 1)
- WTP: Codebook says `WTP` condition column used for ccComp10 in wave 2. But column
    doesn't exist. Currently using `WTP10` instead; following pattern from other vars.
- GroupInfrastructure: Codebook doesn't specify when this is used. Presumably it is
    an alternative to GroupGreenInfrastructure.

To check:
---------

- cc_timeframe_w4new: Codebook says originally coded as Q423. Check if this also means the question was asked prior to wave 4.
- pol7_DO: Is this question ordering? Entries are of form "1|2", "2|1"
"""

from __future__ import annotations
from climate_attitudes.schema.columns import (
    ConditionGroup,
    ConditionalColumn,
)
from climate_attitudes.settings import Config, BuiltAsset
import polars as pl
import polars.selectors as cs
import pandera.polars as pa
from pandera.polars import PolarsData

US_STATES = [
    ("Alabama", "AL"),
    ("Alaska", "AK"),
    ("Arizona", "AZ"),
    ("Arkansas", "AR"),
    ("American Samoa", "AS"),
    ("California", "CA"),
    ("Colorado", "CO"),
    ("Connecticut", "CT"),
    ("Delaware", "DE"),
    ("District of Columbia", "DC"),
    ("Florida", "FL"),
    ("Georgia", "GA"),
    ("Guam", "GU"),
    ("Hawaii", "HI"),
    ("Idaho", "ID"),
    ("Illinois", "IL"),
    ("Indiana", "IN"),
    ("Iowa", "IA"),
    ("Kansas", "KS"),
    ("Kentucky", "KY"),
    ("Louisiana", "LA"),
    ("Maine", "ME"),
    ("Maryland", "MD"),
    ("Massachusetts", "MA"),
    ("Michigan", "MI"),
    ("Minnesota", "MN"),
    ("Mississippi", "MS"),
    ("Missouri", "MO"),
    ("Montana", "MT"),
    ("Nebraska", "NE"),
    ("Nevada", "NV"),
    ("New Hampshire", "NH"),
    ("New Jersey", "NJ"),
    ("New Mexico", "NM"),
    ("New York", "NY"),
    ("North Carolina", "NC"),
    ("North Dakota", "AND"),
    ("Northern Mariana Islands", "MP"),
    ("Ohio", "OH"),
    ("Oklahoma", "OK"),
    ("Oregon", "OR"),
    ("Pennsylvania", "PA"),
    ("Puerto Rico", "PR"),
    ("Rhode Island", "RI"),
    ("South Carolina", "SC"),
    ("South Dakota", "SD"),
    ("Tennessee", "TN"),
    ("Texas", "TX"),
    ("Trust Territories", "TT"),
    ("Utah", "UT"),
    ("Vermont", "VT"),
    ("Virginia", "VA"),
    ("Virgin Islands", "VI"),
    ("Washington", "WA"),
    ("West Virginia", "WV"),
    ("Wisconsin", "WI"),
    ("Wyoming", "WY"),
]

WAVES = [1, 2, 3, 4, 5, 6]

GROUP_COLUMNS = pl.col(r"^Group.*$", r"^WTP.*$", "d_ran1", "d_ran2")

EXPERIMENT_CONDITION_COLUMNS = [
    # ccIO, ccGovt, ccIOinterest, ccGovtinterest
    ConditionGroup(
        "cc_global_response",
        ConditionalColumn("ccIO", "ccIO")
        .add_group_cond(1, ["GroupNoUSinterest", "GroupCCIO"])
        .add_group_cond([2, 4], "GroupCCIO"),
        ConditionalColumn("ccGovt", "ccGovt")
        .add_group_cond(1, ["GroupNoUSinterest", "GroupCCGovt"])
        .add_group_cond([2, 4], "GroupCCGovt"),
        ConditionalColumn("ccIOinterest", "ccIOinterest").add_group_cond(
            1, ["GroupUSinterest", "GroupCCIO"]
        ),
        ConditionalColumn("ccGovtinterest", "ccGovtinterest").add_group_cond(
            1, ["GroupUSinterest", "GroupCCGovt"]
        ),
    ),
    ConditionGroup(
        "ccCompensation",
        ConditionalColumn("ccComp0", variant=0).add_group_cond([1, 2, 3], "WTP0"),
        ConditionalColumn("ccComp1", variant=1).add_group_cond([1, 2, 3], "WTP1"),
        ConditionalColumn("ccComp10", variant=10)
        .add_group_cond(1, "WTP3")
        .add_group_cond([2, 3], "WTP10"),
        ConditionalColumn("ccComp25", variant=25).add_group_cond(1, "WTP5"),
        ConditionalColumn("ccComp50", variant=50)
        .add_group_cond(1, "WTP10")
        .add_group_cond([2, 3], "WTP50"),
        ConditionalColumn("ccComp100", variant=100).add_group_cond([2, 3], "WTP100"),
    ),
    ConditionGroup(
        "ccSolving",
        ConditionalColumn("ccSolve0", variant=0).add_group_cond([2, 3, 4], "WTP0"),
        ConditionalColumn("ccSolve1", variant=1).add_group_cond([2, 3, 4], "WTP1"),
        ConditionalColumn("ccSolve10", variant=10).add_group_cond([2, 3, 4], "WTP10"),
        ConditionalColumn("ccSolve50", variant=50).add_group_cond([2, 3, 4], "WTP50"),
        ConditionalColumn("ccSolve100", variant=100).add_group_cond(
            [2, 3, 4], "WTP100"
        ),
    ),
    ConditionGroup(
        "dustin_question",
        ConditionalColumn("dustin_ques_64", variant=64).add_group_cond(3, "d_ran1"),
        ConditionalColumn("dustin_ques_256", variant=256).add_group_cond(3, "d_ran2"),
    ),
    ConditionGroup(
        "cvcc_clean_air_policy",
        ConditionalColumn("cvccAirCC", "Climate change (control)").add_group_cond(
            2, "GroupAirCC"
        ),
        ConditionalColumn("cvccAirDemCC", "Climate change (Democrat)").add_group_cond(
            [1, 2], "GroupAirDemCC"
        ),
        ConditionalColumn("cvccAirRepCC", "Climate change (Republican)").add_group_cond(
            [1, 2], "GroupAirRepCC"
        ),
        ConditionalColumn("cvccAirHealth", "Health (control)").add_group_cond(
            2, "GroupAirHealth"
        ),
        ConditionalColumn("cvccAirDemHealth", "Health (Democrat)").add_group_cond(
            [1, 2], "GroupAirDemHealth"
        ),
        ConditionalColumn("cvccAirRepHealth", "Health (Republican)").add_group_cond(
            [1, 2], "GroupAirRepHealth"
        ),
        allow_null=True,
    ),
]


class ClimateAttitudesNullResponses:
    ignore_columns = ["start_date", "end_date"]

    # Columns which are allowed to be null, even if presented to participant.
    null_allowed: list[str] = [
        "dem_male_77_TEXT",
        "attr_storm_6_TEXT",
        "attr_outage_13_TEXT",
        "cvcc8a__opp_6_TEXT",
        "cvcc8a__supp_8_TEXT",
    ]

    null_checks: list[ConditionalColumn] = [
        ConditionalColumn("dem_male_77_TEXT").add_cond(expr=pl.col("dem_male") == 77),
        ConditionalColumn("ew_attribution").add_cond(expr=pl.col("ew1") != [0]),
        ConditionalColumn("ew_attribution_apr").add_cond(expr=pl.col("ew1_apr") != [0]),
        ConditionalColumn("ew_attribution_jun").add_cond(expr=pl.col("ew1_jun") != [0]),
        ConditionalColumn("ew_attribution_nov").add_cond(expr=pl.col("ew1_nov") != [0]),
        ConditionalColumn("attr_storm_6_TEXT").add_cond(
            expr=pl.col("attr_storm").list.contains(6)
        ),
        ConditionalColumn("attr_outage_13_TEXT").add_cond(
            expr=pl.col("attr_outage").list.contains(13)
        ),
        ConditionalColumn("ccComp100").add_cond(expr=pl.col("WTP100") == 1),
        ConditionalColumn("ccComp50")
        .add_cond(waves=[2, 3], expr=pl.col("WTP50") == 1)
        .add_cond(1, expr=pl.col("WTP10") == 1),
        ConditionalColumn("ccComp25").add_cond(expr=pl.col("WTP5") == 1),
        ConditionalColumn("ccComp10")
        .add_cond(waves=[2, 3], expr=pl.col("WTP10") == 1)
        .add_cond(1, expr=pl.col("WTP3") == 1),
        ConditionalColumn("ccComp1").add_cond(expr=pl.col("WTP1") == 1),
        ConditionalColumn("ccComp0").add_cond(expr=pl.col("WTP0") == 1),
        ConditionalColumn("ccSolve100").add_cond(expr=pl.col("WTP100") == 1),
        ConditionalColumn("ccSolve50").add_cond(expr=pl.col("WTP50") == 1),
        ConditionalColumn("ccSolve10").add_cond(expr=pl.col("WTP10") == 1),
        ConditionalColumn("ccSolve1").add_cond(expr=pl.col("WTP1") == 1),
        ConditionalColumn("ccSolve0").add_cond(expr=pl.col("WTP0") == 1),
        ConditionalColumn("ccIO")
        .add_cond(
            1, expr=(pl.col("GroupCCIO") == 1) & (pl.col("GroupNoUSinterest") == 1)
        )
        .add_cond([2, 4], expr=pl.col("GroupCCIO") == 1),
        ConditionalColumn("ccIOinterest").add_cond(
            expr=pl.all_horizontal(pl.col("GroupCCIO", "GroupUSinterest") == 1)
        ),
        ConditionalColumn("ccGovt")
        .add_cond(
            1, expr=(pl.col("GroupCCGovt") == 1) & (pl.col("GroupNoUSinterest") == 1)
        )
        .add_cond([2, 4], expr=pl.col("GroupCCGovt") == 1),
        ConditionalColumn("ccGovtinterest").add_cond(
            expr=pl.all_horizontal(pl.col("GroupCCGovt", "GroupUSinterest") == 1)
        ),
        ConditionalColumn("dustin_ques_64").add_cond(expr=pl.col("d_ran1") == 1),
        ConditionalColumn("dustin_ques_256").add_cond(expr=pl.col("d_ran2") == 1),
        ConditionalColumn("dustin_support").add_cond(
            expr=pl.any_horizontal(pl.col("dustin_ques_64", "dustin_ques_256") == 1)
        ),
        ConditionalColumn("dustin_oppose").add_cond(
            expr=pl.any_horizontal(pl.col("dustin_ques_64", "dustin_ques_256") == 0)
        ),
        ConditionalColumn("cvcc6")
        .add_cond(2, expr=pl.col("Groupcvcc_5and6") == 1)
        .add_cond([1, 3, 4], expr=True),
        ConditionalColumn("cvcc7a")
        .add_cond([1, 3], expr=pl.col("GroupGreenInfrastructure") == 1)
        .add_cond(
            2,
            expr=(pl.col("GroupGreenInfrastructure") == 1)
            & (pl.col("Groupcvcc7show") == 1),
        ),
        ConditionalColumn("cvcc8a__opp").add_cond(expr=pl.col("cvcc7a").is_in([1, 2])),
        ConditionalColumn("cvcc8a__supp").add_cond(expr=pl.col("cvcc7a").is_in([4, 5])),
        ConditionalColumn("cvcc8a__opp_6_TEXT").add_cond(
            expr=pl.col("cvcc8a__opp").list.contains(6)
        ),
        ConditionalColumn("cvcc8a__supp_8_TEXT").add_cond(
            expr=pl.col("cvcc8a__supp").list.contains(8)
        ),
        ConditionalColumn("cvccAirDemHealth").add_cond(
            expr=pl.col("GroupAirDemHealth") == 1
        ),
        ConditionalColumn("cvccAirRepHealth").add_cond(
            expr=pl.col("GroupAirRepHealth") == 1
        ),
        ConditionalColumn("cvccAirHealth").add_cond(expr=pl.col("GroupAirHealth") == 1),
        ConditionalColumn("cvccAirDemCC").add_cond(expr=pl.col("GroupAirDemCC") == 1),
        ConditionalColumn("cvccAirRepCC").add_cond(expr=pl.col("GroupAirRepCC") == 1),
        ConditionalColumn("cvccAirCC").add_cond(expr=pl.col("GroupAirCC") == 1),
        ConditionalColumn("cvcc10_cc")
        .add_cond(2, expr=pl.col("Groupcvcc10") == 1)
        .add_cond(1, expr=True),
        ConditionalColumn("cv__priority_7_TEXT").add_cond(
            expr=pl.col("cv__priority") == 7
        ),
        ConditionalColumn("cv__priority2_7_TEXT").add_cond(
            expr=pl.col("cv__priority2") == 7
        ),
        ConditionalColumn("pol_lean").add_cond(expr=pl.col("pol_party") == 3),
        ConditionalColumn("pol_vote_CCdem").add_cond(
            expr=(pl.col("GroupVoteCC") == 1)
            & pl.any_horizontal(pl.col("pol_party", "pol_lean") == 2)
        ),
        ConditionalColumn("pol_vote_CCrep").add_cond(
            expr=(pl.col("GroupVoteCC") == 1)
            & pl.any_horizontal(pl.col("pol_party", "pol_lean") == 1)
        ),
    ]

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

        a V b V c ==> d
        ~(a V b V c) V d
        (~a & ~b & ~c) V d
        (~a V d) & (~b V d) & (~c V d)
        (a ==> d) & (b ==> d) & (c ==> d)

        So we can test the implications separately

        Going other way,
        d ==> (a V b V c)
        ~d V a V b V c

        Must check all together.
        However, we can simplify by doing unconditional questions separately.

        So:
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
        item = BuiltAsset.Item.scan(config)
        item_columns = BuiltAsset.ItemColumns.scan(config)
        response_long = response_long.join(item_columns, on="column_name", how="left")
        response_long = response_long.join(
            item.select(pl.col("name").alias("item_name"), "item_id"),
            on="item_name",
            how="left",
        )

        # Join against Question table so we can identify conditions to show question
        question = BuiltAsset.Question.scan(config)
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

        response = cls.join_response_to_question_long(
            response.drop(GROUP_COLUMNS), config
        )

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

        for column in cls.null_checks:
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
            response.drop(GROUP_COLUMNS, *[col.name for col in cls.null_checks]), config
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
            .filter(~pl.col("column_name").is_in(cls.null_allowed))
        ).collect()

        if not items_null.is_empty():
            print(
                "One or more columns failed check: 'question displayed ==> "
                "response is not null':"
            )

            # items_not_null = items_not_null.join()
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
        item_columns = BuiltAsset.ItemColumns.scan(config)
        question = (
            BuiltAsset.Question.scan(config)
            .select(
                "item_name",
                "question_id",
                "wave",
                "participant_type",
            )
            .join(item_columns, on="item_name", how="left")
        )

        failed_checks = []
        for column in cls.null_checks:
            # Disregard items where null is okay
            if column.name in cls.null_allowed:
                continue

            cond_met = response.filter(column.condition())

            # Join on question to filter out waves/participants not asked
            # TODO: Check that column name is in question table
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


class ClimateAttitudesSchema(pa.DataFrameModel):
    wave: int = pa.Field(isin=[1, 2, 3, 4, 5, 6], nullable=False)
    participant_id: int = pa.Field(nullable=False)
    start_date: pl.Datetime = pa.Field(nullable=False)
    end_date: pl.Datetime = pa.Field(nullable=False)

    # Demographic columns
    dem_stcount_1: int = pa.Field(nullable=False)  # State
    dem_stcount_1_char: str = pa.Field(
        isin=[name for state, name in US_STATES], nullable=False
    )
    dem_stcount_2: int = pa.Field(nullable=False)  # County
    dem_stcount_2_char: str = pa.Field(nullable=False)
    dem_zip: str = pa.Field(nullable=False)  # Zip code
    dem_educ: int = pa.Field(isin=[1, 2, 3, 4, 5, 6], nullable=False)
    dem_male: int = pa.Field(isin=[0, 1, 77], nullable=False)
    dem_male_77_TEXT: str = pa.Field(nullable=True)  # Nonempty if dem_male == 77
    dem_age: int = pa.Field(gt=0, le=99, nullable=False)
    dem_income: int = pa.Field(isin=[1, 2, 3, 4, 5, 6], nullable=False)

    # Extreme weather
    ew1: list[int] = pa.Field(nullable=True)
    ew1_apr: list[int] = pa.Field(nullable=True)
    ew1_jun: list[int] = pa.Field(nullable=True)
    ew1_nov: list[int] = pa.Field(nullable=True)
    ew_attribution: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_apr: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_jun: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_nov: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew5: int = pa.Field(isin=[1, 2, 3, 4], nullable=False)
    attr_storm: list[int] = pa.Field(nullable=True)
    attr_storm_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    attr_outage: list[int] = pa.Field(nullable=True)
    attr_outage_13_TEXT: str = pa.Field(
        nullable=True
    )  # Non-null only if response is 13
    # TODO: ew_attr_fires_drag: Drag-and-drop

    # ===== Climate change (cc) columns =====
    # Climate change happening
    cc1: int = pa.Field(isin=[0, 1, 99], nullable=True)

    # Climate change causes/anthropogenic CC
    cc2: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Climate change is a scam
    cc_scam: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Seriousness of climate change problem
    cc3: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Current harms from climate change
    cc4_world: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_wealthcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_poorcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_wealthUS: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=False)
    cc4_poorUS: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=False)
    cc4_comm: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=False)
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
    cc6: int = pa.Field(isin=[1, 2, 3, 4], nullable=False)

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
    cc13: list[int] = pa.Field(nullable=True)
    cc13_apr: list[int] = pa.Field(nullable=True)

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
    cc_policybenefit: list[int] = pa.Field(nullable=True)

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
    cvcc8a__opp: list[int] = pa.Field(nullable=True)
    cvcc8a__supp: list[int] = pa.Field(nullable=True)
    cvcc8a__opp_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    cvcc8a__supp_8_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 8

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
    cv__priority: int = pa.Field(isin=[1, 2, 3, 4, 5, 8, 9, 7, 6], nullable=True)
    cv__priority2: int = pa.Field(isin=[0, 1, 2, 3, 4, 5, 7], nullable=True)
    cv__priority_7_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 7
    cv__priority2_7_TEXT: str = pa.Field(
        nullable=True
    )  # Non-null only if response is 7

    # ==== US political issues =====
    # How much of a threat is global warming/climate change
    pol_threat_cc: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # Strict environmental laws: hurt economy vs. worth the cost
    pol7: int = pa.Field(isin=[1, 2], nullable=False)

    # Political identification
    pol_party: int = pa.Field(isin=[1, 2, 3], nullable=False)
    pol_lean: int = pa.Field(isin=[1, 2, 4], nullable=True)

    # Would proposal of climate policies make you more or less likely to support a political candidate
    pol_vote_CCdem: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    pol_vote_CCrep: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # ===== Experiment conditions =====
    # Willingness to pay (ccComp, ccSolve)
    # NOTE: These are used for ccComp and ccSolve, but don't correspond in same ways
    # TODO: cast to true/false, null in not-applicable columns
    WTP100: int = pa.Field(isin=[None, 1], nullable=True)
    WTP50: int = pa.Field(isin=[None, 1], nullable=True)
    WTP10: int = pa.Field(isin=[None, 1], nullable=True)
    WTP5: int = pa.Field(isin=[None, 1], nullable=True)
    WTP3: int = pa.Field(isin=[None, 1], nullable=True)
    WTP1: int = pa.Field(isin=[None, 1], nullable=True)
    WTP0: int = pa.Field(isin=[None, 1], nullable=True)

    # dustin_ques_64, dustin_ques_256
    d_ran1: int = pa.Field(isin=[None, 1], nullable=True)
    d_ran2: int = pa.Field(isin=[None, 1], nullable=True)

    # ccIO, ccIOinterest, ccGovt, ccGovtinterest
    GroupCCIO: int = pa.Field(isin=[None, 1], nullable=True)
    GroupCCGovt: int = pa.Field(isin=[None, 1], nullable=True)
    GroupUSinterest: int = pa.Field(isin=[None, 1], nullable=True)
    GroupNoUSinterest: int = pa.Field(isin=[None, 1], nullable=True)

    # cvcc5 and cvcc6
    Groupcvcc_5and6: int = pa.Field(isin=[None, 1], nullable=True)

    # cvcc7 and cvcc8
    Groupcvcc7show: int = pa.Field(isin=[None, 1], nullable=True)
    GroupGreenInfrastructure: int = pa.Field(isin=[None, 1], nullable=True)
    GroupInfrastructure: int = pa.Field(isin=[None, 1], nullable=True)

    # cvccAir<X>Health
    GroupAirDemHealth: int = pa.Field(isin=[None, 1], nullable=True)
    GroupAirRepHealth: int = pa.Field(isin=[None, 1], nullable=True)
    GroupAirHealth: int = pa.Field(isin=[None, 1], nullable=True)

    # cvccAir<X>CC
    GroupAirDemCC: int = pa.Field(isin=[None, 1], nullable=True)
    GroupAirRepCC: int = pa.Field(isin=[None, 1], nullable=True)
    GroupAirCC: int = pa.Field(isin=[None, 1], nullable=True)

    # cvcc10
    # NOTE: Group only used for wave 2
    Groupcvcc10: int = pa.Field(isin=[None, 1], nullable=True)

    # Political leaning (pol_vote_CC<X>)
    GroupVoteCC: int = pa.Field(isin=[None, 1], nullable=True)

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
        ]

        return df.lazyframe.select(
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
                    ([4], [1, 2, 3, 4, 5, 6]),
                ],
            ),
            (
                "attr_outage",
                [
                    ([4], [1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13]),
                ],
            ),
            (
                "cc13",
                [
                    ([1], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 77]),
                    ([2, 3, 4], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 77]),
                ],
            ),
            (
                "cc13_apr",
                [
                    ([2], [2, 3, 4, 5, 6, 7, 8, 13, 10, 11, 14, 12, 77]),
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
                    ([1], [1, 2, 3, 4, 5, 6]),
                ],
            ),
            (
                "cvcc8a__supp",
                [
                    ([1], [1, 2, 3, 4, 5, 6, 7, 8]),
                ],
            ),
        ]

        return df.lazyframe.select(
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
