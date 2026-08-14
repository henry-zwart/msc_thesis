#import "@local/drifting-cls-thesis:0.1.0": caption
#import "./introduction.typ": RQ1, RQ2
#import "./discussion.typ": internal-link
#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *
#show: show-theorion
// #import "@preview/algorithmic:1.0.7"
// #import algorithmic: algorithm-figure, style-algorithm
// #show: style-algorithm

// == Plan
//
// First results section, for experiments on the effect of asymmetry
//
// - *RF1:* Show asymmetric model fit
// - *RQ2.1:* Existence of asymmetric relations. Some, but not all, are significant.
//   Categorising relations into types: symmetric, asymmetric (both directions exist,
//   with different effect sizes), and unidirectional (only one direction exists).
// - *RQ3.1:* Differences between symmetric and asymmetric models, with regards to
//   intervention strategy (which intervention to do) and effectiveness (magnitude of
//   change compared to the no-intervention case).
//
// #line(length: 100%)


In this chapter we address the primary research questions, presented in
@sec:introduction:

#{
  set enum(numbering: "RQ1.", indent: 1em)
  block(width: 97%, [
    + #RQ1

    + #RQ2
  ])
}

To address RQ1., we first investigate the presence of (significantly) asymmetric
influence relations in the asymmetric KBS model calibrated to the climate beliefs
dataset in @sec:calibration. We then turn our attention to RQ2., where we examine
differences in the population-level intervention impacts observed for the symmetric
and asymmetric models, for both inbound and outbound interventions.

// Belief system models based on the Ising model, inspired by the cognitive dissonance
// theory of belief system dynamics, demonstrate impressive descriptive and explanatory
// capacities for various observed cognitive phenomena at both individual and collective
// scales. The currently prevalent view within the modelling community is that influence
// relations between beliefs are symmetric --- the pressure for $X$ to align
// with $Y$ is equal to that placed on $Y$ to align with $X$. The present chapter places
// this assumption on trial.
//
// We begin, in @subsec:asymmetry-results-existence, by calibrating the non-equilibrium
// belief system model to the climate beliefs dataset described in
// @subsec:dataset-dataset-construction. We demonstrate that belief system relations
// cannot be universally classified as symmetric, that some influence relations are
// recognisably asymmetric, and that relational asymmetry can vary in degree. In
// @subsec:asymmetry-results-impact, we then show that this finding is not
// inconsequential. Asymmetric models exhibit different dynamics in experiments on
// belief-level interventions, with the potential to affect conclusions drawn about
// the relative effectiveness of interventions.


== Existence of asymmetric relations <subsec:asymmetry-results-existence>

// To investigate the existence of asymmetric relations in the asymmetric model calibrated
// to the climate beliefs dataset, we examine the differences in directional interaction
// effects for the asymmetric models calibrated using bootstrapping in the previous
// section.
//
// For each bootstrapped model, $cal(M)_((i))$ with parameters
// $chevron bold(J)_((i)), bold(h)_((i)) chevron.r$, we obtain an estimate for
// the directional differential matrix:
//
// $
//   Delta_J^((i)) = bold(J)_((i)) - bold(J)^T_((i))
// $ <eqn:asymmetry-results-existence-directional-differential-matrix>
//
// Recall that the $k$'th row of $bold(J)_((i))$ (for #box[$k in {1, ..., N}$])
// describes the strength and direction of influence _from_ the
// spin $S_k$ _toward_ each other spin. Hence for $k, ell in {1, ..., N}$ we should
// interpret the element $Delta_(J)^((i))|_(k,ell)$ of the directional differential matrix
// as the excess influence of spin $S_k$ on $S_ell$. A positive value indicates that
// $S_k$ exerts greater influence on $S_ell$ than $S_ell$ does on $S_k$.

To assess the presence of asymmetric influence relations, we examine the estimated
sampling distribution of directional differentials (as defined in
@sec:methods-directional-differential), obtained from the set of asymmetric KBS models
calibrated to the bootstrapped climate beliefs dataset ($n=500$) in @sec:calibration.


#figure(
  image("../results/figures/model/directional_differentials/rank_no_structure.pdf"),
  caption: caption(
    short: [Interaction matrix directional differentials],
    long: [
      Directional differentials---the difference between directed interaction effects
      for a pair of spins---in reverse order of median value. Confidence intervals are
      calculated using the percentile method on models calibrated using bootstrapping
      ($n = 500$). Grey confidence intervals indicate absence of significant asymmetry.
      For cases with significant asymmetry, the colour indicates that one
      (#text(fill: orange)[*orange*]) or both (#text(fill: blue)[*blue*]) of the
      directed interacton effects are nonzero.
    ],
  ),
  placement: auto,
) <fig:asymmetry-results-existence-ranked-differentials>


