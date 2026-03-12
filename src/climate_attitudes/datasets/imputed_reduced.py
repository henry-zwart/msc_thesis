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

ATTITUDE_COLS = [
    "cc3",
    "cc6",
    # "ccIO",
    # "ccGovt",
    "cvcc_worryothers",
    "ew5",
    "cvcc4_should",
    "cvcc6",
    "cvcc9_econ",
    "cvcc9_cc",
    "cvcc9_cv",
    "cc_ica",
    "cc_pol_tax",
    "cc_pol_car",
    "pol4",
    "pol7",
    "pol7_pi",
    "pol8",
    "pol8_pi",
    "pol9",
    "pol_affiliation",
    "pol_ideology",
    "pol_trust_cong",
    "pol_trust_state",
    "pol_trust_io",
    "pol_trust_cdc",
    "pol_trust_news",
    "pol_trust_epa",
    "pol_trust_sci",
    "pol_laws_cong",
    # "pol_laws_state",
    # "pol_vote_support",
]

BEHAVIOUR_COLS = [
    "ew6",
    "cvcc4_personal",
]

DEMOGRAPHIC_COLS = [
    # "dem_age",
]

EXTERNAL_FACTORS = [
    # "current_pres",
]

TREATMENT_COLUMNS = [
    # "Group_pol_vote_support",
]

REVERSE_CODING = [
    "cc10",
    "pol4",
    "pol8",
    "pol8_pi",
    "pol9",
]

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
