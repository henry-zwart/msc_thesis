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
    "cc5_world",
    "cc5_wealthUS",
    "cc5_poorUS",
    "cc5_comm",
    "cc10",
    "cc11",  # If included, cc10 and cc12 related. If excluded, they are less so. Possible collider.
    "cc12",
    "cvcc4_will",
    "cc3",
    "cc6",
    # "ccIO",
    # "ccGovt",
    "ccSolving",
    "ccCompensation",
    "cvcc_worryothers",
    "ew5",
    "cvcc4_should",
    "cvcc6",
    "cvcc9_cc",
    "cc_ica",
    "cc_pol_tax",
    "cc_pol_car",
    "pol7",
    "pol7_pi",
    "pol_affiliation",
    "pol_ideology",
    "ew6",
    "cvcc4_personal",
    "dem_age",
    "dem_income",
    "Variant_ccSolving",
    "Variant_ccCompensation",
]

ALL_INPUT_COLUMNS = SURVEY_COLS + INPUT_QUESTION_COLUMNS

REVERSE_CODING = [
    "cc10",
]

TRANSFORMS = [
    pl.col("cc1").replace({1: 2, 99: 1}),  # Move "yes" to 2, "don't know" to 1
    pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace(
        {1: 0, 2: 1, 99: 2}
    ),  # Shift "not at all", "only a little" down; insert "don't know" between "only a little" and "a moderate amount"
    pl.col(r"^cc5_(world|wealthUS|poorUS|comm)$").replace({1: 0, 2: 1, 99: 2}),
]

VITERBI_IMPUTE_COLS = [
    col
    for col in INPUT_QUESTION_COLUMNS
    if col
    not in (
        "dem_age",
        "ccSolving",
        "ccCompensation",
        "Variant_ccSolving",
        "Variant_ccCompensation",
    )
]
FILL_IMPUTE_COLS = pl.col("dem_age")


BELIEF_COLS = [
    "cc1",
    "cc2",
    "cc4_world",
    "cc4_wealthUS",
    "cc4_poorUS",
    "cc4_comm",
    "cc5_world",
    "cc5_wealthUS",
    "cc5_poorUS",
    "cc5_comm",
    "cc10",
    "cc11",  # If included, cc10 and cc12 related. If excluded, they are less so. Possible collider.
    "cc12",
    "cvcc4_will",
]

EXPERIENCE_COLS = []

ATTITUDE_COLS = [
    "cc3",
    "cc6",
    # "ccIO",
    # "ccGovt",
    "wtp_solve",
    "wtp_compensation",
    "cvcc_worryothers",
    "ew5",
    "cvcc4_should",
    "cvcc6",
    "cvcc9_cc",
    "cc_ica",
    "cc_pol_tax",
    "cc_pol_car",
    "pol7",
    "pol7_pi",
    "pol_affiliation",
    "pol_ideology",
]

BEHAVIOUR_COLS = [
    "ew6",
    "cvcc4_personal",
]

DEMOGRAPHIC_COLS = [
    # "dem_age",
    # "dem_income",
]

EXTERNAL_FACTORS = [
    # "current_pres",
]


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