@fig:asymmetry-results-existence-ranked-differentials shows the median directional
differential (defined in @sec:methods-directional-differential) for each pair of spins
in the asymmetric model, in decreasing order.
The 90% confidence intervals are calculated as the 5th and 95th percentiles across
bootstrap samples of the directional differential matrix
elements. For each pair of spins we display only the
directional differential for which the median is positive (since $Delta_J$ is
symmetric), and we exclude diagonal entries (which are zero by definition).

// NOTE:
// For a directional pairwise
// relation $A --> B$, if the corresponding confidence interval is consistently above
// zero this indicates that we observe asymmetry in most bootstrapped models. Conversely,
// if the corresponding confidence interval contains zero, then we cannot say (within the
// confidence bounds) that the two interaction effects are different. This interpretation
// applies even when regularisation is used in model calibration. Suppose, for instance,
// that the confidence intervals are consistently above zero because regularisation pushes
// the opposite relation, $B --> A$, to zero in most bootstrapped models. If the relation
// were symmetric, then $A --> B$ would also have been pushed to zero in a majority of
// models.



#figure(
  image("../results/figures/model/interaction_matrix/full_asym_ising_no_structure.pdf"),
  caption: caption(
    short: [Climate belief system interaction effect matrix],
    long: [
      Interaction effect matrix ($bold(J)$) for the asymmetric belief system model
      calibrated to the full climate beliefs dataset. Red borders indicate significant
      asymmetric pairs. The matrix is otherwise identical to the
      asymmetric interaction matrix in @fig:calibration-interaction-matrices.
    ],
  ),
) <fig:asymmetry-results-existence-interaction-matrix>

Most relations appear to be inconclusively asymmetric
(characterised by confidence intervals containing zero), with a small number of
asymmetric relations.
We can partition the asymmetric relations into two groups, according to whether
directional interactions exist in only one direction, indicated using orange confidence
intervals, or both directions with different strengths, indicated with blue confidence
intervals (see the interaction matrix in @fig:asymmetry-results-existence-interaction-matrix;
cell entries are identical to the matrix shown in
@fig:calibration-interaction-matrices of @sec:calibration). Pairs with two nonzero
interactions comprise $#raw("Politics") -> {#raw("CC Action"), #raw("CC Worry")}$ and
#box[$#raw("CC Worry") -> {#raw("CC Impact"), #raw("CC Human")}$]; the only pair with a
unidirectional interaction is $#raw("Politics") -> #raw("CC Real")$.

Comparing directional strength and degree centrality indices for `CC Worry` and
`Politics` across bootstrapped models, we find significant differences ($p < 0.05$) for
strength centrality on `CC Worry`, and both strength and degree centrality on `Politics`.
The difference in degree centrality for `Politics` arises from difference in selection
probability between outbound and inbound interactions with `CC Human` and `Weather Worry`
@fig:calibration-selection-probability. In particular, most bootstrapped models contain
only outbound interactions from `Politics` to these beliefs.
<significant-connectivity-diffs-politics>

