#import "@local/drifting-cls-thesis:0.1.0": caption
#import "./dataset.typ": climate-beliefs-variable-table

#import "@preview/zero:0.6.1": num
#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

// #let full-details-footnote = footnote[
//   Full details regarding the validation, cleaning, and construction of the climate
//   beliefs dataset are provided in @sec:dataset.
// ]


#let ideology-eval-footnote = footnote[
  We do not evaluate the conservative and liberal models here, but
  return to this in @sec:heterogeneity-in-belief-systems-and-intervention-effects.
]
In this chapter, we calibrate both the symmetric and asymmetric KBS models to the
*climate beliefs dataset* described in @sec:dataset. We then evaluate the calibrated
models with respect to both structural accuracy ('how accurate are the
parameter estimates?') and predictive capacity ('how well do the models explain the
data?'). We also calibrate two additional asymmetric models to the conservative and
liberal subsets of the climate beliefs dataset for later use in
@sec:heterogeneity-in-belief-systems-and-intervention-effects.#ideology-eval-footnote

#figure(
  climate-beliefs-variable-table,
  gap: 1em,
  caption: caption(
    short: [Climate beliefs dataset variables (replicated)],
    long: [
      Variables included in the climate beliefs dataset. Index variables are constructed
      by taking the average of their constituent columns, after re-scaling to the
      interval $[-1, 1]$. Note that this table is identical to
      @tab:climate-beliefs-dataset-items displayed in @sec:dataset.
    ],
  ),
) <tab:calibration-climate-beliefs-dataset-items>

The climate beliefs dataset comprises eight beliefs relating to climate change
(@tab:calibration-climate-beliefs-dataset-items), extracted from the CCCV survey
(cf. #cite(<constantinoPersonalHardshipNarrows2022>, form: "prose")). The dataset
includes responses from 1693 repeating participants, measured during waves 3 and 4 of
the survey. A subset of the variables are indices constructed from sets of variables
in the CCCV survey. The marginal distributions for each variable are displayed in
@fig:calibration-marginal-distributions. @sec:dataset provides complete details on the
CCCV survey, including validation and cleaning, as well as the construction of the
climate beliefs dataset.


#figure(
  image("../results/figures/dataset/marginal_distributions.pdf"),
  caption: caption(
    short: [Climate beliefs dataset marginal distributions (replicated)],
    long: [
      Marginal distribution for each of the eight variables in the climate beliefs
      dataset (@tab:calibration-climate-beliefs-dataset-items). Note that this figure
      is identical to @fig:dataset-marginal-distributions displayed in @sec:dataset.
    ],
  ),
) <fig:calibration-marginal-distributions>


// #figure(
//   block(height: 65%, breakable: false)[
// #figure(
//   image("../results/figures/dataset/marginal_distributions.pdf"),
//   caption: caption(
//     short: [Climate beliefs dataset marginal distributions (replicated)],
//     long: [
//       Marginal distribution for each of the eight variables in the climate beliefs
//       dataset (@tab:calibration-climate-beliefs-dataset-items). Note that this figure
//       is identical to @fig:dataset-marginal-distributions displayed in @sec:dataset.
//     ],
//   ),
// ) <fig:calibration-marginal-distributions>
// #figure(
//   {
//     show table: set text(size: 10pt)
//     climate-beliefs-variable-table
//   },
//   gap: 1em,
//   caption: caption(
//     short: [Climate beliefs dataset variables (replicated)],
//     long: [
//       Variables included in the climate beliefs dataset. Index variables are constructed
//       by taking the average of their constituent columns, after re-scaling to the
//       interval $[-1, 1]$. Note that this table is identical to
//       @tab:climate-beliefs-dataset-items displayed in @sec:dataset.
//     ],
//   ),
// ) <tab:calibration-climate-beliefs-dataset-items>
//   ],
// )

