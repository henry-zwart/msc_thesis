#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

#let observation(x) = text(fill: red, x)

Key points to hit:
// 1. Remind the reader of the research questions

// 2. Summarise the main findings clearly and concisely. Highlight unexpected, important,
//   or otherwise significant results

3. Interpret the results in relation to the research questions. What do they mean in
  the context of the study? How do they support/conflict with previous research?

4. Discuss limitations

5. Implications of findings. How can the results be applied practically? What
  questions/directions do the findings suggest?

6. Conclude with summary of the main points and reiteration of our contributions


// In this chapter we interpret the results from the previous two chapters with respect
// to each of the above research questions, as well as the broader context of belief
// system dynamics. We then conclude the chapter with discussion on limitations of the
// study, and the implications of our findings for future work on belief system dynamics
// and belief-level interventions.

In this chapter we interpret the results of the previous two chapters with respect to
the research questions posed back in @sec:introduction and restated below, as well as
the broader context of belief system dynamics. We then describe limitations of the
present study, and conclude the chapter with a discussion on the implications of our
findings for future work on belief system dynamics and belief-level interventions.

//At the start of this thesis, we posed four research questions:

*RQ1:* To what extent are causal relations _symmetric_ or _asymmetric_, in models
of climate change belief systems inferred from the climate beliefs dataset?

*RQ2:* How do asymmetric and symmetric beliefs systems differ with regards to
intervention strategy and effectiveness, in models inferred from the climate
beliefs dataset?

*RQ3:* How do intervention outcome and effectiveness vary between individuals with
different initial conditions in asymmetric belief systems inferred from the
climate beliefs dataset?

*RQ4:* How do asymmetric belief systems inferred from the climate beliefs dataset
vary between conservative and liberal individuals?

// NOTE:
// The previous two chapters describe various experiments performed and results obtained in
// pursuit of these research questions. Let's take a moment to review the key findings.

On the question of existence, @subsec:asymmetry-results-existence presented evidence of
asymmetric directional relations between several pairs of beliefs or attitudes, while
also finding that not _all_ pairs necessarily exhibit this asymmetry. Two attitudes in
particular---political ideology/alignment and climate-related concerns---displayed
significant preponderance of influence over several other beliefs and attitudes.

Following this, @subsec:asymmetry-results-impact demonstrated that relational symmetry
assumptions meaningfully impact intervention dynamics and outcomes. Interventions on
political ideology/alignment in the asymmetric model were found to be almost universally
more effective than those in the corresponding symmetric model. For inbound
interventions targeting attitudes toward climate action, the results showed differences
in relative effectiveness for different points-of-intervention between the two models.
In one case, the differences were sufficiently large to change intervention
effectiveness rankings, impacting intervention strategy.

We then changed tack to investigate heterogeneity in intervention effects and belief
systems. @sec:heterogeneity-results-intervention-effects found that
intervention effectiveness varies predictably with respect to individuals'
pre-intervention belief states. Most high-effect interventions targeting attitudes
toward climate action required low initial values for both the point-of-intervention and
target. Surprisingly, pre-intervention climate-related concern was required to be low
for _all_ of the personas identified as characteristic of effective interventions, even
when this was neither the point-of-intervention, nor the target.

Finally, @sec:heterogeneity-results-belief-system showed substantive differences
between asymmetric belief system models calibrated separately to conservative and
liberal subpopulations. Each model featured high-magnitude interactions not present
in the other, yet while the liberal model was considerably sparser than the conservative
model, most interactions in the former were also present in the latter. In comparison
with the asymmetric model calibrated on the complete dataset, used in the prior
experiments, the ideological models were both sparser, yet together had high overlap
in connectivity with the complete model.

Interpreting asymmetric relations:
- In terms of the mathematical model
- Compare with other notions of 'influence' or 'centrality'

Political ideology/alignment and climate-related concern as asymmetric instigators:
- Interpret
- Compare with other results