Most directional differentials display substantial uncertainty (confidence
interval width $> 0.1$ on average), reflecting the parameter accuracy discussed in the
previous chapter (@fig:calibration-edge-accuracy). This results in several inconclusive
cases, where the median bootstrap-estimate directional differential is nonzero but
the confidence interval contains zero. In other cases we observe apparent symmetric
or near-symmetric relations (e.g., $#raw("Weather worry") --> #raw("CC Others Worry")$).

At the top of @fig:asymmetry-results-existence-ranked-differentials we see several
apparently skewed confidence intervals. These all correspond to cases where both
interactions are zero in the complete model
(@fig:asymmetry-results-existence-interaction-matrix), so the skews likely reflect
differences in edge selection probability between the two directional interactions
(@fig:calibration-selection-probability). For instance,
$#raw("CC Others Worry") --> #raw("CC Human")$ exhibits a larger apparent skew than
$#raw("CC Others Worry") --> #raw("CC Real")$, and this is reflected in observed
differences in selection probability.

Due to the large confidence intervals on most directional differentials we are less
likely to observe significant asymmetric relations between variables with small
interaction effects (since the possible difference in effects is smaller by definition).
Indeed, all observed significant cases of asymmetry have at least one interaction effect
with magnitude exceeding $0.1$. This raises the question of whether asymmetry is instead
simply explained by a high total interaction influence in combination with sampling
error. However, this is disputed by `CC Action`, which has several strong interaction
effects (its outbound effects are typically larger than those of `Politics`), yet does
not exhibit significant asymmetric influence over any other variables. On the contrary,
it is asymmetrically _influenced_ by `Politics`.




== Asymmetry affects intervention dynamics <subsec:asymmetry-results-impact>

// *TODO:*
// - Discuss how the observed effects of intervening on politics are _in spite of_
//   the high inertia on this variable. i.e., high inertia lowers the pre-intervention
//   $h_"eff"$, making it harder to intervene (higher barrier to surpass).
// - Comparatively, `CC Impact` is easier to intervene on (lower inertia), but ranks
//   lower for the asymmetric model. Since all outbound interactions are similar (or
//   better) than `Politics`, with the exception of `CC Action`, indicates that
//   the added difficulty of overcoming the barrier on politics is outweighed by
//   the greater influence on the target. Also perhaps due to the fact that the
//   inertia works in favour of the intervention once politics flips.
// - $checkmark$ *Overall goal of these experiments:* understand how belief system behaviour under
//   intervention differs between symmetric and asymmetric models calibrated to the
//   climate beliefs dataset. _Re-state the corresponding research question_.
//
// - $checkmark$ *In broad strokes, how do we test this?*
//   - Two-pronged approach.
//     + We first consider how intervention effects propagate from a single point of
//       intervention for varying intervention strengths. We measure: (i) effect of
//       intervention at each other spin, and (*maybe*) (ii) the effect of asymmetry at
//       each other spin.
//     + We then consider targeted interventions, in which we wish to change the state of
//       a particular belief or attitude, and want to know where is best to intervene. We
//       measure: (i) the effect of intervention for each possible intervention point, and
//       (ii) the expected ranking of interventions, scored by collective effect.
//
// - $checkmark$ *Specific experimental details:*
//   - We calibrate the models on the full (non-bootstrapped) dataset.
//   - We use intervention strengths $delta_h in {0.5, 1.5, 2.5}$ (weak, medium, strong).
//   - We take each survey participant's binarised measurements from Wave 4 as the initial
//     state of the model, then draw samples using parallel Glauber dynamics until $t=5$
//     (2.5 years in simulation time).
//   - Since both the binarisation and sampling procedures are stochastic we repeat this
//     500 times for each individual.
//
// - *First set of results:*
//   - Figures showing how intervention effects propagate from $X$ and $Y$.
//   - Effect of asymmetry figure(s)
//
// - *Second set of results:*
//   - Target variable: 'Climate Action'
//   - Effect of interventions
//   - Ranked interventions
//     - Explaining the occasional wider error bars in ranked interventions.

We now investigate differences in belief system behaviour under intervention for
symmetric and asymmetric models calibrated to the climate beliefs dataset. In this
section we are concerned with _collective_ impacts, e.g., the proportion of individuals
whose behaviour shifts due to an intervention. This reflects population-level
intervention scenarios, such as media campaigns or policies which affect most
individuals. We will return to _individual_ impacts of intervention in the following
chapter to understand who is most affected for interventions targeting attitudes toward
climate action.

We consider both outbound and inbound interventions (defined in
@sec:methods-inbound-outbound) to examine differences in how interventions
propagate in general between the symmetric and asymmetric models, and to investigate
how intervention strategy may differ between the two models. For outbound intervention
experiments we examine the effects of intervening on the following spins:

- `Weather worry`: Level of worry about future extreme weather events

- `CC Worry`: Level of worry about current and future climate change

- `Politics`: General political party identification and ideology

These choices are motivated by our findings in the previous section. Recall that
`CC Worry` and `Politics` both feature in the set of asymmetric relations, including
in the relation between these two variables. `Weather worry` does not appear in any
significant asymmetric relations, and---in comparison with the other variables---has
relatively small outgoing interaction effects.

For inbound intervention experiments we consider interventions seeking to influence
the `CC Action` variable, which captures individuals' general support for
pro-environmental action on climate change (e.g., specific policies, support for
increased regulation, and affirmative attitudes toward individual responsibility on
climate change).

// We define two quantities of interest: the *effect of intervention*, and *effect of
// asymmetry*. These are used, respectively, to assess an intervention's impact on a given
// spin's behaviour with reference to our expectations in a no-intervention scenario
// (@def:asymmetry-results-effect-of-intervention),
// and the difference in a spin's behaviour in the asymmetric model, compared to our
// expectations in the symmetric model (@def:asymmetry-results-effect-of-asymmetry).
// Note that the
// effect of asymmetry is not inherently concerned with intervention, but is a general
// measure for the difference between asymmetric and symmetry model dynamics.
//
// Both quantities compute a difference in effects between two distinct models: the
// intervention and null models for the effect of intervention, and the asymmetric
// and symmetric models for the effect of asymmetry. To ensure outcome
// comparability, differences are computed between models with identical random number
// generation contexts.
//
// #definition[Effect of Intervention][
//   Let $cal(M)$ be a non-equilibrium belief system model, and denote the result of
//   simulating the model for $t in NN$ timesteps with initial state $bold(s)_0$ as
//   $cal(M)^t (bold(s)_0)$.
//
//   For an intervention model $cal(M)_delta$ with an arbitrary point-of-intervention, we
//   define the *effect of intervention* for $cal(M)_delta$ as the change in outcome at
//   time $t in NN$, with respect to the null (no-intervention) model, $cal(M)_0$:
//
//   $
//     f_"int" (cal(M)_delta) = cal(M)_delta^t (bold(s)_0) - cal(M)_0^t (bold(s)_0)
//   $
// ] <def:asymmetry-results-effect-of-intervention>
//
// #definition[Effect of Asymmetry][
//   Let $cal(M)_"asym"$ be a calibrated asymmetric non-equilibrium belief system model
//   with an arbitrary intervention applied, and $cal(M)_"sym"$ be a corresponding
//   symmetric model calibrated to the same dataset.
//   We define the *effect of asymmetry* for $cal(M)_"asym"$ as the difference
//   in the effect of intervention with respect to the symmetric model:
//   $
//     f_"asym" (cal(M)_"asym") = f_"int" (cal(M)_"asym") - f_"int" (cal(M)_"sym")
//   $
// ] <def:asymmetry-results-effect-of-asymmetry>

#let timescale-footnote = footnote[
  Since the duration between waves in the climate beliefs dataset is approximately
  six months, in the calibrated model this corresponds to measuring the belief states
  roughly two and a half years after intervening.
]
In each of the intervention experiments described below, we use the models calibrated
to the full climate beliefs dataset in @sec:calibration. For a given experiment, we
initialise the associated model (symmetric/asymmetric; intervention/null) with the
binarised observations from the final wave of the climate beliefs dataset. We then
draw consecutive samples from the model using parallel glauber dynamics
(@subsec:methods-glauber-dynamics) until $t=5$, before measuring the state of the
target spin.#timescale-footnote To account for stochasticity in both the simulation
procedure and binarisation of individuals' initial states we perform 500 repeats for
each intervention.

