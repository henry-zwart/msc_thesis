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
    "cc11",  # If included, cc10 ~ cc12. If excluded, less so. Possible collider.
    "cc12",
    "cvcc4_will",
    "cc3",
    "cc6",
    # "ccIO",
    # "ccGovt",
    # "ccSolving",
    # "ccCompensation",
    "cvcc_worryothers",
    # "ew3_phy_recent",
    # "ew3_mat_recent",
    # "ew3_men_recent",
    # "ew3_fin_recent",
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
    "cc_behaviorchange",
    "cc_behaviour_meat",
    "cc_behaviour_travel",
    "cc_behaviour_active",
    "cc_behaviour_discuss",
    "cc_behaviour_evacuate",
    "cc_behaviour_move",
    # "dem_age",
    # "dem_income",
    # "dem_income_percep",
    # "Variant_ccSolving",
    # "Variant_ccCompensation",
]

ALL_INPUT_COLUMNS = SURVEY_COLS + INPUT_QUESTION_COLUMNS

REVERSE_CODING = [
    "cc10",
]

TRANSFORMS = [
    pl.col("cc1").replace({1: 2, 99: 1}),  # Move "yes" to 2, "don't know" to 1
    pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace(
        {1: 0, 2: 1, 99: 2}
    ),  # "Don't know" between 'only a little' and 'a moderate amount'
    pl.col(r"^cc5_(world|wealthUS|poorUS|comm)$").replace({1: 0, 2: 1, 99: 2}),
]

VITERBI_IMPUTE_COLS = [
    col
    for col in INPUT_QUESTION_COLUMNS
    if col
    not in (
        "ew3_phy_recent",
        "ew3_mat_recent",
        "ew3_men_recent",
        "ew3_fin_recent",
        "cc_behaviorchange",
        "cc_behaviour_meat",
        "cc_behaviour_travel",
        "cc_behaviour_active",
        "cc_behaviour_discuss",
        "cc_behaviour_evacuate",
        "cc_behaviour_move",
        # "dem_age",
        # "ccSolving",
        # "ccCompensation",
        # "Variant_ccSolving",
        # "Variant_ccCompensation",
    )
]
FILL_IMPUTE_COLS = [
    pl.col(r"^ew3_(phy|mat|fin|men)(_recent)?$")
]  # pl.none()#pl.col("dem_age")


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
    "cc11",  # If included, cc10 ~ cc12. If excluded, less so. Possible collider.
    "cc12",
    "cvcc4_will",
]

EXPERIENCE_COLS = []

ATTITUDE_COLS = [
    "cc3",
    "cc6",
    # "ccIO",
    # "ccGovt",
    # "wtp_solve",
    # "wtp_compensation",
    "cvcc_worryothers",
    # "ew3_phy_recent",
    # "ew3_mat_recent",
    # "ew3_men_recent",
    # "ew3_fin_recent",
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
    "cc_behaviorchange",
    "cc_behaviour_meat",
    "cc_behaviour_travel",
    "cc_behaviour_active",
    "cc_behaviour_discuss",
    "cc_behaviour_evacuate",
    "cc_behaviour_move",
]

DEMOGRAPHIC_COLS = [
    # "dem_age",
    # "dem_income",
    # "dem_income_percep",
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

GROUPS: dict[str, list[str | pl.Expr]] = {
    "Politics": ["pol_ideology", "pol_affiliation"],
    "Extreme weather": ["ew5", "ew6"],
    "CC Behaviour Change": ["cvcc4_should", "cvcc4_will", "cvcc4_personal"],
    "CC Rational": ["cc10", "cc11", "cc12"],
    "CC Impacts": [pl.col(r"^cc(4|5)_(world|poorUS|wealthUS|comm)$")],
    "CC Policy": ["cc_pol_car", "cc_pol_tax", "cc_ica", "pol7"],
}

RENAME: dict[str, str] = {}
