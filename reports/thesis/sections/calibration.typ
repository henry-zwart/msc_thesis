#import "@local/drifting-cls-thesis:0.1.0": caption
#import "./dataset.typ": climate-beliefs-variable-table

#import "@preview/theorion:0.6.0": *
#import cosmos.simple: *
//#import cosmos.rainbow: *
// #import cosmos.clouds: *
#show: show-theorion

// #let full-details-footnote = footnote[
//   Full details regarding the validation, cleaning, and construction of the climate
//   beliefs dataset are provided in @sec:dataset.
// ]

// *TODO:*
// - Discuss differences in baseline activations.
//   - Exogenous influences, and unmeasured beliefs

The *climate beliefs dataset*, detailed in @sec:dataset, comprises eight beliefs
relating to climate change (@tab:calibration-climate-beliefs-dataset-items),
extracted from the CCCV survey
(cf. #cite(<constantinoPersonalHardshipNarrows2022>, form: "prose"). The dataset
includes responses from 1693 repeating participants, measured during waves 3 and 4 of
the survey. We map the maximum and minimum (possible) values for each variable to $+1$
and $-1$ respectively, such that these reflect the two spin states in the KBS model.




#figure(
  block(height: 100%, breakable: false)[

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
    #figure(
      {
        show table: set text(size: 10pt)
        climate-beliefs-variable-table
      },
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

  ],
)


Using the
parameter estimation method outlined in the previous chapter, we calibrate the
symmetric and asymmetric belief system models to the climate beliefs dataset (see
@sec:dataset). We will evaluate the calibrated models on both structural accuracy
('how accurate are the parameter estimates?') and predictive capacity ('how well do
the models explain the data?').

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
with parameters
$
  chevron bold(J)_((i)), bold(h)_((i)) chevron.r =: bold(theta)^*_((i)) in RR^p
$

where $p in NN$ is the number of model parameters.

// TODO: Consider adding squares/indicators for elements which are zero

#figure(
  image("../results/figures/model_fit/interaction_heatmap.pdf"),
  caption: caption(
    short: [Calibrated model interaction matrix],
    long: [
      (_Top_) Baseline activations, $bold(h)$, and (_Bottom_) interaction effect matrices,
      $bold(J)$, for the symmetric and asymmetric belief
      system model variants, calibrated to the climate beliefs dataset (@sec:dataset)
      using the parameter estimation method in @subsec:methods-parameter-estimation.
      Error bars on the baseline activations display 95% confidence intervals, calculated
      over bootstrapped models ($n=500$) using the percentile method.
    ],
  ),
) <fig:calibration-interaction-matrices>

#let timescale-footnote = footnote[
  The models' timescales are set by the duration between survey responses, in this case
  approximately six months (@sec:dataset).
]
@fig:calibration-interaction-matrices shows the baseline activation parameters, $bold(h)$,
and interaction effect matrix, $bold(J)$,
for each model. Note that we only display the upper triangular elements of the symmetric
model's interaction matrix, since the matrix is symmetric.
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

We now evaluate the models' predictive capacities#calibration-disclaimer. First, we
examine the reliability of predicted transitions. @fig:calibration-transition-reliability
shows the average binarisation probability for each spin (i.e., the probability that the
corresponding observation in the second wave of the dataset is binarised to $+1$), binned
by transition probability. Bins with no observations are not shown (e.g., extreme values
for `CC Others Worry`).

#figure(
  image("../results/figures/model_fit/transition_reliability.pdf"),
  caption: caption(
    short: [Calibrated model: transition reliability],
    long: [
      Reliability of transitions predicted by the model measured as the agreement
      between conditional probabilities under the model,
      $P(S_i^(t+1) = +1 | bold(S)^t)$, and expected proportion of $+1$ values after
      binarisation, calculated as the average transition probability for survey
      participants in a given conditional probability bin.
    ],
  ),
) <fig:calibration-transition-reliability>

