#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
#show: show-theorion

#let internal-link(label) = {
  show link: set text(fill: black)
  let arrow = context {
    if query(selector(label).after(selector(here()))).len() == 1 {
      $arrow.r.hook$
    } else {
      $arrow.l.hook$
    }
  }
  link(label, arrow)
}


In this chapter we review the research questions posed back in @sec:introduction
(restated below) in light of the results presented in the previous two chapters, and
discuss their place in the broader context of belief system dynamics. We then
conclude the chapter with a discuss on the limitations
of our findings, and implications for future work on belief system dynamics and
belief-level interventions.

#let show-rq(number, body) = block(above: 2em, below: 2em)[*RQ#number\:* #emph(body)]


#show-rq(1)[
  To what extent are causal relations _symmetric_ or _asymmetric_, in models
  of climate change belief systems inferred from the climate beliefs dataset?
] <discussion-rq1>

On the question of existence, @subsec:asymmetry-results-existence demonstrated
asymmetric relations between several pairs of beliefs and attitudes, while also
finding that asymmetry may  not _always_ be exhibited. Two attitudes---political
ideology/alignment and climate-related #box[concerns---displayed] significant excess
influence over several other beliefs and attitudes.

#let within-person-footnote = footnote[
  Note that this interpretation (in particular, the use of the verb 'constrains') depends
  on the assumption that the calibrated model captures within-person associations. We
  discuss this matter in some depth
  #link(<within-person-discussion>)[later in this chapter].
]

How should we interpret these asymmetric relations? Recall that relations in the
non-equilibrium belief system model reflect temporal influence---how much one belief or
attitude constrains#within-person-footnote the future state of another (@sec:asymmetric-belief-systems). An
asymmetric relation reflects a constraint differential, where one belief or attitude
has greater influence on the other than vice versa. More generally, the asymmetric model
distinguishes between two forces: influence, and influentiability. Influence
(the strength of outbound interactions) determines how the extent to which one belief or
attitude constrains others, while influentiability (the strength of inbound interactions)
determines the extent to which its own behaviour is constrained by others.

Political identity being more influential than influentiable in this context is
consistent with previous studies on its mutual influences
with climate-related beliefs and attitudes in the USA. First, political identity
has been shown to substantially impact both climate-related beliefs
@whitmarshScepticismUncertaintyClimate2011, as well as support for climate policies
@bumannWhatAreDeterminants2021, with individuals tending to support or oppose specific
policies on the basis of partisan identification rather than policy content
@unsworthItsPoliticalHow2014 @vanbovenPsychologicalBarriersBipartisan2018.
<rq1-asymmetry-explanations>

#figure(
  image("../diagrams/politics_example/politics_example.svg", width: 80%),
  placement: none,
  outlined: false,
)

At the same
time, while public beliefs and attitudes toward climate change in the USA have shifted
significantly over the past two decades @marlonChangeUSStatelevel2022
@hamiltonTrackingPublicBeliefs2015, political identity has been shown to be highly
stable over similar timeframes @greenPartisanStabilityTurbulent2024
@brandtBetweenpersonMethodsProvide2022. This suggests that while political identity
contributes meaningfully to climate-related beliefs and attitudes, changes in these
states are less likely to incite changes in political identity.


Climate-related concern exhibits asymmetric influence over beliefs regarding the
anthropogenic nature and current impacts of climate change. Both relationships have
received comparatively less attention in prior research than those of political
attitudes with climate beliefs and attitudes. One possible explanation for
these asymmetric relations is that climate worry and climate beliefs influence
one another through different mechanisms. For instance,
#cite(<meadInformationSeekingGlobal2012>, form: "prose") suggest that climate worry
may promote information-seeking behaviour, leading to changes in climate-related beliefs.


// NOTE:
// How does this relate to findings from other studies? I.e., compare our conclusions
// regarding the influence/influentiabiltiy of these variables:
// - Show that political ideology affects climate beliefs/worry/policy support AND
//   these things have changed in recent years AND political alignment is fairly static AND
//   policy support has changed only in liberal states.
// - Showing that politics is influential
//   - Politics influences climate beliefs: @whitmarshScepticismUncertaintyClimate2011
//   - Politics causes policy support:
//     In combination with climate beliefs @bumannWhatAreDeterminants2021;
//     Drawing attention to ideology changes support @unsworthItsPoliticalHow2014;
//     People choose policy along party lines, irrespective of content @vanbovenPsychologicalBarriersBipartisan2018;
// - Showing that politics is hard to influence
//   - Party identification is quite stable in the short run, but subject to long-term changes @greenPartisanStabilityTurbulent2024
//   - @eganIdentityDependentVariable2020
// - Determinants of climate concern
//   - Politics, in US. Less so elsewhere @lewisCrossnationalVariationDeterminants2019
//   - Contrasting result: extreme weather experience @chenGlobalPublicPerceptions2025
//   - Politics:
//     @palmWhatCausesPeople2017
//     @mccrightIdeologyCapitalismClimate2016
//     @dryzekOxfordHandbookClimate2011
//     @mccrightPoliticizationClimateChange2011
//     @lewisCrossnationalVariationDeterminants2019
//   - Limited longitudinal support for influence of right-wing populism.
// - Effects of climate concern on other climate beliefs, attitudes, attitude on action.
//   - @goldbergIdentifyingMostImportant2021
//   - Influences policy support directly and indirectly @boumanWhenWorryClimate2020
// - Others:
//   - Weather worry, extreme weather worry don't impact climate views much @shaoApprovalPoliticalLeaders2020

// *NOTE:* Doesn't mention #cite(<eganIdentityDependentVariable2020>, form: "prose")

#show-rq(2)[
  How do asymmetric and symmetric beliefs systems differ with regards to
  intervention strategy and effectiveness, in models inferred from the climate
  beliefs dataset?
] <discussion-rq2>

The consequences of asymmetry for belief system dynamics were subsequently reflected in
@subsec:asymmetry-results-impact, where interventions on political ideology/alignment
in the asymmetric model were found to be almost universally more effective than in the
symmetric model. Moreover, for interventions targeting attitudes toward climate action,
political ideology/alignment ranked higher with regards to collective effect in the
asymmetric model than the symmetric model, displacing a mostly-symmetric belief with
similar outbound interactions.
Interestingly, while interventions on climate-related concerns typically
outperformed those on political ideology/alignment in terms of absolute effect of
intervention, the differences between the asymmetric and symmetric models for this
variable were comparatively less pronounced.

For the measurement timescale used in these experiments (approximately 2.5 years),
interventions appeared to act primarily through direct interactions, though smaller
indirect effects were also present. Additional experiments included in
@sec:appendix-extra-results found that longer timeframes led to increased indirect
intervention effects. The presence of indirect effects is broadly expected given the
pre-defined model dynamics; however, the observed magnitudes suggest that while state
changes may propagate beyond direct connections, this process is typically slow. We
return to this point shortly in our discussion of *RQ3*
(#internal-link(<discussion-rq3-indirect-effects>)), which finds that some indirect
propagation may nonetheless be instrumental to achieving effective interventions at
an individual level. <discussion-rq2-indirect-effects>

#let full-model-disclaimer = footnote[
  Note that this point pertains to the model calibrated on the complete climate
  beliefs dataset. This model omits several interactions (due to
  regularisation) which are inconsistently excluded from the bootstrap models used to
  assess the significance of asymmetric relations.
]

