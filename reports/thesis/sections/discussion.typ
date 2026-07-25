== Plan

#let observation(x) = text(fill: red, x)

- Draw out the key findings from the above two results sections
- Make clear the implications for our theory of belief system dynamics
- Sensitivity of parameter estimation to unmeasured factors or incorrect structural
  assumptions. i.e., what happens when we cannot include an influential belief, or
  when we falsely assume that a relation does or does not exist?
- Representational limitations of our model:
  - Pairwise relations limit what can be modelled. Demonstrate using vaccination
    example --- we can't capture relations between pairs of attitudes, whose effect
    sign or magnitude depends on a third belief/attitude.
  - Polar ($-1, +1$) spin state assumption; some beliefs may be better treated as
    'on/off', where the 'off' state has _no_ effect on other spins, rather than a
    negative effect.
  - More generally, effect sizes may vary depending on specific spin states.

Key points to hit:
1. Remind the reader of the research questions

2. Summarise the main findings clearly and concisely. Highlight unexpected, important,
  or otherwise significant results

3. Interpret the results in relation to the research questions. What do they mean in
  the context of the study? How do they support/conflict with previous research?

4. Discuss limitations

5. Implications of findings. How can the results be applied practically? What
  questions/directions do the findings suggest?

6. Conclude with summary of the main points and reiteration of our contributions

*RQ1:* To what extent are causal relations _symmetric_ or _asymmetric_ in models
of climate change belief systems inferred from observational data?

*RQ2:* How do asymmetric and symmetric beliefs systems inferred from the climate
attitudes dataset differ with regards to intervention strategy and effectiveness?

*RQ3:* How do intervention outcome and effectiveness vary between individuals with
different initial conditions?

*RQ4:* How do (symmetric or asymmetric) belief systems relating to climate change
vary between conservative and liberal individuals?