// #figure(
//   block(height: 100%, breakable: false)[
//
//     #figure(
//       image("../results/figures/dataset/marginal_distributions.pdf"),
//       caption: caption(
//         short: [Climate beliefs dataset marginal distributions (replicated)],
//         long: [
//           Marginal distribution for each of the eight variables in the climate beliefs
//           dataset (@tab:calibration-climate-beliefs-dataset-items). Note that this figure
//           is identical to @fig:dataset-marginal-distributions displayed in @sec:dataset.
//         ],
//       ),
//     ) <fig:calibration-marginal-distributions>
//     #figure(
//       {
//         show table: set text(size: 10pt)
//         climate-beliefs-variable-table
//       },
//       gap: 1em,
//       caption: caption(
//         short: [Climate beliefs dataset variables (replicated)],
//         long: [
//           Variables included in the climate beliefs dataset. Index variables are constructed
//           by taking the average of their constituent columns, after re-scaling to the
//           interval $[-1, 1]$. Note that this table is identical to
//           @tab:climate-beliefs-dataset-items displayed in @sec:dataset.
//         ],
//       ),
//     ) <tab:calibration-climate-beliefs-dataset-items>
//
//   ],
// )




== Hyperparameters and calibration details <sec:climate-beliefs-calibration>

#let binarisation_sigma = json("../results/data/methods/binarisation_sigma.json").sigma

The maximum expected likelihood parameter estimation method described in the previous
chapter requires several hyperparameters to be specified, namely: the soft binarisation
scale term, $xi in RR_(>0)$, the regularisation smoothing and strength hyperparameters,
$epsilon in RR_(>0)$ and $lambda in RR_(>= 0)$, and the EBIC prior parameter
$gamma in RR_(>= 0)$. The values of these parameters are summarised in
@tab:methods-hyperparameter-values.

#let regularisation_strengths = json("../results/data/model_fit/optimised_regularisation.json")

