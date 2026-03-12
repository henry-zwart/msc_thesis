import numpy as np

SURVEY_COLS = [
    "participant_id",
    "wave",
]

BELIEF_COLS = []

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

BEHAVIOUR_COLS = []

DEMOGRAPHIC_COLS = []

EXTERNAL_FACTORS = []

TREATMENT_COLUMNS = []

REVERSE_CODING = [
    "pol4",
    "pol8",
    "pol8_pi",
    "pol9",
]

TRANSFORMS = []

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
