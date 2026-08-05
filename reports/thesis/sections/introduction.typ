#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion


// *TODO:*
// - Address the specific variables we look at in the outbound/inbound experiments.
//   Are the variables interesting independently of the asymmetry results/theoretically
//   motivated?
// - Mention our hypotheses, where they exist.
//   - RQ3: That interventions can only be effective when the target and the
//     point-of-intervention are both low.


Our subjective interpretations of the world, natural phenomena, and
those around us are dependent on a collection of beliefs about how things are,
and how they work. These beliefs and attitudes are highly interdependent,
related by logical and psychological associations in what are often referred to as
belief systems. Beliefs and attitudes are also subject to social dynamics, as
evidenced by observed geographic segregation of political attitudes in the United
States. Moreover, beliefs and attitudes held by an individual have external consequences
for behavioural decisions and are in turn influenced by these decisions, often in the
form of reinforcing feedback loops. Put plainly, the beliefs and attitudes which allow us
to make internal sense of the world inevitably shape our collective impact on it.


Distinct beliefs and attitudes behave differently within a belief system. Some
attitudes, such as political ideology (e.g., conservativism or liberalism) are highly
stable over time @greenPartisanStabilityTurbulent2024. Others appear to be more
malleable (e.g., attitudes toward particular political candidates). In addition, some
beliefs and attitudes appear to be more influential than others. For instance, one
might intuitively expect political alignment to be dependent on individuals' policy
preferences. However, #cite(<unsworthItsPoliticalHow2014>, form: "prose") demonstrate
that causal influence may actually flow primarily in the opposite direction. When shown
identical policies with different partisan framings, individuals' support for those
policies shifts in line with their own political alignment, suggesting that partisan
identity may shape policy preferences more so than in the other direction.


Given belief systems' interdependent nature, understanding the behaviour of any single
belief (or attitude) requires consideration not only of how it interacts with
other beliefs, but also how _those beliefs_ interact with the broader belief system.
This has motivated empirical approaches to studying belief system structure based on
network science, which treat belief systems as undirected networks describing the
pairwise correlational structure (edges) between distinct beliefs and attitudes (nodes).