#let see-intervention-strengths-sec-footnote = footnote[
  For detailed discussion on the selection and implications of intervention strengths
  see @sec:methods-modelling-interventions.
]


We first consider the impact of intervention strength on effect of intervention.
Since, as discussed in @sec:methods-intervention-strength, the change in behaviour at the
point-of-intervention is sensitive to intervention strength, it follows that intervention
strength may also impact the absolute or relative effects of intervention elsewhere in a
belief system. @fig:asymmetry-results-compare-strength compares the mean effect of
intervention on state (@def:asymmetry-results-effect-of-intervention) for each possible
target belief, across 'weak' and
'strong' interventions, $delta_h in {0.5, 2.5}$, for each of the outbound
points-of-intervention listed above.

// The
// strength of an intervention affects the degree to which the intervention changes the
// state of the point-of-intervention. However, this is also sensitive to the pre-existing
// influence on that spin#see-intervention-strengths-sec-footnote. Since the climate
// beliefs dataset comprises individuals with different states, it follows that
// intervention strength may impact not only the degree to which the behaviour of
// a target spin changes, but also the relative effects of different interventions.
//
// To understand the potential impacts of intervention strength, we compare the mean
// effect of intervention across individuals for intervention strengths
// $delta_h in {0.5, 2.5}$, for each of the outbound points of intervention listed above
// @fig:asymmetry-results-compare-strength. The choice of intervention strengths is
// motivated by our earlier analysis in
// @sec:methods-modelling-interventions, with the two strengths
// corresponding to 'weak' and 'strong' interventions respectively, as judged by their
// direct impact on the behaviour of the point-of-intervention.

#figure(
  image("../results/figures/asymmetry_results/intervention_strength_compare.pdf"),
  caption: caption(
    short: [Comparison of intervention effect across strengths],
    long: [
      Weak ($delta_h = 0.5$) and strong ($delta_h = 2.5$) interventions exhibit strong
      positively correlated effects of intervention, consistently across
      points-of-intervention (panels) and intervention targets (scatterplots). This
      finding holds for both symmetric and asymmetric models calibrated to the climate
      beliefs dataset.
    ],
  ),
) <fig:asymmetry-results-compare-strength>

We observe a strong linear relationship between intervention strength effects
for each point-of-intervention, indicating that---at the population-mean level---the
impact of intervention strength on effect is mostly one of scale, that applies similarly
to all target spins.
For the purposes of the following experiments it then suffices to consider
only a single intervention strength. As our current focus is on intervention
propagation and the effects felt at spins other than the point-of-intervention, we take
$delta_h = 2.5$, such that the interventions can be considered generally effective at
shifting the behaviour at the point-of-intervention.

#figure(
  image("../results/figures/asymmetry_results/outbound_effects_5.pdf"),
  caption: caption(
    short: [Outbound intervention effects],
    long: [
      Outbound effect of intervention (@def:asymmetry-results-effect-of-intervention)
      at each target spin for interventions targeting `Weather Worry`, `CC Worry`, and
      `Politics`, in symmetric and asymmetric belief system models calibrated to the
      climate beliefs dataset. Intervention strength: $delta_h = 2.5$. Confidence
      intervals display 1.96 standard deviations around the mean effect, measured
      across 500 repeated simulations.
    ],
  ),
) <fig:asymmetry-results-outbound-effect>

