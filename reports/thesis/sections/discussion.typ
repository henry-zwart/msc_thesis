#import "./introduction.typ": RQ1, RQ2, RQ3, RQ4
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
we discuss their place in the broader context of belief system dynamics. We then
conclude the chapter by discussing limitations
of our findings and implications for future work on belief system dynamics and
belief-level interventions.

#let show-rq(number, body) = block(above: 2em, below: 2em)[*RQ#number\:* #emph(body)]


#show-rq(1, RQ1) <discussion-rq1>

On the question of existence, @subsec:asymmetry-results-existence demonstrated
asymmetric relations between several pairs of beliefs, while also
finding that asymmetry may  not _always_ be exhibited. Two beliefs---political
ideology/alignment and climate-related #box[worry---displayed] significant excess
influence over several other beliefs.

#let within-person-footnote = footnote[
  Note that this interpretation (in particular, the use of the verb 'constrains') depends
  on the assumption that the calibrated model captures within-person associations. We
  discuss this matter in some depth later in this chapter
  (#internal-link(<within-person-discussion>)).
]

How should we interpret these asymmetric relations? Recall that relations in the
KBS model reflect temporal influence---how much one belief constrains the future state of
another (@chp:kinetic-belief-system).#within-person-footnote An asymmetric relation
reflects a constraint differential, where one belief has greater influence on the other
than vice versa. More generally, the asymmetric model distinguishes between two forces:
influence and influentiability. Influence (the strength of outbound interactions)
determines how the extent to which one belief constrains others, while influentiability
(the strength of inbound interactions) determines the extent to which its own behaviour
is constrained by others.

Political identity being more influential than influentiable in this context is
consistent with previous studies on its mutual influences
with climate-related beliefs in the USA. First, political identity
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
time, while public beliefs toward climate change in the USA have shifted
significantly over the past two decades @marlonChangeUSStatelevel2022
@hamiltonTrackingPublicBeliefs2015, political identity has been shown to be highly
stable over similar timeframes @greenPartisanStabilityTurbulent2024
@brandtBetweenpersonMethodsProvide2022. This suggests that while political identity
contributes meaningfully to climate-related beliefs, changes in these
states are less likely to incite changes in political identity.


Climate-related worry exhibits asymmetric influence over beliefs regarding the
anthropogenic nature and current impacts of climate change. Both relationships have
received comparatively less attention in prior research than those of political
political with climate beliefs. One possible explanation for
these asymmetric relations is that climate worry and climate beliefs influence
one another through different mechanisms. For instance,
#cite(<meadInformationSeekingGlobal2012>, form: "prose") suggest that climate worry
may promote information-seeking behaviour, leading to changes in climate-related beliefs.

For both variables, we found significant differences between inbound and outbound
centrality indices (strength centrality for climate worry; strength and degree centrality
for political ideology/alignment). The undirected-network versions of these centrality
indices are often used to assess belief importance, influence, or position in belief
systems. Our findings indicate that such assessments may be misleading for beliefs
involved in several asymmetric relations.




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

#show-rq(2, RQ2) <discussion-rq2>

The consequences of asymmetry for belief system dynamics were subsequently addressed in
@subsec:asymmetry-results-impact, where interventions on political ideology/alignment
in the asymmetric model were found to be almost universally more effective than in the
symmetric model. Moreover, for interventions targeting attitudes toward climate action,
political ideology/alignment ranked higher with regards to collective effect in the
asymmetric model than the symmetric model, displacing a mostly-symmetric belief with
similar outbound interactions.
Interestingly, while interventions on climate-related worry typically
outperformed those on political ideology/alignment in terms of absolute effect of
intervention, the differences between the asymmetric and symmetric models for this
variable were comparatively less pronounced.

It is important to note that the effectiveness of interventions on political
ideology/alignment is _despite_ this variable's high inertia (i.e., strong
self-interaction effect). When this variable is negative, high inertia leads to
a lower pre-intervention effective baseline activation, making it harder to
intervene. The effectiveness of interventions on this variable may be explained
by fact that if an intervention successfully 'flips' political ideology/alignment,
the high inertia works in favour of the intervention.