Analysis of _belief system networks_ using network science methods has proven
valuable for understanding belief system structure and the roles of specific beliefs and
attitudes in topic-specific belief systems. Using cross-national surveys, several studies
have examined geographic variation in belief system structure on topics including
politics @keskinturkOrganizationPoliticalBelief2022 @vannoordNatureStructureEuropean2025
and climate change @leeVariationsClimateChange2025, comparing both specific relations and
whole-network features such as density (the proportion of realised connections), and
inconsistency (the number of negative correlations). Similarly,
#cite(<chambonHowComplianceBehavioural2023>, form: "prose") examines how beliefs and
attitudes relating to COVID-19 changed over time in the Netherlands during the start of
the global pandemic. Node centrality---despite ongoing debate about its usefulness and
applicability to belief system networks
(cf. #cite(<bringmannWhatCentralityMeasures2019>, form: "prose"))---node
centrality is frequently used to assess belief position within a belief system
@brandtWhatCentralPolitical2019 @borsboomNetworkAnalysisMultivariate2021, relative influence
@robinaughIdentifyingHighlyInfluential2016, or structural importance
@dalegeNetworkAnalysisAttitudes2017 @fonseca2018analisis @heveyNetworkAnalysisBrief2018.
In addition, #cite(<chambonTailoredInterventionsBroad2022>, form: "prose") demonstrate
that node centrality may also contribute to the propagation of belief-level
interventions, in the context of a belief system on COVID-19.


// TODO: 'Both of these aspects are important to understanding how beliefs and attitudes
// change, affect one another and behaviour, and spread between individuals'.
Although belief system networks characterise the statistical associations between
beliefs and attitudes in a belief system, they make no claims regarding the nature of
these associations, how they arise, nor their implications for belief dynamics.
Several explanatory models have been proposed to address these shortcomings, most often
considering endogenous belief system dynamics as driven by individuals' efforts to
achieve consistent sets of beliefs and attitudes; that is, which are perceived as
mutually compatible. This perspective is particularly amenible to formalisation under
the framework of complex systems, treating belief system dynamics as arising from
micro-level attempts to resolve perceived inconsistencies between beliefs and attitudes.

Current theories (and models) of belief system dynamics have been especially influenced
by two classical theories of belief and attitude consistency:
#cite(<heiderAttitudesCognitiveOrganization1946>, form: "author")'s
_balance theory_
(#cite(<heiderAttitudesCognitiveOrganization1946>, form: "year")) and
#cite(<festingerCognitiveDissonance1962>, form: "author")'s
_theory of cognitive dissonance_
(#cite(<festingerCognitiveDissonance1962>, form: "year")).
Heider's balance theory interprets attitudes as signed, affective associations between
concepts. Inconsistency arises when three concepts are related in a triangle for which
the product of edge weights is negative. Festinger's theory of cognitive dissonance,
on the other hand, takes the view that beliefs (and by extension, attitudes) can be
more or less compatible with one another. The difference is best clarified with an
example. For instance, consider a person who cares deeply about animal wellbeing but who
also eats meat. We illustrate the two interpretations below. Heider (_left_) considers
the cognitive inconsistency as arising from the negative association between animals and
meat consumption (interpreted as 'harm'). To resolve this, the individual could adjust
their attitudes toward animal wellbeing, change their dietary habits, or limiting the
perceived association between animals and meat consumption. Festinger (_right_) instead
relates the individual's attitudes directly, rather than via their conceptual referrents,
but comes to the same conclusion, namely that the person will tend to change one of the
two attitudes, or reduce their perceived negative association.

#grid(
  columns: (1fr, 1fr),
  align: (center, center),
  row-gutter: 0.8em,
  [*(Balance theory)*], [*(Cognitive dissonance)*],
  image("../diagrams/cog_inconsistency/balance_theory.svg", height: 8em),
  image("../diagrams/cog_inconsistency/cognitive_dissonance.svg", height: 8em),
)

// TODO: Doesn't use their version of 'attitude'
// TODO: Maybe reference HIOM and networks of belief?
Balance theory and the theory of cognitive dissonance have given way to two families
of belief system models basd on the statistical physics notion of energy minimisation
@isingBeitragZurTheorie1925. The present study primarily considers models inspired by
Festinger's theory of cognitive dissonance, which is more so concerned with relations
_between_ beliefs and attitudes than attitudes as relating concepts. For models based
on Heider's balance theory, we refer the reader to
#cite(<greenwaldUnifiedTheoryImplicit2002>, form: "prose"),
#cite(<rodriguezCollectiveDynamicsBelief2016>, form: "prose"), and
#cite(<aiyappaEmergenceSimpleComplex2024>, form: "prose").

// TODO: We don't use the precise notion of attitude that they use
// TODO: Mention the HIOM, Networks of Belief as social extensions.
//  - More generally, mention the usefulness of these models.
The _Causal Attitude Network_ (CAN) model @dalegeFormalizedAccountAttitudes2016
formalises Festinger's theory of cognitive dissonance in an Ising-style model, also
drawing on the more recently-proposed connectionist perspective on attitude change
@monroeGeneralConnectionistModel2008. It can be viewed as a theory-driven variant of
the belief network approach described above. While the Ising model was originally
presented as a model of ferromagnetic behaviour @isingBeitragZurTheorie1925, it has
since been variously applied to describe diverse systems of interacting variables which
attract or repel one another @nguyenInverseStatisticalProblems2017.
In the CAN model, beliefs and attituds are
represented as spins which take on values in the set ${-1, +1}$, representing two
opposing states (e.g., 'climate change is happening' versus 'climate change is _not_
happening' or 'support' versus 'oppose'). These are related by reinforcing ($+$) or
opposing ($-$) interaction effects, based on the notion of cognitive dissonance.
Model dynamics are described in terms energy (read 'inconsistency') minimisation.
That is, individuals tend to reduce cognitive dissonance, such that positively
associated beliefs generally agree, and negatively associated beliefs generally disagree.

// *TODO:* (Maybe) Diagram of the CAN model.
Critically, the CAN model defines interaction relations as symmetric, such that related
beliefs exert equal reinforcing or opposing influence on one another. Under this
assumption the underlying Ising model satisfied detailed balance and can be considered
an equilbrium system. This is mathematically convenient, as it allows the CAN model to
define belief system dynamics implicitly using the Boltzmann distribution, such that
each belief system state is observed with constant probability as a decreasing function
of that state's inconsistency (or 'energy' in statistical physics terms).

In spite of its simple foundations, the CAN model and recent variants have
proven effective at capturing observed phenomena and demonstrated value for
predicting, or testing hypotheses about belief and attitude change.
For instance, both #cite(<dalegeAttitudinalEntropyAE2018>, form: "prose") and
#cite(<vandermaasPolarizationIndividualsHierarchical2020>, form: "prose") show
that such models may explain how merely thinking about a topic can induce more
extreme views. In several cases the CAN model (or analogous models) have been
used to explore the potential effects of intervention or persuasion attempts
on belief system dynamics via simulation
@dalegeNetworkAnalysisAttitudes2017 @schlicht-schmalzleAttitudeNetworkAnalysis2018
@lunanskyInterveningPsychopathologyNetworks2022 @berteroConsolidationChangeExploring2025.
Furthermore, #cite(<vandermaasPolarizationIndividualsHierarchical2020>, form: "prose")
and #cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose") demonstrate that
extensions of the CAN model which incorporate social influences on belief and
attitude dynamics are also highly expressive. In both cases, the authors model
social network influences via theoretically simple social cohesion mechanisms
(i.e., the assumption that individuals who interact tend to align their beliefs
and attitudes). This turns out to be sufficient to capture various phenomena
observed in reality, including: (i) attitude polarisation, (ii) how interventions
can drive extreme attitudes on topics that has previously received limited
attention, and (iii) how minority views propagate through a population
@dalegeNetworksBeliefsIntegrative2025.

// NOTE: Could point out the Monroe inspired CAN, and was 10 years prior.

However, although mathematically convenient, symmetric interactions are not
psychologically necessary. Indeed, this has been broadly acknowledged within the belief
systems modelling literature as a limitation of current approaches. Most authors
explicitly mention either causal directionality underlying inferred bi-directional
associations, or asymmetric/non-reciprocal influences as _plausible_
@epskampPersonalizedNetworkModeling2018 @brandtMeasuringBeliefSystem2022
@brandtEvaluatingBeliefSystem2021 @leeClimateChangeBelief2024
@powellModelingLeveragingIntuitive2023 @monroeGeneralConnectionistModel2008
@keskinturkOrganizationPoliticalBelief2022.
#cite(<vandermaasPolarizationIndividualsHierarchical2020>, form: "prose")
go so far as to assert that asymmetric influences are _likely_, for instance, in
relations linking attitudes and behaviour. Moreover, there exists some empirical evidence
for asymmetric interactions. For instance,
#cite(<chambonHowComplianceBehavioural2023>, form: "prose") observe directional
differences in temporal networks @kriekeEcologicalMomentaryAssessments2015 used to study
belief systems relating to COVID-19; however, as identifying asymmetry was not a core aim
of this study they do not test for the significance of these differences.

#let bn-footnote = footnote[
  Bayesian network models are a notable exception, which consider belief systems as
  directed acyclic graphs @powellModelingLeveragingIntuitive2023
  @cookRationalIrrationalityModeling2016. However, these do not allow for reinforcing
  relationships.  Moreover, they fall victim to the
  same problem as faced by the statistical belief system networks---while they describe the
  relationships observed in data, they provide no explanation for the nature of these
  relationships.
]
Despite general agreement on the plausibility of asymmetric interactions,
current research remains predominantly focused on symmetric models#bn-footnote.
A handful of authors make reference to simulation studies in which asymmetric edges
are used and found to have little impact
@vandermaasPolarizationIndividualsHierarchical2020 @monroeGeneralConnectionistModel2008.
However, these experiments are rarely described in detail, and we are not aware of any
instances in which asymmetric models are estimated from data. For the purposes of
mean-field approximation, #cite(<vandermaasStatisticalPhysicsPsychological2026>, form: "prose")
argue that theoretical results derived for Ising-style belief system models are robust
to asymmetric and non-reciprocity assumptions. However, they note that studies outside
the belief system modelling literature demonstrate that non-reciprocal Ising models
can, under certain conditions, exhibit considerably more complex behaviour than
the symmetric variant.


One area where the effects of asymmetric influence are likely to surface is the
assessment of belief importance, often quantified using centrality indices (as discussed
above). While most undirected-network centrality indices have directed-network analogues,
these can differ substantially in value @bringmannWhatCentralityMeasures2019. This
becomes especially critical when belief centrality is used to predict intervention
effectiveness. For instance, beliefs with many connections
(i.e., high strength or degree centrality) are often considered both (i) good targets
for interventions intended to propagate to other beliefs
(cf. #cite(<chambonTailoredInterventionsBroad2022>, form: "prose")), and (ii) more
resistant to such interventions, on account of their received influence from adjacent
beliefs (cf. #cite(<brandtInterattitudeCentralityDoes2023>, form: "prose")).
However, both conclusions rely on the assumption of bi-directional influence.
When influence may be asymmetric or non-reciprocal, we may find that some beliefs are
characterised almost exclusively by incoming or outgoing interactions, leading to
situations where well-connected beliefs have limited influence on other beliefs or
little-to-no resistance to interventions, respectively.

However, at the time of writing, empirical and theoretical studies into the existence,
nature, and potential structure of asymmetric influences among beliefs remain scarce.
Of particular concern, the absence of theoretical models of asymmetric
influences appears to be self-perpetuating, with some studies citing historical
trends as justification for continued focus on symmetric models
@brandtMeasuringBeliefSystem2022[p.~3].
Consequentially, it remains unclear as to whether asymmetric influence---should it
exist---meaningfully impacts belief system dynamics, or the conclusions we draw from
models thereof.





//
//
// Asymmetric interactions
// Asymmetric influences may have
// From an empirical perspective, the presence of asymmetric
// interactions has potentially significant implications for node centrality. While
// most undirected-network centrality indices have directed-network analogues, these
// can differ substantially in value @bringmannWhatCentralityMeasures2019.
//
// Belief-level interventions may be particularly sensitive to
// assumptions about interaction asymmetry. For instance, beliefs with many connections
// (i.e., high strength or degree centrality) are often considered both (i) good targets
// for interventions intended to propagate to other beliefs
// (cf. #cite(<chambonTailoredInterventionsBroad2022>, form: "prose")), and (ii) more
// resistant to such interventions, on account of their received influence from adjacent
// beliefs (cf. #cite(<brandtInterattitudeCentralityDoes2023>, form: "prose")).
// Both conclusions rely on the assumption that influence between
// beliefs flows bi-directionally, such that well-connected beliefs are both highly
// influential and highly influenced. However, if influence may be asymmetric or
// non-reciprocal it is entirely possible that some well-connected beliefs or attitudes
// are related primarily via incoming interactions, such that they have limited influence
// on others, or primarily via outgoing interactions, with limited
// resistance to interventions.
//


// - Alternatively, it may be the case that asymmetry only features as minor differences in
//   interaction strength, in which case the impacts would be smaller
// - Whether such beliefs and attitudes actually exist has not been studied


// - Choosing effective interventions with simulation studies: @castroCentralityMeasuresPsychological2024
//   - Their 'simulation' is the deactivation of nodes in the network. They don't simulate
//     belief system dynamics. They just measure path length after each deactivation.

In this study, we investigate the prevalence of asymmetric influence among beliefs and
attitudes about climate change in the US, as well as the dynamic implications of
symmetric and asymmetric modelling assumptions for belief-level interventions.
Using a combination of data-driven and simulation-based methods, we will
address the following four research questions:

#let RQ1 = [
  To what extent are belief-level influences _symmetric_ or _asymmetric_, in models
  of climate change belief systems inferred from the climate beliefs dataset?
]

#let RQ2 = [
  How do asymmetric and symmetric beliefs systems differ with regards to
  intervention strategy and effectiveness, in models inferred from the climate
  beliefs dataset?
]

#let RQ3 = [
  How do intervention outcome and effectiveness vary between individuals with
  different initial conditions in asymmetric belief systems inferred from the
  climate beliefs dataset?
]

#let RQ4 = [
  How do asymmetric belief systems inferred from the climate beliefs dataset
  vary between conservative and liberal individuals?
]

