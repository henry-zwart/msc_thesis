from __future__ import annotations
from climate_attitudes.schema.enums import WAVES, ItemCategory, UrbanArea
import polars as pl
import pandera.polars as pa
from .enums import (
    ResponseType,
    ParticipantType,
    GroupCCGlobalResponse,
    GroupCleanAir,
    GroupPolVoteSupport,
    Education,
    StateAbbrev,
    NaturalDisaster,
    Gender,
    StormAttribution,
    OutageAttribution,
    ClimateChangeCause,
    ClimateChangeInducedAction,
    ClimatePolicyBenefit,
    ReasonOpposeGreenInfra,
    ReasonSupportGreenInfra,
    ReasonOpposeInfra,
    ReasonSupportInfra,
    CovidPolicyFlowonPriority,
    PoliticalParty,
    PoliticalLeaning,
    PoliticalIdeology,
)


class BaseSchema(pa.DataFrameModel):
    class Config:
        ordered = True
        strict = True


class OutputCodebookSchema(BaseSchema):
    codebook_name: str
    item_name: str
    question_text: str
    response_type: ResponseType  # ty: ignore (not handling Polars Enum)
    response_schema: str = pa.Field(nullable=True)
    display_logic: str = pa.Field(nullable=True)
    response_requirements: str = pa.Field(nullable=True)
    randomization: str = pa.Field(nullable=True)
    note: str = pa.Field(nullable=True)
    w1_new: bool
    w2_new: bool
    w2_rep: bool
    w3_new: bool
    w3_rep: bool
    w4_new: bool
    w4_rep: bool
    w5_new: bool
    w5_rep: bool


class OutputItemColumnsSchema(BaseSchema):
    item_id: pl.UInt32
    item_name: str
    column_name: str


class OutputItemSchema(BaseSchema):
    item_id: pl.UInt32
    item_name: str
    group: str = pa.Field(nullable=True)
    category: ItemCategory = pa.Field(nullable=True)  # ty: ignore
    has_error: bool
    ideology_operational: bool
    ideology_symbolic: bool
    lee_2025_cc_happening: bool
    lee_2025_cc_human: bool
    lee_2025_cc_worried: bool
    lee_2025_personal_harm: bool
    lee_2025_future_gen_harm: bool
    lee_2025_fossil_fuel_reduction: bool
    lee_2025_renewable_energy: bool
    lee_2025_govt_priority: bool


class OutputQuestionSchema(BaseSchema):
    question_id: pl.UInt32
    item_id: pl.UInt32
    item_name: str
    codebook_name: str
    wave: int = pa.Field(isin=WAVES)
    participant_type: ParticipantType  # ty: ignore
    response_type: ResponseType  # ty: ignore
    response_schema: str = pa.Field(nullable=True)
    question_text: str
    treatment: pl.Int32


class OutputParticipantSchema(BaseSchema):
    participant_id: pl.UInt32
    wave_joined: int = pa.Field(isin=WAVES)
    wave_1: bool
    wave_2: bool
    wave_3: bool
    wave_4: bool
    wave_5: bool