Plan:
+ *A:* What have we learned?

  Remind reader of research questions:
  - *A:* Numerous recent studies on belief systems/models acknowledge(?) the likelihood
    of directed causal relations between beliefs and attitudes, possibly arising from
    various mechanisms (logical, influence, ...)
  - *A:* Whether we should consider relations as directed or undirected/bi-directional
    has implications for the expected dynamics of beliefs and attitudes. This
    affects both natural, endogenous dynamics, as well as how changes in a belief
    system propagate during interventions.
  - *B:* Based on reckons and theoretical reasoning. Limited empirical evidence on the
    existence of such directed relationships and their impact on belief and attitude
    dynamics.
  - *T:* We address these topics in the present thesis, through our first two research
    questions (state them)
  - *A:* These research questions are primarily concerned with population-level
    intervention effects on belief systems assumed to be shared between individuals.
  - *B:* While individuals likely share some aspects of belief system structure (due
    to shared social contexts, experiences), belief systems are inherently individual.
  - *B:* We also do not expect all individuals to respond the same way to
    interventions. (give example)
  - *T:* Our remaining research questions investigate individual heterogeneity in
    both intervention effects and belief systems (state them)
  - We now interpret the results presented in the previous two chapters with respect to
    each research question, and in the broader context of belief system dynamics.
    - Limitations
    - Implications of findings, how they should inform future work. Questions that
      are invited by the findings.
  Findings, per-research-question:#linebreak()
  *RQ1.* _Existence_
  - Positive result:
    - *A:* Positive result, in that we observe significant asymmetric relations,
      with two variables---political ideology and climate-related concerns---exhibiting
      asymmetric influence over the behaviour of several other variables.
    - *A:* In addition, we observe one asymmetric relation in which only one of the
      directed interaction effects is nonzero, such that there is a positive influence
      in one direction, with no feedback in the other.
    - *B:* However, not all pairs display this asymmetry. In some cases we find
      near-symmetric relationships #observation[(small confidence intervals close to zero)] or
      inconclusive results due to sampling error #observation[(large confidence intervals which
        contain zero)].
    - *T:* The symmetric assumption may often be valid, or at least a reasonable
      approximation (e.g., when asymmetry exists, but the difference in effects is
      small), yet asymmetric relations are likely to exist, and will not be captured
      by such an approach.
    - *A:* Variables with low total influence are less likely to be significantly
      asymmetric (due to large error bars)
    - #observation[*A:* The two observed asymmetric variables both have high total influence
        (connectivity, interaction weights)]
    - #observation[*B:* `CC Action` is similar to `Politics`, and has no asymmetric influence.
        - *T:* Asymmetry is not simply explained in terms of total influence.
      ]
  - Interpretation:
    - We interpret relations temporally, as one variable's influence
      on the future state of another (@sec:asymmetric-belief-systems). In an asymmetric
      relation, one variable has greater influence over the other's future
      state. Our findings suggest that in several instances political ideology and
      climate-related concerns drive the behaviour of other beliefs and attitudes,
      while being relatively insensitive, themselves, to the states of those beliefs
      and attitudes.
  - Comparison with other work:
    - Politics driving support for climate action, belief in CC, concerns about CC,
      while not being substantially influenced by these
    - Climate concern driving beliefs about climate impacts and causes, while not
      being influenced so much by them (e.g., psychological distance)
    - Other discussions on variables with varying 'influence', e.g., centrality.
  *RQ2:* _Impact_
  - Quickly summarise results:
    - *A:* We have demonstrated the existence of asymmetric relations.
    - *B:* Existence does not, on it's own, imply that the observed asymmetric relations
      are impactful.
    - *T:* In response to the second research question, we show that an asymmetric model
      calibrated to the climate beliefs dataset exhibits intervention behaviour which
      is different to the symmetric model, and that this can affect decisions regarding
      where to intervene.

  - Differences in propagation:
    - *A:* Interventions on politics in the asymmetric model outperformed those in the
      symmetric model almost universally.
    - *A:* Politics was considerably more influential than influentiable in the
      asymmetric model.
    - *B:* Whereas in the symmetric model the observed interaction effects
      were typically smaller, in order to capture both the large outbound and small
      inbound effects.
    - #observation[*A:* Comparison with `CC Impact`, which has similar outbound interaction effects
        in the asymmetric model, but has mostly symmetric relations. In the symmetric
        model `CC Impact` stays influential, but `Politics` is reduced. e.g., they have
        comparable outbound interactions with `CC Real`, `CC Human` in the asymmetric
        model, but in the symmetric model, the relations for `Politics` are approximately
        half the size of the corresponding relations for `CC Impact`.]
    - *T:* When true relations are asymmetric, assuming symmetry during calibration can
      lead to biased predictions regarding intervention effects, caused by
      underestimation in interaction parameter magnitude.
    - *T:* More generally, shows the dangers of model misspecification.

  - Impact of timescale:
    - *A:* For the measurement timescale used in the experiments we found
      that interventions propagated mostly through direct relations.
    - *B:* At longer timescales indirect paths also contribute.
    - *T:* If the true relation is asymmetric, we may still
      see intervention effects propagate significantly to a given target given sufficient
      time. If the symmetric model ascribes a bidirectional edge (as we see typically in
      @sec:calibration) then it will underestimate the time taken to spread, and potentially
      overestimate the overall effect (since the relation is direct).

  - Changes in rankings:
    - *A:* We see the impacts of the above in our experiments for interventions targeting
      climate action.
    - *B:* In the asymmetric model, `Politics` overtakes `CC Impact` as the
      second-most-effective intervention.
    - *T:* Assumptions regarding the symmetry or asymmetry of belief relations can change
      conclusions drawn regarding (absolute and relative) intervention effectiveness.

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

_Conclude with summary of the main points and reiteration of our contributions_
+ *A:* Contributions
  _Directed, causal belief system model_

  _Longitudinal data, captures dynamics as opposed to observed state_

  _RQ-focused contributions_
