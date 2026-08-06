#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

// NOTE:
// - Nodes considered peripheral in a symmetric model may be more central in an asymmetric
//   model.

//*0. (Maybe) Little reminder of the gap(?)*

Most studies on belief system structure or dynamics acknowledge the likelihood
that some beliefs or attitudes may be more causally influential than others. Despite
this, current research deals, almost universally, in belief system models which assume
symmetric influences between beliefs and/or attitudes. Theoretical models which capture
asymmetric relations remain scarce, as do empirical studies on the existence of such
asymmetry and its potential implications for belief system dynamics.

In this study we have addressed both theoretical and empirical shortcomings. We first
introduced the Kinetic Belief System model (KBS) as a theory-based model of belief system
dynamics based on the Causal Attitude Network model  @dalegeFormalizedAccountAttitudes2016,
which: (i) _does not_ require symmetric influence and (ii) _does not_ assume equilibrium
dynamics. We then used the KBS model, calibrated to a longitudinal dataset comprising
beliefs and attitudes about climate change in the US, to address the four research
questions outined in the first chapter.

Our empirical investigation identified several clear asymmetric influence relations which
appeared to be structured around a small set of highly influential attitudes (political
views and climate-related worry). This suggests that (i) asymmetry may be the exception
rather than the norm, and (ii) asymmetry may be better characterised in terms of the
difference between a belief's influence and influentiability _in general_, than as a
property of specific relations. Furthermore, our simulated intervention
experiments demonstrated that asymmetry in a belief system can meaningfully affect
intervention effectiveness, in some cases potentially impacting conclusions about where
to intervene. These effects were most pronounced when targeting or intervening on
variables with several asymmetric influence relations.

Our secondary investigation examined how intervention effectiveness varies among
individuals, and potential differences between belief systems for liberal and
conservative subpopulations. In the first case, intervention effectiveness was found
to depend predictably on the pre-intervention state of individuals' belief systems.
Most effective interventions required that the point-of-intervention and target both
be different from their desired post-intervention states. While this was expected
behaviour, we additionally found that _all_ highly effective interventions required that
prior climate-related worry be low, suggesting that attitudes which are both highly
influential and highly influentiable may serve as effective indirect pathways for various
interventions.

Second, despite relatively smaller sample sizes, conservative and liberal
belief systems differed in sparsity and specific belief relations, while
also displaying broad structural similarities. Both findings align with those of previous
studies using symmetric networks @leeClimateChangeBelief2024. The similarities suggest
that while belief systems likely vary between individuals, they also likely
display common structural features (e.g., based on shared experiences or world-views).
The observed differences in pairwise relations when stratifying by
political ideology suggest the presence of higher-order relations between beliefs. This
is to say that the existence, strength, or direction of a given relation between two
beliefs may depend on the specific state of a third (in this case, political ideology).

Returning


#emph-block[
  An issue that was not addressed in this
  investigation was the disentangling of within-person from between-person effects. As such
  we cannot say whether the observed asymmetric relations are features of individual belief
  dynamics or population-level variation. Our study is not unique in this limitation;
  disentangling these effects has received increased attention in recent years
  @brandtBetweenpersonMethodsProvide2022 @brandtMeasuringBeliefSystem2022, yet remains
  difficult without substantial individual-level data. As methods
  progress in this area we consider addressing this limitation highly important.
]

#emph-block[
  We attribute the
  difference in dynamics between the symmetric and asymmetric models to misspecification
  under the symmetric model when true relations are asymmetric, showing that this can
  result in underestimating, overestimating, falsely including, or falsely
  excluding interaction effects.
]

#emph-block[
  In @sec:discussion we
  demonstrated a hypothetical scenario in which such higher-order interactions
  result in complex intervention dynamics. As such, while these are not presently
  captured by the KBS model, our findings here suggest that this may be a worthwhile
  extension.
]

#line(length: 100%)


While most studies on belief system dynamics acknowledge that some beliefs and
attitudes may be more causally influential than others, current research practice
is almost exclusively concerned with symmetric influence relations. Theoretical
belief system models which capture asymmetric relations remain scarce, as do
empirical studies on their existence and their potential impacts on belief
system dynamics. This study set out to address these theoretical and
empirical shortcomings.