#figure(
  {
    show table: set text(size: 9.25pt)
    table(
      columns: (20%, 20%, 20%, 20%),
      stroke: none,
      table.header[Parameter][Model type][Dataset][Value],
      table.hline(stroke: 0.5pt),
      [$lambda$],
      [Symmetric],
      [Climate beliefs],
      [#num(exponent: "sci")[#calc.round(regularisation_strengths.sym_ising.full, digits: 3)]],
      [],
      [Asymmetric],
      [Climate beliefs],
      [#num(exponent: "sci")[#calc.round(regularisation_strengths.ising.full, digits: 3)]],
      [],
      [Asymmetric],
      [Conservative],
      [#num(exponent: "sci")[#calc.round(regularisation_strengths.ising.conservative, digits: 3)]],
      [],
      [Asymmetric],
      [Liberal],
      [#num(exponent: "sci")[#calc.round(regularisation_strengths.ising.liberal, digits: 3)]],
      [$xi$], [All], [All], [#num(exponent: "sci")[#binarisation_sigma]],
      [$epsilon$], [All], [All], [$10^(-8)$],
      [$gamma$], [All], [All], [#num(exponent: "sci")[0.25]],
    )
  },
  caption: caption(
    short: [Hyperparameter values],
    long: [
      Values for regularisation strength ($lambda$) and smoothing ($epsilon$)
      hyperparameters. Regularisation strength model- and dataset-specific;
      _Conservative_ and _Liberal_ refer to subsets of the climate beliefs dataset
      comprising individuals with the specified ideology (@sec:dataset).
    ],
  ),
  placement: auto,
) <tab:methods-hyperparameter-values>

As mentioned in the previous chapter, the soft thresholding scale parameter,
$xi in RR_(> 0)$, is context-specific, and should be chosen to reflect the range of
measurement values which are considered 'near-neutral'. To choose this, we first
map the minimum and maximum (allowable) values for each variable to $-1$
and $+1$ respectively, such that these reflect the two spin states in the KBS model.
We then choose the soft thresholding function $b_xi$ with $xi = #binarisation_sigma$ such
that a 'weakly oppose' response to a 7-point Likert scale (i.e., value $-1\/3$ in the
normalised data) is mapped to $+1$ with probability 0.05. The resulting probability
distribution is displayed in @fig:calibration-likert-7-prob for a Likert-7
scale.@likert7-footnote-ref Under this choice of $b_xi$, values to either side of
'neutral' are considered mostly unambiguously positive or negative, with some flexibility
for 'weak' responses.

#figure(
  image("../results/figures/dataset/likert_7_binarisation_probability.pdf"),
  placement: auto,
  caption: caption(
    short: [Likert-7 binarisation distribution],
    long: [
      The probability of binarisation to $+1$ for each possible Likert-7 scale survey
      response,@likert7-footnote-ref using a soft thresholding function
      $b_xi$ as defined in @eqn:methods-dataset-binarisation-probability-map-to-1 with
      $xi approx #calc.round(binarisation_sigma, digits: 1)$.
    ],
  ),
) <fig:calibration-likert-7-prob>

#figure(
  image(
    "../results/figures/model_fit/regularisation_ebic.pdf",
  ),
  caption: caption(
    short: [Regularisation strength EBIC],
    long: [
      Effect of regularisation strength $lambda$ on Extended Bayesian Information
      Criterion for symmetric and asymmetric belief system models optimised to the
      climate beliefs dataset using
      @eqn:parameter-estimation-optimisation-problem. The vertical axis measures
      the difference in EBIC compared to the no-regularisation case ($lambda = 0$);
      smaller is better.

    ],
  ),
  placement: auto,
) <fig:calibration-regularisation-ebic>

We choose the regularisation hyperparameters in accordance with the discussion
in @subsec:parameter-estimation-regularisation (_Smooth L1 regularisation_).
Taking $tau = 10^(-2)$ as the threshold below which parameters are considered 'effectively
zero', we choose the regularisation smoothing hyperparameter to be $epsilon = 10^(-8)$,
such that $epsilon << tau^2$.
We set separate regularisation strengths for the symmetric and asymmetric models,
as well as the conservative and liberal asymmetric models, taking values
$lambda in [10^(-4), 1]$ which minimise the EBIC (@eqn:parameter-estimation-ebic). We
take #box[$gamma = 0.25$] when computing the EBIC, i.e., the smallest value tested by
#cite(<barberHighdimensionalIsingModel2015>, form: "prose").
@fig:calibration-regularisation-ebic shows the EBIC results for the
symmetric and asymmetric models calibrated to the complete climate beliefs dataset.

=== Implementation details

We solve the parameter estimation problem using the Scipy 1.17.1 implementation of the
quasi-Newton BFGS optimisation algorithm @virtanenSciPy10Fundamental2020
@nocedal2006numerical[p.~136], using the analytic jacobian comprising the partial
derivatives stated in @sec:parameter-estimation-method. We take $bold(theta) = bold(0)$ as the initial guess.
To ensure numerical stability irrespective of dataset size, we rescale the expected
log-likelihood contribution to the objective function and partial derivatives, dividing
by the number of observed observations (time intervals) in the dataset. For $M in NN$
individuals and $T in NN$ timesteps this amounts to a scale factor of $1/(M(T-1))$.



== Evaluating the calibrated model <sec:climate-beliefs-evaluation>

#let bootstrap-footnote = footnote[
  Each bootstrap sample comprises a set of survey participants, such that each sampled
  dataset either contains all, or none, of the observations from any given individual.
]
#let dataset-size-footnote = footnote[
  In the climate beliefs dataset we have $M = 1693$, $T=2$, and $N=8$
]

As recommended in #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose"),
we evaluate interaction parameter accuracy by examining the bootstrapped confidence
intervals around each parameter estimate.
We use bootstrapping to estimate the uncertainty in our parameter estimates due to
sampling error. Let $bold(D) in RR^(M times T times N)$ be the complete dataset, where
$M$, $T$, and $N$ denote the number of participants, observations, and spins
respectively#dataset-size-footnote. We construct 500 bootstrapped
datasets by sampling rows (participants) with replacement from $bold(D)$,
such that each bootstrapped dataset has the same shape as the complete dataset.

For each bootstrapped dataset $bold(D)_((i))$ we calibrate a model $cal(M)_((i))$
with $p in NN$ parameters:
$
  chevron bold(J)_((i)), bold(h)_((i)) chevron.r =: bold(theta)^*_((i)) in RR^p
$

//where $p in NN$ is the number of model parameters.

// TODO: Consider adding squares/indicators for elements which are zero

#figure(
  image("../results/figures/model_fit/interaction_heatmap.pdf"),
  caption: caption(
    short: [Calibrated model interaction matrix],
    long: [
      (_Top_) Baseline activations, $bold(h)$, and (_Bottom_) interaction effect matrices,
      $bold(J)$, for the symmetric and asymmetric belief
      system model variants, calibrated to the climate beliefs dataset.
      Error bars on the baseline activations display 95% confidence intervals, calculated
      over bootstrapped models ($n=500$) using the percentile method.
    ],
  ),
) <fig:calibration-interaction-matrices>