#figure(
  image("../results/figures/asymmetry_results/outbound_effect_of_asymmetry.pdf"),
  caption: caption(
    short: [Outbound effect of asymmetry],
    long: [
      Outbound effect of asymmetry (@def:asymmetry-results-effect-of-asymmetry) at each
      target spin for interventions on `Weather Worry`, `CC Worry`, and `Politics`, for
      models calibrated to the climate beliefs dataset. Intervention strength:
      $delta_h = 2.5$. Confidence intervals display 1.96 standard deviations around the
      mean effect of asymmetry ($n=500$).
    ],
  ),
) <fig:asymmetry-results-outbound-effect-of-asymmetry>


Figures @fig:asymmetry-results-outbound-effect[] and
@fig:asymmetry-results-outbound-effect-of-asymmetry[] show the mean effect of
intervention on state (@def:asymmetry-results-effect-of-intervention) and mean effect of
asymmetry (@def:asymmetry-results-effect-of-asymmetry), respectively, across individuals,
for the points-of-intervention listed above. The confidence intervals show two standard
deviations around the mean values, as calculated across repeats.

We observe, in @fig:asymmetry-results-outbound-effect, that different targets exhibit
different effects of intervention. The effect generally decreases with the magnitude of
the interaction from the point-of-intervention to the target spin; however, we also note
that all effects appear to be nonzero #box[($p < 0.05$)]. This suggests that for the measurement time
examined here, interventions act primarily through direct interactions with the target
spin, with some indirect influence propagating through intermediary interactions. For
instance, while `Weather Worry` has no direct influence on `CC Action`, we see nonzero
effect of intervention as a result of indirect paths, e.g., through `CC Worry`. We see
further evidence of this through comparison with measurements taken at time $t = 10$
(approximately five years in the calibrated model;
@fig:apdx-extra-results-outbound-effects-10 in @sec:appendix-extra-results), which showed
larger increases in the effect of intervention for variables with stronger incoming
interactions from non-intervention spins.

Note that @fig:asymmetry-results-outbound-effect does not provide an accurate reflection
of the difference in intervention effects between symmetric and asymmetric models, as
overlapping confidence intervals do not necessarily indicate insignificant differences.
The effects of asymmetry displayed in @fig:asymmetry-results-outbound-effect-of-asymmetry
provide a cleaner comparison of the two models. We observe no significant differences
between the two models for the `Weather Worry` scenario. For the remaining two scenarios,
however, we see several significant differences. In particular, all pairs of variables
with asymmetric direct relations
(#box[$#raw("Politics") -> {#raw("CC Action"), #raw("CC Worry"), #raw("CC Real")}$]
and $#raw("CC Worry") -> {#raw("CC Impact"), #raw("CC Human")}$) display significant
differences.

Comparing `Politics` and `CC Worry`, we observe that while `CC Worry` exhibits greater
effects of intervention (@fig:asymmetry-results-outbound-effect), `Politics` exhibits
larger mean effects of asymmetry (@fig:asymmetry-results-outbound-effect-of-asymmetry),
though the latter differences are not statistically significant. In both cases we see
that in the symmetric model the strengths of cross-interactions with other spins are
typically between the corresponding inbound and outbound asymmetric interaction
strengths. We contrast this with `CC Impact`, which has mostly symmetric relations.
While `CC Impact` and `Politics` have extremely similar outbound interaction strengths
in the asymmetric model, `CC Impact` is considerably more influential than `Politics`
in the symmetric model (i.e., it has higher average interaction effects).

#let different-connectivity-footnote = footnote[
  Recall that this difference in connectivity was found to be significant in the
  previous section #internal-link(<significant-connectivity-diffs-politics>).
]

Notice that the asymmetric model includes outbound (but not inbound) interactions from
`Politics` to `CC Human` and `Weather Worry`, while symmetric model omits interactions
with these beliefs entirely.#different-connectivity-footnote In contrast, `CC Worry` has
inbound and outbound interactions with all other spins in both models. This explain the
observed differences in the effects of intervention and asymmetry for `CC Worry` and
`Politics`: `CC Worry` has higher effects of intervention in
both models on account of its strong outbound interaction effects, which are also mostly
retained in the symmetric model, while the removal of interactions for `Politics` results
in lower influence and fewer (direct and indirect) paths in the symmetric model, compared
with the asymmetric model.


// Notice that while `CC Worry` exhibits greater intervention
// effects than `Politics` in @fig:asymmetry-results-outbound-effect, `Politics` exhibits
// larger mean effects of asymmetry in @fig:asymmetry-results-outbound-effect-of-asymmetry
// (though the differences are not statistically significant). Comparison of
// the interaction effect matrices (@fig:calibration-interaction-matrices) shows
// direct connectivity differences for `Politics` between the models.
// While the symmetric model excludes interactions with `CC Human`
// and `Weather Worry` entirely, the asymmetric model permits _outbound_ interactions with
// these spins, allowing interventions to propagate. By contrast,
// interventions on `Politics`  in the symmetric model are more reliant on indirect
// propagation.