Explaining differences in intervention results:
- In terms of influence/influentiability
  - Distinction which isn't possible in the symmetric model
  - Also comes back in the heterogeneity results
- Model misspecification

Measurement timescales:

Answering the research questions:
- Ideally 1--2 sentences for each

Interpreting 'with respect to the broader context of belief system dynamics':
- Likely one paragraph






== RQ1: Asymmetric influence of political ideology & climate concern


Our findings in @subsec:asymmetry-results-existence demonstrate, by example, a positive
response to the question of asymmetric relation existence. Two variables in
particular---political ideology and climate-related concerns---exhibited significant
asymmetric influence over the behaviour of several other variables. Additionally,
we observed two forms of asymmetry: where two beliefs or attitudes reinforce one another
with different strengths, and where one belief or attitude influences another with no
apparent direct reinforcing feedback.

However, not all pairs of beliefs or attitudes display asymmetry. Aside from
interactions with these two variables, we found that most interactions were either
symmetric or near-symmetric, or otherwise have inconclusive support for asymmetry due
to sampling error. Moreover, the presence or absence of asymmetry for different
variables was not cleanly explained in terms of differences in average influence
(interaction strength) or sampling error.

Hence while asymmetric relations between beliefs and attitudes appear to be less
prevalent than symmetric ones (at least in this context), they exist nonetheless.

As per the underlying mathematical model defined in @sec:asymmetric-belief-systems,
we interpret belief relations temporally, as the influence of one belief or attitude
on the future state of another. An asymmetric relation is one in which one belief or
attitude influences (i.e., constrains) the other more than in the opposite direction.
Our findings therefore suggest that in several cases political ideology/alignment and
climate-related concerns drive the behaviour of other beliefs and attitudes, while being
relatively insensitive, themselves, to the states of those beliefs and attitudes.

For instance, political ideology and/or alignment exerts asymmetric influence
on general attitudes toward action on climate change. This is to say that a conservative
and/or Republican-aligned individual is more likely to display lower _future_ support
for climate action than a liberal and/or Democrat-aligned individual. Yet conversely,
if an individual's support for climate action changes, this asymmetry implies a smaller
corresponding shift in their political views.

// In particular, political ideology or alignment exerts asymmetric influence on
// climate-related concerns, beliefs about the reality of climate change (with no
// feedback influence), and general support for action on climate change. Climate-related
// concerns, on the other hand, asymmetrically influences beliefs about the causes and
// impacts of climate change. This is to say, for instance, that a conservative and/or
// Republican-aligned individual is more likely to display lower _future_ support for
// climate action than a liberal and/or Democrat-aligned individual. Yet conversely, if
// an individual's support for climate action changes, the asymmetry implies that their
// political alignment is less likely to shift in-turn.

*TODO:*
- Comparison with other work:
  - Politics driving support for climate action, belief in CC, concerns about CC,
    while not being substantially influenced by these
  - Climate concern driving beliefs about climate impacts and causes, while not
    being influenced so much by them (e.g., psychological distance)
  - Other discussions on variables with varying 'influence', e.g., centrality.

== RQ2: ...


While we have demonstrated the existence of asymmetic relations between beliefs and
attitudes, existence does not, on its own, imply that the observed asymmetric relations
are impactful on endogenous dynamics. Our findings in @subsec:asymmetry-results-impact,
however, show that assumptions regarding asymmetry _are_ consequential when reasoning
about interventions.

We showed, by way of simulation, that asymmetric models calibrated to the climate beliefs
dataset exhibit post-intervention behaviour which differs from the corresponding
symmetric model. Interventions on political views in the asymmetric model outperformed
those in the symmetric model almost universally across target beliefs and attitudes. This
was further reflected in our experiments on inbound interventions targeting attitudes
toward climate action. Under the symmetric model assumption, intervening on beliefs
regarding the impacts of climate change is expected to be more effective than intervening
on political views, while under the _asymmetric_ model asummption the situation is
reversed.