class OutputResponseSchema(BaseSchema):
    response_id: pl.UInt32
    wave: int = pa.Field(isin=WAVES)
    participant_id: pl.UInt32
    participant_type: ParticipantType  # ty: ignore
    start_date: pl.Datetime
    end_date: pl.Datetime

    # Demographic columns
    dem_stcount_1: int  # State
    dem_stcount_1_char: StateAbbrev  # ty: ignore
    dem_stcount_2: int  # County
    dem_stcount_2_char: str
    dem_zip: str  # Zip code
    dem_educ: Education  # ty: ignore
    dem_male: Gender  # ty: ignore
    dem_male_77_TEXT: str = pa.Field(nullable=True)  # Nonempty if dem_male == 77
    dem_age: int = pa.Field(gt=0, le=99)
    dem_income: int = pa.Field(isin=[1, 2, 3, 4, 5, 6])
    dem_urban: UrbanArea = pa.Field(nullable=True)  # ty: ignore

    # Extreme weather
    ew1: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew1_apr: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew1_jun: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew1_nov: pl.List(NaturalDisaster) = pa.Field(nullable=True)  # ty: ignore
    ew_attribution: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_apr: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_jun: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew_attribution_nov: int = pa.Field(isin=[0, 1, 2, 3], nullable=True)
    ew3_mat: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)
    ew5: int = pa.Field(isin=[1, 2, 3, 4])
    ew6: int = pa.Field(isin=[1, 2, 3, 4])
    attr_storm: pl.List(StormAttribution) = pa.Field(nullable=True)  # ty: ignore
    attr_storm_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    attr_outage: pl.List(OutageAttribution) = pa.Field(nullable=True)  # ty: ignore
    attr_outage_13_TEXT: str = pa.Field(
        nullable=True
    )  # Non-null only if response is 13
    # TODO: ew_attr_fires_drag: Drag-and-drop

    # ===== Climate change (cc) columns =====
    # Climate change happening
    cc1: int = pa.Field(isin=[0, 1, 99], nullable=True)

    # Climate change causes/anthropogenic CC
    cc2: ClimateChangeCause = pa.Field(nullable=True)  # ty: ignore

    # Climate change is a scam
    cc_scam: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Seriousness of climate change problem
    cc3: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Current harms from climate change
    cc4_world: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_wealthcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_poorcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_wealthUS: int = pa.Field(isin=[1, 2, 3, 4, 99])
    cc4_poorUS: int = pa.Field(isin=[1, 2, 3, 4, 99])
    cc4_comm: int = pa.Field(isin=[1, 2, 3, 4, 99])
    cc4_person: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc4_famheal: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)
    cc4_famecon: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)
    cc4_raceUS: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Total impact of climate change on participant and family
    cc_impact_1: int = pa.Field(in_range=(0, 10), nullable=True)

    # Learn to live with CC vs. target with interventions until 'gone'
    cc_endemic: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Future generation harm from climate change
    cc5_world: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_wealthcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_poorcoun: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_wealthUS: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_poorUS: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)
    cc5_comm: int = pa.Field(isin=[1, 2, 3, 4, 99], nullable=True)

    # Level of worry about climate change
    cc6: int = pa.Field(isin=[1, 2, 3, 4])

    # Should <PERSON/ENTITY> be doing more/less to address current and future CC
    cc7_pres: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_cong: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_gov: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_local: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_ordcoun: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_ordcomm: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_corp: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_epa: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_fema: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc7_IO: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Support for data collection policy concerning personal emissions
    cc8: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # How much should <PERSON/ENTITY> be doing to address current and future CC
    cc8_pres: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_cong: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_gov: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_ordinary: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_corp: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_epa: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_fema: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_IO: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc8_otherctry: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # How often think about/discuss climate change in last month
    cc_think: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Threat assessments of climate change
    cc9_globecon: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_globstab: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_USecon: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_commday: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_famheal: int = pa.Field(isin=[1, 2, 3], nullable=True)
    cc9_famecon: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # Willingness to pay X amt. for policy to compensate climate-affected communities
    ccCompensation: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Willingness to pay X amt. for policy to response to/solve climate-affected communities
    ccSolving: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Support US financially supporting global resposne to climate change
    cc_global_response: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Support international climate agreement committing US (and others) to reduce carbon emissions
    cc_ica: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # Support $10B for climate change investments
    cc_fedinvest: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # If an international agreement is made to reduce emissions, what commitments should US make relative to other countries
    cc_commit: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # Policy support
    cc_pol_RE__research: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Renewables research
    cc_pol_tax: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Tax on fuel production
    cc_pol_car: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Stronger standards for auto manufacturers
    cc_pol_subs: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Rebates/subsidies for buying energy-efficient vehicles/solar

    # CC risks known precisely to those exposed
    cc10: int = pa.Field(in_range=(1, 7), nullable=True)

    # Capacity, through own actions, to avoid CC-related death
    cc11: int = pa.Field(in_range=(1, 7), nullable=True)

    # Public calm/dread regarding CC
    cc12: int = pa.Field(in_range=(1, 7), nullable=True)

    # Actions taken due to current/future CC impacts
    cc13: pl.List(ClimateChangeInducedAction) = pa.Field(nullable=True)  # ty: ignore
    cc13_apr: pl.List(ClimateChangeInducedAction) = pa.Field(nullable=True)  # ty: ignore

    # behaviors taken to help address CC
    cc_behavior_meat: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_travel: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_activ: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_discuss: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_evacuate: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cc_behavior_move: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # behaviors taken in last week to limit impact on CC
    cc_behaviorchange: int = pa.Field(isin=[0, 1, 2], nullable=True)

    # Support climate-related policies
    cc_policy_cars: int = pa.Field(in_range=(1, 7), nullable=True)
    cc_policy_re: int = pa.Field(in_range=(1, 7), nullable=True)
    cc_policy_house: int = pa.Field(in_range=(1, 7), nullable=True)
    cc_policy_risk: int = pa.Field(in_range=(1, 7), nullable=True)

    # Expected benefit from climate related policies
    cc_policybenefit: pl.List(ClimatePolicyBenefit) = pa.Field(nullable=True)  # ty: ignore

    # Climate change as policy issue vs. individual responsibility
    cc_resp_action: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Timeframe to mitigate catastrophic climate change
    cc_timeframe_w4new: int = pa.Field(
        isin=[1, 2, 3, 4, 5, 6, 9, 7, 8, 10], nullable=True
    )
    cc_timeframe: int = pa.Field(isin=[2, 3, 4, 5, 6, 7, 8, 1], nullable=True)

    # Policy support: reduce fossil fuel use, with cost to households
    dustin_question: int = pa.Field(isin=[0, 1], nullable=True)
    dustin_support: int = pa.Field(isin=[1, 2, 3], nullable=True)
    dustin_oppose: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # ==== COVID-19 / Climate-change =====
    # behavior change (experienced during COVID-19 pandemic), to reduce emissions
    cvcc4_personal: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)  # Intention
    cvcc4_will: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Expectation (of others)
    cvcc4_should: int = pa.Field(
        isin=[1, 2, 3, 4, 5], nullable=True
    )  # Attitude/normative view

    # Importance of individual action on climate change
    # cvcc_solution_kind: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvcc6: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # How worried are most Americans about CC?
    cvcc_worryothers: int = pa.Field(isin=[1, 2, 3, 4], nullable=True)

    # Policy support: large-scale green infrastructure plan
    cvcc_infrastructure_policy: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)
    cvcc8a__opp: pl.List(ReasonOpposeGreenInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8a__supp: pl.List(ReasonSupportGreenInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8a__opp_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    cvcc8a__supp_8_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 8
    cvcc8b__opp: pl.List(ReasonOpposeInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8b__supp: pl.List(ReasonSupportInfra) = pa.Field(nullable=True)  # ty: ignore
    cvcc8b__opp_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6
    cvcc8b__supp_6_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 6

    # Policy support: reducing emissions to reduce impact of future pandemics/CC
    cvcc_clean_air_policy: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Policy support: reducing emissions to reduce impact of global warming/climate change

    # Scientists with appropriate expertise should guide climate change response
    cvcc9_cc: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Optimism that climate change can be solved with technological solutions
    cvcc10_cc: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # Prioritise issues: COVID-19 policies that could help address other issues.
    cv__priority: CovidPolicyFlowonPriority = pa.Field(nullable=True)  # ty: ignore
    cv__priority2: CovidPolicyFlowonPriority = pa.Field(nullable=True)  # ty: ignore
    cv__priority_7_TEXT: str = pa.Field(nullable=True)  # Non-null only if response is 7
    cv__priority2_7_TEXT: str = pa.Field(
        nullable=True
    )  # Non-null only if response is 7

    # ==== US political issues =====
    # How much of a threat is global warming/climate change
    pol_threat_cc: int = pa.Field(isin=[1, 2, 3], nullable=True)

    # Regulation of business: harmful vs. necessary for public good
    pol4: int = pa.Field(isin=[1, 2])

    # Poor people: have it easy vs. have it hard
    pol5: int = pa.Field(isin=[1, 2])

    # Immigrants: good or bad for workforce
    pol6: int = pa.Field(isin=[1, 2])

    # Strict environmental laws: hurt economy vs. worth the cost
    pol7: int = pa.Field(isin=[1, 2])

    # US Foreign interests: Align with allies vs. follow own national interests
    pol8: int = pa.Field(isin=[1, 2])

    # US participation in global affairs: yes/no
    pol9: int = pa.Field(isin=[1, 2])

    # US economic system: unfair vs. fair
    pol10: int = pa.Field(isin=[1, 2])

    # In times of crises govt should: exercise control vs. prioritise civil liberties
    pol11: int = pa.Field(isin=[1, 2])

    # Political identification
    pol_interest: int = pa.Field(in_range=(1, 5))
    pol_party: PoliticalParty  # ty: ignore
    pol_lean: PoliticalLeaning = pa.Field(nullable=True)  # ty: ignore
    pol_ideology: PoliticalIdeology  # ty: ignore

    # Would proposal of climate policies make you more or less likely to support a political candidate
    # Change in support for political candidate after proposing climate/covid policies
    pol_vote_support: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)

    # ===== Experiment conditions =====
    # Willingness to pay (ccComp, ccSolve)
    Group_ccCompensation: int = pa.Field(isin=[0, 1, 2, 3, 4, 5], nullable=True)
    Variant_ccCompensation: int = pa.Field(isin=[0, 1, 10, 25, 50, 100], nullable=True)

    Group_ccSolving: int = pa.Field(isin=[0, 1, 2, 3, 4], nullable=True)
    Variant_ccSolving: int = pa.Field(isin=[0, 1, 10, 50, 100], nullable=True)

    # dustin_ques_64, dustin_ques_256
    Group_dustin_question: int = pa.Field(isin=[0, 1], nullable=True)
    Variant_dustin_question: int = pa.Field(isin=[64, 256], nullable=True)

    # ccIO, ccIOinterest, ccGovt, ccGovtinterest
    Group_cc_global_response: GroupCCGlobalResponse = pa.Field(nullable=True)  # ty: ignore

    # cvcc5 and cvcc6
    # Group_cvcc_solution_kind: int = pa.Field(isin=[0, 1], nullable=True)
    Groupcvcc_5and6: bool = pa.Field(nullable=True)

    # cvcc7 and cvcc8
    Group_cvcc_infrastructure_policy: int = pa.Field(isin=[0, 1], nullable=True)

    # cvccAir<X><Health | CC>
    Group_cvcc_clean_air_policy: GroupCleanAir = pa.Field(nullable=True)  # ty: ignore

    # # cvcc10
    Groupcvcc10: bool = pa.Field(nullable=True)

    # Political leaning (pol_vote_<CC | CV><X>)
    Group_pol_vote_support: GroupPolVoteSupport = pa.Field(nullable=True)  # ty: ignore