#{
  set enum(numbering: "RQ1.", indent: 1em)
  block(width: 97%, [
    + #RQ1 <RQ1>

    + #RQ2 <RQ2>

    + #RQ3 <RQ3>

    + #RQ4 <RQ4>
  ])
}

This study is divided into two halves. In the first half we establish a framework for
modelling belief systems with asymmetric influence relations, and estimating such models
from time-series data. In the second half, we then use this framework to address the
research questions listed above.

In @sec:asymmetric-belief-systems we introduce the *non-equilibrium belief system* model
(NEBS), a kinetic Ising model formulation of the Causal Attitude Network (CAN) model.
NEBS represents directed belief influences using distinct parameters, so is well-suited
for studying asymmetry in belief systems. NEBS' dynamics are explicitly time-dependent,
enabling straightforward analysis of belief system dynamics, including
post-intervention behaviour, on an _individual_ basis. This contrasts past studies that
analyse intervention effects via simulation on the CAN model
@dalegeNetworkAnalysisAttitudes2017 @schlicht-schmalzleAttitudeNetworkAnalysis2018
@lunanskyInterveningPsychopathologyNetworks2022 @berteroConsolidationChangeExploring2025
or GGM models @wuSimulatingNodeManipulations2026, which do
consider neither individuals' pre-intervention belief states, nor the time-scale of
model dynamics. @sec:methods then outlines a parameter estimation method for NEBS based
on maximum likelihood estimation. The proposed method uses knowledge of
a pre-defined soft binarisation function to robustly estimate binary model parameters
from survey data that is not necessarily binary, without requiring explicit binarisation.
We use this method to calibrate the NEBS model to a two-wave longitudinal
dataset comprising beliefs and attitudes relating to climate change (see below).