One of the symmetric model's key strengths is its small(er) parameter count. With fewer
degrees of freedom than the asymmetric model, it can achieve more accurate parameter
estimates when calibrated to the same dataset (i.e., smaller
confidence intervals in @fig:calibration-edge-accuracy). However, this comes at the cost
of model misspecification when a subset of the true relations are asymmetric. In the
symmetric model, bidirectional interaction strengths are generally inferred as being
between the corresponding directional interaction strengths in the asymmetric model.

This has little impact on beliefs and attitudes with largely symmetric relations, but
can dramatically affect the level of influence for those with asymmetric relations, and
hence affect intervention dynamics considerably. For instance, consider again the
attitude associated with political ideology/alignment. In the asymmetric model this
displays similar outbound interactions as the (largely symmetrically-interacting)
belief regarding the impacts of climate change. On the other hand, in the symmetric
model most interactions with political ideology/align are roughly half the magnitude
of those for the latter belief. The result is a diminishing of the influence of this
attitude, due to model misspecification, causing the latter belief to appear more
influential, when, in-fact, it is almost identical.
Regularisation can exacerbate this issue. In the asymmetric model, political
ideology/alignment has outbound interactions with all (seven) other beliefs and
attitudes. In the symmetric model, only four remain.

For the measurement timescale used in the experiments (roughly 2.5 years) we found
that interventions act mostly through direct relations, as evidenced by rough
correspondence between intervention effects and direct interaction strength. While
some indirect influence was observed (e.g., for intervention targets with no direct
connections to the point-of-intervention) this was small compared to direct effects,
though increases for longer measurement timescales. This finding is potentially
impactful for the difference between symmetric and asymmetic intervention dynamics.
If two beliefs or attitudes are related asymmetrically such that only one directional
interaction is nonzero, then a symmetric model is likely to both _overestimate_ the
effect of an intervention on the more influential variable, and _underestimate_ the
time until the effect is realised.

In summary, and responding to *RQ2*, we find that assumptions regarding the symmetry or
asymmetry of relations between beliefs and attitudes can impact expectations regarding
both the absolute and relative effect of intervention, as well as the time taken for
the effects of an intervention to be realised. Differences between the models'
dynamics arise both as a direct result of asymmetric relations existing (e.g., as in
the example from the previous paragraph), and due to differences in influence
(outbound interactions) and influen#emph[tiability] (inbound interactions) which are
characteristic of beliefs and attitudes in asymmetric relations. The latter can, from
the other side, be considered a difference resulting from model misspecification ---
assuming that a belief system comprises only symmetric relations, when asymmetric
relations are present.



// intervention effects between asymmetric and symmetric models;
// @def:asymmetry-results-effect-of-asymmetry) indicates that asymmetry impacts the
// propagation of intervention effects
// in a belief system for different targets given a single point-of-intervention (as seen
// in the varied effects of asymmetry (@fig:asymmetry-results-outbound-effect-of-asymmetry)
// for different target spins), as well as the relative effectiveness of different
// interventions targeting a specific belief or attitude.

// As evidence to the first point, we found that when intervening on climate-related
// concerns, the effect of asymmetry (i.e., the difference in
// expected outcomes between the asymmetric and symmetric models;
// @def:asymmetry-results-effect-of-asymmetry) varies for different target spins. This
// indicates that the impact of asymmetry on endogenous

== RQ3: ...


In @sec:introduction we hypothesised that in order for interventions to be effective,
it is necessary for the initial states of both the point-of-intervention and target
beliefs or attitudes to be different from the desired post-intervention states.