The two measurements are strongly correlated for most variables. The higher variation
for `CC Real` and `CC Human` likely reflects the observed heavy skew in these variables
toward larger values (see @fig:dataset-marginal-distributions in @sec:dataset).
We observe no high/low probabilities for either `CC Others Worry` or `Weather Worry`,
on account of the limited influence of other spins on these variables, as seen in
the corresponding columns of @fig:calibration-interaction-matrices.

Next, we compare the calibrated model against a null model, in which we permit only
baseline activation ($h_i$) and self-influence ($J_(i,i)$) parameters. We measure the
relative entropy of the binarised data from the second wave of the dataset, with respect
to the probability distributions induced by each model. For each participant and spin,
we calculate the relative entropy as

$
  D(P || Q) := H_C (P, Q) - H(P)
$ <def:calibration-relative-entropy>

Where $P := P(op("Bin")(X_(i, (m))^(t+1)))$ is the distribution over binarisations of
the observation in the first timestep, and $Q := P_cal(M) (S_(i, (m))^(t+1))$ is the
distribution over subsequent states according to the model, marginalising over
binarisation of the previous observation,

$
  Q := P_cal(M) (S_(i, (m))^(t+1)) = P_cal(M) (S_(i, (m))^(t+1) | op("Bin")(X_(i, (m))^t)) dot P(op("Bin")(X_(i, (m))^t))
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

@fig:relative-entropy-difference-dist explores this hypothesis, displaying the empirical
probability density and cumulative distribution functions for the mean difference in
relative entropy, across individuals. Indeed, we see substantial variation in effects.
The weak right tail and heavy left tail indicate cases which are better-explained by
the null and fully-connected models respectively.

We examine a sample of cases from either tail (top panel: left tail, bottom panel:
right tail) in @fig:relative-entropy-difference-examples. Each panel displays the
change in binarisation probability between the two observed survey waves for a sampled
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
      Observed transitions for sample survey participants in the left tail (top row) and
      right tail (bottom row) of @fig:relative-entropy-difference-dist. Circles indicate
      the probability that participants' observations in the first wave are binarised to
      $+1$. Arrows denote the change in the second wave, colour-coded according to
      whether the change is toward the positive (blue) or negative (orange) state.
    ],
  ),
) <fig:relative-entropy-difference-examples>




// #figure(
//   image("../results/figures/model/network.pdf"),
//   caption: caption(
//     short: [Calibrated belief system networks],
//     long: [*TODO*],
//   ),
// ) <fig:calibration-networks>

// *(Briefly!) Discuss the heatmap*:
// - Large self-interaction effects.
// - Be careful not to tread on topics that should be in results.


// // To evaluate the calibrated models, we consider both structural accuracy as well as
// // predictive capacity on unseen data. As recommended in
// // #cite(<epskampEstimatingPsychologicalNetworks2018>, form: "prose"), we investigate
// // edge weight accuracy by examining the bootstrapped confidence intervals around each
// // parameter estimate (@fig:calibration-edge-accuracy). Due to the use of
// // regularisation in model calibration we must be careful not to draw conclusions regarding
// // edge _existence_ from this figure (Ibid.). For this reason we intentionally omit edge
// // labels from this figure.
//
// We observe small 95% confidence intervals for most parameters in both the symmetric
// and asymmetric models, indicating an accurate fit for both models. On average, the
// symmetric model exhibits smaller confidence intervals than the asymmetric model
// ($0.065 < 0.085$), which is expected given the larger number of parameters in the
// latter model. In both models the self-interaction effect on `Politics` is significantly
// larger than all other parameters, as evidenced by the non-overlapping confidence
// intervals. Moreover, we see that the remaining self-interaction effects are, in-general,
// significantly larger than the pairwise effects, with the exception of `CC Impact` in the
// symmetric model, and `CC Impact`, `CC Worry Others` in the asymmetric model.