For the measurement timescale used in these experiments (approximately 2.5 years),
interventions appeared to act primarily through direct interactions, though smaller
indirect effects were also present; this is consistent with empirical results
obtained by #cite(<chambonTailoredInterventionsBroad2022>, form: "prose") in an
experimental study concerning beliefs relating to COVID-19.
Additional experiments included in
@sec:appendix-extra-results found that longer timeframes led to increased indirect
intervention effects. The presence of indirect effects is broadly expected given the
pre-defined model dynamics; however, the observed magnitudes suggest that while state
changes may propagate beyond direct connections, this process is typically slow. We
return to this point shortly in our discussion on *RQ3*
(#internal-link(<discussion-rq3-indirect-effects>)), which finds that indirect
propagation may nonetheless contribute meaningfully to intervention effectiveness at
an individual level. <discussion-rq2-indirect-effects>


#let full-model-disclaimer = footnote[
  Note that this point pertains to the model calibrated on the complete climate
  beliefs dataset. This model omits several interactions (due to
  regularisation) which are inconsistently excluded from the bootstrap models used to
  assess the significance of asymmetric relations.
]

The distinction in behaviour between political ideology/alignment and climate-related
worry likely relates to differences in influentiality and influentiability between the
two beliefs. Climate-related worry is more influential than political
ideology/alignment, on account of its increased outbound interactions and interaction
strength. The key difference, however, lies in the beliefs' influentiability; while
climate-related worry has inbound and outbound interactions with all other beliefs,
political ideology/alignment has considerably fewer _inbound_ than _outbound_
edges.#full-model-disclaimer That is, several beliefs influenced by this
variable have no influence on it themselves. Since the symmetric model
must include or exclude both directional interactions between a pair of
beliefs, cases where the asymmetric model specifies an interaction in only one
direction necessarily lead to differences in model behaviour.
This draws attention to a broader issue regarding relational symmetry assumptions.

One of the symmetric model's key strengths is its small(er) parameter count. With fewer
degrees of freedom than the asymmetric model, it can achieve more accurate parameter
estimates when calibrated to the same dataset (i.e., smaller confidence intervals in
@fig:calibration-edge-accuracy). However, this comes at the cost of model
misspecification when a subset of the true relations are asymmetric. We might expect
the inferred symmetric influence relations to be similar to the average of the
corresponding directed effects, yet this reasoning turns out to be flawed for at least
two reasons. Firstly, interaction effects are not estimated in isolation, but jointly
with all other parameters which influencing the same spin (or _both_ spins in the
symmetric case). Hence, when one interaction parameter changes---for instance, if we
replace a pair of asymmetric interactions by their average---the rest are likely to
change as well. Secondly, regularisation is often used to obtain sparse network
representations and reduce overfitting, and distorts parameter values non-linearly
in the process. In reality we find that while most symmetric interactions lie between
their asymmetric analogues, this is not always the case, and those that are do not
fall predictably near the middle. As observed in the case of political
ideology/alignment, the symmetric model may also exclude pairwise interactions
altogether, or create a (bi-)directional interaction where influence actually
flows unidirectionally.

#show-rq(3, RQ3) <discussion-rq3>

In @sec:heterogeneity-results-intervention-effects we found that
intervention effectiveness depends predictably on individuals' pre-intervention belief
states. Most high-effect interventions targeting attitudes toward climate action
required low initial values for both the point-of-intervention and target.

Surprisingly, pre-intervention climate-related worry was required to be low for _all_
of the personas identified as characteristic of effective interventions, even when this
was neither the point-of-intervention, nor the target.
This finding may be explained by the combination of high influence and
influentiability associated with climate-related worry, thereby making this variable an
effective indirect route for various interventions (not restricted to this particular
target). This stands in contrast with political ideology/alignment, which has similarly
high influence on the target variable, but is harder to influence, as discussed above.

At first glance this finding appears to contradict our earlier discussion on *RQ2*
(#internal-link(<discussion-rq2-indirect-effects>)), which found that indirect
interventions have limited impact on collective effects over short timeframes.
However, recall that the corresponding experiments measured indirect intervention effects
by examining beliefs with no direct influence from the point-of-intervention. In other
words, all propagation of intervention effects to these beliefs is indirect. Compare this
with the present analysis, in which the target belief (attitudes toward climate action) is
directly influenced, nontrivially, by all of the considered points-of-intervention---this
implies that effective interventions on these points-of-intervention, targeting this
belief, are possible _in principle_. Therefore the apparent discrepancy in our findings
is likely explained by low pre-intervention levels of climate-related worry marginally
increasing the effectiveness of interventions which were already effective.
<discussion-rq3-indirect-effects>


#let persona-count-footnote = footnote[
  The personas are given by the paths from the root to each leaf; a binary tree with
  depth three has $2^3 = 8$ leaves, and thus eight personas.
]

