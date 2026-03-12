import numpy as np
import polars as pl

SURVEY_COLS = [
    "participant_id",
    "wave",
]

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
    "cc11",
    "cc12",
    "cvcc4_will",
    # "soc_trust",
    # "soc_help",
    "cvcc10_cc",
]

EXPERIENCE_COLS = []

ATTITUDE_COLS = []

BEHAVIOUR_COLS = []

DEMOGRAPHIC_COLS = []

EXTERNAL_FACTORS = []

TREATMENT_COLUMNS = []

REVERSE_CODING = ["cc10"]

TRANSFORMS = [
    pl.col("cc1").replace({1: 2, 99: 1}),  # Move "yes" to 2, "don't know" to 1
    pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace(
        {1: 0, 2: 1, 99: 2}
    ),  # Shift "not at all", "only a little" down; insert "don't know" between "only a little" and "a moderate amount"
    pl.col(r"^cc5_(world|wealthUS|poorUS|comm)$").replace({1: 0, 2: 1, 99: 2}),
]

QUESTION_COLS = (
    BELIEF_COLS
    + EXPERIENCE_COLS
    + ATTITUDE_COLS
    + BEHAVIOUR_COLS
    + DEMOGRAPHIC_COLS
    + EXTERNAL_FACTORS
)

ALL_COLS = SURVEY_COLS + QUESTION_COLS + TREATMENT_COLUMNS

CATEGORIES = np.asarray(
    ["Belief"] * len(BELIEF_COLS)
    + ["Experience"] * len(EXPERIENCE_COLS)
    + ["Attitude"] * len(ATTITUDE_COLS)
    + ["Behaviour"] * len(BEHAVIOUR_COLS)
    + ["Demographic"] * len(DEMOGRAPHIC_COLS)
    + ["External factor"] * len(EXTERNAL_FACTORS)
)
