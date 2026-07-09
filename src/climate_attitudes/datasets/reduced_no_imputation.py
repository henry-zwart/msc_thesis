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
    "cc2",
    "cc4_world",
    "cc4_wealthUS",
    "cc4_poorUS",
    "cc4_comm",
    # "cc5_world",
    # "cc5_wealthUS",
    # "cc5_poorUS",
    # "cc5_comm",
    # "cc10",
    # "cc11",  # If included, cc10 ~ cc12. If excluded, less so. Possible collider.
    # "cc12",
    # "cvcc4_will",
    # "cc3",
    "cc6",
    "cvcc_worryothers",
    "ew5",
    # "cvcc4_should",
    "cvcc6",
    "cvcc9_cc",
    "cc_ica",
    "cc_pol_tax",
    "cc_pol_car",
    "pol7",
    # "pol7_pi",
    "pol_affiliation",
    "pol_ideology",
    # "ew6",
    # "cvcc4_personal",
]

ALL_INPUT_COLUMNS = SURVEY_COLS + INPUT_QUESTION_COLUMNS

REVERSE_CODING = []

TRANSFORMS = [
    pl.col("cc1").replace({0: -1, 99: 0}),  # (-1, 0, +1) = (no, dont know, yes)
    pl.col("cc2").replace({0: -1, 1: -1, 2: 1, 3: 1}),  # (-1, +1) = (not human, human)
    pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace(
        {1: -2, 2: -1, 99: 0, 3: 1, 4: 2}
    ),  # (-2, -1, 0, 1, 2) = (not at all, a little, dont know, moderate, great deal)
    pl.col("cc6", "cvcc_worryothers") - 2.5,
    pl.col("ew5") - 2.5,
    (pl.col("cvcc6", "cvcc9_cc") - 3),  # -2..=2 is strongly disagree to strongly agree
    pl.col("cc_ica").replace(
        {0: -1, 1: 1, 2: 1}
    ),  # (-1, 1) = (No, Yes [legally binding or otherwise])
    (pl.col("cc_pol_tax", "cc_pol_car") - 3),  # -2..=2 is strong opp to strong supp
    pl.col("pol7").replace({1: -1, 2: 1}),  # (-1,1) = (env regulation bad, worth it)
    (pl.col("pol_affiliation").cast(pl.Int64) - 2),  # -2..=2 is repub to democ
    (pl.col("pol_ideology").cast(pl.Int64) - 2),  # -2..=2 is very cons to very liberal
]
# TRANSFORMS = [
#     pl.col("cc1").replace({1: 2, 99: 1}) - 1,  # Move "yes" to 2, "don't know" to 1
#     pl.col("cc2").replace({0: -1, 1: -1, 2: 1, 3: 1}),
#     (pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace({1: 0, 2: 1, 99: 2}) - 2)
#     / 2,  # "Don't know" between 'only a little' and 'a moderate amount'
#     (pl.col("ew5", "ew6", "cc6", "cvcc_worryothers") - 2.5) / 1.5,
#     (
#         pl.col(
#             "cvcc6",
#             "cvcc9_cc",
#             "cc_pol_tax",
#             "cc_pol_car",
#             "pol_affiliation",
#             "pol_ideology",
#         )
#         - 3
#     )
#     / 2,
#     (
#         pl.col("cc_ica").replace_strict(
#             {0: -1.0, 1: 0.5, 2: 1.0}, return_dtype=pl.Float64
#         )
#     ),
#     (pl.col("pol7") - 1.5) * 2,
# ]

VITERBI_IMPUTE_COLS = []
FILL_IMPUTE_COLS = []


BELIEF_COLS = [
    "cc1",
    "cc2",
    "cc4_world",
    "cc4_wealthUS",
    "cc4_poorUS",
    "cc4_comm",
    # "cc10",
    # "cc11",  # If included, cc10 ~ cc12. If excluded, less so. Possible collider.
    # "cc12",
]

EXPERIENCE_COLS = []

ATTITUDE_COLS = [
    # "cc3",
    "cc6",
    "cvcc_worryothers",
    "ew5",
    # "cvcc4_should",
    "cvcc6",
    "cvcc9_cc",
    "cc_ica",
    "cc_pol_tax",
    "cc_pol_car",
    "pol7",
    # "pol7_pi",
    "pol_affiliation",
    "pol_ideology",
]

BEHAVIOUR_COLS = [
    # "ew6",
    # "cvcc4_personal",
]

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
    "Climate Action": [
        "cc_pol_car",
        "cc_pol_tax",
        "cc_ica",
        "pol7",
        "cvcc6",
        "cvcc9_cc",
    ],
}

RENAME: dict[str, str] = {
    "cc1": "CC Real",
    "cc2": "CC Human",
    "cc6": "CC Worry",
    "cvcc_worryothers": "CC Others Worry",
    "ew5": "Weather worry",
    "politics": "Politics",
    "climate_action": "Climate Action",
    "climate_impacts": "Climate Impacts",
    # "ew6": "Weather preparation",
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
            name="cc2",
            display_name="Belief about causes of climate change",
            short_name="CC Human",
            abbrev="B(CCA)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={0: -1, 1: -1, 2: 1, 3: 1}),
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
            name="cvcc_worryothers",
            display_name="Belief about others' worry about current and future CC",
            short_name="CC Others Worry",
            abbrev="B(CCWO)",
            category="Belief",
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
        Column(
            name="cvcc6",
            display_name="Importance of individual action on CC",
            short_name="CC Responsibility",
            category="Attitude",
            kind="measurement",
            transform=PolarsSubtract(amt=3),
        ),
        Column(
            name="cvcc9_cc",
            display_name="Scientists should guide CC response",
            short_name="CC Scientists",
            category="Attitude",
            kind="measurement",
            transform=PolarsSubtract(amt=3),
        ),
        Column(
            name="cc_ica",
            display_name="Support for international carbon emission agreement",
            short_name="Policy: ICA",
            category="Attitude",
            kind="measurement",
            transform=PolarsReplace(mapping={0: -1, 1: 1, 2: 1}),
        ),
        Column(
            name="cc_pol_tax",
            display_name="Support for tax on carbon-based fuels",
            short_name="Policy: Tax fuel",
            category="Attitude",
            kind="measurement",
            transform=PolarsSubtract(amt=3),
        ),
        Column(
            name="cc_pol_car",
            display_name=(
                "Support for stronger emissions standard for auto manufacturers"
            ),
            short_name="Policy: Auto",
            category="Attitude",
            kind="measurement",
            transform=PolarsSubtract(amt=3),
        ),
        Column(
            name="pol7",
            display_name="Strict environmental regulations are worth it",
            short_name="Policy: Env. Reg.",
            category="Attitude",
            kind="measurement",
            transform=PolarsReplace(mapping={1: -1, 2: 1}),
        ),
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
        IndexColumn(
            name="climate_action",
            display_name="Climate Action",
            short_name="CC Action",
            abbrev="A(CCA)",
            category="Attitude",
            kind="measurement",
            parts=["cc_pol_car", "cc_pol_tax", "cc_ica", "pol7", "cvcc6", "cvcc9_cc"],
        ),
    ],
)
