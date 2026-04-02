import numpy as np
import polars as pl

SURVEY_COLS = [
    "participant_id",
    "wave",
]

INPUT_QUESTION_COLUMNS = [
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
    "ew6",
    # "cvcc4_personal",
]

ALL_INPUT_COLUMNS = SURVEY_COLS + INPUT_QUESTION_COLUMNS

REVERSE_CODING = []

TRANSFORMS = [
    pl.col("cc1").replace({1: 2, 99: 1}),  # Move "yes" to 2, "don't know" to 1
    pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace(
        {1: 0, 2: 1, 99: 2}
    ),  # "Don't know" between 'only a little' and 'a moderate amount'
]

VITERBI_IMPUTE_COLS = INPUT_QUESTION_COLUMNS
FILL_IMPUTE_COLS = []


BELIEF_COLS = [
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
    "ew6",
    # "cvcc4_personal",
]

DEMOGRAPHIC_COLS = []

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
    "Extreme weather": ["ew5", "ew6"],
    # "Climate Behaviour": ["cvcc4_should", "cvcc4_will", "cvcc4_personal"],
    # "Self Efficacy": ["cc10", "cc11", "cc12"],
    "Climate Impacts": [
        "cc4_world",
        "cc4_poorUS",
        "cc4_wealthUS",
        "cc4_comm",
        # "cc5_world",
        # "cc5_poorUS",
        # "cc5_wealthUS",
        # "cc5_comm",
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
    # "cc3": "CC threat level",
    "cc6": "CC worry",
    "cvcc_worryothers": "CC worry (others)",
    # "cvcc6": "CC indiv. action",
    # "cvcc9_cc": "CC scientists role",
}
