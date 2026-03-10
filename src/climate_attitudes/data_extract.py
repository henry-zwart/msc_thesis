from __future__ import annotations
from climate_attitudes.schema.enums import WAVES, ItemCategory, UrbanArea
from climate_attitudes.schema.extract import (
    OutputResponseSchema,
    ConditionalColumns,
    NULLABLE_COLUMNS,
    RESPONSE_REMAP_SUB_1,
    RESPONSE_REMAP,
)
from climate_attitudes.schema import extract as schema
from climate_attitudes.schema.enums import (
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
    PoliticalIdeology,
)
import json
import polars as pl
import polars.selectors as cs
from climate_attitudes.settings import Config, RawDataFile, StaticAsset


class DataExtract:
    codebook: pl.LazyFrame
    item: pl.LazyFrame
    question: pl.LazyFrame
    columns: pl.LazyFrame
    participant: pl.LazyFrame
    response: pl.LazyFrame

    def __init__(self, config: Config):
        self.config = config

    def load(self) -> DataExtract:
        """Load raw data into Polars LazyFrames.

        Since we only have a codebook for waves 1---5 at the moment, we only
        load the responses from these waves. This excludes the sixth wave, which
        can be included at a later date.
        """

        self.codebook = RawDataFile.Codebook.scan(self.config)
        self.response = RawDataFile.Waves1to5Responses.scan(self.config)

        # Ensure consistent schema before doing any DataFrame operations
        self._clean_schema()

        # Create `item` and `question` tables from codebook
        self.item = self._create_item_table()
        self.question = self._create_question_table()

        # Create `columns` correspondence between item_names and response columns
        self.columns = self._load_item_columns()

        # Tidy up `response` table
        self._tidy_response_table()

        # Create `participant` table from responses
        self.participant = self._create_participant_table()

        # Reorder columns to match schemas
        self._reorder_columns()

        # Validate that all data loaded correctly
        self._validate()

        return self

    def _validate(self):
        schema.OutputCodebookSchema.validate(self.codebook.collect())
        schema.OutputItemSchema.validate(self.item.collect())
        schema.OutputQuestionSchema.validate(self.question.collect())
        schema.OutputItemColumnsSchema.validate(self.columns.collect())
        schema.OutputResponseSchema.validate(self.response.collect())
        schema.OutputParticipantSchema.validate(self.participant.collect())

        self._validate_response_null_values()

    def _clean_schema(self):
        """Clean + normalise table schemas for codebook and response data."""

        # Normalise codebook column names
        self.codebook = self.codebook.rename(
            lambda column_name: column_name.lower().replace(" ", "_")
        )
        self.codebook = self.codebook.rename(
            {
                "variable_name": "codebook_name",
                "response_format": "response_type",  # I find these column names a little less ambiguous
                "response_fields": "response_schema",
                "wave_1": "w1_new",  # All participants are new in wave 1
                "wave_2_new": "w2_new",
                "wave_2_rep": "w2_rep",
                "wave_3_new": "w3_new",
                "wave_3_rep": "w3_rep",
                "wave_4_new": "w4_new",
                "wave_4_rep": "w4_rep",
                "wave_5_new": "w5_new",
                "wave_5_rep": "w5_rep",
            }
        )

        # Convert question-in-wave indicators to bool
        self.codebook = self.codebook.with_columns(
            pl.col(r"^w\d_.*$").replace_strict(
                {"N/A": False, "ERROR": False, "X": True}, return_dtype=pl.Boolean
            )
        )

        # Replace any empty strings in codebook with None
        self.codebook = self.codebook.with_columns(cs.string().replace("", None))

        # Convert response type to enum
        self.codebook = self.codebook.with_columns(
            pl.col("response_type").cast(ResponseType)
        )

        # Normalise key response column names; leave case to distinguish treatments
        self.response = self.response.rename(
            {
                "WAVE": "wave",
                "PID": "participant_id",
                "StartDate": "start_date",
                "EndDate": "end_date",
            }
        )

        # Normalise item names:
        # 1. Fix item names that are incorrectly recorded in codebook
        self.codebook = self.codebook.join(
            StaticAsset.ItemName.scan(self.config),
            on="codebook_name",
            how="left",
            maintain_order="left",
        )
        # 2. Replace '.' with double underscore '__'
        self.codebook = self.codebook.with_columns(
            pl.col("item_name").str.replace_all(".", "__", literal=True)
        )
        self.response = self.response.rename(
            lambda column_name: column_name.replace(".", "__")
        )

        # Cast response columns to correct types
        self.response = self.response.with_columns(cs.integer().cast(pl.Int64))
        self.response = self.response.with_columns(
            pl.col("wave").cast(pl.Int64),
            pl.col("participant_id").cast(pl.UInt32),
            pl.col("dem_age").cast(pl.Int64),
            pl.col("start_date", "end_date").str.strptime(
                pl.Datetime, format="%-m/%-d/%y %R", strict=True
            ),
        )

    def _create_item_table(self) -> pl.LazyFrame:
        """Create `item` table from codebook.

        The item table describes the underlying notions assessed by the survey. A single
        item may be assessed using different questions, or question variants, in
        different waves.

        This table includes enriched metadata about the items, such as category (e.g.
        demographic items), ideological status, and relation to cognitive items
        assessed in Lee et al. 2025.
        """

        # NOTE: Category is unimplemented so currently null. Intended to distinguish
        # demographic/experience/belief/attitude/etc.
        item = self.codebook.select("item_name").unique(maintain_order=True)

        # Add item id (also add these to the codebook)
        item = item.with_row_index("item_id")
        self.codebook = self.codebook.join(
            item.select("item_id", "item_name"),
            on="item_name",
            how="left",
            maintain_order="left",
        )

        # Add enrichment metadata
        # 1. Groups (questions with complex/conditional relationships)
        item = item.join(
            StaticAsset.ItemGroups.scan(self.config),
            how="left",
            on="item_name",
        )
        # 2. Categories
        item = item.join(
            StaticAsset.Category.scan(self.config).with_columns(
                pl.col("category").cast(ItemCategory)
            ),
            how="left",
            on="item_name",
        )
        # 3. Items with errors
        item = item.join(
            StaticAsset.ErrorItem.scan(self.config).with_columns(
                pl.lit(True).alias("has_error")
            ),
            on="item_name",
            how="left",
            maintain_order="left",
        ).with_columns(pl.col("has_error").fill_null(False))
        # 4. Ideological status
        item = item.join(
            StaticAsset.Ideology.scan(self.config),
            on="item_name",
            how="left",
            maintain_order="left",
        ).with_columns(pl.col(r"^ideology_.*$").fill_null(False))
        # 5. Lee et al. 2025 items
        item = item.join(
            StaticAsset.Lee2025.scan(self.config),
            on="item_name",
            how="left",
            maintain_order="left",
        ).with_columns(pl.col(r"^lee_2025_.*$").fill_null(False))

        return item

    def _create_question_table(self) -> pl.LazyFrame:
        """Create `question` table.

        The `question` table specifies which items are assessed in each wave, and of
        which participants (new vs. repeating). It includes the specific question text
        that is used in each wave, as well as the response type and schema.
        """

        # We build `question` from the codebook, but will retain row index for sorting
        codebook = self.codebook.with_row_index("codebook_row_id")

        # Unpivot the codebook such that each wave + participant type is a new row
        question = codebook.unpivot(
            index=cs.exclude(cs.matches(r"^w\d_(new|rep)$")),
            value_name="question_shown",
            variable_name="wave_and_participant",
        )

        # Filter any rows (wave + participant type) where question isn't shown
        question = question.filter("question_shown").drop("question_shown")

        # Extract wave number and participant type
        question = question.with_columns(
            pl.col("wave_and_participant")
            .str.extract(r"^w(\d).*$", 1)
            .cast(pl.Int64)
            .alias("wave"),
            pl.col("wave_and_participant")
            .str.extract(r"^w\d_(.*)$", 1)
            .replace({"rep": "repeating"})
            .cast(ParticipantType)
            .alias("participant_type"),
        )

        # Sort according to original order in codebook (unpivot doesn't maintain this)
        question = question.sort(by=("codebook_row_id", "wave", "participant_type"))

        # Add question id columns
        question = question.with_row_index("question_id")

        return question

    def _create_participant_table(self) -> pl.LazyFrame:
        """"""

        participant = self.response.select("participant_id", "wave")

        # Record 'wave_joined' for each participant, i.e., first wave with a response
        participant = participant.with_columns(
            pl.col("wave").min().over("participant_id").alias("wave_joined")
        )

        # Add per-wave boolean columns to indicate participant responses
        participant = (
            participant
            # Transform wave index to label: i --> wave_i
            .with_columns(
                pl.col("wave").replace_strict({i: f"wave_{i}" for i in WAVES})
            )
            # Create boolean column for use in pivot
            .with_columns(pl.lit(True).alias("participated"))
            # Pivot wide: for each participant get per-wave response bool
            .pivot(
                "wave",
                on_columns=[f"wave_{i}" for i in WAVES],
                index=["participant_id", "wave_joined"],
                values="participated",
                maintain_order=True,
            )
            .fill_null(False)
            .select("participant_id", "wave_joined", *[f"wave_{i}" for i in WAVES])
        )

        return participant

    def _load_item_columns(self) -> pl.LazyFrame:
        """Load item <--> column correspondence from static JSON file.

        We assume that each `item_name` in the codebook corresponds to a column in the
        data. The JSON file describes additional fields.

        For example, `attr_storm` asks about the causes of a storm in Texas. If a
        respondent answers 'Other' they can then provide a text entry for the
        `attr_storm_6_TEXT` column (which is otherwise null). However, the codebook
        only has an entry for `attr_storm`, so the additional column is linked to this
        base column in the item_columns JSON file. The format for this is:

        {
            "attr_storm": [
                "attr_storm_6_TEXT",
                ...
            ],
            ...
        }

        We load these additional column correspondences and create a LazyFrame
        which includes these as well as all standard item_name <--> column_name
        mappings, i.e., where the two are identical.
        """

        with StaticAsset.ItemColumns.filepath(self.config).open("r") as f:
            extra_columns = json.load(f)

        data = {"item_name": [], "column_name": []}
        item_names = self.codebook.select("item_name").collect().to_series()
        for item in item_names:
            data["item_name"].append(item)
            data["column_name"].append(item)
            for extra_col in extra_columns.get(item, []):
                data["item_name"].append(item)
                data["column_name"].append(extra_col)

        # Add item ids
        item_columns = pl.LazyFrame(data).join(
            self.item, on="item_name", how="left", maintain_order="left"
        )

        return item_columns.unique(maintain_order=True)

    def _tidy_response_table(self):
        """Clean up response table fields, filter null-ID participants."""

        # Filter out any individuals with no registered ID
        response = self.response.filter(pl.col("participant_id").is_not_null())

        # Filter columns to only those validated in the schema
        # 1. Get list of columns in the schema
        schema_cols = list(OutputResponseSchema.build_schema_().columns.keys())
        # 2. Ensure that all of these are in the response table (i.e., no transforms)
        all_response_cols = set(response.collect_schema().names())
        keep_cols = [col for col in schema_cols if col in all_response_cols]
        response = response.select(*keep_cols)

        # Clean up any text columns
        TEXT_COLUMN_REGEX = r"^.*_TEXT$"
        text_columns = (
            self.question.filter(
                response_type="Text",
            )
            .select("item_id")
            .unique()
            # Join with `columns` to identify related cols not specified in codebook
            .join(self.columns, on="item_id", how="left")
            # Filter to those columns validated in the schema
            .filter(pl.col("column_name").is_in(schema_cols))
            .select("column_name")
            .collect()
            .to_series()
        )
        response = response.with_columns(
            pl.col(*text_columns, TEXT_COLUMN_REGEX).str.strip_chars().replace("", None)
        )

        # Clean up multichoice columns
        multichoice_columns = (
            self.question.filter(
                pl.col("response_type") == "Multiple response",
                pl.col("item_name").is_in(schema_cols),
            )
            .select("item_name")
            .unique()
            .collect()
            .to_series()
        )
        response = response.with_columns(
            pl.col(*multichoice_columns)
            .replace("", None)
            # Transform csv format responses to list of integers
            .str.split(",")
            .list.eval(pl.element().cast(pl.Int64))
        )

        # Remap any required columns. Treat lists separately.
        # 1. Re-map columns requiring subtraction by one
        response = response.with_columns(
            (cs.by_name(RESPONSE_REMAP_SUB_1) & ~cs.list()) - 1
        ).with_columns(
            (cs.by_name(RESPONSE_REMAP_SUB_1) & cs.list()).list.eval(pl.element() - 1)
        )

        # 2. Perform any additional required remaps
        for column, remap in RESPONSE_REMAP.items():
            if isinstance(response.collect_schema()[column], pl.List):
                expr = pl.col(column).list.eval(pl.element().replace(remap))
            else:
                expr = pl.col(column).replace(remap)
            response = response.with_columns(expr)

        # Cast enum-type columns
        response = response.with_columns(
            pl.col("dem_educ").cast(Education),
            pl.col("dem_male").cast(Gender),
            pl.col("dem_urban").cast(UrbanArea),
            pl.col("dem_stcount_1_char").cast(StateAbbrev),
            pl.col("ew1").list.eval(pl.element().cast(NaturalDisaster)),
            pl.col("ew1_apr").list.eval(pl.element().cast(NaturalDisaster)),
            pl.col("ew1_jun").list.eval(pl.element().cast(NaturalDisaster)),
            pl.col("ew1_nov").list.eval(pl.element().cast(NaturalDisaster)),
            pl.col("attr_storm").list.eval(pl.element().cast(StormAttribution)),
            pl.col("attr_outage").list.eval((pl.element().cast(OutageAttribution))),
            pl.col("cc2").cast(ClimateChangeCause),
            pl.col("cc13").list.eval(pl.element().cast(ClimateChangeInducedAction)),
            pl.col("cc13_apr").list.eval(pl.element().cast(ClimateChangeInducedAction)),
            pl.col("cc_policybenefit").list.eval(
                pl.element().cast(ClimatePolicyBenefit)
            ),
            pl.col("cvcc8a__opp").list.eval(pl.element().cast(ReasonOpposeGreenInfra)),
            pl.col("cvcc8a__supp").list.eval(
                pl.element().cast(ReasonSupportGreenInfra)
            ),
            pl.col("cvcc8b__opp").list.eval(pl.element().cast(ReasonOpposeInfra)),
            pl.col("cvcc8b__supp").list.eval(pl.element().cast(ReasonSupportInfra)),
            pl.col("cv__priority").cast(CovidPolicyFlowonPriority),
            pl.col("cv__priority2").cast(CovidPolicyFlowonPriority),
            pl.col("pol_party").cast(PoliticalParty),
            pl.col("pol_lean").cast(PoliticalLeaning),
            pl.col("pol_ideology").cast(PoliticalIdeology),
        )

        # Convert treatment class indicator columns to bool,
        #  - Only when these columns are valid for wave
        # TODO: Also check that valid for participant type
        for group in ConditionalColumns.group_columns():
            response = response.with_columns(
                pl.when(group.valid())
                # Replace treatment class Null/1 indicators with bool False/True
                .then(pl.col(group.name).is_not_null())
            )

        # Add participant type (new vs. repeating) to each response row
        response = (
            # 1. Determine which wave each participant joined in
            response.with_columns(
                pl.col("wave").min().over("participant_id").alias("wave_joined")
            )
            # 2. If a response wave is equal to this, mark as 'new', otherwise 'repeating'
            .with_columns(
                pl.when(pl.col("wave_joined") == pl.col("wave"))
                .then(pl.lit("new"))
                .otherwise(pl.lit("repeating"))
                .cast(ParticipantType)
                .alias("participant_type")
            )
            # 3. Finally drop the temporary column
            .drop("wave_joined")
        )

        # Add a `response_id` column
        response = response.with_row_index("response_id")

        # Re-order columns according to the schema
        if missing := set(response.collect_schema().names()) - set(schema_cols):
            raise RuntimeError(
                "One or more response columns are not specified in the schema:"
                f"{missing}"
            )
        self.response = response.select(*schema_cols)

    def _reorder_columns(self):
        # Codebook
        self.codebook = self.codebook.select(
            "codebook_name",
            "item_name",
            "item_id",
            "question_text",
            "response_type",
            "response_schema",
            "display_logic",
            "response_requirements",
            "randomization",
            "note",
            "w1_new",
            "w2_new",
            "w2_rep",
            "w3_new",
            "w3_rep",
            "w4_new",
            "w4_rep",
            "w5_new",
            "w5_rep",
        )

        # Response
        schema_cols = list(OutputResponseSchema.build_schema_().columns.keys())
        if missing := set(self.response.collect_schema().names()) - set(schema_cols):
            raise RuntimeError(
                "One or more response columns are not specified in the schema:"
                f"{missing}"
            )
        self.response = self.response.select(*schema_cols)

        # Question
        self.question = self.question.select(
            "question_id",
            "item_id",
            "item_name",
            "codebook_name",
            "wave",
            "participant_type",
            "response_type",
            "response_schema",
            "question_text",
        )

        # Columns
        self.columns = self.columns.select("item_id", "item_name", "column_name")

    def _validate_response_null_values(self):
        """Check that responses are null if, and only if, we expect them to be."""

        # Select question columns from response, and also relevant metadata
        question_columns = (
            self.columns.filter(
                pl.col("column_name").is_in(self.response.collect_schema().names())
            )
            .select("column_name")
            .collect()
            .to_series()
        )
        response = self.response.select(
            "response_id",
            "participant_id",
            "wave",
            "participant_type",
            *question_columns,
        )

        # Convert list columns to string, enum to int, so we can unpivot on them
        response = response.with_columns(
            cs.list().cast(pl.List(pl.String)).list.join(","),
            (cs.enum() & cs.exclude("participant_type")).cast(pl.Int64),
        )

        # Convert response to long format, one row per question
        response_long = response.unpivot(
            index=["response_id", "participant_id", "wave", "participant_type"],
            variable_name="column_name",
            value_name="response",
        )

        # Get item name and id for each column
        response_long = response_long.join(self.columns, on="column_name", how="left")

        # Join question table on item name, wave, participant_type
        response_long = response_long.join(
            self.question.select(
                "question_id", "item_name", "item_id", "wave", "participant_type"
            ),
            on=("item_name", "wave", "participant_type"),
            how="left",
        )

        # First, check that 'not asked in wave ==> response is null'
        question_not_in_wave = response_long.filter(pl.col("question_id").is_null())
        response_not_null = question_not_in_wave.filter(
            pl.col("response").is_not_null()
        )
        problem_items = (
            response_not_null.select("column_name", "item_id", "wave")
            .unique()
            .group_by("column_name")
            .agg(pl.col("item_id").first(), pl.col("wave").unique().sort())
            .sort(by="item_id")
        ).collect()
        if not problem_items.is_empty():
            print(
                "At least one column failed check: question not asked in wave "
                "==> response is null."
            )
            for col, _, waves in problem_items.iter_rows():
                print(f"  - {waves}: {col}")
            print()

        # Second, check that 'conditions not met ==> response is null'
        failed_checks = []
        for col in ConditionalColumns.question_columns():
            cond_not_met = self.response.filter(~col.condition())
            waves_not_null = (
                cond_not_met.filter(pl.col(col.name).is_not_null())
                .select(pl.col("wave").unique().sort())
                .collect()
                .to_series()
            )
            if not waves_not_null.is_empty():
                failed_checks.append((col.name, waves_not_null.to_list()))

        if failed_checks:
            print(
                "At least one conditional column failed check: condition not "
                "satisfied ==> response is null."
            )
            for col, waves in failed_checks:
                print(f"  - {waves}: {col}")
            print()

        # Third, check 'question shown ==> response not null' for unconditional Qs
        response_long = response_long.filter(
            ~pl.col("column_name").is_in(ConditionalColumns.column_names())
        )
        question_shown = response_long.filter(pl.col("question_id").is_not_null())
        response_is_null = (
            question_shown.filter(pl.col("response").is_null())
            .select("column_name", "item_id", "wave")
            .unique()
            .group_by("column_name")
            .agg(pl.col("item_id").first(), pl.col("wave").unique().sort())
            # Disregard items where null is okay
            .filter(~pl.col("column_name").is_in(NULLABLE_COLUMNS))
            .sort(by="item_id")
        ).collect()

        if not response_is_null.is_empty():
            print(
                "At least one column failed check: question displayed ==> "
                "response is not null."
            )

            for col, _, waves in response_is_null.iter_rows():
                print(f"  - {waves}: {col}")
            print()

        # Finally, check 'question shown ==> response not null' for conditional Qs
        question = self.question.select(
            "item_name", "question_id", "wave", "participant_type"
        ).join(self.columns, on="item_name", how="left")
        question_columns = set(question.select("column_name").collect().to_series())
        failed_checks = []
        for col in ConditionalColumns.question_columns():
            # Disregard items where null is okay
            if col.name in NULLABLE_COLUMNS:
                continue

            cond_met = self.response.filter(col.condition())

            # Join on question to filter out waves/participants not asked
            if col.name not in question_columns:
                raise RuntimeError(
                    f"Column `{col.name}` not found in item column table."
                )
            displayed = (
                cond_met.select("wave", col.name, "participant_type")
                .join(
                    question.filter(pl.col("column_name") == col.name),
                    on=("wave", "participant_type"),
                    how="left",
                )
                .filter(
                    pl.col("question_id").is_not_null(),
                )
            )

            waves_null = (
                displayed.filter(pl.col(col.name).is_null())
                .select(pl.col("wave").unique().sort())
                .collect()
                .to_series()
            )
            if not waves_null.is_empty():
                failed_checks.append((col.name, waves_null.to_list()))

        if failed_checks:
            print(
                "At least one conditional column failed check: question displayed "
                "==> response is not null."
            )
            for col, waves in failed_checks:
                print(f"  - {waves}: {col}")
            print()