In the first half of the study, we presented the Kinetic Belief System model (KBS) as a
theory-driven model of belief system dynamics, based
on the Causal Attitude Network (CAN) model @dalegeFormalizedAccountAttitudes2016.
In contrast to the CAN model, KBS can represent both asymmetric _and_ symmetric belief
relations, and defines belief system dynamics as explicitly time-dependent and
conditional on instantaneous beliefs and attitudes.

In the second half of the study we used the KBS model to address four research questions.
The primary aim of this study was to investigate the existence, prevalence, and structure
of asymmetric influence relations amongst beliefs and attitudes about climate change
(*RQ1*), and the dynamic implications of modelling assumptions about relational symmetry
in the context of belief-level interventions (*RQ2*). The secondary aims of this study
were to investigate how intervention effectiveness varies among individuals with
asymmetric belief systems (*RQ3*), and how asymmetric belief systems may differ
structurally between conservative and liberal subpopulations (*RQ4*).
We assessed the existence of asymmetric
relations and structural differences between ideological belief systems via direct
analysis of the calibrated models, and investigated the consequences of asymmetry for
intervention dynamics by comparing simulated outcomes with those of an analogous
symmetric model using common random numbers.

Our investigation identified several cases of asymmetry, among which political
views and cliamte-related worry consistently displayed excess influence over other
variables. These findings provide evidence for the existence of asymmetric influence
in belief systems, and suggest that this may be better characterised in terms
of differences between a belief's influence and influentiability in general, than as
a property of pairwise relations. Furthermore, the results indicate that asymmetry
may be the exception as opposed to the norm.
An issue that was not addressed in this
investigation was the disentangling of within-person from between-person effects. As such
we cannot say whether the observed asymmetric relations are features of individual belief
dynamics or population-level variation. Our study is not unique in this limitation;
disentangling these effects has received increased attention in recent years
@brandtBetweenpersonMethodsProvide2022 @brandtMeasuringBeliefSystem2022, yet remains
difficult without substantial individual-level data. As methods
progress in this area we consider addressing this limitation highly important.

// Our investigation identified several apparent cases of asymmetry. Among these,
// political ideology/alignment and climate-related worry were consistently identified as
// having excess influence on other variables. This suggests that asymmetry
// is likely to exist within belief systems, and may be better characterised in terms of
// the difference between a given belief's influence and influentiability in general, than
// as a property of particular relations. Most relations were
// not conclusively asymmetric, indicating that asymmetry may be the exception as opposed
// to the norm. An issue that was not addressed in this
// investigation was the disentangling of within-person from between-person effects. As such
// we cannot say whether the observed asymmetric relations are features of individual belief
// dynamics or population-level variation. Our study is not unique in this limitation;
// disentangling these effects has received increased attention in recent years
// @brandtBetweenpersonMethodsProvide2022 @brandtMeasuringBeliefSystem2022, yet remains
// difficult without substantial individual-level data. As methods
// progress in this area we consider addressing this limitation highly important.

Asymmetry was found to significantly impact simulated intervention dynamics, particularly
when targeting or intervening on asymmetric beliefs or attitudes. These findings suggest
that asymmetry can meaningfully impact belief system dynamics, and that assumptions of
symmetry can, in some cases, change strategic intervention decisions. We attribute the
difference in dynamics between the symmetric and asymmetric models to misspecification
under the symmetric model when true relations are asymmetric, showing that this can
result in underestimating, overestimating, falsely including, or falsely
excluding interaction effects.
// We found that assumptions regarding belief system symmetry or asymmetry can significantly
// impact model dynamics in intervention scenarios.  Both of the 'high-influence' attitudes
// identified in our initial investigation demonstrated increased overall effectiveness as
// points-of-intervention in asymmetric models. The evidence from these experiments suggests
// that asymmetry can meaningfully impact belief system dynamics, and assumptions of
// symmetry can, in some cases, change simulation-based conclusions about intervention
// strategy. We attribute the difference between the symmetric and asymmetric model dynamics
// to misspecification under the symmetric model when true relations are symmetric, showing
// that this can lead to underestimating, overestimating, falsely including, or falsely
// excluding interaction effects.