// ---the calibrated model is
// subsequently used to address our research questions in the second half of this study.

We then subsequently use the calibrated model to address our research questions in
the second half of the study. Inspired by approaches used in the context of the CAN
model, in @sec:methods we formalise interventions in Ising-style belief system models
as additional influencing variables. We also give algorithms for: (i) quantifying expected
intervention effects on an individual basis and (ii) comparing effects between symmetric
and asymmetric models, using Common Random Numbers to ensure result comparability.
We assess the existency of asymmetry and its population-level implications for
intervention dynamics in @sec:results-asymmetry-in-belief-systems, and
heterogeneity in intervention outcomes and belief systems in
@sec:heterogeneity-in-belief-systems-and-intervention-effects, relating these back
to our research questions in @sec:discussion, also discussing broader implications
for belief system modelling.

The data used for this study is sourced from the Longitudinal Panel of Perceptions About
Climate Change and Covid representative longitudinal survey (*CCCV*), collected in the
US between 2020 and 2023 @constantinoPersonalHardshipNarrows2022. Comprehensively
validating this dataset and constructing the targeted dataset of beliefs and attitudes
relating to climate change used in our experiments constituted substantial components of
this investigation, and contribute to future use of the CCCV dataset. We detail both
processes in @sec:dataset.


In its totality, this study presents a theory-driven approach to studying the structure
and dynamics of asymmetric belief systems. We apply this to investigate the existence and
prevalence of asymmetry in an observational context regarding beliefs and attitudes about
climate change, and the consequences of symmetry and asymmetry assumptions for reasoning
about intervention dynamics.

