import numpy as np
import polars as pl

from .common import Column, DatasetSchema, IndexColumn, PolarsReplace, PolarsSubtract

SURVEY_COLS = [
    "participant_id",
    "wave",
]

INPUT_QUESTION_COLUMNS = [
    "dem_male",
    "dem_educ",
    "dem_income_percep",
    "dem_urban",
    "cc1",
    "cc4_world",
    "cc4_wealthUS",
    "cc4_poorUS",
    "cc4_comm",
    "cc6",
    "ew5",
    "pol_affiliation",
    "pol_ideology",
]

ALL_INPUT_COLUMNS = SURVEY_COLS + INPUT_QUESTION_COLUMNS

REVERSE_CODING = []

TRANSFORMS = [
    pl.col("cc1").replace({0: -1, 99: 0}),  # (-1, 0, +1) = (no, dont know, yes)
    pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace(
        {1: -2, 2: -1, 99: 0, 3: 1, 4: 2}
    ),  # (-2, -1, 0, 1, 2) = (not at all, a little, dont know, moderate, great deal)
    pl.col("cc6") - 2.5,
    pl.col("ew5") - 2.5,
    (pl.col("pol_affiliation").cast(pl.Int64) - 2),  # -2..=2 is repub to democ
    (pl.col("pol_ideology").cast(pl.Int64) - 2),  # -2..=2 is very cons to very liberal
]

VITERBI_IMPUTE_COLS = []
FILL_IMPUTE_COLS = []


BELIEF_COLS = [
    "cc1",
    "cc4_world",
    "cc4_wealthUS",
    "cc4_poorUS",
    "cc4_comm",
]

EXPERIENCE_COLS = []

ATTITUDE_COLS = [
    "cc6",
    "cvcc_worryothers",
    "ew5",
    # "cvcc6",
    # "cvcc9_cc",
    "pol_affiliation",
    "pol_ideology",
]

BEHAVIOUR_COLS = []

DEMOGRAPHIC_COLS = [
    "dem_male",
    "dem_educ",
    "dem_income_percep",
    "dem_urban",
]

EXTERNAL_FACTORS = []


QUESTION_COLS = (
    BELIEF_COLS
    + EXPERIENCE_COLS
    + ATTITUDE_COLS
    + BEHAVIOUR_COLS
    + DEMOGRAPHIC_COLS
    + EXTERNAL_FACTORS
)


ALL_COLS = SURVEY_COLS + QUESTION_COLS

CATEGORIES = np.asarray(
    ["Belief"] * len(BELIEF_COLS)
    + ["Experience"] * len(EXPERIENCE_COLS)
    + ["Attitude"] * len(ATTITUDE_COLS)
    + ["Behaviour"] * len(BEHAVIOUR_COLS)
    + ["Demographic"] * len(DEMOGRAPHIC_COLS)
    + ["External factor"] * len(EXTERNAL_FACTORS)
)

GROUPS: dict[str, list[str | pl.Expr]] = {
    "Politics": ["pol_ideology", "pol_affiliation"],
    # "Extreme weather": ["ew5", "ew6"],
    # "Self Efficacy": ["cc10", "cc11", "cc12"],
    "Climate Impacts": [
        "cc4_world",
        "cc4_poorUS",
        "cc4_wealthUS",
        "cc4_comm",
    ],
    # "Climate Action": [
    #     "cc_pol_car",
    #     "cc_pol_tax",
    #     "cc_ica",
    #     "pol7",
    #     "cvcc6",
    #     "cvcc9_cc",
    # ],
}

RENAME: dict[str, str] = {
    "cc1": "CC Real",
    "cc6": "CC Worry",
    "ew5": "Weather worry",
    "politics": "Politics",
    "climate_impacts": "Climate Impacts",
}

schema = DatasetSchema(
    columns=[
        Column(name="participant_id", display_name="Participant ID", kind="survey"),
        Column(name="wave", display_name="Wave", kind="survey"),
        Column(
            name="dem_male", display_name="Is male", short_name="Male", kind="covariate"
        ),
        Column(
            name="dem_educ",
            display_name="Education level",
            short_name="Education",
            kind="covariate",
        ),
        Column(
            name="dem_income_percep",
            display_name="Self-perceived income level",
            short_name="Income perception",
            kind="covariate",
        ),
        Column(
            name="dem_urban",
            display_name="Urbanity",
            short_name="Urbanity",
            kind="covariate",
        ),
        Column(
            name="cc1",
            display_name="Belief in climate change",
            short_name="CC Real",
            abbrev="B(CC)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={0: -1, 99: 0}),
        ),
        Column(
            name="cc4_world",
            display_name="Belief about impacts of CC on world",
            short_name="CC Impact (world)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: -2, 2: -1, 99: 0, 3: 1, 4: 2}),
        ),
        Column(
            name="cc4_wealthUS",
            display_name="Belief about impacts of CC on wealthy US communities",
            short_name="CC Impact (wealthy)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: -2, 2: -1, 99: 0, 3: 1, 4: 2}),
        ),
        Column(
            name="cc4_poorUS",
            display_name="Belief about impacts of CC on poor US communities",
            short_name="CC Impact (poor)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: -2, 2: -1, 99: 0, 3: 1, 4: 2}),
        ),
        Column(
            name="cc4_comm",
            display_name="Belief about impacts of CC on own community",
            short_name="CC Impact (comm)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: -2, 2: -1, 99: 0, 3: 1, 4: 2}),
        ),
        Column(
            name="cc6",
            display_name="Worry about current and future CC",
            short_name="CC Worry",
            abbrev="A(CCW)",
            category="Attitude",
            kind="measurement",
            transform=PolarsReplace(mapping={1: -2, 2: -1, 3: 1, 4: 2}),
        ),
        Column(
            name="ew5",
            display_name="Worry about future extreme weather",
            short_name="Weather worry",
            abbrev="A(WW)",
            category="Attitude",
            kind="measurement",
            transform=PolarsReplace(mapping={1: -2, 2: -1, 3: 1, 4: 2}),
        ),
        # Column(
        #     name="cvcc6",
        #     display_name="Importance of individual action on CC",
        #     short_name="CC Responsibility",
        #     category="Attitude",
        #     kind="measurement",
        #     transform=PolarsSubtract(amt=3),
        # ),
        # Column(
        #     name="cvcc9_cc",
        #     display_name="Scientists should guide CC response",
        #     short_name="CC Scientists",
        #     category="Attitude",
        #     kind="measurement",
        #     transform=PolarsSubtract(amt=3),
        # ),
        Column(
            name="pol_affiliation",
            display_name="Political affiliation",
            short_name="Political affiliation",
            category="Attitude",
            kind="measurement",
            transform=PolarsSubtract(amt=2),
        ),
        Column(
            name="pol_ideology",
            display_name="Political ideology",
            short_name="Political ideology",
            category="Attitude",
            kind="measurement",
            transform=PolarsSubtract(amt=2),
        ),
        IndexColumn(
            name="politics",
            display_name="Politics",
            short_name="Politics",
            abbrev="A(P)",
            category="Attitude",
            kind="measurement",
            parts=["pol_ideology", "pol_affiliation"],
        ),
        IndexColumn(
            name="climate_impacts",
            display_name="Climate Impacts",
            short_name="CC Impact",
            abbrev="B(CCI)",
            category="Belief",
            kind="measurement",
            parts=["cc4_world", "cc4_poorUS", "cc4_wealthUS", "cc4_comm"],
        ),
    ],
)