#{
  [
    In general, the identified personas characterise the conditions for effective
    interventions accurately. The rare instances where individuals with these traits fell
    outside the high-effect region may be attributable to the rough-and-ready use of the
    upper quartile to classify high-effect interventions. On the other hand, while the
    personas capture _most_ cases where interventions are effective, this varies between
    points-of-intervention. This directly reflects the limited representational capacity of
    effect characterisation functions based on shallow decision trees; a tree depth of three
    permits at most eight personas to describe the full range of intervention effectiveness,
    each of which comprises at most three conditions.#persona-count-footnote
  ]
}
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

Importantly, the findings from this experiment must be interpreted in the context
of the belief system model calibrated to the complete dataset. Individual differences
in belief systems (as discussed in a moment) are likely to result in heterogeneous
responses to interventions beyond those characterised here. Potentially influential
factors include political identity and social norms. Both vary individually
@laursenWhatDoesIt2022 and socially @laursenWhatDoesIt2022
@brownMeasurementPartisanSorting2021 @websterSocialConsequencesPolitical2022, and both
have been demonstrated as moderating the effects of interventions in the USA targeting
support for climate policy and related beliefs @grometPoliticalIdeologyAffects2013
@unsworthItsPoliticalHow2014 @allcottSocialNormsEnergy2011
@vanvalkengoedSelectEffectiveInterventions2022.

#show-rq(4, RQ4) <discussion-rq4>


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
higher-order relationships between beliefs, consistent with
the view that belief system relations, themselves, correspond to beliefs
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
with various climate-related beliefs for non-right-leaning individuals.
These findings were not replicated in our results; instead we found limited association
(inbound or outbound) with this variable in both models. There are several possible
explanations for this apparently contrary result, including parameter uncertainty in
the present study. Firstly, both studies are based in a European, as opposed to US,
context; #cite(<leeVariationsClimateChange2025>, form: "prose") showed cross-national
differences in climate belief systems including related variables. Second, both measure
association using cross-sectional correlational measures, which may differ considerably
from the time-lagged interaction parameters used in the present study.

== Limitations <sec:discussion-limitations>


#metadata[] <within-person-discussion>
When beliefs are fairly stable---as in the climate beliefs
dataset---cross-sectional methods for inferring belief system structure tend to
identify _between_-person associations more so than the _within_-person associations
which are typically desired @brandtBetweenpersonMethodsProvide2022. We partially
mitigate this problem by calibrating to longitudinal data, and using self-interaction
terms to capture persistence in belief states. However, our model does not
account for belief stability due to the presence of stable traits
@hamakerCritiqueCrosslaggedPanel2015 @usamiUnifiedFrameworkLongitudinal2019.

#let identifiability-footnote = footnote[
  For a given individual, each pair of consecutive waves constitutes a single
  observation (given we model conditional transition probability). For a set of
  $N in NN$ beliefs the asymmetric model comprises $N^2 + N$ parameters,
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
identifiable, while the climate beliefs dataset comprises only two
waves.#identifiability-footnote In unreported experiments we tried a similar approach,
modelling baseline activations as linear functions of demographic factors (e.g., age,
education, rural/urban status), which requires only two waves to be identifiable. While
the resulting baseline activations varied substantially between individuals, indicating
that they captured some differences in stable traits, we found little-to-no impact on
either the inferred interactions or the intervention experiment results. Hence further
investigation is required to determine the extent to which the models calibrated in
@sec:calibration capture within-person associations.

Relatedly, since the climate beliefs dataset comprises only two waves, we cannot
distinguish between belief system dynamics arising due to endogenous factors (the
states of other beliefs) and exogenous factors (current events which
affect beliefs). We implicitly assume that (i) exogenously-driven
dynamics at an individual level are not substantially correlated between individuals,
and thus not reflected in the model, and (ii) the time between measurements
(approximately six months) is sufficiently short that widespread exogenous factors are
negligible.