This distinction in behaviour between political ideology/alignment and climate-related
concern likely relates to differences in influentiality and influentiability between the
two attitudes. Climate-related concern is more influential than political
ideology/alignment, on account of its increased outbound interactions and interaction
strength. The key difference, however, lies in the attitudes' influentiability; while
climate-related concern has inbound and outbound interactions with all other beliefs and
attitudes, political ideology/alignment has considerably fewer _inbound_ than _outbound_
edges#full-model-disclaimer. That is, several beliefs and attitudes influenced by this
variable have no influence on it themselves. Since the symmetric model
must include or exclude both directional interactions between a pair of
beliefs, cases where the asymmetric model specifies an interaction in only one
direction necessarily lead to differences in model behaviour.
This draws attention to a broader issue regarding relational symmetry assumptions.

One
of the symmetric model's key strengths is its small(er) parameter count. With fewer
degrees of freedom than the asymmetric model, it can achieve more accurate parameter
estimates when calibrated to the same dataset (i.e., smaller confidence intervals in
@fig:calibration-edge-accuracy). However, this comes at the cost of model
misspecification when a subset of the true relations are asymmetric. In the symmetric
model, inferred strengths generally lie between the corresponding directional
interaction strengths in the asymmetric model. For beliefs or attitudes with asymmetric
relations we found that this can result in substantial differences in influentiality
and influentiability between the two models.


#show-rq(3)[
  How do intervention outcome and effectiveness vary between individuals with
  different initial conditions in asymmetric belief systems inferred from the
  climate beliefs dataset?
] <discussion-rq3>

In @sec:heterogeneity-results-intervention-effects we found that
intervention effectiveness depends predictably on individuals' pre-intervention belief
states. Most high-effect interventions targeting attitudes toward climate action
required low initial values for both the point-of-intervention and target.

Surprisingly, pre-intervention climate-related concern was required to be low for _all_
of the personas identified as characteristic of effective interventions, even when this
was neither the point-of-intervention, nor the target.
This finding may be explained by the combination of high influence and
influentiability associated with climate-related concern, thereby making this variable an
effective indirect route for various interventions (not restricted to this particular
target). This stands in contrast with political ideology/alignment, which has similarly
high influence on the target variable, but is harder to influence, as discussed above.
At first glance this finding appears to contradict our earlier discussion on *RQ2*
(#internal-link(<discussion-rq2-indirect-effects>)), which found indirect interventions
to have limited impact on collective effects over short timeframes. However, this rather
reflects the diversity in intervention outcomes across individuals.
<discussion-rq3-indirect-effects>

#let persona-count-footnote = footnote[
  The personas are given by the paths from the root to each leaf; a binary tree with
  depth three has $2^3 = 8$ leaves, and thus eight personas.
]

In general, the identified personas characterise the conditions for effective
interventions accurately. The rare instances where individuals with these traits fell
outside the high-effect region may be attributable to the rough-and-ready use of the
upper quartile to classify high-effect interventions. On the other hand, while the
personas capture _most_ cases where interventions are effective, this varies between
points-of-intervention. This directly reflects the limited representational capacity of
effect characterisation functions based on shallow decision trees; a tree depth of three
permits at most eight personas#persona-count-footnote to describe the full range of
intervention effectiveness, each of which comprises at most three conditions.
<rq3-prespecified-complexity>
// NOTE: Do I need to say anything else here?

The results also highlighted a separate issue with our regression decision tree
approach to characterising intervention effectiveness, namely that the descriptions
may be incomplete when important features are highly correlated. This is a result of
the decision tree optimisation procedure, which selects the 'splits' which best account
for unexplained variance. We saw this reflected in the characterisation of effects for
interventions on beliefs about the existence of climate change. While effective
interventions here generally require that the initial point-of-intervention state be low,
this was omitted due to high correlation between this variable and beliefs regarding the
causes of climate change.
<rq3-highly-correlated-features>

As a final point, the findings from this experiment must be interpreted in the context
of the belief system model calibrated to the complete dataset. Individual differences
in belief systems (as discussed in a moment) are likely to result in heterogeneous
responses to interventions beyond those characterised here. Potentially influential
factors include political identity and social norms. Both vary individually
@laursenWhatDoesIt2022 and socially @laursenWhatDoesIt2022
@brownMeasurementPartisanSorting2021 @websterSocialConsequencesPolitical2022, and both
have been demonstrated as moderating the effects of interventions in the USA targeting
support for climate policy and related attitudes @grometPoliticalIdeologyAffects2013
@unsworthItsPoliticalHow2014 @allcottSocialNormsEnergy2011
@vanvalkengoedSelectEffectiveInterventions2022.

#show-rq(4)[
  How do asymmetric belief systems inferred from the climate beliefs dataset
  vary between conservative and liberal individuals?
] <discussion-rq4>

Finally, @sec:heterogeneity-results-belief-system showed (potentially) substantive
differences between asymmetric belief system models calibrated separately to
conservative and liberal subpopulations; however, given the smaller sample sizes used
to calibrate these models---and consequentially, higher parameter uncertainty---these
results must be interpreted with caution.

When calibrated on the non-bootstrapped data subsets, each model featured high-magnitude
interactions not present in the other, yet while the liberal model was considerably
sparser than the conservative model, most interactions in the former were also present
in the latter. In comparison with the asymmetric model calibrated on the complete
dataset, used in the prior experiments, the ideological models were both sparser, yet
together had high overlap in connectivity with the complete model. We found only one
case of significant asymmetry, which was also present in the model fit to the complete
dataset.

// NOTE: Maybe include
// Three interactions differed significantly between the models, consistent with
// political identity as a moderating factor between climate beliefs and climate worry
// @gregersenPoliticalOrientationModerates2020.

These findings demonstrate both significant differences and similarities between
relational belief system structures, conditional on political ideology, in line with
earlier studies comparing belief systems on partisan identity
@leeClimateChangeBelief2024. The observed differences suggest the presence of
higher-order relationships between beliefs and attitudes, consistent with
the view that belief system relations, themselves, correspond to beliefs or attitudes
(e.g., belief that two states of affairs are related) @fishbein1977belief[p.~219].

Sparse networks imply a restricted set of commonly-observed transitions. This is, to
an extent, expected for the liberal model, which is calibrated using fewer observations
than the conservative model; however, the higher sparsity is also corroborated by
significantly lower edge selection for several interaction in the liberal model across
bootstrap samples. This finding may suggest a greater degree of consistency in the
observed dynamics between individuals who self-identify as liberal.