// - Compare models across points of intervention, for a single target
//   - We see the impact of the asymmetric relations from `Politics` to `CC Worry` and
//     `CC Real` reflected in the intervention effects when compared with those of
//     `Weather worry`. The two points of intervention have similar direct influence on
//     `CC Worry` in the asymmetric model (reflected in the similarity in intervention
//     effects). However, in the symmetric model, the influence of `Politics` is diminished.
//     As such we see a significant difference in the effect of intervention for the
//     `Politics` point of intervention.



// NOTE:
// - Observations across panels:
//   - `Politics` includes significant effect on `CC Impact`, even though this pair is
//     not asymmetric in the model. May reflect the indirect asymmetric impact through
//     `CC Worry`.
//   - The effect of asymmetry is greater for `Politics` on `CC Worry` than in the other
//     direction. Recall that `Politics` has a strong self-interaction term, and
//     relatively small incoming interactions compared to `CC Worry`. So this finding is
//     expected---the effect of asymmetry on the intervention behaviour of any single spin
//     depends (in general) on the whole network, not only the point-of-intervention.


#let tiebreak-footnote = footnote[
  For instance, suppose we have five variables, ${A, B, C, D, E}$ with average
  collective effects ${0.2, 0.2, 0.6, 0.4, 0.1}$. Then the assigned ranking would
  be $op("Rank")(A,B,C,D,E) = [2,2,5,4,1]$. The variables $B$ and $C$ are both
  assigned the rank $2$. No variable is assigned rank $3$.
]
Turning our attention toward inbound intervention dynamics, we now consider the effects
of different interventions seeking to influence the state of `CC Action`.
The top panel of @fig:asymmetry-results-inbound-effect shows the mean effect of
intervention on `CC Action` for each possible point-of-intervention.
// Examining the mean effects allows us to gauge the expected absolute effect of each
// intervention, but is limited for purposes of comparing the relative effects of
// interventions.

#figure(
  image("../results/figures/asymmetry_results/inbound_effects.pdf"),
  caption: caption(
    short: [Inbound effect of intervention on `CC Action`],
    long: [
      Inbound mean effect of intervention (@def:asymmetry-results-effect-of-intervention)
      (_Top_) and mean rank (_Bottom_) for interventions targeting `CC Action`. Ranks are
      calculated per-repeat with respect to the average effect of intervention---higher
      values are assigned higher ranks. Confidence intervals display 1.96 standard
      deviations ($n=500$).
    ],
  ),
) <fig:asymmetry-results-inbound-effect>

#let rank-order-footnote = footnote[
  We take ranks as being ordered by index, such that rank 1 is the lowest and (in this
  model, with seven possible points-of-intervention) 7 is the highest.
]
The mean effect of intervention, calculated separately for each point-of-intervention,
erases information regarding the expected _relative_ effectiveness of different
interventions. To assess relative effectiveness, we therefore also estimate the
expected ranking over points-of-intervention (the bottom panel of
@fig:asymmetry-results-inbound-effect). For each repeat, we order the
points-of-intervention in increasing order of average collective effect of
intervention. Higher values are assigned higher ranks.#rank-order-footnote In the case
of a tie, we assign
all tied spins the minimum rank which would have been assigned to the group, had they
been distinct.#tiebreak-footnote

As with the outbound case, we find that the effect of intervention on `CC Action` varies
depending on where we intervene. Points-of-intervention (along the horizontal axes) are
sorted in decreasing order of mean values. We observe identical orderings between the
effect of intervention and ranking plots, showing good correspondence between the two
measures. We observe a clear inversion in this ordering for the asymmetric model, with
`Politics` exhibiting the second-highest rank, and (at least) second-highest mean effect
of intervention ($p < 0.05$).

Unlike with the outbound effects, the order of effect sizes does not align well with the
corresponding strengths of direct interactions strengths into the target variable. For
instance, `CC Real` and `CC Human` have the second- and third-strongest cross-interactions
into `CC Action` in the symmetric model, yet the fourth- and fifth-highest effect of
intervention. This likely reflects the low outbound connectivity of these variables
in comparison with `CC Impact` and `Politics`, despite the latter spins having relatively
lower direct on the target---additional evidence that indirect influence plays a critical
role in intervention dynamics.

Most confidence intervals around the mean ranks are small, indicating negligible (if any)
variation between simulations or possible binarisations of the dataset. However, we do
observe three larger, overlapping confidence intervals for each model. These arise due
to variation the mean effect of intervention causing occasional inversions of the ranking
order. Note that we only observe inversions between points-of-intervention which are
adjacent in the sorted order.