#line(length: 100%)




// Suggestions that interactions are not symmetric:
// - Converse:
//   - #cite(<converseNatureBeliefSystems2006>, form: "full")
//     - Page 70: [Social] groups which are "more or less potent as points of reference"
//     - View treats centrality as the measure of potency.
// - Brandt:
//   - #cite(<brandtWhatCentralPolitical2019>, form: "full")
//     - Page 2: Distinguishes causal potency from the simple 'centrality' adopted by
//       Converse. Asserts that causally potent variables may be on the periphery.
//     - Page 9: "It may be that some components with high centrality are never the cause
//       and only the consequence of other components."
//   - #cite(<brandtEvaluatingBeliefSystem2021>, form: "full")
//     - Page 6: "It is plausible that some nodes do not have reciprocal associations, [or]
//       that nodes affect themselves."
//   - #cite(<brandtMeasuringBeliefSystem2022>, form: "full")
//     - Page 3: Acknowledges plausibility of causal directionality, and limitation of
//       not capturing this with conceptual similarity judgements. Argues that this "may
//       be sufficient at this time as the theoretical models of belief systems also do
//       not specify causal direction". i.e., evidence that not modelling causal
//       directionality may be constraining advances.
// - Keskinturk:
//   - #cite(<keskinturkOrganizationPoliticalBelief2022>, form: "full")
//     - Page 10: "It is imperative for future research to incorporate the questions of
//       time and causal identification into the analyses."
// - Epskamp:
//   - #cite(<epskampPersonalizedNetworkModeling2018>, form: "full")
//     - Use of temporal networks to identify potential causal relations.
// - Sanguk Lee:
//   - #cite(<leeClimateChangeBelief2024>, form: "full")
// - Monroe:
//   - #cite(<monroeGeneralConnectionistModel2008>, form: "full")
//     - "No reason in principle that [weights must be symmetric]".
// - Van de Maas:
//   - #cite(<vandermaasPolarizationIndividualsHierarchical2020>, form: "full")
//     - Asserts that some relations---particularly between attitudes and behaviours---are
//       likely to be asymmetric.
//   - #cite(<vandermaasStatisticalPhysicsPsychological2026>, form: "full")
//     - Asymmetry may not affect mean-field results so much. But in some situations
//       can exhibit more complex behaviour @avniNonreciprocalIsingModel2025.



