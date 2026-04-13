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
    "cc11",
    "cc12",
    "cvcc4_will",
    "soc_trust",
    "soc_help",
    "future",
    "cvcc10_cc",
    "cc3",
    "cc6",
    # "ccIO",
    # "ccGovt",
    # "ccSolving",
    # "ccCompensation",
    "cvcc_worryothers",
    "ew5",
    "cvcc4_should",
    "cvcc6",
    # "cvcc9_econ",
    "cvcc9_cc",
    # "cvcc9_cv",
    "cc_ica",
    "cc_pol_tax",
    "cc_pol_car",
    # "pol4",
    "pol7",
    "pol7_pi",
    # "pol8",
    # "pol8_pi",
    # "pol9",
    # "pol10",
    # "pol11",
    # "pol11_pi",
    "pol_affiliation",
    "pol_ideology",
    # "pol_worry_econ",
    # "pol_trust_cong",
    # "pol_trust_state",
    # "pol_trust_io",
    # "pol_trust_cdc",
    # "pol_trust_news",
    # "pol_trust_epa",
    # "pol_trust_sci",
    # "pol_laws_cong",
    # "pol_laws_state",
    # "pol_vote_support",
    "ew6",
    "cvcc4_personal",
    "dem_age",
    "dem_income",
    "dem_income_percep",
    "dem_urban",
    "current_pres",
    # "Variant_ccSolving",
    # "Variant_ccCompensation",
]

ALL_INPUT_COLUMNS = SURVEY_COLS + INPUT_QUESTION_COLUMNS

REVERSE_CODING = [
    "cc10",
    # "pol4",
    # "pol8",
    # "pol8_pi",
    # "pol9",
    # "pol10",
    # "pol11",
    # "pol11_pi",
    "dem_urban",
]

TRANSFORMS = [
    pl.col("cc1").replace({1: 2, 99: 1}),  # Move "yes" to 2, "don't know" to 1
    pl.col(r"^cc4_(world|wealthUS|poorUS|comm)$").replace(
        {1: 0, 2: 1, 99: 2}
    ),  # Insert "Don't know" between 'only a little' and 'a moderate amount'
    pl.col(r"^cc5_(world|wealthUS|poorUS|comm)$").replace({1: 0, 2: 1, 99: 2}),
]

VITERBI_IMPUTE_COLS = [
    col
    for col in INPUT_QUESTION_COLUMNS
    if col
    not in (
        "dem_age",
        # "ccSolving",
        # "ccCompensation",
        # "Variant_ccSolving",
        # "Variant_ccCompensation",
    )
]
FILL_IMPUTE_COLS = [pl.col("dem_age")]

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
    "soc_trust",
    "soc_help",
    "future",
    "cvcc10_cc",
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
    "ew5",
    "cvcc4_should",
    "cvcc6",
    # "cvcc9_econ",
    "cvcc9_cc",
    # "cvcc9_cv",
    "cc_ica",
    "cc_pol_tax",
    "cc_pol_car",
    # "pol4",
    "pol7",
    "pol7_pi",
    # "pol8",
    # "pol8_pi",
    # "pol9",
    # "pol10",
    # "pol11",
    # "pol11_pi",
    "pol_affiliation",
    "pol_ideology",
    # "pol_worry_econ",
    # "pol_trust_cong",
    # "pol_trust_state",
    # "pol_trust_io",
    # "pol_trust_cdc",
    # "pol_trust_news",
    # "pol_trust_epa",
    # "pol_trust_sci",
    # "pol_laws_cong",
    # "pol_laws_state",
    # "pol_vote_support",
]

BEHAVIOUR_COLS = [
    "ew6",
    "cvcc4_personal",
]

DEMOGRAPHIC_COLS = [
    "dem_urban",
    "dem_income",
    "dem_income_percep",
    "dem_age",
]

EXTERNAL_FACTORS = [
    "current_pres",
]

TREATMENT_COLUMNS = [
    # "Group_pol_vote_support",
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

GROUPS: dict[str, list[str | pl.Expr]] = {}

RENAME: dict[str, str] = {}