Previous studies by #cite(<gregersenPoliticalOrientationModerates2020>, form: "prose")
and #cite(<lindComparingAttitudinalStructures2024>, form: "prose") identified
beliefs about the anthropogenic causes of climate change as more strongly associated
with various climate-related beliefs and attitudes for non-right-leaning individuals.
These findings were not replicated in our results; instead we found limited association
(inbound or outbound) with this variable in both models. There are several possible
explanations for this apparently contrary result, including parameter uncertainty in
the present study. Firstly, both studies are based in a European, as opposed to US,
context; #cite(<leeVariationsClimateChange2025>, form: "prose") showed cross-national
differences in climate belief systems including related variables. Second, both measure
association using cross-sectional correlational measures, which may differ considerably
from the time-lagged interaction parameters used in the present study.

== Limitations

#metadata[] <within-person-discussion>
When beliefs and attitudes are fairly stable---as in the climate beliefs
dataset---cross-sectional methods for inferring belief system structure tend to
identify _between_-person associations more so than the _within_-person associations
which are typically desired @brandtBetweenpersonMethodsProvide2022. We partially
mitigate this problem by calibrating to longitudinal data, and using self-interaction
terms to capture persistence in belief/attitude states. However, our model does not
account for belief/attitude stability due to the presence of stable traits
@hamakerCritiqueCrosslaggedPanel2015.

#let identifiability-footnote = footnote[
  For a given individual, each pair of consecutive waves constitutes a single
  observation (given we model conditional transition probability). For a set of
  $N in NN$ beliefs/attitudes the asymmetric model comprises $N^2 + N$ parameters,
  with $M$ additional parameters when modelling individual baselines. Hence for
  $M in NN$ individuals we require at least three observations per-individual
  for the problem to be determined. Note that more waves may be required when
  $N$ is large, such that the number of non-intercept model parameters is larger
  than $M$.
]
#cite(<hamakerCritiqueCrosslaggedPanel2015>, form: "author") suggest modelling
individual random intercepts (in our case, individual baseline activations) which
are fixed across waves and account for some of the effects of stable traits. However,
at least three waves of data are required for the random intercept model to be
identifiable#identifiability-footnote, while the climate beliefs dataset comprises only
two waves.

In unreported experiments we tried a similar approach, modelling baseline activations
as linear functions of demographic factors (e.g., age, education, rural/urban status),
which requires only two waves to be identifiable. While the resulting baseline
activations varied substantially between individuals, indicating that they captured
some differences in stable traits, we found little-to-no impact on either the inferred
interactions or the intervention experiment results. Hence further investigation is
required to determine the extent to which the models calibrated in @sec:calibration
capture within-person associations.

Relatedly, since the climate beliefs dataset comprises only two waves, we cannot
distinguish between belief system dynamics arising due to endogenous factors (the
states of other beliefs and attitudes) and exogenous factors (current events which
affect beliefs and attitudes). We implicitly assume that (i) exogenously-driven
dynamics at an individual level are not substantially correlated between individuals,
and thus not reflected in the model, and (ii) the time between measurements
(approximately six months) is sufficiently short that widespread exogenous factors are
negligible.

The second assumption has questionable validity, since for instance, both
the 2020 US presidential election and January 6 Capitol attack occurred during this
timeframe.
However, we observed highly stable political attitudes over this period, consistent
with prior studies @greenPartisanStabilityTurbulent2024. Given the significance and
considerable media coverage of both events, as well as their highly-political nature,
we would expect political attitudes to be affected more so than climate-related
beliefs/attitudes. The fact that we do not see this reflected may suggest minimal
exogenous impacts, more generally, on the beliefs and attitudes considered in this
study.


Our present focus on endogenous dynamics also does not discount the substantial
role of social interaction in belief and attitude change
@karashialiQualitativeStudyExploring2023 @galesicHumanSocialSensing2021
@degrootReachingConsensus1974a or stability @prenticePluralisticIgnorancePerpetuation1996
@brownMeasurementPartisanSorting2021, including in intervention contexts
@brewerIncreasingVaccinationPutting2017. Rather, this decision reflects the fact that
the dataset used in this study did not include social network information. The matter
of integrating social and cognitive forces in similar belief system models has been
explored in several accounts @rodriguezCollectiveDynamicsBelief2016
@aiyappaEmergenceSimpleComplex2024 @dalegeNetworksBeliefsIntegrative2025, generally
assuming dual objectives of cognitive consistency and social coherence
@festingerCognitiveDissonance1962 @heiderAttitudesCognitiveOrganization1946
@gawronskiCognitiveConsistencyFundamental2012. The Networks of Belief theory, proposed by
#cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose"), builds on the Causal
Attitude Network model which also serves as the foundation for our proposed model. Since
our work is mostly orthogonal to theirs, we anticipate that it would be straightforward
to incorporate such social influences in our model.


// - Previous work integrating cognitive and social forces in belief system models:
//   - Based on the assumption that individuals tend to strive for both cognitive
//     consistency and social coherence in their beliefs and attitudes.
//   - Extending the belief system energy description to include comparison
//     of belief states between individuals (directly encouraging social coherence)
//     @rodriguezCollectiveDynamicsBelief2016
//   - Communicating specific beliefs between individuals @aiyappaEmergenceSimpleComplex2024
//   - Indirect inluences via second-order beliefs about the states of others
//     beliefs/attitudes.
//   - Former two studies assume a Social Knowledge Structure model, while latter builds
//     on the CAN model, so is directly applicable to our approach.

We now discuss three representational limitations of the model used in the present study,
pertaining to (i) the use of pairwise relations, (ii) representation of belief and
attitude states as Ising model spins, $s in {-1, +1}$, as opposed to binary variables,
#box[$s in {0,1}$], and (iii) the non-dependence of interacton effect magnitude on belief states.

Consider the following (hypothetical) motivating example. Suppose that parents'
attitudes toward childhood vaccination typically depend, in a simplistic way, on
their perceived relative risk of a vaccine, and the disease it protects against.
Positive attitudes prevail when the disease is considered more risky or dangerous
than the vaccine. Values around family wellbeing conceivably influence the relationship
between perceived risk and vaccine attitudes, serving to amplify the existing effect.

#h(0.5em)
#figure(
  image("../diagrams/vaccination_example/vaccination_example_nocircles.svg", width: 70%),
  placement: none,
  outlined: false,
)
#h(0.5em)

Suppose that in an attempt to promote increased childhood vaccination rates, we
undertake a media campaign appealing to family wellbeing values. The expected outcome
is evident: attitudes improve for individuals who are relatively more concerned about
the disease; for other individuals the opposite effect ensues.

This relational structure can be seen as a triplet-interaction extension to the belief
system model used in the present study. In a belief system model with triplet
interactions, the _effective_ influence relations between pairs of beliefs or attitudes
can vary in accordance with the specific belief state.
Findings from #cite(<brewerIncreasingVaccinationPutting2017>, form: "prose") suggest
that such interventions, which selectively leverage or amplify existing beliefs and
attitudes may be more effective than interventions which attempt to change
belief/attitude states. However, such relational structures cannot be captured in the
pairwise model adopted here.

#block(breakable: false)[
  Next, we consider the implications of our decision to model belief and attitude states
  as spins, with values $s in {-1, +1}$. Consider the following belief:

  #align(center)[
    #block[_Believes that climate change is happening._]
  ]
]