// #emph-block[
//   Turning to our secondary aims, we found that variations in intervention effectiveness
//   between individuals were straightforwardly characterisable in terms of the individuals'
//   initial states. The results suggest that indirect propagation of intervention effects
//   (i.e., through variables that are neither intervened on directly nor the target) can
//   contribute substantially to intervention effectiveness.
//
//   Expected intervention effectiveness was found to depend predictably on an individual's
//   belief system state prior to intervention. Most effective interventions required that
//   the point-of-intervention and target both be different from their desired
//   post-intervention states. While this was expected behaviour, we additionally found
//   that all highly effective interventions required that prior climate-related worry be
//   low. We attribute this finding to the variable's high levels of both influence and
//   influentiability, which make it an effective indirect pathway for various interventions
//   to propagate.
//
// ]

Expected intervention effectiveness was found to depend predictably on an individual's
belief system state prior to intervention. Most effective interventions required that
the point-of-intervention and target both be different from their desired
post-intervention states. While this was expected behaviour, we additionally found
that all highly effective interventions required that prior climate-related worry be
low. We attribute this finding to the variable's high levels of both influence and
influentiability, which make it an effective indirect pathway for various interventions
to propagate.

// #emph-block[
//   Finally, in spite of sample size limitations, we found that conservative and liberal
//   belief systems exhibited both structural _similarities_ and structural _differences_.
//   From a descriptive perspective this finding broadly aligns with previous studies using
//   symmetric belief system networks. From a theory-based modelling perspective, however,
//   the observed differences between the subpopulations may indicate the presence of
//   higher-order interactions between beliefs and attitudes. In @sec:discussion we
//   demonstrated a hypothetical scenario in which such higher-order interactions
//   result in complex intervention dynamics. As such, while these are not presently
//   captured by the KBS model, our findings here suggest that this may be a worthwhile
//   extension.
//
// In spite of relatively smaller sample sizes, our findings suggest that belief systems
// for the conservative and liberal subsets of the dataset may differ in sparsity (the
// proportion of missing edges) and specific belief relations, while also displaying broad
// structural similarities. These similarities suggest, in line with previous studies,
// that while belief systems likely vary between individuals, they also likely
// display common structural features (e.g., based on shared experiences or world-views).
// The observed differences in pairwise relations when stratifying by
// political ideology suggest the presence of higher-order relations between beliefs. This
// is to say that the existence, strength, or direction of a given relation between two
// beliefs may depend on the specific state of a third (in this case, political ideology).
// In @sec:discussion we
//   demonstrated a hypothetical scenario in which such higher-order interactions
//   result in complex intervention dynamics. As such, while these are not presently
//   captured by the KBS model, our findings here suggest that this may be a worthwhile
//   extension.
//
// ]

In spite of relatively smaller sample sizes, our findings suggest that belief systems
for the conservative and liberal subsets of the dataset may differ in sparsity (the
proportion of missing edges) and specific belief relations, while also displaying broad
structural similarities. These similarities suggest, in line with previous studies,
that while belief systems likely vary between individuals, they also likely
display common structural features (e.g., based on shared experiences or world-views).
The observed differences in pairwise relations when stratifying by
political ideology suggest the presence of higher-order relations between beliefs. This
is to say that the existence, strength, or direction of a given relation between two
beliefs may depend on the specific state of a third (in this case, political ideology).
In @sec:discussion we
demonstrated a hypothetical scenario in which such higher-order interactions
result in complex intervention dynamics. As such, while these are not presently
captured by the KBS model, our findings here suggest that this may be a worthwhile
extension.

*Should I mention the dataset validation, etc?*

In addition to the limitations discussed above, the outcomes of this study suggest
several interesting avenues for future work, not limited to: empirically validating
the intervention dynamics predicted by our experiments, using the KBS model to
test hypotheses about the presence and behaviour of asymmetric influences, and
considering more realistic intervention mechanisms (e.g., which do not assume
all beliefs/attitudes are equally easy to intervene on).