// @avniNonreciprocalIsingModel2025: Ising models with non-reciprocal or asymmetric edges
// can exhibit considerably more complex behaviour.




//
// *The puzzle*
//
// - Interpretation of node importance/influence in the CAN model. More constrained. Changes
//   affect many other beliefs.
// -
//
//
// + Target phenomenon: Some beliefs are more influential than others. Peripheral nodes
//   can be good intervention targets.
// + Failure mode of current understanding:
//   - Most authors agree/acknowledge directed influence relations as plausible
//   - Evidence of asymmetric relations between beliefs and attitudes from temporal networks
//   - To the best of our knowledge, there are no current theoretical models of belief
//     dynamics which capture asymmetric influences.
// + Consequence:
//   - Conceivably matters for interventions. (Diagrams)
//
// Examples:
// - Asymmetry? @arceneauxCriticalEvaluationResearch2025
// - @brandtWhatCentralPolitical2019[p.~2] "Causal potency does not necessarily say
//   anything about centrality, as the causally potent variable may be on the periphery
//   of the belief system."
//
// *Our study ...*



// Recent empirical evidence of asymmetric relations in fast-changing context using
// temporal network @chambonHowComplianceBehavioural2023:
// - Frame as:
//   - Evidence of asymmetric relations
//   - Helpful for explaining changes in compliance.
//   - Focuses on bi-directional reinforcing relations (we argue unidirectional cases also important,
//     as are cases where they are different)
//   - Post-hoc analysis (we argue this means also useful for simulation studies)
//   - 'Temporal networks have been used to analyse temporal associations between attitudes
//     and compliance during COVID-19'. i.e., focus is on 'analysis'. Can then say
//     *mechanistic* models of belief system dynamics are mostly concerned with
//     static constraint (symmetric relations). Is Bayesian network a mechanistic model?

// NOTE: Maybe talk about why symmetric relations prevalent. Easy (can use
// cross-sectional data); historically-prevalent.

// Empirical evidence for both the prevalence of asymmetric influences and their potential
// impacts on belief system dynamics remain limited.