The results in @sec:heterogeneity-results-intervention-effects broadly support this
hypothesis for interventions targeting attitudes toward climate action, showing that
the most effective interventions are observed in cases where the point-of-intervention
is initially 'low', and initial attitudes toward climate action are negative.
We found no requirement that the initial attitudes be close to the low extreme. This
is consistent with our earlier discussion in
@subsec:asymmetric-belief-system-modelling-interventions, in which we illustrated how
the impact of an intervention on the _point-of-intervention_ behaviour diminishes as
the magnitude of the initial influence on that belief or attitude grows (i.e., for strong
opposition or support).

Unexpectedly, for all points-of-intervention, the majority of individuals for whom
we estimate a high intervention effectiveness also had low pre-existing concerns about
climate change. This was true even when climate-related concern was neither the
point-of-intervention nor the target. This result is likely related to the variable's
high degree of influence in the asymmetric model, in combination with a high potential
to _be influenced_, compared with other variables.

Overall, we find that intervention effectiveness does vary in predictable ways with
respect to individuals' pre-intervention belief system state. Effectiveness depends
not only on the initial states of the target of point-of-intervention, but also on
other auxiliary beliefs and attitudes through which interventions can propagate
indirectly.

== RQ4: ...




// In line with our hypothesis, for interventions (targeting attitudes toward climate
// action) to be highly effective at shifting the target attitude toward the desired state,
// in comparison with a no-intervention scenario, it is generally necessary that both the
// target and point-of-interventions
#line(length: 100%)



Plan:
+ *A:* What have we learned?

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
  Findings, per-research-question:#linebreak()
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

  *RQ3:* _Individual impacts_
  - *A:* In line with our hypothesis, for interventions (targeting `CC Action`) to be
    highly effective, it is generally necessary that both the target and
    point-of-intervention states be low (such that the intervention changes the
    point-of-intervention, and there is space for the target to shift)
  - *B:* Unexpectedly, almost all highly effective interventions were also predicated
    on a low initial level of climate-related concern.
  - *T:* We attribute this to climate-related concern's high degree of influence in the
    model, in combination with a high potential to _be influenced_, compared with other
    variables.
  - *T:* Intervention effectiveness is not only dependent on the initial states of the
    target and point-of-intervention, but also by other auxiliary beliefs and attitudes
    through which interventions can propagate indirectly.
  - _Comparison with other work:_ Perhaps we have sources discussing the impact of
    climate concerns on policy specifically; ideally can find sources talking about
    interventions.

  *RQ4:* _Individual belief systems_
  - *A:* Conservative and liberal belief system models differ in sparsity (edge
    existence) and strength of specific interactions.
  - *A:* The liberal model is considerably sparser than either the conservative
    model or the model calibrated on the complete dataset.
  - *A:* In several cases, high-effect interactions are present in only one of the
    two models.
  - *B:* The ideological models do, however, still display substantial overlap in
    the inferred edges.
  - *T:* Belief systems may differ significantly between individuals or subpopulations
    at the level of individual relations, but nonetheless appear to exhibit some shared
    structures.
  - _Can we find evidence, explanations for some of the big differences between the
    models?_
  - _Compare to other research_