#let timescale-footnote = footnote[
  The timescale is determined by the interval between survey responses, i.e.,
  approximately six months (@sec:dataset).
]
#let symmetric-matrix-footnote = footnote[
  We only display the upper triangular elements of the symmetric model's interaction
  matrix, since the matrix is symmetric.
]
@fig:calibration-interaction-matrices shows the baseline activation parameters, $bold(h)$,
and interaction effect matrix, $bold(J)$,
for each model.#symmetric-matrix-footnote
The two models exhibit very similar baseline activations. The observed values indicate
that after accounting for interaction effects, (i) belief in the existence and
human-causes of climate change tend to be high, (ii) concern about extreme weather tends
to be low, and (iii) people mostly believe that other individuals are not particularly
worried about climate change. Regularisation has pushed some values (e.g., worry about
climate change) to zero, indicating that the dataset provides limited evidence that these
tend to be either positive or negative.

Both models feature a dominant diagonal, indicating that most variables are slow-moving
with respect to the modelled timescale#timescale-footnote (they are 'sticky'), which
is consistent with prior studies looking at the rate of change for beliefs
@greenPartisanStabilityTurbulent2024 @kileyMeasuringStabilityChange2020.
This is particularly true for `Politics`, and less so for `CC Others Worry` and
`CC Impact`.

Observe that all interaction effects are non-negative. This is by design; we have
re-coded the dataset variables such that this is the case. The fact that such
a re-coding exists implies that it is possible, within this belief system, to hold
a set of beliefs which are internally consistent, i.e., with no cognitive
dissonance. We provide a formal proof of this statement in @sec:appendix-derivations.



// #emph-block[
//   Stability of belief dynamics:
//   - @osborneDoesOpennessExperience2020
//   - @kileyMeasuringStabilityChange2020
//     - Most observed change in beliefs and behaviours is short-term (or measurement error)
//     - This is consistent with the cognitive dissonance theory
// ]


#figure(
  image("../results/figures/model_fit/edge_accuracy.pdf"),
  caption: caption(
    short: [Calibrated model edge accuracy],
    long: [
      Interaction effect parameter accuracy for symmetric and asymmetric models
      calibrated to the climate beliefs dataset (@sec:dataset). Mean parameter values
      are shown in increasing order. 95% confidence intervals are calculated using the
      percentile method over models calibrated to bootstrapped datasets (500 repeats).
    ],
  ),
) <fig:calibration-edge-accuracy>



// @fig:calibration-edge-accuracy shows the
// estimated interaction effects in increasing order for each model. We apply
// non-parametric bootstrapping (500 repeats), calibrating models to bootstrap datasets
// drawn with replacement from the original dataset#bootstrap-footnote. The confidence
// intervals are calculated using the percentile method (*CITE*) across the bootstrapped
// models' parameters.



@fig:calibration-edge-accuracy shows the estimated interaction effects in increasing
order for each model. The confidence intervals are calculated using the percentile
method (*CITE*) across the bootstrapped models' parameters.
Most parameters display small 95% confidence
intervals, indicating an accurate fit for both models. On average, the
symmetric model exhibits smaller confidence intervals than the asymmetric model
($0.065 < 0.085$), which is expected given the larger number of parameters in the
asymmetric model. In both models the self-interaction effect on `Politics` is
significantly larger than all other parameters, as evidenced by the non-overlapping
confidence intervals, supporting our earlier observation regarding
@fig:calibration-interaction-matrices. Moreover, the remaining self-interaction effects
are, in-general, significantly larger than the pairwise effects, with the exception of
`CC Impact` in the symmetric model, and `CC Impact`, `CC Worry Others` in the asymmetric
model.