Which comprises both an epistemic position (_Believes that_) and a state-of-affairs
(_climate change is happening_). Negating each of these components yields two
reasonable choices for the 'opposite' state:

#align(center)[
  #block[_*Does not* believe that climate change is happening._]
]


#align(center)[
  #block[_Believes that climate change is *not* happening._]
]

As a consequence of our decision to model belief and attitude states as spins, we are
assuming that beliefs and attitudes always emit influence on associated variables,
regardless of their state. However, it is not clear that this assumption is always
reasonable, in particular for beliefs where the opposite state is a negation of the
epistemic position (the first example), or in the case of neutral or ambiguous
states @vandermaasStatisticalPhysicsPsychological2026.

// The climate attitudes survey, used in the present study, asks individuals whether or
// not they think that climate change is happening, with response options: _Yes_, _No_, and
// _Don't know_. While the first two options constitute affirmation and negation of the
// state-of-affairs, the third negates the epistemic position. We treat
// this option as a 'middle' state which is assigned to $-1$ or $+1$
// with equal probability during simulation. As argued in
// #cite(<vandermaasStatisticalPhysicsPsychological2026>, form: "prose"), however, the
// situation for neutral, uncertain, or ambiguous states in psychological networks is
// nuanced, and often such states are more reasonably interpretable as having no influence
// on the rest of the network.

Finally, while the present model assumes that interaction effects in asymmetric belief
systems are independent of the 'influencing' variable's state, we argue that there is
reason to think that this may not always be true. Consider two variables:

- *Happening:* The belief that climate change is happening, and

- *Action:* General attitude toward climate action.

An individual who _does not_ believe in climate change logically should not support
climate action. In the asymmetric belief system model, this corresponds to a large
positive interaction, such that *Action* aligns with *Happening*. However, individuals
who _do_ believe in climate change may nonetheless oppose climate action for other
reasons (e.g., cost or prioritisation), suggesting that *Action* may be less
constrained when *Happening* is high than when it is low.

*I have other limitations to discuss, but judged these as the most critical*
// // NOTE:
// - _How we think about interventions:_
//   - *A:* We have assumed that interventions can act directly, and with equal effect on
//     different beliefs and attitudes. This is to say, we are not concerned here with the
//     nature of an intervention itself (the interface between the intervention and the
//     belief system). Rather, we operate under the assumption that we _can_ intervene,
//     and study the resulting endogenous dynamics.
//   - *B:* In reality, some beliefs or attitudes may be easier or harder to intervene on
//     than others.
//   - *T:* Taking the intervention process into account may result in different expected
//     effects of intervention. For instance, we found that political ideology is often
//     influential, but is difficult to influence, due to a scarcity of incoming
//     interactions. Supposing, then, that we can only intervene indirectly on politics,
//     the expected intervention outcomes may change.
// - _Synchronous updates:_
//   - *A:* We use synchronous updates to simulate model dynamics.
//   - *A:* This is due to both the nature of the dataset (long intervals between
//     measurements, such that multiple beliefs can change state) and computational reasons
//     (synchronous updates simplify the sampling process
//     @nguyenInverseStatisticalProblems2017)
//   - *B:* If beliefs update asynchronously (one at a time), this could affect the model
//     dynamics
//
//
// - _Transferring natural endogenous dynamics to intervention:_
//   - Related to confounding factors, we (assume that we) calibrate the models to data
//     which is taken from a 'normal' environment.
//   - Possible that dynamics are different when we intervene. Raises 'temperature'.
//     Causes to think about beliefs/attitudes that would otherwise remain
//     dormant---conflicting but unnoticed.
//
// - _Data variables:_
//   - We use what is available, rather than what is ideal
//
// - _Confounding factors:_
//   - Model calibrated to only two waves. Cannot separate endogenous from exogenous
//     factors. Individual-level exogenous factors likely to be 'washed out'. Shared
//     factors (e.g. election, weather events) could cause correlated changes between
//     individuals.
//
// - _Sensitivity to unmeasured factors or incorrect structure:_
//   - What happens when we cannot include (because we don't measure) an influential belief,
//     i.e., a fork
//   - What about colliders, or paths?
//   - What happens when we falsely assume that there is/isn't a connection between two
//     beliefs?

== Implications for future work

// NOTE:
// Practical takeaways:
// + Model choice:
//   - Symmetry assumption may often be valid
//   - But risks misspecification
// + Distinction between influence and influentiability:
//   - Compare with other measures of centrality/influence
//   - Influence is often important for interventions, but influentiability is also
//     important for indirect propagation.

// - May be different for symmetric and asymmetric networks
// - Influence and influentiability are both important
// - While high values may indicate both high in asymmetric, low values don't necessarily
//   mean that both are low (e.g., in-degree vs out-degree for `Politics`).

// Measures of influence:
// - Centrality:
//   - Degree: Number of incident connections
//   - Strength: Strength of association with other nodes.
//   - Betweenness: Number of shortest paths a node occurs on
//   - Closeness: Average shortest path to each other node
// - Hierarchy (in DAG model)
// - Expected influence @robinaughIdentifyingHighlyInfluential2016

Our findings suggest that while the symmetric assumption may often be valid, or at
least a reasonable approximation, asymmetric relations between beliefs and attitudes
are nonetheless possible. When true relations are asymmetric, not accounting for this
when modelling belief interactions is a case of model misspecification, and can lead to
incorrect inferences regarding the relative influence of different beliefs.
The primary issue here is that symmetric models do not account for differences between
a belief's influence (how much it affects the states of other beliefs) and
influentiability (how much its own state is affected by other beliefs).

// Future work, building directly on our results:
// + Reducing sampling error/parameter uncertainty, to gauge extent of asymmetry,
//   better distinguish between symmetric and 'minimally asymmetric' cases.
// + Determine extent to which inferred models reflect within-person associations
//   or between-person associations.
// + Improve effect characterisation function approach:
//   - Handling of highly correlated features robustly
//   - Current approach constrains rule complexity by prespecifying decision tree depth.
//     This is somewhat arbitrary. Limits the number of rules (when more rules may be
//     required for a full characterisation) and implies a fixed rule length equal to the
//     depth. Also assumes a hierarchical structure to the rules (i.e., all rules include
//     the root feature). We could instead identify rules more flexibly and penalise the
//     characterisation complexity directly, e.g., using MDL.
// + Experimental extensions:
//   - Investigating transferability of models inferred from 'natural' dynamics (i.e.,
//     minimal exogenous influence, as assumed in the present study) to situations with
//     exogenous influences. Interventions fall under the latter category. Prior research
//     suggests dynamics may be different, for instance due to increased salience of
//     certain attitudes/beliefs @unsworthItsPoliticalHow2014.
//   - Experimental validation using intervention studies.

// Empirical
// studies on belief systems often use network centrality measures (e.g., degree, strength,
// betweenness, closeness) to assess nodes' relative 'importance' or 'influence', in lieu
// of measures derived from model dynamics. While most of these measures have directed
// network analogues---for instance, degree becomes in-degree and out-degree, closeness
// becomes average shortest path length to, and from a node---it is well-known that the
// directed-network values can differ significantly both from one another and from the
// undirected-network measurements. Our findings reinforce this point, also demonstrating
// that it holds for simulation-based measures of influence.