// - General observations:
// - Similar situation to the outbound effects. Heterogeneous effect of intervention
//   depending on where we intervene.
// - Identical ordering for effect and ranking, for both symmetric and asymmetric models.
// - Ordering of variables does not reflect the sorted order of incoming interaction
//   effect sizes (for either model).
// - Asymmetric model has different ordering in both effect and ranking. `Politics` is
//   (significantly) second-highest.
// - Model comparisons on effect of intervention:
//   - Most consecutive differences in effect for the symmetric model are not significant
//   - In asymmetric model, `CC Worry` and `Politics` are significantly higher than all
//     others.
// - Model comparisons in mean rank:
//   - Mean rank means generally reflect those of the mean effect.
//   - For both models, most confidence bars are small, indicating a clear ranking which is
//     not identifiable in the mean effect sizes.
//   - Some confidence intervals are larger. _which ones_


// Large confidence intervals in mean rankings:
// - To assess whether these are due to random variability in the mean effect of
//   intervention or whether the rankings are correlated (such that when one is low, the
//   other is also low), we examine the proportion of runs for which each variable is ranked
//   higher than the other.
// - Findings:
//   - `CC Real` is ranked higher than `CC Human` in more than 95% of simulations.
//   - Difference in rankings for remaining pairs are not statistically significant.



// NOTE:
// Figures:
// - Outbound intervention effects: For each repeat and possible _target_ spin, calculate
//   the difference between the observed state in the intervention model and that in the
//   null model (with no intervention). Calculate the average difference across
//   individuals and repeats as an estimate of the expected effect that intervening on $X$
//   has on each other spin $Y$. Shows differences between the symmetric and
//   asymmetric models with regards to how interventions propagate through the network.
//   - Remember to observe: heterogeneity in absolute effects on different spins,
//     differences between symmetric and asymmetric models.
// - Inbound intervention effects: For each repeat and possible _intervention_ spin, again
//   estimate the expected effect; however, this time the effect that intervening on each
//   $X$ has on a particular target spin $Y$. Shows how interventions targeting a
//   particular spin vary between the symmetric and asymmetric models, and between
//   intervention spins, in absolute terms. Compared to ranked plot, this shows actual
//   differences between interventions, while the ranking shows which interventions are
//   typically better.
// - Ranked interventions: For each repeat and possible intervention spin, calculate the
//   resulting average state of the target variable across individuals at $t=5$. Rank the
//   interventions for each repeat, such that interventions which yield a higher average
//   state receive a high rank. Interventions which yield the same average state are
//   assigned the same rank. Calculate the average rank across repeats as an estimate for
//   the expected ranking over interventions.
//   - Remember to observe:
//     - Differences in error bars between this and the inbound effect plot. For strong
//       interventions most error bars shrink to near-zero for ranking plot but stay large
//       in other plot. Means that either: (i) when the inbound effect from one spin
//       is lower for a particular binarisation it is also lower for the other spin, such
//       that the relative ordering of the effects is preserved. This would indicate that
//       the spins are susceptible in similar ways to variation due to binarisation. Or
//       (ii) that all other spins are just significantly more/less effective than this
//       one, such that the variation in effectiveness across binarisations is insufficient
//       to change its ranking. In some cases the error bars stay larger in the ranking
//       plot (symmetric: politics, CC real, CC human; asymmetric: CC real, CC human,
//       weather worry). This means that different binarisations cause these variables to
//       be ranked differently. Analogously, this could either result from: (i) variables
//       which respond differently to different binarisations (e.g., one variable increases
//       in effect, or is unaffected, while the other decreases), or (ii) variables whose
//       collective effects are sufficiently close together so as to be ranked differently
//       due to randomness.
// - (Maybe) something with effect of asymmetry? e.g., for each intervention spin, plot
//   the effect of asymmetry for varying intervention strengths.
// - (Maybe) explore the above idea in ranked interventions. Look at the variables with
//   large error bars in the strong/perfect ranked intervention plot. Can we determine
//   which of the two cases they are?
//   - We can use an independence test for this. If the error bars are large because for
//     specific binarisations the effects differ (type A) then the probability
//     distributions over the collective effects for the two variables should be
//     non-independent. If they are large because of random variation (type B), they
//     should be independent (maybe? or perhaps we can't say for certain in this case).
//     The samples we've drawn approximate a distribution over collective effect sizes.
//     We can: (1) simply estimate the probability that one collective effect is less than
//     the other under an independence assumption (e.g., by drawing random samples from
//     the approximate distribution) and compare this to the observed proportion of such
//     cases, or (2) do some sort of statistical test.


// #figure(
//   image("../results/figures/model/intervention_effects/05_cc_worry.pdf"),
//   caption: caption(
//     short: [Outbound intervention effect: CC Worry (weak)],
//     long: [Outbound intervention effect: CC Worry (weak)],
//   ),
// )



// #figure(
//   image("../results/figures/model/intervention_effects/05_politics.pdf"),
//   caption: caption(
//     short: [Outbound intervention effect: Politics (weak)],
//     long: [Outbound intervention effect: Politics (weak)],
//   ),
// )



// #figure(
//   image("../results/figures/asymmetry_results/effect_of_asymmetry_politics.pdf"),
//   caption: caption(
//     short: [Outbound effect of asymmetry: Politics],
//     long: [Outbound effect of asymmetry: Politics],
//   ),
// )