The second assumption has questionable validity, since for instance, both
the 2020 US presidential election and January 6 Capitol attack occurred during this
timeframe.
However, we observed highly stable political beliefs over this period, consistent
with prior studies @greenPartisanStabilityTurbulent2024. Given the significance and
considerable media coverage of both events, as well as their highly-political nature,
we would expect political beliefs to be affected more so than climate-related
beliefs. The fact that we do not see this reflected may suggest minimal
exogenous impacts, more generally, on the beliefs considered in this
study.

Our present focus on endogenous dynamics also does not discount the substantial
role of social interaction in belief change
@karashialiQualitativeStudyExploring2023 @galesicHumanSocialSensing2021
@degrootReachingConsensus1974a @converseNatureBeliefSystems2006 or stability
@prenticePluralisticIgnorancePerpetuation1996 @brownMeasurementPartisanSorting2021,
including in intervention contexts
@brewerIncreasingVaccinationPutting2017. Rather, this decision reflects the fact that
the dataset used in this study did not include social network information. The matter
of integrating social and cognitive forces in similar belief system models has been
explored in several accounts @rodriguezCollectiveDynamicsBelief2016
@aiyappaEmergenceSimpleComplex2024 @dalegeNetworksBeliefsIntegrative2025
@vandermaasPolarizationIndividualsHierarchical2020, generally assuming individuals have
dual objectives of cognitive consistency and social coherence @festingerCognitiveDissonance1962
@heiderAttitudesCognitiveOrganization1946 @gawronskiCognitiveConsistencyFundamental2012.
The Networks of Belief theory, proposed by
#cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose"), builds on the Causal
Attitude Network model which also serves as the foundation for our proposed model. Since
our work is mostly orthogonal to theirs, we anticipate that it would be straightforward
to incorporate such social influences in our model.

#let aspirin-footnote = footnote[
  In their original paper, #cite(<gollobTakingAccountTime1987>, form: "prose")
  illustrate this with respect to the effects of aspirin over time. See
  #cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") for extended discussion
  on this example.
]
To ensure computational tractability and model simplicity we have defined the
KBS model dynamics as progressing via discrete timesteps. However, this means that
the model parameters inferred during calibration are a function of the time between
observations, known as the _time-interval dependency problem_
@gollobTakingAccountTime1987. #cite(<gollobTakingAccountTime1987>, form: "prose")
demonstrate that in certain contexts, inferred effect size, sign, and existence can
be sensitive to interval duration. This is particularly evident in cases where the
true dynamics play out at a much faster timescale than the measurements.#aspirin-footnote
Furthermore, #cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") argue that
when several state updates can occur between observations, the inferred effects should
be treated as _total effects_ rather than _direct effects_. This is potentially critical
for the present study, which fundamentally assumes that the interaction effects relating
beliefs are direct effects.
<time-interval-dependency-problem>

However, we do not expect these problems to be especially consequential in the context
considered in this study. In particular, per the results of previous studies
@greenPartisanStabilityTurbulent2024 @kileyMeasuringStabilityChange2020
@marlonChangeUSStatelevel2022, we expect most of the examined beliefs to be quite stable
over the measurement timeframe (six months). As such, we do not expect any given belief
to exhibit multiple significant changes in state between observations. We may, however,
fail to detect causal dynamics between beliefs which play out on a quick timescale. For
instance, suppose that following natural disasters, individuals typically become
increasingly concerned about impending extreme weather, causing potentially rapid shifts
in their beliefs regarding climate change. If both changes occur between measurements,
our calibration method will attempt to explain both transitions with respect to
individuals' belief states prior to the natural disaster, thereby missing the fast causal
influence of extreme weather concerns on climate-related beliefs.
<fast-causal-influence-example>

// #cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") suggest the use of
// continuous-time models to cope with the described issues; however, since, as argued, we
// do not expect belief systems to be particularly vulnerable to

// In other words, we expect that the belief system dynamics to play out at a slower
// timescale than is captured by the model. This, of course, poses a separate issue,
// as the stability of beliefs over this timeframe means the observations provide
// limited information on belief dynamics.