+ *B:* Limitations

  _How we think about interventions:_
  - *A:* We have assumed that interventions can act directly, and with equal effect on
    different beliefs and attitudes. This is to say, we are not concerned here with the
    nature of an intervention itself (the interface between the intervention and the
    belief system). Rather, we operate under the assumption that we _can_ intervene,
    and study the resulting endogenous dynamics.
  - *B:* In reality, some beliefs or attitudes may be easier or harder to intervene on
    than others.
  - *T:* Taking the intervention process into account may result in different expected
    effects of intervention. For instance, we found that political ideology is often
    influential, but is difficult to influence, due to a scarcity of incoming
    interactions. Supposing, then, that we can only intervene indirectly on politics,
    the expected intervention outcomes may change.

  _Representational limitations:_
  - Polar vs. binary states:
    - We use polar ${-1, +1}$ states. This means that whatever the state of a spin, it
      exerts nonzero influence on spins it relates to. This makes more sense for some
      variables than others. For instance, political alignment and measures of policy
      support have clear positive and negative states (up to re-labelling). Beliefs such
      as 'Climate change is real' are murky, and whether they fit this assumption
      depends on how the survey questions are framed. In particular, we should distinguish
      between holding the opposite belief, and holding _no belief_. In the latter case
      (e.g., in questions such as 'Do you believe that ...'), there is an argument to
      be made that the absence of belief should impose no influence on other spins.
    - Relates to discussion on zero @vandermaasStatisticalPhysicsPsychological2026
  - Vaccination example: Pairwise relations can't capture mediated relations between
    beliefs. i.e., relations which depend on other beliefs.
    - Can tie this into the individual belief systems limitation

  _Individual belief systems:_
  - *A:* We see differences between the ideological models which suggest that while
    individuals may share some structural components of their belief systems,
    the existence and strength of interactions can vary on an individual basis.
  - *A:* This has also been discussed at length in
    @brandtBetweenpersonMethodsProvide2022.
  - *B:* Estimating individual-level belief systems remains an open problem. Limited
    data, and the fact that many transitions will not be observed. Some progress has
    been made for bidirectional belief systems,
    e.g., #cite(<brandtMeasuringBeliefSystem2022>, form: "prose").
  - *A:* In our experiments we have made the simplifying assumption that belief systems
    are shared.
  - *B:* As seen in the comparison of symmetric and asymmetric model dynamics, the
    structure and relative interaction strengths in a belief system can change
    endogenous dynamics.
  - *A:* The complete model can be seen as a 'mixing' of the two ideological models.
  - *T:* We would expect to see differences in intervention dynamics between individuals
    to a greater extent than observed in RQ3. Yet expect that the observations from the
    complete model reflect an 'average case'.

  _Synchronous updates:_
  - *A:* We use synchronous updates to simulate model dynamics.
  - *A:* This is due to both the nature of the dataset (long intervals between
    measurements, such that multiple beliefs can change state) and computational reasons
    (synchronous updates simplify the sampling process
    @nguyenInverseStatisticalProblems2017)
  - *B:* If beliefs update asynchronously (one at a time), this could affect the model
    dynamics

  _Confounding factors:_
  - Model calibrated to only two waves. Cannot separate endogenous from exogenous
    factors. Individual-level exogenous factors likely to be 'washed out'. Shared
    factors (e.g. election, weather events) could cause correlated changes between
    individuals.

  _Transferring natural endogenous dynamics to intervention:_
  - Related to confounding factors, we (assume that we) calibrate the models to data
    which is taken from a 'normal' environment.
  - Possible that dynamics are different when we intervene. Raises 'temperature'.
    Causes to think about beliefs/attitudes that would otherwise remain
    dormant---conflicting but unnoticed.

  _Data variables:_
  - We use what is available, rather than what is ideal

  _Sensitivity to unmeasured factors or incorrect structure:_
  - What happens when we cannot include (because we don't measure) an influential belief,
    i.e., a fork
  - What about colliders, or paths?
  - What happens when we falsely assume that there is/isn't a connection between two
    beliefs?

+ *T:* Open questions and future work
  - Individual belief systems
  - Representational capacity
  - Purposeful intervention study
  - Index variables could be derived intentionally, i.e., theoretically-motivated.

_Implications of findings. How can the results be applied practically? What
questions/directions do the findings suggest?_
- *T:* The symmetric assumption may often be valid, or at least a reasonable
  approximation (e.g., when asymmetry exists, but the difference in effects is
  small), yet asymmetric relations are likely to exist, and will not be captured
  by such an approach.


_Conclude with summary of the main points and reiteration of our contributions_
+ *A:* Contributions
  _Directed, causal belief system model_

  _Longitudinal data, captures dynamics as opposed to observed state_

  _RQ-focused contributions_