// #figure(
//   image("../results/figures/model/intervention_collective_effect/05_cc_action.pdf"),
//   caption: caption(
//     short: [Effect of weak interventions targeting climate policy support],
//     long: [
//       Expected effect of weak interventions ($delta h_i = 0.5$) targeting
//       individuals' support for climate-related policies. Effect is calculated as the
//       difference in state after 30 months, as observed in the intervention scenario,
//       compared to the no-intervention scenario.
//     ],
//   ),
// )
//
// #figure(
//   image("../results/figures/model/intervention_collective_effect/15_cc_action.pdf"),
//   caption: caption(
//     short: [
//       Effect of medium interventions targeting climate policy support
//     ],
//     long: [
//       Expected effect of medium interventions ($delta h_i = 1.5$) targeting
//       individuals' support for climate-related policies. Effect is calculated as the
//       difference in state after 30 months, as observed in the intervention scenario,
//       compared to the no-intervention scenario.
//     ],
//   ),
// )


// #figure(
//   image("../results/figures/model/intervention_collective_ranking/05_cc_action.pdf"),
//   caption: caption(
//     short: [Intervention ranking targeting climate policy support (weak intervention)],
//     long: [
//       Expected ranking for weak interventions ($delta h_i = 0.5$) targeting
//       individuals' support for climate-related policies. A higher rank indicates that
//       an intervention is more effective, as measured by the proportion of the
//       population who support climate policy after 30 months in simulation time.
//     ],
//   ),
// )
//
// #figure(
//   image("../results/figures/model/intervention_collective_ranking/15_cc_action.pdf"),
//   caption: caption(
//     short: [
//       Intervention ranking targeting climate policy support (medium intervention)
//     ],
//     long: [
//       Expected ranking for medium interventions ($delta h_i = 1.5$) targeting
//       individuals' support for climate-related policies. A higher rank indicates that
//       an intervention is more effective, as measured by the proportion of the
//       population who support climate policy after 30 months in simulation time.
//     ],
//   ),
// )



// While the above results demonstrate the existence of asymmetric influence relations
// in a belief system inferred from real data, it does not automatically follow that
// asymmetry is an important modelling consideration. If the symmetric model behaves
// identically in all scenarios of interest, then why should we bother with modelling
// asymmetric relations. Indeed, asymptotically, the asymmetric model uses twice as many
// parameters as the symmetric variation, increasing both computational and data burdens.
// In this section we compare the intervention dynamics of symmetric and asymmetric models
// calibrated on the climate beliefs dataset (@subsec:dataset-dataset-construction).
//
// We first calibrate the symmetric and asymmetric models using the complete
// (non-bootstrapped) dataset. This yields the belief system networks shown in *reference
// the below figure*.
//
//
//
// #let intervention-strength-footnote = footnote[
//   The chosen intervention strengths correspond, qualitatively, to _weak_, _moderate_,
//   and _strong_ interventions, respectively.
// ]
// #let timeframe-footnote = footnote[
//   Since the time between observations in the climate beliefs dataset is roughly six
//   months, this corresponds to approximately two and a half years in the calibrated
//   model's timescale.
// ]
//
// Taking the 'Climate Action' spin as the target of our intervention (i.e., the attitude
// we wish to affect), we simulate interventions of varying strengths#intervention-strength-footnote,
// $delta_h in {0.5, 1.5, 2.5}$, on each other spin separately using the method described
// in @subsec:asymmetric-belief-system-modelling-interventions. For each survey
// participant we then measure the effect of intervention at the target spin after $t=5$
// samples#timeframe-footnote (*reference definition in methods section*). For each such
// simulation we initialise the model using each participant's binarised observations from
// the final wave of the climate beliefs dataset. Since both the binarisation process and
// model dynamics are stochastic in nature, we repeat this measurement process 500 times
// for each participant.
//
//
// Intervention experiment: Intervening on $S_i$ with intervention strength $delta$.
// - Construct intervention model from calibrated model using method described in
//   @subsec:asymmetric-belief-system-modelling-interventions
// - For each survey participant in the climate beliefs dataset:
//   - Sample a binarisation of their measurements at the final timestep in the dataset
//   - Initialise the model state with this binarisation
//   - Draw $Q$ consecutive samples from the model using parallel glauber dynamics
//     (@eqn:asymmetric-belief-system-glauber-dynamics)
//   - At each timestep, record the state of the target spin
// - Repeat this process 300 times. For each repeat, sample a new binarisation.
// - We take $Q=5$, which reflects approximately 2.5 years in simulation time.
//
// Comparability across models and intervention strengths:
// - For a given repeat $r in {1, ..., 300}$, we use identical random number generation
//   contexts for both the symmetric and asymmetric model simulations, and for each
//   intervention strength.
// - This ensures that any difference in results is due to differences in either the
//   model or the intervention strength.
//