*Contribution statement:*
- Theory: model
- Data: validation, reusable pipeline
- Empirical: existence, impacts.







#line(length: 100%)

This study set out to address these theoretical and empirical unknowns, primarily
investigating the prevalence and structure of asymmetric influence
relations among climate change beliefs and attitudes in the US (*RQ1*), and the dynamic
implications of symmetry assumptions for belief-level interventions (*RQ2*).
The second aims of this study were to investigate how intervention effectiveness varies
among individuals with asymmetric belief systems (*RQ3*), and how asymmetric belief
systems may differ structurally between subpopulation with different political
ideologies (*RQ4*).

To address these research questions we first introduced the *Kinetic Belief System*
model (KBS) as an extension on the Causal Attitude Network (CAN) model
@dalegeFormalizedAccountAttitudes2016. KBS differs
from the CAN model in two important respects which make it well-suited to our
investigation. Firstly, it crucially supports both symmetric and asymmetric influence
relations, enabling us to compare these assumptions under a common framework. Secondly,
it defines belief system dynamics as explicitly time-dependent and conditional on
instantaneous beliefs and attitudes. This enables two key aspects of the current study:
(i) the ability to examine, via simulation, the propagation of (inherently
non-equilibrium) intervention effects over time, and (ii) to investigate how intervention
dynamics depend on an individual's initial state.

We then calibrated the KBS model to a two-wave longitudinal dataset comprising beliefs
and attitudes about climate change in the US.

Our findings demonstrate the likely existence of asymmetric influence relations, which
are the exception rather than the norm.

Our findings demonstrated that asymmetric influence between beliefs and attitudes is
likely to exist, but is most likely the exception rather than the norm. Moreover, we
tWe found that asymmetry is likely to exist in

// To do so, we introduce the *Kinetic Belief System* model (KBS) as an extension on the
// Causal Attitude Network (CAN) model @dalegeFormalizedAccountAttitudes2016. KBS differs
// from the CAN model in two important respects.
// Firstly, KBS supports both symmetric and asymmetric influence relations,
// while the CAN model only supports symmetric relations.
// Crucially, this makes it possible for us to compare these assumptions under a common
// framework. Secondly, KBS defines belief system behaviour as explicitly time-dependent,
// and conditional on instantaneous beliefs and attitudes, as opposed to the equilibrium
// dynamics assumption used in the CAN model. This enables two key aspects of the present
// study: (i) the ability to examine, via simulation the propagation of (inherently
// non-equilibrium) intervention effects over time, and (ii) to investigate how intervention
// dynamics depend on an individual's initial state. This contrasts previous simulation
// studies which use the CAN model to examine how interventions affect the _equilibrium
// state_ of a given belief/attitude.






In this study, we set out to
This study set out to explore the presence of asymmetric relations in beliefs and
attitudes relating to climate change in the US (*RQ1*), and their potential consequences
for collective interventions on belief systems (*RQ2*). The secondary aims
of this study were to investigate how intervention effectiveness varies among individuals
in asymmetric belief systems (*RQ3*), and how asymmetric belief systems may differ
structurally between subpopulations with different political ideologies (*RQ4*).
// In this work we address each of these items in turn. After introducing an asymmetric
// belief system model based on the Causal Attitude Network theory
// @dalegeFormalizedAccountAttitudes2016, we investigate the extent to which asymmetric
// relations feature in longitudinal data on climate-related beliefs and attitudes in the
// US (*RQ1*), and their consequences for collective (*RQ2*) and individual (*RQ3*) belief
// system dynamics during interventions. We additionally investigate differences in
// asymmetric belief system structure between subpopulations with different political
// ideologies (*RQ4*).
//*2. Describe the general approach we took (mathematical model based on cognitive dissonance, calibrated to longitudinal survey data on climate change; intervention studies using common random numbers)*
To address these research questions, we first introduced an asymmetric non-equilibrium
model of belief system dynamics based on the Causal Attitude Network theory
@dalegeFormalizedAccountAttitudes2016, which we then calibrated to longitudinal survey
data on climate-related beliefs and attitudes collected in the US between 2020 and 2023.
We assessed the existence of asymmetric
relations and structural differences between ideological belief systems via direct
analysis of the calibrated models, and investigated the consequences of asymmetry for
intervention dynamics by comparing simulated outcomes with those of an analogous
symmetric model using common random numbers.
// We then proceaassessed the existence of asymmetric
// relations as well as structural differences in ideological belief systems via direct
// analysis of the calibrated models. We investigated the implications of asymmetry for
// intervention dynamics