// While we have identified cases of apparent asymmetry, further work is required to
// understand both the extent to which asymmetry is the exception as opposed to the norm
// (requiring more observations to reduce sampling error), and the extent to which the
// inferred asymmetry reflects within-person associations (requiring at least three waves).
// The models used for the experiments detailed in the previous chapters were limited to
// two waves of the climate attitudes survey in order to assess a reasonable number of
// parameters, and certain variables of interest (see @subsec:dataset-dataset-construction).
// If we drop these requirements, however, then additional waves and observations become
// available, and both questions are somewhat approachable.
//
// For instance, if we use
// variables from Waves 2-5 of the climate attitudes survey, the total number of repeat
// participants is 1067. Since we expect the parameter error to go to zero like
// $1/sqrt(M(T-1))$, where $M$ is the number of participants and $T$ is the number of
// observations, ... *Actually, the number I see in the figure is before removing problem
// participants*

// - We could only use two waves because we wanted to have a sufficient number of
//   variables.
// - With a smaller set of variables, we could potentially use more waves (e.g., 3,4,5
//   gives 1258 participants; 2,3,4,5 gives 1067), and be able to obtain lower sampling
//   error, as well as investigate the extent to which the models capture within-person
//   interactions.


Despite the promising results of this study, several questions remain. The limited
number of waves in the climate beliefs dataset prohibits us from confidently
distinguishing between within-person and between-person effects, which is required
to make strong claims regarding causal influences. We note that the broader
climate attitudes survey does contain several additional waves, which are usable if we
drop our requirements regarding the number of variables and inclusion of specific
beliefs/attitudes. However, this raises a separate issue regarding the intervals between
measurements, as inter-response times between different pairs of waves can differ
significantly, violating the model requirements. Further consideration is required to
determine whether, for instance, the additional waves can be used _only_ to estimate
individual baselines, while evenly-spaced observations are used to estimate interaction
effects.