// only the effect _size_, but also sign
// and existence are
// can be
// #cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") suggest two possible
// implications, respectively, for our calibrated model. First, that when
//
// - Inferred effect size and sign may depend on the interval duration. Aspirin example. @gollobTakingAccountTime1987
// - Since several states may change in the time between measurements,
//   #cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") argue that effects inferred
//   for discrete-time autoregressive models should be treated as total effects rather than
//   direct effects.
//
// , and has several
// implications for our results.
// - Several beliefs can change between observations -->
//   #cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") argue that this implies
//   effects should be treated as total, rather than direct, effects.
// - Inferred effect depends on time interval. e.g., aspirin example. May judge as different
//   effect, sign, or direction depending on the interval length.
//   - We do not expect this to be particularly consequential in the current study, on
//     account of the observed belief stability. Beliefs are, in general, unlikely to
//     change multiple times during the time between responses.
//   - We may, however, miss causal dynamics which happen at a quick timescale. For
//     instance, consider an individual who, after experiencing an extreme weather event
//     becomes concerned about future events, and soon after adopts belief in the reality
//     of climate change. If both changes occur between measurements, we will attempt to
//     attribute both to the pre-extreme-weather state, thereby missing the fast causal
//     influence of extreme weather concerns on belief in climate change.
//   - As in the aspirin example, we may find that effect sizes are smaller than those
//     obtained for longer intervals (e.g., if beliefs change a bit, from neutral to weakly
//     support, during six months). However, given the stability of beliefs, we are unlikely
//     to see the extreme case where zero-effect is measured at 24h. Particularly for
//     political beliefs, which are highly stable over short timeframes. Maybe an issue for
//     other beliefs with lower inertia, such as beliefs about climate impacts.
// - In response to the time-interval problem,
//   #cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") suggest the use of
//   continuous-time models.
//
//
// *TODO:* "The DT-VAR model suffers from the problem of time-interval
// dependency @gollobTakingAccountTime1987" @ryanTimeInterveneContinuousTime2022
// - Ours does not(?) because we use temporal data, and include self-interaction
//   effects which set timescale.

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
pertaining to (i) the use of pairwise relations, (ii) representation of belief states as
Ising model spins, $s in {-1, +1}$, as opposed to binary variables, #box[$s in {0,1}$],
and (iii) the non-dependence of interacton effect magnitude on belief states.

Consider the following (hypothetical) motivating example. Suppose that parents'
attitudes toward childhood vaccination typically depend, in a simplistic way, on
their perceived relative risk of a vaccine, and the disease it protects against.
Positive attitudes prevail when the disease is considered more risky or dangerous
than the vaccine. Values around family wellbeing conceivably influence the relationship
between perceived risk and vaccination attitudes, serving to amplify the existing effect.

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
interactions, the _effective_ influence relations between pairs of beliefs
can vary in accordance with the specific belief state.
Findings from #cite(<brewerIncreasingVaccinationPutting2017>, form: "prose") suggest
that such interventions, which selectively leverage or amplify existing beliefs may be
more effective than interventions which attempt to change
belief states. However, such relational structures cannot be captured in the
pairwise model adopted here.

#block(breakable: false)[
  Next, we consider the implications of our decision to model belief states
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

As a consequence of our decision to model belief states as spins, we are
assuming that beliefs always exert influence over associated variables,
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

- *Happening:* The belief that climate change is happening.

- *Action:* General attitude toward climate action.

An individual who _does not_ believe in climate change logically should not support
climate action. In the asymmetric belief system model, this corresponds to a large
positive interaction, such that *Action* aligns with *Happening*. However, individuals
who _do_ believe in climate change may nonetheless oppose climate action for other
reasons (e.g., cost or prioritisation), suggesting that *Action* may be less
constrained when *Happening* is high than when it is low.

//*I have other limitations to discuss, but judged these as the most critical*
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
least a reasonable approximation, asymmetric relations between beliefs
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
number of waves in the climate beliefs dataset prohibits us from
distinguishing within-person and between-person effects, which is required
to make strong claims regarding causal influences. We note that the broader
CCCV survey from which the climate beliefs dataset used for calibration in
this study does contain several additional waves, which are usable if we
drop our requirements regarding the number of variables and inclusion of specific
beliefs.