// To address these research questions we introduced a non-equilibrium model of belief
// system dynamics which captures asymmetric influences, based on the Causal Attitude
// Network theory @dalegeFormalizedAccountAttitudes2016, which we then calibrated to
// longitudinal survey data collected in the US between 2020 and 2023.
// We assessed
// the existence of asymmetric relations using model bootstrapping, and investigate
// the consequences for belief system dynamics under intervention via model simulation,
// and comparison to an analogous symmetric model using common random numbers.

//*3. Answer the RQs. At most 3-4 sentences on each.*

Our investigation identified several significant instances of asymmetry in the calibrated
model. In particular, all such cases featured either 'political ideology/alignment' or
'climate-related worry' as the dominant influencing factor. All other (non-null)
relations were found to be inconclusively asymmetric or likely symmetric. This suggests
that (i) asymmetry is likely the exception as opposed to the norm, and (ii) asymmetry
may be more accurately characterised in terms of differences between a given belief's
influence and influentiability, rather than at the level of
individual relations. In the subsequent simulation experiments on collective interventions
we found significant differences in expected outcomes between symmetric and asymmetric
models, particularly when targeting or intervening on the aforementioned attitudes. We
argue that these differences arise primarily due to conflation of influence and
influentiability by the symmetric model, which amounts to model misspecification when
true relations are asymmetric.

Expected intervention effectiveness was found to depend predictably on an individual's
belief system state prior to intervention. Most effective interventions required that
the point-of-intervention and target both be different from their desired
post-intervention states. While this was expected behaviour, we additionally found
that all highly effective interventions required that prior climate-related worry be
low. We attribute this finding to the variable's high levels of both influence and
influentiability, which make it an effective indirect pathway for various interventions
to propagate.
// In addition, we find that low climate-related worry is necessary for all effective
// interventions targeting attitudes toward climate action.

In spite of relatively smaller sample sizes, our findings suggest that belief systems
for the conservative and liberal subsets of the dataset may differ in sparsity (the
proportion of missing edges) and specific belief relations, while also displaying broad
structural similarities. These similarities suggest that while, in line with
the typical assumption, belief systems likely vary between individuals, they also likely
display common structural features (e.g., based on shared experiences or world-views).
On the other hand, the observed differences in pairwise relations when stratifying by
political ideology suggest the presence of higher-order relations between beliefs. This
is to say that the existence, strength, or direction of a given relation between two
beliefs may depend on the specific state of a third (in this case, political ideology).



*4. Particularity of the research (also sometimes called limitations)*


Since the data used for model calibration comprised only two waves, it was not possible
to model individual baseline activations; therefore, the extent to which the observed
asymmetric relations reflect within-person or between-person associations is unknown.

- Within-person and between-person effects
- Individual belief systems
- Modelling social influences, exogenous effects
- Higher-order interactions (as suggested by the ideology experiment). Limits
  representational capacity. We expect that such effects may qualitatively change
  belief (and intervention) dynamics.
-


*5. Contributions to the literature*

- Empirical evidence of asymmetry in belief system interactions
- Simulation-based analysis of the effects of intervening in (symmetric or asymmetric)
  belief systems

*6. Implications for the field*

- Symmetric models as misspecification:
  - Asymmetry characterised at the belief level (mostly influential vs. mostly influenced)
  - Can lead to underestimating 'importance' in symmetric models on most (all?) centrality
    measures.






