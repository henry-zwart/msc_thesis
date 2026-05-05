import numpy as np
import polars as pl

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
    pl.col("cc6", "cvcc_worryothers").replace(
        {1: -2, 2: -1, 3: 1, 4: 2}
    ),  # (-2, -1, 1, 2) = (not at all, not very, somewhat, very)
    pl.col("ew5").replace(
        {1: -2, 2: -1, 3: 1, 4: 2}
    ),  # (-2, -1, 1, 2) = (not at all, a little, moderate, great deal)
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
    "Climate Policy": [
        "cc_pol_car",
        "cc_pol_tax",
        "cc_ica",
        "pol7",
        "cvcc6",
        "cvcc9_cc",
    ],
}

RENAME: dict[str, str] = {
    "cc1": "Climate change",
    "cc2": "CC anthropogenic",
    "cc6": "CC worry",
    "cvcc_worryothers": "CC worry (others)",
    "ew5": "Weather worry",
    "politics": "Politics",
    "climate_policy": "Climate policy",
    "climate_impacts": "Climate impacts",
    # "ew6": "Weather preparation",
}