However, this presents a separate issue regarding the intervals
between measurements, as inter-response times between different pairs of waves can differ
significantly, violating the model requirements.
Further consideration is required to
determine whether, for instance, the additional waves can be used _only_ to estimate
individual baselines, while evenly-spaced observations are used to estimate interaction
effects.
#cite(<ryanTimeInterveneContinuousTime2022>, form: "prose") propose continuous-time
models as an alternative solution, enabling calibration with heterogeneous
inter-response times, while also reducing the potential issues associated with the
_time-interval dependency problem_ (discussed under Limitations,
#internal-link(<time-interval-dependency-problem>)).

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
salience of certain beliefs @unsworthItsPoliticalHow2014. As such,
experimental validation---and, ideally, calibration to data collected in controlled
intervention scenarios---is a natural continuation to the present study.

Our findings also suggest and support several broader directions for future research.
Firstly, we posited two explanations for the asymmetric relations observed with
regards to political beliefs and climate-related worry
(#internal-link(<rq1-asymmetry-explanations>)). These are retrospectively
applied to the findings, so arguably have minimal evidential weight @popper1963science.
However, they demonstrate how the asymmetric KBS model may be
used to test (as opposed to generate) hypotheses about the general mechanisms by which
asymmetric belief relations may occur.

Secondly, while belief system structure is typically expected to vary on an individual
basis @morganStructurePoliticalIdeology2017 @brandtBetweenpersonMethodsProvide2022,
calibrating individual belief system models is generally considered infeasible due
to the associated data requirements @brandtMeasuringBeliefSystem2022. Moreover, due to
the potential stability of belief dynamics, as observed in the present study, even
substantial individual-level data is likely to reflect only a small set of possible
belief states, limiting counterfactual analysis in individual models. However, our
findings demonstrate structural similarities, as well as differences, across ideological
groups. This suggests that a middle-ground approach, between individual-level and
population-level networks may be effective in capturing both the ways in which belief
systems are different, and the ways in which they are similar. This is akin to the
notion of partial-pooling in multi-level Bayesian models, which assumes individuals in a
group vary with respect to one another, but are constrained by common parameters
@gelmanBayesianDataAnalysis2013 @gelmanDataAnalysisUsing2007
@mcelreathStatisticalRethinkingBayesian2020a. Note that this is distinct from the
estimation of individual _baseline activations_ for the purpose of inferring
within-person associations.

#let package-url-footnote = footnote[
  #link("https://github.com/henry-zwart/ising")
]
In our experiments we considered interventions as attempts to change the state of
a belief directly. However, previous studies indicate that
in certain situations, interventions targeting belief system _structure_ may be more
effective @aggarwalWiredCoherenceNetwork2026 @brewerIncreasingVaccinationPutting2017.
Rather than attempting to affect beliefs directly, structural interventions
can be seen as amplifying or changing the influence between beliefs. Although we have
not considered such interventions in this study, the open source _Ising_ Python
package released alongside this study already supports these, inviting future work on
this topic.#package-url-footnote

Finally, we adopt a simplistic view of the interface between belief systems and the
external world. This is most evident, for instance, in our treatment of interventions as
acting directly and identically on individual beliefs, and the assumption that
current events (e.g., the 2020 US presidential election) have minimal impact on observed
belief dynamics. In reality, some beliefs may be easier or harder to affect
directly than others. Communication of interventions or current events may be noisy
(e.g., subject to interpretation), potentially impacting the magnitude, direction, and
set of affected beliefs, also on an individual basis. Clearly, a more realistic
treatment of this interface is required for the proposed methods to be useful in the
context of actual interventions. From a modelling perspective,
#cite(<dalegeNetworksBeliefsIntegrative2025>, form: "prose") consider a related problem,
namely the interface between belief systems belonging to different individuals, modelling
peer influence as indirect, via social beliefs which may only be indicative of the true
external state.


// *Todos:*
// - Comparison with other measures of influence, e.g., centrality in PRCNs @brandtWhatCentralPolitical2019, hierarchy in Bayesian networks @powellModelingLeveragingIntuitive2023
// - Comparison of model with other kinds:
//   - Partial correlation networks
//   - Bayesian networks
//   - Symmetric (cross-sectional) Ising model
//
// *TODO:*
// - Comparison with other work:
//   - Politics driving support for climate action, belief in CC, concerns about CC,
//     while not being substantially influenced by these
//   - Climate concern driving beliefs about climate impacts and causes, while not
//     being influenced so much by them (e.g., psychological distance)
//   - Other discussions on variables with varying 'influence', e.g., centrality.