#figure(
  image("../results/figures/model_fit/selection_probability.pdf"),
  caption: caption(
    short: [Model calibration edge selection probability],
    long: [
      Edge selection probability for models calibrated to bootstrapped datasets sampled
      with replacement from the climate beliefs dataset (500 repeats). Edges are
      'selected' if they survive regularisation with magnitude at least $0.01$.
    ],
  ),
) <fig:calibration-selection-probability>

Due to the use of regularisation in model calibration we must be careful not to draw
conclusions regarding edge _existence_ from this figure
@epskampEstimatingPsychologicalNetworks2018. Instead, we may consider the proportion
of bootstrapped models for which each edge is nonzero, shown in
@fig:calibration-selection-probability. Relations which are selected in all
models are not shown.
<edge-existence-warning>

All edges excluded from the model calibrated on the full
dataset (@fig:calibration-interaction-matrices) have low selection probability in the
bootstrapped datasets ($< 50%$). The relation
#box[$#raw("CC Real") -> #raw("Politics")$] is excluded from the complete asymmetric
model but included (bidirectionally) in the symmetric model. This is reflected in the
corresponding selection probabilities---this edge is selected in 100% of bootstrapped
symmetric models but only 23% of asymmetric models. Edges which _are_ selected in the
complete models generally have high selection probability. The notable exception in the
asymmetric case, #box[$#raw("CC Human") -> #raw("CC Impact")$], has a relatively small
effect size ($J_(i,j) approx 0.04$).

#let calibration-disclaimer = footnote[
  While we only show results for the asymmetric model here, the corresponding figures
  for the symmetric model are substantially similar, and all conclusions drawn regarding
  the asymmetric model apply also to the symmetric one.
]

We now evaluate the models' predictive capacities.#calibration-disclaimer First, we
examine the reliability of predicted transitions. @fig:calibration-transition-reliability
shows the average binarisation probability for each spin (i.e., the probability that the
corresponding observation in the second wave of the dataset is binarised to $+1$), binned
by transition probability. Bins with no observations are not shown (e.g., extreme values
for `CC Others Worry`).
The two measurements are strongly correlated for most variables. The higher variation
for `CC Real` and `CC Human` likely reflects the observed heavy skew in these variables
toward larger values (see @fig:calibration-marginal-distributions).
We observe no high/low probabilities for either `CC Others Worry` or `Weather Worry`,
on account of the limited influence of other spins on these variables, as seen in
the corresponding columns of @fig:calibration-interaction-matrices.

#figure(
  image("../results/figures/model_fit/transition_reliability.pdf"),
  caption: caption(
    short: [Calibrated model: transition reliability],
    long: [
      Reliability of transitions predicted by the model measured as the agreement
      between conditional probabilities under the model,
      $P_cal(M)(sigma_i^(t+1) = +1 | bold(sigma)^t)$, and expected proportion of $+1$ values after
      binarisation, calculated as the average transition probability for survey
      participants in a given conditional probability bin.
    ],
  ),
) <fig:calibration-transition-reliability>

Next, we compare the calibrated model against a null model with only
baseline activation ($h_i$) and self-influence ($J_(i,i)$) parameters. We measure the
relative entropy of the binarised data from the second wave of the dataset, with respect
to the probability distributions induced by each model. For each participant and spin,
we calculate the relative entropy as

$
  D(P || Q) := H_C (P, Q) - H(P)
$ <def:calibration-relative-entropy>

Where $P := P(b_xi (x_((m), i)^t))$ is the distribution over binarisations of
the observation in the first timestep, and $Q := P_cal(M) (sigma_((m), i)^(t+1) = +1)$ is the
distribution over subsequent states according to the model, marginalising over the
binarisation of the previous observation,

$
  Q := P_cal(M) (sigma_((m), i)^(t+1) = +1) = P_cal(M) (sigma_(i, (m))^(t+1) = +1 | b_xi (bold(x)_((m))^t)) dot P(b_xi (bold(x)_((m))^t))
$

The functions $H$ and $H_C$ denote the entropy and cross-entropy, respectively. The
entropy term quantifies the uncertainty in the binarisation process, and the
cross-entropy measures the 'expected surprise' when comparing predictions generated from
the model with the true binarised dataset. Formally, these are defined as follows:

$
  H(P) = - sum_(s in plus.minus 1) P(s) log_2 P(s)
$ <def:calibration-entropy>