// We evaluate the models' predictive capacity with respect to the *relative entropy* of
// the binarised data with respect to the calibrated model#calibration-disclaimer. Before
// proceeding, let us take a moment to define the relative entropy, and understand its
// expected behaviour. We first define a related quantity --- the *cross-entropy*, $H_C$
// --- which measures the expected surprise when drawing samples from a distribution $P$,
// but anticipating the distribution $Q$:
//
// $
//   H_C (P, Q) := -sum_(x in cal(X)) P_X (x) log_2 Q_X (x)
// $ <eqn:calibration-cross-entropy>
//
// The relative entropy is then defined as:
//
// $
//   D(P || Q) := H_C (P, Q) - H(P)
// $ <eqn:calibration-relative-entropy>
//
// and can be can be considered the _excess_ surprise in such a situation as described
// for the cross entropy, compared to the baseline entropy of the true distribution $P$.
//
// In our context, for a spin $i in {1, ..., N}$ and survey participant $m$, the _true_
// distribution is the distribution over possible binarisations of the corresponding
// observation in the dataset,
// $
//   P := P[op("Bin")(X_(i,(m))^(t+1))]
// $
// and the _proxy_ distribution is
// that implied by the model, conditional on the previous observed configuration,
// $
//   Q := P[S_i^(t+1) | bold(S)^t = bold(s)]
// $
//
// The relative entropy is small when either:
// - The cross-entropy is small, such that the model predicts the transition accurately, or
//
// - The random variable $op("Bin")(X_(i, (m))^(t+1))$ has high entropy.
//
// This second property is particularly desirable---it means that we don't unduly
// penalise poor model predictions on states which are highly ambiguous due to the
// soft binarisation.
//
// Let us now proceed with evaluating the calibrated model. First, we investigate the
// degree to the calibrated model's prediction capacity depends on cross-interaction
// terms ($J_(i,j)$ for $i != j$), through comparison with the null model which allows
// only baseline activation ($bold(h)$) and self-interaction terms ($J_(i,i)$). Using
// 5-fold cross-validation, we estimate the mean difference in relative entropy between
// the fully-connected and null models, on both calibration and validation
// cross-validation splits. The null hypothesis---that the mean difference in relative
// entropy is zero---is rejected ($p < 0.05$), with the cross-interaction model exhibiting
// lower relative entropy than the null model on average in both calibration and validation
// datasets.


// @fig:calibration-mean-relative-entropy shows the mean relative entropy for each model
// and dataset category. This is distinct from the above experiment, which measures the
// mean difference. The similarity in mean relative entropy between the null and
// fully-connected models reflects the dominance of self-interaction terms (*REFERENCE
// HEATMAP FIGURE*). Note that since the relative entropy
// responds non-linearly to changes in the model distribution, the magnitude of the
// observed differences should be interpreted with caution. Furthermore, there is minimal
// difference between the estimated relative entropy on the calibration and validation
// splits, indicating that the model is not overfit.
//
// We may also consider how the relative entropy per spin varies between individuals
// (@fig:calibration-cv-relative-entropy) for the calibrated fully-connected model.
// The distribution is unimodel, peaking slightly below the mean relative entropy, and has
// a long right tail, indicating the presence of participants whose behaviour is not
// well-explained by the model. @fig:calibration-highest-relative-entropy examines the
// eight participants with the highest mean relative entropy within the validation splits,
// showing how the binarisation probability for each variable changes between the first and
// second observations.

// #figure(
//   image("../results/figures/model_fit/cross_validation_relative_entropy.pdf"),
//   caption: caption(
//     short: [Cross-validated relative entropy on calibration model],
//     long: [*TODO*],
//   ),
// ) <fig:calibration-cv-relative-entropy>
//
// #figure(
//   image("../results/figures/model_fit/high_relative_entropy.pdf"),
//   caption: caption(
//     short: [Participants with high relative entropy],
//     long: [*TODO*],
//   ),
// ) <fig:calibration-highest-relative-entropy>


// *Note:* We _could_ compare BIC/EBIC between the symmetric and asymmetric models,
// but we don't. We're not doing model selection. Our goal is to have calibrated models
// for each.