As discussed above, the regression decision tree approach to modelling the effect
characterisation function can produce incomplete descriptions when important
features are highly correlated (#internal-link(<rq3-highly-correlated-features>)), and
may not identify all effective-intervention conditions due to the somewhat arbitrary
nature of tree depth to limit complexity (#internal-link(<rq3-prespecified-complexity>)).
The first issue can be resolved post-hoc (by assessing correlations with identified
variables). One promising direction for the second is to identify more flexible
rulesets, allowing arbitrary quantity and size, while penalising characterisation
complexity directly, e.g., using description length @aogaFindingProbabilisticRule2018
@proencaInterpretableMulticlassClassification2020.

The models calibrated in @sec:calibration are assumed to reflect 'natural' belief system
dynamics (i.e., minimal exogenous influence). By simulating interventions on these
models, we are therefore assuming transferrability to situations _with_ exogenous
influences in the form of interventions. However, prior studies have demonstrated that
belief system dynamics may differ in such situations, for instance due to increased
salience of certain attitudes or beliefs @unsworthItsPoliticalHow2014. As such,
experimental validation---and ideally, calibration to data collected under controlled
intervention scenarios---is a natural continuation to the present study.

Our findings also suggest and support several broader directions for future research.
Firstly, we posited two explanations for the asymmetric relations observed with
regards to political attitudes and climate-related worry
(#internal-link(<rq1-asymmetry-explanations>)). These are retrospectively
applied to the findings, so arguably have minimal evidential weight @popper1963science.
However, they demonstrate how the asymmetric non-equilibrium belief system model may be
used to test (as opposed to generate) hypotheses about the general mechanisms by which
asymmetric belief/attitude relations may occur.







Future directions suggested by our findings:
// + How asymmetry arises:
//   - We have posited two explanations for the asymmetric relations observed in political
//     attitudes and climate-related worry. However, these are retrospectively applied to
//     the findings, so arguably have minimal evidential weight @popper1963science.
//   - Our model provides a method by which hypotheses about the general mechanisms by which
//     asymmetric belief and attitude relations occur can be tested.
+ Modelling individual belief systems:
  - Baselines _and_ structure. Separate questions.
  - Differences, but also similarities, between belief systems, implied by ideological
    belief system experiment.
  - Measuring or approximating individual baseline activations. Unreported experiments
    show these can be somewhat approximated using demographic factors.
  - Suggests a middle-ground between calibrating individual models and assuming a single
    shared model. Akin to partial pooling, compared with no pooling or total pooling in
    Bayesian statistics.
  - Must consider how both baseline activations and belief system structure vary between
    people.
+ The 'world-belief interface':
  - We adopt a simplistic view of interventions, which assumes we can intervene directly
    and equivalently on individual beliefs/attitudes. In reality some beliefs/attitudes
    may be easier or more difficult to intervene on, and the communication of
    interventions may be 'noisy' (e.g., subject to interpretation), potentially
    impacting the magnitude, direction, and set of beliefs/attitudes affected. Each of
    these has conceivable implications for intervention dynamics and effects.
    Understanding how interventions cross this interface is therefore important.
  - Exogenous factors (e.g., the 2020 presidential election) can, in theory, be treated
    using the intervention framework applied in this study. These are simply
    interventions which we don't control. From this perspective we can consider modelling
    these directly to study their impacts. If we expect such factors to meaningfully
    affect belief system dynamics, modelling exogenous factors is perhaps more sensible
    than attempting to control for them.
  - #cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose") consider a related
    problem, namely the interface between different individuals' belief systems.
    Individual beliefs are affected by (and affect) others' belief systems indirectly
    via social beliefs---beliefs about the state of others' belief systems.
    - This actually supports our method for modelling interventions. i.e., in the NB
      model exogenous changes (other peoples' beliefs) affect your belief system via
      an interaction term to the belief about that state. Our approach is analogous.
      The exogenous change affects our belief (say, about the state of climate change)
      via an interaction term.


// *Todos:*
// - Comparison with other measures of influence, e.g., centrality in PRCNs @brandtWhatCentralPolitical2019, hierarchy in Bayesian networks @powellModelingLeveragingIntuitive2023
// - Comparison of model with other kinds:
//   - Partial correlation networks
//   - Bayesian networks
//   - Symmetric (cross-sectional) Ising model
//
// Format:
// - Key result:
//   - Direct implications
//   - Specific areas for future work
// - Broader takeaways
// - Broader areas for future work
//
// - Evidence of asymmetry, especially for political attitudes and climate-related concerns:
//   - Affects how we should think about influence or centrality. A belief may be central
//     and influential, but hard to influence. Alternatively may be easy to influence but
//     not very influential.
//   - Extent to which this exists is unclear. Sampling error
//     results in confidence intervals with average width $approx 0.1$, preventing us
//     from distinguishing minor asymmetry from symmetry. Sampling error is expected
//     to reduce as $sqrt(M(T-1))$, where $M$ is the number of participants and $T$
//     timesteps. @hertzIsingModelsInferring2011
//
// - Broader takeaways
//
// - Broader areas for future work:
//   - Individual belief systems, understanding the within-person components
//     - While #cite(<hamakerCritiqueCrosslaggedPanel2015>, form: "prose") suggests
//       modelling individual intercepts (baseline activations) to absorb between-person
//       effects, accounting for the presence of stable traits, this is akin to 'using
//       a hammer to kill a fly'. Ideally, we would measure the culprit traits directly
//       (or proxies thereof). In unreported experiments, we found that a small
//       number of demographic factors were sufficient to describe noticeable differences
//       in baseline activations.
//     - This also doesn't capture _individual_ belief systems. We saw evidence of these
//       in the ideology experiment. Even if we capture within-person associations, if
//       we do not model structural differences between individuals, the resulting model
//       at best captures a murky approximation to the 'average' individual.
//   - Experimental validation, and calibration based on experimental data with
//     interventions. Since natural dynamics are slow, but we anticipate
//     interventions may be quicker (we observe sudden changes in several beliefs;
//     if states changed independently and slowly for all people, we wouldn't see this).
//
// - RQ1:
//   - Evidence of asymmetry. Extent to which this exists is unclear. Sampling error
//     results in confidence intervals with average width $approx 0.1$, preventing us
//     from distinguishing minor asymmetry from symmetry. Sampling error is expected
//     to reduce as $sqrt(M(T-1))$, where $M$ is the number of participants and $T$
//     timesteps.
//   - Furthermore, additional investigation is required to determine the extent to
//     which the inferred interactions, and hence asymmetry, reflect within-person
//     associations.
//   - Practically, our findings suggest the symmetric assumption may often be valid, or
//     at least a reasonable
//     approximation, yet asymmetric relations are likely to exist, and will not be captured
//     by such an approach.
//   - Robustness to external events.
//   - Simplistic intervention assumptions (only affect one spin, )
// - RQ2:
//
//
// + *T:* Open questions and future work
//   - Individual belief systems
//   - Representational capacity
//   - Purposeful intervention study
//   - Index variables could be derived intentionally, i.e., theoretically-motivated.
//
// _Implications of findings. How can the results be applied practically? What
// questions/directions do the findings suggest?_
// - *T:* The symmetric assumption may often be valid, or at least a reasonable
//   approximation (e.g., when asymmetry exists, but the difference in effects is
//   small), yet asymmetric relations are likely to exist, and will not be captured
//   by such an approach.


// NOTE: Re-statement of results
// On the question of existence, @subsec:asymmetry-results-existence presented evidence of
// asymmetric directional relations between several pairs of beliefs or attitudes, while
// also finding that not _all_ pairs necessarily exhibit this asymmetry. Two attitudes in
// particular---political ideology/alignment and climate-related concerns---displayed
// significant preponderance of influence over several other beliefs and attitudes.
//
// Following this, @subsec:asymmetry-results-impact demonstrated that relational symmetry
// assumptions meaningfully impact intervention dynamics and outcomes. Interventions on
// political ideology/alignment in the asymmetric model were found to be almost universally
// more effective than those in the corresponding symmetric model. For inbound
// interventions targeting attitudes toward climate action, the results showed differences
// in relative effectiveness for different points-of-intervention between the two models.
// In one case, the differences were sufficiently large to change intervention
// effectiveness rankings, impacting intervention strategy.
//
// We then changed tack to investigate heterogeneity in intervention effects and belief
// systems. @sec:heterogeneity-results-intervention-effects found that
// intervention effectiveness varies predictably with respect to individuals'
// pre-intervention belief states. Most high-effect interventions targeting attitudes
// toward climate action required low initial values for both the point-of-intervention and
// target. Surprisingly, pre-intervention climate-related concern was required to be low
// for _all_ of the personas identified as characteristic of effective interventions, even
// when this was neither the point-of-intervention, nor the target.
//
// Finally, @sec:heterogeneity-results-belief-system showed substantive differences
// between asymmetric belief system models calibrated separately to conservative and
// liberal subpopulations. Each model featured high-magnitude interactions not present
// in the other, yet while the liberal model was considerably sparser than the conservative
// model, most interactions in the former were also present in the latter. In comparison
// with the asymmetric model calibrated on the complete dataset, used in the prior
// experiments, the ideological models were both sparser, yet together had high overlap
// in connectivity with the complete model.



// == RQ1: Asymmetric influence of political ideology & climate concern
//
// Our findings in @subsec:asymmetry-results-existence demonstrate, by example, a positive
// response to the question of asymmetric relation existence. Two variables in
// particular---political ideology and climate-related concerns---exhibited significant
// asymmetric influence over the behaviour of several other variables. Additionally,
// we observed two forms of asymmetry: where two beliefs or attitudes reinforce one another
// with different strengths, and where one belief or attitude influences another with no
// apparent direct reinforcing feedback.
//
// However, not all pairs of beliefs or attitudes display asymmetry. Aside from
// interactions with these two variables, we found that most interactions were either
// symmetric or near-symmetric, or otherwise have inconclusive support for asymmetry due
// to sampling error. Moreover, the presence or absence of asymmetry for different
// variables was not cleanly explained in terms of differences in average influence
// (interaction strength) or sampling error.
//
// Hence while asymmetric relations between beliefs and attitudes appear to be less
// prevalent than symmetric ones (at least in this context), they exist nonetheless.
//
// As per the underlying mathematical model defined in @sec:asymmetric-belief-systems,
// we interpret belief relations temporally, as the influence of one belief or attitude
// on the future state of another. An asymmetric relation is one in which one belief or
// attitude influences (i.e., constrains) the other more than in the opposite direction.
// Our findings therefore suggest that in several cases political ideology/alignment and
// climate-related concerns drive the behaviour of other beliefs and attitudes, while being
// relatively insensitive, themselves, to the states of those beliefs and attitudes.
//
// For instance, political ideology and/or alignment exerts asymmetric influence
// on general attitudes toward action on climate change. This is to say that a conservative
// and/or Republican-aligned individual is more likely to display lower _future_ support
// for climate action than a liberal and/or Democrat-aligned individual. Yet conversely,
// if an individual's support for climate action changes, this asymmetry implies a smaller
// corresponding shift in their political views.
//
// *TODO:*
// - Comparison with other work:
//   - Politics driving support for climate action, belief in CC, concerns about CC,
//     while not being substantially influenced by these
//   - Climate concern driving beliefs about climate impacts and causes, while not
//     being influenced so much by them (e.g., psychological distance)
//   - Other discussions on variables with varying 'influence', e.g., centrality.

// == RQ2: ...
//
//
// While we have demonstrated the existence of asymmetic relations between beliefs and
// attitudes, existence does not, on its own, imply that the observed asymmetric relations
// are impactful on endogenous dynamics. Our findings in @subsec:asymmetry-results-impact,
// however, show that assumptions regarding asymmetry _are_ consequential when reasoning
// about interventions.
//
// We showed, by way of simulation, that asymmetric models calibrated to the climate beliefs
// dataset exhibit post-intervention behaviour which differs from the corresponding
// symmetric model. Interventions on political views in the asymmetric model outperformed
// those in the symmetric model almost universally across target beliefs and attitudes. This
// was further reflected in our experiments on inbound interventions targeting attitudes
// toward climate action. Under the symmetric model assumption, intervening on beliefs
// regarding the impacts of climate change is expected to be more effective than intervening
// on political views, while under the _asymmetric_ model asummption the situation is
// reversed.
//
// One of the symmetric model's key strengths is its small(er) parameter count. With fewer
// degrees of freedom than the asymmetric model, it can achieve more accurate parameter
// estimates when calibrated to the same dataset (i.e., smaller
// confidence intervals in @fig:calibration-edge-accuracy). However, this comes at the cost
// of model misspecification when a subset of the true relations are asymmetric. In the
// symmetric model, bidirectional interaction strengths are generally inferred as being
// between the corresponding directional interaction strengths in the asymmetric model.
//
// This has little impact on beliefs and attitudes with largely symmetric relations, but
// can dramatically affect the level of influence for those with asymmetric relations, and
// hence affect intervention dynamics considerably. For instance, consider again the
// attitude associated with political ideology/alignment. In the asymmetric model this
// displays similar outbound interactions as the (largely symmetrically-interacting)
// belief regarding the impacts of climate change. On the other hand, in the symmetric
// model most interactions with political ideology/align are roughly half the magnitude
// of those for the latter belief. The result is a diminishing of the influence of this
// attitude, due to model misspecification, causing the latter belief to appear more
// influential, when, in-fact, it is almost identical.
// Regularisation can exacerbate this issue. In the asymmetric model, political
// ideology/alignment has outbound interactions with all (seven) other beliefs and
// attitudes. In the symmetric model, only four remain.
//
// For the measurement timescale used in the experiments (roughly 2.5 years) we found
// that interventions act mostly through direct relations, as evidenced by rough
// correspondence between intervention effects and direct interaction strength. While
// some indirect influence was observed (e.g., for intervention targets with no direct
// connections to the point-of-intervention) this was small compared to direct effects,
// though increases for longer measurement timescales. This finding is potentially
// impactful for the difference between symmetric and asymmetic intervention dynamics.
// If two beliefs or attitudes are related asymmetrically such that only one directional
// interaction is nonzero, then a symmetric model is likely to both _overestimate_ the
// effect of an intervention on the more influential variable, and _underestimate_ the
// time until the effect is realised.
//
// In summary, and responding to *RQ2*, we find that assumptions regarding the symmetry or
// asymmetry of relations between beliefs and attitudes can impact expectations regarding
// both the absolute and relative effect of intervention, as well as the time taken for
// the effects of an intervention to be realised. Differences between the models'
// dynamics arise both as a direct result of asymmetric relations existing (e.g., as in
// the example from the previous paragraph), and due to differences in influence
// (outbound interactions) and influen#emph[tiability] (inbound interactions) which are
// characteristic of beliefs and attitudes in asymmetric relations. The latter can, from
// the other side, be considered a difference resulting from model misspecification ---
// assuming that a belief system comprises only symmetric relations, when asymmetric
// relations are present.
//


// == RQ3: ...
//
//
// In @sec:introduction we hypothesised that in order for interventions to be effective,
// it is necessary for the initial states of both the point-of-intervention and target
// beliefs or attitudes to be different from the desired post-intervention states.
//
// The results in @sec:heterogeneity-results-intervention-effects broadly support this
// hypothesis for interventions targeting attitudes toward climate action, showing that
// the most effective interventions are observed in cases where the point-of-intervention
// is initially 'low', and initial attitudes toward climate action are negative.
// We found no requirement that the initial attitudes be close to the low extreme. This
// is consistent with our earlier discussion in
// @subsec:asymmetric-belief-system-modelling-interventions, in which we illustrated how
// the impact of an intervention on the _point-of-intervention_ behaviour diminishes as
// the magnitude of the initial influence on that belief or attitude grows (i.e., for strong
// opposition or support).
//
// Unexpectedly, for all points-of-intervention, the majority of individuals for whom
// we estimate a high intervention effectiveness also had low pre-existing concerns about
// climate change. This was true even when climate-related concern was neither the
// point-of-intervention nor the target. This result is likely related to the variable's
// high degree of influence in the asymmetric model, in combination with a high potential
// to _be influenced_, compared with other variables.
//
// Overall, we find that intervention effectiveness does vary in predictable ways with
// respect to individuals' pre-intervention belief system state. Effectiveness depends
// not only on the initial states of the target of point-of-intervention, but also on
// other auxiliary beliefs and attitudes through which interventions can propagate
// indirectly.
//
// == RQ4: ...
//



// In line with our hypothesis, for interventions (targeting attitudes toward climate
// action) to be highly effective at shifting the target attitude toward the desired state,
// in comparison with a no-intervention scenario, it is generally necessary that both the
// target and point-of-interventions

// + *A:* What have we learned?

// Remind reader of research questions:
// - *A:* Numerous recent studies on belief systems/models acknowledge(?) the likelihood
//   of directed causal relations between beliefs and attitudes, possibly arising from
//   various mechanisms (logical, influence, ...)
// - *A:* Whether we should consider relations as directed or undirected/bi-directional
//   has implications for the expected dynamics of beliefs and attitudes. This
//   affects both natural, endogenous dynamics, as well as how changes in a belief
//   system propagate during interventions.
// - *B:* Based on reckons and theoretical reasoning. Limited empirical evidence on the
//   existence of such directed relationships and their impact on belief and attitude
//   dynamics.
// - *T:* We address these topics in the present thesis, through our first two research
//   questions (state them)
// - *A:* These research questions are primarily concerned with population-level
//   intervention effects on belief systems assumed to be shared between individuals.
// - *B:* While individuals likely share some aspects of belief system structure (due
//   to shared social contexts, experiences), belief systems are inherently individual.
// - *B:* We also do not expect all individuals to respond the same way to
//   interventions. (give example)
// - *T:* Our remaining research questions investigate individual heterogeneity in
//   both intervention effects and belief systems (state them)
// - We now interpret the results presented in the previous two chapters with respect to
//   each research question, and in the broader context of belief system dynamics.
//   - Limitations
//   - Implications of findings, how they should inform future work. Questions that
//     are invited by the findings.
// Findings, per-research-question:#linebreak()
// *RQ1.* _Existence_
// - Positive result:
//   - *A:* Positive result, in that we observe significant asymmetric relations,
//     with two variables---political ideology and climate-related concerns---exhibiting
//     asymmetric influence over the behaviour of several other variables.
//   - *A:* In addition, we observe one asymmetric relation in which only one of the
//     directed interaction effects is nonzero, such that there is a positive influence
//     in one direction, with no feedback in the other.
//   - *B:* However, not all pairs display this asymmetry. We find that most other pairs
//     are either symmetric or near-symmetric, or have inconclusive support for asymmetry
//     due to sampling error.
//   - *T:* The symmetric assumption may often be valid, or at least a reasonable
//     approximation (e.g., when asymmetry exists, but the difference in effects is
//     small), yet asymmetric relations are likely to exist, and will not be captured
//     by such an approach.
//   - *T:* Furthermore, we find that asymmetry is not simply explained in terms of
//     high average influence (many strong outbound interaction effects), as we observe
//     such cases with no clear asymmetric relations.
// - Interpretation:
//   - We interpret relations temporally, as one variable's influence
//     on the future state of another (@sec:asymmetric-belief-systems). In an asymmetric
//     relation, one variable has greater influence over the other's future
//     state. Our findings suggest that in several instances political ideology and
//     climate-related concerns drive the behaviour of other beliefs and attitudes,
//     while being relatively insensitive, themselves, to the states of those beliefs
//     and attitudes.
// - Comparison with other work:
//   - Politics driving support for climate action, belief in CC, concerns about CC,
//     while not being substantially influenced by these
//   - Climate concern driving beliefs about climate impacts and causes, while not
//     being influenced so much by them (e.g., psychological distance)
//   - Other discussions on variables with varying 'influence', e.g., centrality.
// *RQ2:* _Impact_
// - Quickly summarise results:
//   - *A:* We have demonstrated the existence of asymmetric relations.
//   - *B:* Existence does not, on it's own, imply that the observed asymmetric relations
//     are impactful.
//   - *T:* In response to the second research question, we show that an asymmetric model
//     calibrated to the climate beliefs dataset exhibits intervention behaviour which
//     is different to the symmetric model, and that this can affect decisions regarding
//     where to intervene.
//
//   - *A:* Interventions on politics in the asymmetric model outperformed those in the
//     symmetric model almost universally.
//   - *A:* This was also reflected in the inbound experiments for interventions targeting
//     attitudes toward climate action. In the asymmetric model, interventions on politics
//     were found to be relatively more effective than those on beliefs about the impacts
//     of climate change, where the opposite is true in the symmetric model.
//
// - Impact of timescale:
//   - *A:* For the measurement timescale used in the experiments we found
//     that interventions propagated mostly through direct relations.
//   - *B:* At longer timescales indirect paths also contribute.
//   - *T:* If the true relation is asymmetric, we may still
//     see intervention effects propagate significantly to a given target given sufficient
//     time. If the symmetric model ascribes a bidirectional edge (as we see typically in
//     @sec:calibration) then it will underestimate the time taken to spread, and potentially
//     overestimate the overall effect (since the relation is direct).
//
// - Impact of structural differences:
//   - *A:* Politics was considerably more influential than influentiable in the
//     asymmetric model.
//   - *B:* Whereas in the symmetric model the observed interaction effects
//     were typically smaller, in order to capture both the large outbound and small
//     inbound effects (comparison of `Politics` and `CC Impact`---relations in politics
//     are roughly half the size of the corresponding relations for CC Impact).
//   - *T:* Variables which are influential in the asymmetric model may be considered
//     non-influential in the symmetric model. This can lead to biased expectations
//     regarding intervention effects.
// - Conclusions:
//   - *T:* Assumptions regarding the symmetry or asymmetry of belief relations can change
//     conclusions drawn regarding (absolute and relative) intervention effectiveness.
//   - *T:* Dangers of model misspecification.

// *RQ3:* _Individual impacts_
// - *A:* In line with our hypothesis, for interventions (targeting `CC Action`) to be
//   highly effective, it is generally necessary that both the target and
//   point-of-intervention states be low (such that the intervention changes the
//   point-of-intervention, and there is space for the target to shift)
// - *B:* Unexpectedly, almost all highly effective interventions were also predicated
//   on a low initial level of climate-related concern.
// - *T:* We attribute this to climate-related concern's high degree of influence in the
//   model, in combination with a high potential to _be influenced_, compared with other
//   variables.
// - *T:* Intervention effectiveness is not only dependent on the initial states of the
//   target and point-of-intervention, but also by other auxiliary beliefs and attitudes
//   through which interventions can propagate indirectly.
// - _Comparison with other work:_ Perhaps we have sources discussing the impact of
//   climate concerns on policy specifically; ideally can find sources talking about
//   interventions.
//
// *RQ4:* _Individual belief systems_
// - *A:* Conservative and liberal belief system models differ in sparsity (edge
//   existence) and strength of specific interactions.
// - *A:* The liberal model is considerably sparser than either the conservative
//   model or the model calibrated on the complete dataset.
// - *A:* In several cases, high-effect interactions are present in only one of the
//   two models.
// - *B:* The ideological models do, however, still display substantial overlap in
//   the inferred edges.
// - *T:* Belief systems may differ significantly between individuals or subpopulations
//   at the level of individual relations, but nonetheless appear to exhibit some shared
//   structures.
// - _Can we find evidence, explanations for some of the big differences between the
//   models?_
// - _Compare to other research_



// _Representational limitations:_
// - Polar vs. binary states:
//   - We use polar ${-1, +1}$ states. This means that whatever the state of a spin, it
//     exerts nonzero influence on spins it relates to. This makes more sense for some
//     variables than others. For instance, political alignment and measures of policy
//     support have clear positive and negative states (up to re-labelling). Beliefs such
//     as 'Climate change is real' are murky, and whether they fit this assumption
//     depends on how the survey questions are framed. In particular, we should distinguish
//     between holding the opposite belief, and holding _no belief_. In the latter case
//     (e.g., in questions such as 'Do you believe that ...'), there is an argument to
//     be made that the absence of belief should impose no influence on other spins.
//   - Relates to discussion on zero @vandermaasStatisticalPhysicsPsychological2026
// - Vaccination example: Pairwise relations can't capture mediated relations between
//   beliefs. i.e., relations which depend on other beliefs.
//   - Can tie this into the individual belief systems limitation
//
// _Individual belief systems:_
// - *A:* We see differences between the ideological models which suggest that while
//   individuals may share some structural components of their belief systems,
//   the existence and strength of interactions can vary on an individual basis.
// - *A:* This has also been discussed at length in
//   @brandtBetweenpersonMethodsProvide2022.
// - *A:* While some of the problems with cross-sectional studies are mitigated here,
//   cross-lagged panel data exhibits similar issues with detangling between-person and
//   within-person effects @hamakerCritiqueCrosslaggedPanel2015
// - *B:* Estimating individual-level belief systems remains an open problem. Limited
//   data, and the fact that many transitions will not be observed. Some progress has
//   been made for bidirectional belief systems,
//   e.g., #cite(<brandtMeasuringBeliefSystem2022>, form: "prose").
// - *A:* In our experiments we have made the simplifying assumption that belief systems
//   are shared.
// - *B:* As seen in the comparison of symmetric and asymmetric model dynamics, the
//   structure and relative interaction strengths in a belief system can change
//   endogenous dynamics.
// - *A:* The complete model can be seen as a 'mixing' of the two ideological models.
// - *T:* We would expect to see differences in intervention dynamics between individuals
//   to a greater extent than observed in RQ3. Yet expect that the observations from the
//   complete model reflect an 'average case'.




// _Conclude with summary of the main points and reiteration of our contributions_
// + *A:* Contributions
//   _Directed, causal belief system model_
//
//   _Longitudinal data, captures dynamics as opposed to observed state_
//
//   _RQ-focused contributions_