== Motivation

Causality in psychological networks @kossakowskiSearchCausalityComparison2021

Practical considerations for designing empirical studies for psychological networks.
Discusses limitations of cross-sectional studies for teasing apart within-person and
between-person effects @chambonNetworkPsychometricsPractice2026.

Dynamics vs. static constraint. @converseNatureBeliefSystems2006

Intervention studies with belief system models:
- Looks at dynamics constraint. Uses symmetric network, doesn't fit individual models.
  Applies persuasive experimental condition and predicts how attitudes will change.
  Finds that attitudes generally change most when close to the point-of-intervention
  @turner-zwinkelsBeliefSystemNetworks2022
- Finds that (counter to their hypothesis) peripheral attitudes changed less than
  central ones (no 'straightforward association between inter-attitude centrality and
  persuasion'). Also uses symmetric model. 'such a process is often assumed to be
  bi-directional'. @brandtInterattitudeCentralityDoes2023
  - Possible explanation for their findings: attitudes found to be peripheral may not
    actually be peripheral. They may be asymmetric, with different
    influence/influentiability.
- Looks at temporal network of behavioural compliance in COVID-19
  @chambonHowComplianceBehavioural2023. Says they measure within-person effects, but
  not clear that this is true (they use temporal and contemporaneous networks).
  - Their context is expected to have non-stable beliefs and attitudes. Early stages
    of pandemic.
  - They find cases of asymmetry, but these are typically in the other direction.
    Variables which are mostly influenced by others. We find variables which mostly
    influence others.
  - Their focus is primarily on bi-directional reinforcing effects. They also don't
    compare with symmetric model.
- @chambonTailoredInterventionsBroad2022

Issue support on climate policies in US driven by political identification and climate
beliefs @bumannWhatAreDeterminants2021 @shaoApprovalPoliticalLeaders2020
@zieglerPoliticalOrientationEnvironmental2017 @roser-renoufGenesisClimateChange2014
@unsworthItsPoliticalHow2014.

But political identification is often not consistent with policy attitudes
@iyengarAffectNotIdeology2012 @huddyExpressivePartisanshipCampaign2015. More often
identity-driven (symbolic) than issue-driven (operational)
@masonIdeologuesIssuesPolarizing2018. Also @eganIdentityDependentVariable2020.

Suggestions of asymmetric/causal directionality in belief systems:
- So far reviewed in Zotero: Belief Networks, Papers from Sara
- @brandtWhatCentralPolitical2019[p.~2,9,10]
- @brandtMeasuringBeliefSystem2022[p.~3,22]
- @keskinturkOrganizationPoliticalBelief2022[p.~10]
- @vannoordNatureStructureEuropean2025[p.~4]
- @brandtEvaluatingBeliefSystem2021[p.~2]: Belief system _dynamics_ require causal connections.
  - Constraint, causality, exogenous factors all necessary for any theory of BS dynamics.
  - Though still interprets edges as undirected/bi-directional
- @brandtEvaluatingBeliefSystem2021[p.~22]: "In some cases ... assume that causal influence
  for some elements (e.g., partisan identification) is primarily in one direction".
- @converseNatureBeliefSystems2006[p.~208] (mentioned in @brandtEvaluatingBeliefSystem2021[p.~2])
- @coppockBeliefSystemsExhibit2022: Referenced in @brandtEvaluatingBeliefSystem2021

Self-interaction effects:
- @brandtEvaluatingBeliefSystem2021[p.~22]: "we made the simplifying assumption that a node
  does not affect itself".


Variation in belief systems between individuals:
- @brandtEvaluatingBeliefSystem2021[p.~4,20] "connections will likely vary between people,
  time, and political contexts", "Although ... belief systems are at the individuals level,
  this does not mean that structure is not shared"


Stability of belief dynamics:
- @osborneDoesOpennessExperience2020
- @kileyMeasuringStabilityChange2020
  - Most observed change in beliefs and behaviours is short-term (or measurement error)
  - This is consistent with the cognitive dissonance theory

Individual belief dynamics are important to understanding behavioural influences
between individuals: @rodriguezCollectiveDynamicsBelief2016
@aiyappaEmergenceSimpleComplex2024
- "Models of internal belief networks generally disregard external social networks, although a number of classic social-cognitive theories recognise the importance of social environments in changing individual beliefs and behaviours (Ajzen, 1991; Cialdini & Trost, 1998; Festinger, 1954; Fishbein & Ajzen, 1975; Petty & Cacioppo, 1986)" @dalegeNetworksBeliefsIntegrative2025

Richness of _perceptions_ of others beliefs:
- Discussed in @dalegeNetworksBeliefsIntegrative2025
- References @galesicHumanSocialSensing2021

Approaches to modelling belief systems/dynamics:
- Regularised partial correlation networks, e.g., @brandtWhatCentralPolitical2019
- Bayesian networks @powellModelingLeveragingIntuitive2023
- Social Knowledge Structure @greenwaldUnifiedTheoryImplicit2002
- Causal Attitude Network @dalegeFormalizedAccountAttitudes2016
  - Attitudinal Entropy @dalegeAttitudinalEntropyAE2018
- Hierarchical Ising Opinion model.
- SEM?

Our approach as an intermediate between undirected models and directed models with
prespecified structure or acyclicity constraints.

Understanding exogenous influences on belief systems and attitudes
@coppockBeliefSystemsExhibit2022

Modularity clustering for correlation networks @masudaIntroductionCorrelationNetworks2025

// == Asymmetry example
//
// Suppose thin arrows have weight 1, thick arrows have weight 2, and a belief/attitude
// adopts the dominant state in its neighbourhood, weighted by the incoming edge weights.
// If your support for non-climate-related policies and your social circle are
// Republican-aligned, you adopt that political ideology. Suppose that you believe in
// human-caused climate change, then that reinforces your support for climate action;
// however, the net support is $-1$, so you flip, taking the support for Republican
// politics to $+4$. If you then become concerned about extreme weather, and believe
// that the impacts of climate change are high, your support for climate action flips
// to positive with a net support of $+1$. However, this is not sufficient to shift
// your Republican alignment, which stays at $-1$. In the extreme case, where there is
// no feedback to Politics, your change in attitude has no bearing on your political
// alignment.
//
// Asymmetry is then best thought of as the weight imposed on one belief/attitude by
// another being different from the opposite direction. To overcome Republican alignment,
// we need at least two pro-Democrat attitudes. To overcome negative `CC Action`,
// we require at least three other pro-climate attitudes.
//


// == Contributions
// + We present a mathematical model for belief system dynamics that does not assume
//   equilibrium and does not assume symmetric influence between cognitive aspects
//   (@sec:asymmetric-belief-systems)
// + We describe a novel parameter estimation method for fitting binary Ising models to
//   continuous data (@sec:methods).
// + We calibrate said model to data from a recent longitudinal survey including items on
//   beliefs and attitudes regarding climate change
//   (@sec:results-asymmetry-in-belief-systems).
// + We demonstrate, by way of the calibrated model, the existence of asymmetric influence
//   relations between beliefs and attitudes. Furthermore we show that influence relations
//   are not _necessarily_ asymmetric, may vary in the degree of asymmetry, and can be
//   unidirectional (@sec:results-asymmetry-in-belief-systems).
// + We demonstrate that the decision to represent asymmetric relations in belief system
//   models can change intervention dynamics, and therefore conclusions one draws
//   regarding intervention effect and effectiveness
//   (@sec:results-asymmetry-in-belief-systems).
// + We then show that belief systems may vary significantly between individuals, by
//   fitting the proposed model to subsets of the climate attitudes dataset comprising
//   conservative and liberal individuals
//   (@sec:heterogeneity-in-belief-systems-and-intervention-effects).
// + Finally, we show that reasoning about the effects of interventions on _individuals_
//   is, in general, non-trivial. How an individual responds to an intervention typically
//   depends on their prior belief system state, including beliefs and attitudes other
//   than the target and goal of intervention
//   (@sec:heterogeneity-in-belief-systems-and-intervention-effects).
//
