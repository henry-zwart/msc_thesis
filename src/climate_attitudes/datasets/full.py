import numpy as np
import polars as pl

from .common import Column, DatasetSchema, PolarsReplace

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

schema = DatasetSchema(
    columns=[
        Column(name="participant_id", display_name="Participant ID", kind="survey"),
        Column(name="wave", display_name="Wave", kind="survey"),
        Column(
            name="current_pres",
            display_name="Current president",
            short_name="Current president",
            kind="covariate",
        ),
        Column(name="dem_age", display_name="Age", short_name="Age", kind="covariate"),
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
            reverse_coding=True,
        ),
        Column(
            name="cc1",
            display_name="Belief in climate change",
            short_name="Belief CC",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 2, 99: 1}),
        ),
        Column(
            name="cc2",
            display_name="Belief about causes of climate change",
            short_name="CC anthropogenic",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="cc4_world",
            display_name="Belief about impacts of CC on world",
            short_name="CC impacts (world)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc4_wealthUS",
            display_name="Belief about impacts of CC on wealthy US communities",
            short_name="CC impacts (wealth US)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc4_poorUS",
            display_name="Belief about impacts of CC on poor US communities",
            short_name="CC impacts (poor US)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc4_comm",
            display_name="Belief about impacts of CC on own community",
            short_name="CC impacts (own community)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc5_world",
            display_name="Belief about future impacts of CC on world",
            short_name="CC impacts (world)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc5_wealthUS",
            display_name="Belief about future impacts of CC on wealthy US communities",
            short_name="CC impacts (wealth US)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc5_poorUS",
            display_name="Belief about future impacts of CC on poor US communities",
            short_name="CC impacts (poor US)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc5_comm",
            display_name="Belief about future impacts of CC on own community",
            short_name="CC impacts (own community)",
            category="Belief",
            kind="measurement",
            transform=PolarsReplace(mapping={1: 0, 2: 1, 99: 2}),
        ),
        Column(
            name="cc10",
            display_name="Knowledge of risks of CC by those exposed",
            short_name="CC risk knowledge (others)",
            category="Belief",
            kind="measurement",
            reverse_coding=True,
        ),
        Column(
            name="cc11",
            display_name="Self-efficacy on climate risks",
            short_name="CC self-efficacy",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="cc12",
            display_name="Level of dread about CC (others)",
            short_name="CC dread (others)",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="cvcc4_will",
            display_name=(
                "Most people will adopt enviornmentally-friendly behaviour "
                "following pandemic"
            ),
            short_name="CC behaviour change (will; others)",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="cvcc4_should",
            display_name=(
                "Most people should adopt enviornmentally-friendly behaviour "
                "following pandemic"
            ),
            short_name="CC behaviour change (should; others)",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="cvcc4_personal",
            display_name=(
                "I will adopt enviornmentally-friendly behaviour following pandemic"
            ),
            short_name="CC behaviour change (will; self)",
            category="Behaviour",
            kind="measurement",
        ),
        Column(
            name="soc_trust",
            display_name="People are generally trustworthy",
            short_name="Trust in people",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="soc_help",
            display_name="People are generally helpful",
            short_name="People helpful",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="future",
            display_name="Future outlook",
            short_name="Future outlook",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="cvcc10_cc",
            display_name="CC will be solved through technology",
            short_name="Tech. CC solution optimism",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="cc3",
            display_name="CC threat level",
            short_name="CC threat level",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="cc6",
            display_name="Worry about current and future CC",
            short_name="CC worry",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="cvcc_worryothers",
            display_name="Belief about others' worry about current and future CC",
            short_name="CC worry (others)",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="ew5",
            display_name="Worry about future extreme weather",
            short_name="Weather worry",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="ew6",
            display_name="Level of preparation for extreme weather",
            short_name="Extreme weather prep",
            category="Behaviour",
            kind="measurement",
        ),
        Column(
            name="cvcc6",
            display_name="Importance of individual action on CC",
            short_name="CC individual action",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="cvcc9_cc",
            display_name="Scientists should guide CC response",
            short_name="Scientists in CC response",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="cc_ica",
            display_name="Support for international carbon emission agreement",
            short_name="International emission agreement",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="cc_pol_tax",
            display_name="Support for tax on carbon-based fuels",
            short_name="Tax carbon fuels",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="cc_pol_car",
            display_name=(
                "Support for stronger emissions standard for auto manufacturers"
            ),
            short_name="Stronger emissions standards (auto)",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="pol7",
            display_name="Strict environmental regulations are worth it",
            short_name="Env. regulation worth it",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="pol7_pi",
            display_name="Strict environmental regulations are worth it (others)",
            short_name="Env. regulation worth it (others)",
            category="Belief",
            kind="measurement",
        ),
        Column(
            name="pol_affiliation",
            display_name="Political affiliation",
            short_name="Political affiliation",
            category="Attitude",
            kind="measurement",
        ),
        Column(
            name="pol_ideology",
            display_name="Political ideology",
            short_name="Political ideology",
            category="Attitude",
            kind="measurement",
        ),
    ],
)