$
  H_C (P,Q) = - sum_(s in plus.minus 1) P(s) log_2 Q(s)
$ <def:calibration-cross-entropy>

#let nonneg-rel-entropy = footnote[
  The relative entropy is strictly non-negative (*CITE*), so the binarisation entropy is
  a lower bound on the cross-entropy. This aligns with our intuition---the model cannot
  possibly be highly accurate when the binarisation process is very uncertain.
]
The relative entropy, $D(P || Q)$, is small when either (i) the model
accurately predicts the observed binarised value such that the cross-entropy is
low#nonneg-rel-entropy, or (ii) the binarisation process is very uncertain. It follows
that the relative entropy is high in cases where the model fails to accurately predict
the next state, despite the binarisation process being fairly deterministic.

#figure(
  image("../results/figures/model_fit/mean_relative_entropy.pdf"),
  caption: caption(
    short: [Calibrated model: mean relative entropy],
    long: [
      _(Left)_ Mean absolute relative entropy of the binarised dataset with respect to
      the calibrated model, for the full-connected and null (only self-interactions)
      models, using 10-fold cross-validation. Average calculated across spins and
      survey participants. _(Right)_ Mean difference in relative entropy. Confidence
      intervals display two standard deviations around the mean value.
    ],
  ),
) <fig:calibration-mean-relative-entropy>

To test for the effect of including cross-interactions, we fit the fully-connected model
and null models using 10-fold cross-validation. For each survey participant in the
validation (holdout) split we calculate the mean difference in relative entropy between
the fully-connected and null models. @fig:calibration-mean-relative-entropy shows the
mean relative entropy across individuals and spins on the null and fully-connected
models (left) and the mean _difference_ in relative entropy, averaged across survey
participants (right).


We find, in the right-hand panel, that the fully-connected model leads to significant
reduction in relative entropy averaged over survey participants ($p < 0.05$). While
statistically significant, the reduction is small. Since the measurement is averaged
across survey participants, this finding suggests that the self-interaction model is
sufficient to explain the behaviour for most participants---reflecting the
slow-moving dynamics of the observed belief system---but not all participants. We
anticipate that individuals whose belief states change more between observations are
better explained by the fully-connected model than the null model.

#figure(
  image("../results/figures/model_fit/kl_difference_dist.pdf"),
  caption: caption(
    short: [Null model relative entropy comparison],
    long: [
      Probability density function (left) and empirical cumulative distribution function
      (right) of the mean difference in relative entropy between the fully-connected and
      null (only self-interaction) models across survey participants. Negative values
      indicate lower relative entropy for the fully-connected model.
    ],
  ),
) <fig:relative-entropy-difference-dist>

@fig:relative-entropy-difference-dist explores this hypothesis, showing the empirical
probability density and cumulative distribution functions for the mean difference in
relative entropy. We see substantial variation between individuals;
the weak right tail and heavy left tail indicate cases which are better-explained by
the null and fully-connected models respectively.

We examine a sample of cases from each tail  in @fig:relative-entropy-difference-examples.
Each panel shows the change in binarisation probability between the survey waves for a sampled
survey participant. In the first three panels of the top row, we observe scenarios in
which most spins are initially aligned, and a subset of the remaining spins then update
to align with this set, i.e., where the system shifts toward a more consistent state.
Conversely, in the first, second, and fourth panels in the bottom row we see the opposite
scenario play out. That is, the system is initially well-aligned, yet some spins update
to a less consistent state.

The observed behaviour aligns with our expectations, namely
that the model with cross-interactions outperforms the null model in scenarios where
the belief system state updates toward a more consistent state (according to the theory
of cognitive dissonance), and is out-performed when participants' behaviour contradicts
this theory.



#figure(
  image("../results/figures/model_fit/kl_difference_examples.pdf"),
  caption: caption(
    short: [Null model relative entropy comparison examples],
    long: [
      Observed transitions for sample survey participants in the left (_Top_) and
      right (_Bottom_) tails  of @fig:relative-entropy-difference-dist. Circles indicate
      the probability that participants' observations in the first wave are binarised to
      $+1$. Arrows denote the change in the second wave, colour-coded according to
      the direction of change.
    ],
  ),
) <fig:relative-entropy-difference-examples>

