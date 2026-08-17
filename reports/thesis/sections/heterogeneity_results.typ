#import "@local/drifting-cls-thesis:0.1.0": caption
#import "./discussion.typ": internal-link
#import "./introduction.typ": RQ3, RQ4

#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *
#show: show-theorion

In this chapter, we address the final two research questions presented in
@sec:introduction:

#{
  set enum(numbering: "RQ1.", indent: 1em, start: 3)
  block(width: 97%, [
    + #RQ3

    + #RQ4
  ])
}

// We first address RQ3., using the regression decision tree approach outlined in
// @sec:methods-effect-characterisation-function to qualitatively characterise the
// conditions under which we expect different interventions targeting attitudes on
// climate action to be effective. Then, to address RQ4., we compare
// structural features of the conservative and liberal asymmetric KBS models which were
// calibrated in @sec:calibration.



== Heterogeneity in intervention effects <sec:heterogeneity-results-intervention-effects>


#figure(
  image("../results/figures/model/intervention_effect_distribution/asym_25_cc_action.pdf"),
  caption: caption(
    short: [Individual effectiveness of inbound `CC Action` interventions],
    long: [
      The expected effect-of-intervention on state
      (@def:asymmetry-results-effect-of-intervention) for strong interventions
      #box[($delta_h = 2.5$)] targeting attitudes toward climate action exhibits
      substantial variation between survey participants.
    ],
  ),
) <fig:heterogeneity-results-cc-action-distribution>

While the previous chapter was primarily concerned with the _collective_ effects of
intervention, @fig:heterogeneity-results-cc-action-distribution shows that the expected
effects of interventions targeting attitudes toward climate action can vary
substantially among survey participants.


#figure(
  image("../results/figures/model/heterogeneous_effects/climate_policy_treedepth_3.pdf"),
  caption: caption(
    short: [Conditions for effective interventions],
    long: [
      Pre-intervention states, or 'personas', for which interventions on different beliefs
      (rows) are most effective for changing attitudes toward climate action in the
      asymmetric KBS model calibrated to the climate beliefs dataset. The *left* panel
      shows the distribution of effects of intervention on influence
      (@def:methods-effect-on-influence) for the `CC Action`
      belief at $t=5$ (approximately two and a half years) using a strong intervention
      ($delta_h = 2.5$), with respect to the no-intervention scenario. The *center* panel
      shows the personas corresponding to those individuals in the upper quartile of
      effects (shaded region in the left panel). Rows are distinct
      personas. Cells correspond to intervals in the initial state space dimensions,
      i.e., the different beliefs, with
      $L = [-1, 0]$ and $H = [0, +1]$. The *right* panel shows each persona's prevalence
      within the upper quartile ('High-effect') and below the upper quartile
      ('Low-effect') of effects.
      Personas are identified using depth-3
      regression decision trees fit with a mean-squared error objective and mean effect
      of intervention on influence as the response variable ($n=500$).
      $R^2 > 0.9$ for all decision trees, measured using 10-fold cross validation.
    ],
  ),
) <fig:heterogeneity-results-interventions-personas>

@fig:heterogeneity-results-interventions-personas shows the conditions (or personas)
for which interventions on different nodes in the belief system are expected to be
effective at targeting attitudes toward climate action. These are obtained using the
regression decision-tree approach to approximating the effect characterisation function,
as described in @sec:methods-effect-characterisation-function. We regard an
intervention as _effective_ for a given individual if the expected effect-of-intervention
on influence (@def:methods-effect-on-influence), estimated using the mean across $n=500$
simulations, is greater than or equal to the population upper quartile. Since the
threshold for an intervention to be considered effective is specific to each
point of intervention, we exclude points of intervention whose upper quartile is below
0.1 (`CC Human`, `CC Others Worry`, and `Weather Worry`), which exhibit no meaningfully
effective interventions.


// NOTE: Not mentioned, because we moved the paragraph to methods
//  This is observed, for instance, in the persona
// for interventions on `CC Worry`.


// NOTE: FOOTNOTE NOT INCLUDED
#let rounding-footnote = footnote[
  As our intention is to capture coarse patterns, we round the original `f64` values
  describing the interval boundaries extracted from the model to the nearest multiple
  of 0.5.
]


Note that the identified personas are not necessarily complete. For instance, suppose
that two variables are highly correlated and are 'Low' in the initial state
whenever the intervention effect is high. A complete characterisation includes both
variables; however, a decision tree is likely to include only one, since after splitting
on one variable, the other becomes redundant. This is especially true for shallow
decision trees.
<incomplete-descriptions>

// #let incomplete-descriptions-footnote = footnote[
//   Note that the personas are not necessarily complete. For instance, suppose that a pair
//   of variables are highly correlated in the initial state, and are Low whenever
//   the intervention effect is high. A complete characterisation includes both variables;
//   however, a decision tree is likely to include only one, since after splitting on one
//   of the two variables, the other is redundant. This is especially true for shallow
//   decision trees.
// ]

The expected difference in activation probabilities between the intervention and null
models exhibits a clear bimodal distribution across survey
participants in each scenario, with the higher mode contained within the upper quartile
(indicated by the darker-shaded regions). For each point of intervention, we observe a
small set of personas. In each case, these personas exhibit a high prevalence among
individuals with high intervention effects and a considerably lower prevalence among
other individuals, indicating that the identified personas accurately characterise the
conditions for effective
interventions.
While prevalence among high-effect individuals is generally high, it varies
across points of intervention. For instance, 20% of individuals predicted to be in
the high-effect category for interventions on `CC Worry` are not represented by the
identified persona. In comparison, for interventions on `Politics`, only 3% of
high-effect individuals are not represented.


// Recall that the effect-of-intervention measures the difference in effects between the
// intervention model and the corresponding null (no-intervention) model
// (@def:asymmetry-results-effect-of-intervention).
For the present analysis, it is
important to recognise that the intervention effect measured here does not, in general,
reflect a change in belief state relative to the initial state. It is
entirely possible for both intervention and null models to exhibit an increase, or
decrease, in the probability of the desired behaviour for the target belief. Hence, it is most
appropriate to view 'high-effect' interventions as those that achieve substantially
more desirable states than would be observed in the absence of intervention.

With this in mind, we now consider several specific features of interest in the
identified personas. Firstly, we observe that all personas require a low initial
state for `CC Worry`. This may result from this variable's low inertia
and high connectivity---in particular, its large outbound interaction effect
toward the target variable (see @fig:asymmetry-results-existence-interaction-matrix).
These factors result in `CC Worry` being relatively influential
and influen#emph[ceable], thereby making it an effective indirect pathway for
various interventions targeting `CC Action`. The significance of the requirement
that `CC Worry` be _low_ is evident when comparing the implications for the null
and intervention models. Due to `CC Worry`'s considerable outbound interactions,
an intervention which successfully changes this belief has increased potential
for propagation. In the null model, however, these interactions work against the
desired result---if `CC Worry` remains low, it exerts this influence on all other
beliefs.

Second, we observe that for each point of intervention (except `CC Real`, due to its
high correlation with `CC Human`, the implications of which we noted above
#internal-link(<incomplete-descriptions>)), a necessary condition for a high effect is
that the initial state at the point of intervention itself be low. That is, for an
intervention on $X$ to be successful, $X$ must not already be too high. This aligns with
our prior expectations regarding the varied effects of interventions, with respect to
the pre-intervention state (see @sec:methods-modelling-interventions).


// With the exception of `CC Real`, the personas for each point of intervention require that
// the initial state of the point of intervention be low. This aligns with our expectations
// per our earlier discussion on the varied effects of interventions on the behaviour of the
// point of intervention, with respect to the pre-intervention state
// (@subsec:asymmetric-belief-system-modelling-interventions).
#let negative-cc-human-footnote = footnote[
  The negative state for `CC Human` is an aggregation of the beliefs that climate change
  is a natural phenomenon and that it is not real (i.e., has no causes). See
  @sec:dataset for further details.
]

Finally, the `CC Real` scenario is unique in that it includes two prevalent personas.
The more prevalent persona corresponds to situations in which individuals are worried
about the current/future effects of climate change but do not believe it is
human-caused.#negative-cc-human-footnote In cases where an individual does
believe climate change is human-caused, this intervention may still be effective,
provided the individual does not already have a positive attitude toward climate action.


== Heterogeneity in belief-system structure <sec:heterogeneity-results-belief-system>


Until this point, we have considered belief systems as common to a population of
individuals. However, the relations between beliefs are inherently
individual. The existence, direction, and degree of relation between
two beliefs are dependent on an individual's own beliefs regarding their relatedness.


#let liberal-metadata = json("../results/data/model/ideology_fit_liberal_metadata.json")
#let conservative-metadata = json("../results/data/model/ideology_fit_conservative_metadata.json")
#let nlib = liberal-metadata.dataset_size
#let ncons = conservative-metadata.dataset_size

#let smaller-dataset-footnote = footnote[
  The total number of samples across the conservative and liberal subsets is
  smaller than the number of samples in the complete climate beliefs dataset, because we
  retain only data from participants whose ideology is consistent across survey waves.
]

Here, we investigate the extent to which belief systems may vary between groups of
individuals with different self-reported political ideologies. While this is still
far from representative of the differences between individuals
@brandtBetweenpersonMethodsProvide2022, it will allow us to examine general structural
differences between these subpopulations. We use the models calibrated, in @sec:calibration,
to the subsets of the climate beliefs dataset comprising individuals who consistently
(that is, in both waves) report their political ideology as being either 'conservative'
or 'very conservative' ($n=#ncons$) or 'liberal' or 'very liberal'
#box[($n=#nlib$)].#smaller-dataset-footnote We exclude the `Politics` variable from the
model, since the partitioning of the dataset already captures this.
// The hyperparameters used
// for regularisation strength and smoothing are listed in @tab:methods-hyperparameter-values.

Figures related to model calibration can be found in @sec:appendix-extra-results. The
estimated parameters exhibit considerably higher uncertainty than in the model
calibrated to the complete dataset due to the smaller sample sizes
(@fig:apdx-extra-results-ideology-accuracy). We find only one significant case of
asymmetry, on $#raw("CC Worry") --> #raw("CC Impact")$ in the conservative model
(@fig:apdx-extra-results-ideology-differentials), and only a minority of
significant differences ($p < 0.05$) between interaction strengths, all for edges which
are stronger in the conservative model (@fig:apdx-extra-results-ideology-edge-diffs).

#figure(
  image(
    "../results/figures/model_fit/ideology_interaction_heatmap.pdf",
  ),
  caption: caption(
    short: [Conservative and liberal belief systems],
    long: [
      (_Top_) Baseline activations, $bold(h)$, and (_Bottom_) interaction effect matrices
      ($bold(J)$) for asymmetric belief systems calibrated to the conservative ($n=507$)
      and liberal ($n=375$) subsets of the climate beliefs dataset in @sec:calibration.
    ],
  ),
) <fig:heterogeneity-results-ideology-interaction-matrices>

@fig:heterogeneity-results-ideology-interaction-matrices shows the baseline activation
parameters, $bold(h)$, and interaction effect matrices, $bold(J)$, for the conservative
and liberal subpopulations. The model calibrated to the liberal subpopulation exhibits
much higher uncertainty in the estimated baseline activations for belief in the existence
and human causes of climate change than the conservative subpopulation model; however,
in the liberal model, these are reliably positive. The conservative model shows negative
baseline activations for worry about climate change and extreme weather, beliefs about
others' worry, and beliefs about the general impacts of climate change. While these
are generally low-magnitude, in several cases their sizes are comparable with the
interaction effects influencing these variables (e.g., for `CC Worry Others` and
`Weather Worry`).

We observe several structural differences between the two models, as well as when
comparing them to the model calibrated on the full dataset
(@fig:asymmetry-results-existence-interaction-matrix). Notably, the model calibrated to
the liberal subpopulation has higher sparsity (the proportion of missing
cross-interactions) and a higher mean interaction effect for cross-interactions than
either the conservative or complete model (@tab:heterogeneity-results-belief-systems-properties).
Among the interactions present in the liberal model, 82% also occur in the conservative
model, compared with 54% of conservative interactions that are also in the liberal
model.

#{
  show table: set text(size: 10pt)
  [
    #figure(
      table(
        columns: (30%, 15%, 40%),
        align: (center, center, center),
        column-gutter: 1.5em,
        stroke: none,
        table.header[Data subset][Sparsity][Mean nonzero interaction effect],
        table.hline(stroke: 0.5pt),
        [Full], [0.30], [0.13],
        [Conservative], [0.38], [0.10],
        [Liberal], [0.60], [0.17],
      ),
      gap: 1.5em,
      caption: caption(
        short: [Comparison of ideological model properties],
        long: [
          Sparsity (proportion of missing cross-interactions) and mean
          interaction effect (over cross-interactions) for asymmetric models
          calibrated to the conservative and liberal subsets of the climate beliefs dataset,
          compared with the model calibrated on the complete dataset.
        ],
      ),
    ) <tab:heterogeneity-results-belief-systems-properties>
  ]
}

The conservative model displays broad (yet mostly weak) reinforcing interactions
between climate-related worry, beliefs about others' worry, and climate-impact
beliefs. This contrasts with the liberal model, in which only `CC Worry` and `CC Impact`
are non-trivially related among these beliefs. Moreover, we observe that
`CC Others Worry` and `Weather Worry` in fact have _no_ incoming cross-interactions
in the liberal model.

// NOTE: This may indicate that these variables are more stable in the liberal model,
// and therefore we don't observe any relations between them in the small dataset.

We also note differences in the interaction effects influencing `CC Action` between
the two models. While the liberal model expects attitudes toward climate action to
be substantially influenced by individuals' beliefs about the existence and nature
of climate change, these influences are absent or trivial in the conservative model.
Instead, we observe that worry about climate change (`CC Worry`) is the only
large cross-interaction toward `CC Action` in the conservative model.

Comparing now with the complete model (calibrated to the full dataset), we find that
interactions absent from the complete model are generally also absent from both smaller
models. The exceptions are
${#raw("CC Others Worry"), #raw("Weather Worry")} --> #raw("CC Action")$, which are
present in the conservative model, albeit with small effect sizes.

The converse does not hold: in several cases, edges are absent from the ideological
models but present in the complete model (e.g., $#raw("CC Human") --> #raw("CC Action")$
in the conservative model; #box[$#raw("CC Worry") --> #raw("Weather Worry")$] in the
liberal model). While
it is tempting to interpret these as differences in the ideology-specific belief
systems, this inference is not necessarily valid.
Given the smaller datasets used to calibrate these models---and the slow-moving dynamics
of the measured variables---these edges may be excluded because we do not
observe their effects. This is less likely for effects that are more substantial in
the complete model and thus better supported by the dataset.

// especially when the corresponding
// effect size in the complete model is small (e.g.,
// $#raw("CC Others Worry") --> #raw("Weather Worry")$ has effect size
// $J_(i,j) approx 0.06$ in the complete model, and is absent from the liberal model).




// In the complete model, the beliefs with the highest outbound connectivity are `CC Worry`
// and `CC Impact`. While `CC Worry` remains influential in both of the smaller models,
// `CC Impact` exhibits greater sparsity in the liberal model. We observe also that
// `CC Others Worry` and `Weather Worry` have no inbound interactions in the liberal model,
// i.e., they are not influenced by any other variables. This reflects the relatively
// small inbound interactions seen in the complete model.

// Cross-interactions which are not included in the complete model are generally also
// excluded from both the conservative and liberal models, with the exception of
// ${#raw("CC Others Worry"), #raw("Weather Worry")} --> #raw("CC Action")$ which are
// present in the conservative model. Conversely, each of smaller models excludes some
// interactions which _are_ present in the complete model (e.g.,
// $#raw("CC Human") --> #raw("CC Action")$ in the conservative model,
// $#raw("CC Worry") --> #raw("Weather Worry")$ in the liberal model). In a small number
// of cases, we observe interactions in the complete model which are missing from both
// of the smaller models ($#raw("CC Real") --> #raw("CC Impact")$,
// $#raw("CC Human") --> #raw("CC Worry")$, $#raw("CC Impact") --> #raw("CC Human")$).
// These all correspond to small interactions in the complete model ($|J_(i,j)| < 0.1$),
// suggesting they are only weakly supported by the complete dataset,
// and are likely excluded from the smaller models due to the reduced sample sizes.



// Observations:
// - Relative sparsity. Proportion of non-diagonal interactions which are zero.
//   Conservative: 38%, Liberal: 60%. Compared with the belief system fit to the full dataset: 30%.
// - Strength of interactions compared to one another, compared to the full model.
// - Comparison wrt the full model:
//   - Which variables are influential/have lots of interactions/are very sparse?
//   - Significant interactions which are weak in the full model?
// - Similarities:
//   - Diagonals
//   - Which (significant) non-diagonal interactions are shared?
//     - Very few, if any, bidirectional ones.
//     - One-directional:
//       - $"CC Worry" --> {"CC Real", "CC Impact","CC Action"}$
//       - $"CC Impact" --> {"CC Action"}$
//       - $"CC Action" --> {"CC Real", "CC Human", "CC Impact"}$
// - What are the most significant interactions in each model?
//   - Conservative:
//     - $"CC Worry" --> {"Weather Worry", "CC Impact", "CC Action"}$
//     - $"Weather Worry" --> {"CC Worry"}$
//     - $"CC Action" --> {"CC Worry"}$
//   - Liberal:
//     - $"CC Real" --> {"CC Worry", "CC Action"}$
//     - $"CC Human" --> {"CC Action"}$
//     - $"CC Worry" --> {"CC Impact"}$
//     - $"CC Impact" --> {"CC Worry"}$
//     - $"CC Action" --> {"CC Real", "CC Human", "CC Impact"}$
// - What interactions are symmetric/asymmetric in each model?
//   - Symmetric:
//     - Conservative:
//     - Liberal:
//   - Asymmetric:
//     - Conservative:
//     - Liberal:




// - *Overall goal of these experiments:* Understand how the belief system inferred from
//   the full climate beliefs dataset may differ from those inferred from subsets.
//
// - *In broad strokes, how do we test this?*
//   - We partition the climate beliefs dataset into self-reported conservative and liberal
//     individuals. We then calibrate separate asymmetric belief system models for each
//     group.
//   - We compare the observed belief system structures, and contrast with the belief
//     system calibrated to the full dataset.
//
// - *Specific experimental details:*
//   - Since we subset the data by political ideology, we remove the `Politics` variable
//     from the climate beliefs dataset. So the models are calibrated with only seven
//     beliefs, as opposed to eight.
//   - We apply regularisation to the model calibration, with regularisation strength
//     determined independently for each group (@tab:methods-hyperparameter-values).
//
// - *Results & figures:*
//   - Belief system networks


// #figure(
//   image(
//     "../results/figures/model/ideology_fit/network.pdf",
//   ),
//   caption: caption(
//     short: [_Conservative_ and _Liberal_ belief networks],
//     long: [
//       Prefixes: A (attitude), B (belief); node labels: CC (climate change), CCA (climate
//       change anthropogenic), CCW (climate change worry), CCWO (climate change worry
//       others), CCI (climate change impacts), CCP (climate change policies), WW (weather
//       worry).
//     ],
//   ),
// ) <fig:results-rq22-ideology-networks>


// - *RQ2.2:* Fit models to conservative and liberal subsets of the data; compare and
//   contrast. Compare with the model from the previous section, i.e., fit on the entire
//   dataset.
// - *RQ3.2:*
//   - Distribution of intervention effectiveness by individual.
//   - How does intervention ranking vary across individuals?
//   - Characterising how different initial states affect intervention success.
//   - Looking at how other theory-driven features affect success, e.g.:
//     - How receptive is the individual to the intervention?
//
//       The effective baseline ($h_i + sum_j J_(j i) s_j$) determines the probability
//       that $S_i^(t+1) = s$ for a state $s in plus.minus 1$. Evaluating this after
//       intervening provides a measurement for the success of the intervention on the
//       intervention belief itself.
//
//       We could look at how this changes with different intervention strengths (it
//       follows a logistic curve).
//
//     - How consistent is the individual's belief state, as measured by the total system
//       energy?
//
//     - How 'entrenched' is the target attitude?
//
//       Measure $h_k s_k + sum_(j) J_(j k) s_j s_k$, where $k$ is the target attitude.

// #line(length: 100%)
//
// - Intro section blah blah blah
//
// - Differences in effects of intervention
//
// - Differences in belief systems: conservative vs. liberal
//
// == RQ2.2: differences between belief systems for different (types of) individuals

// Do for both symmetric and asymmetric. Use L1 regularisation to shrink parameters. Use
// bootstrapping to estimate uncertainty around inferred parameters. Characterise relations
// as symmetric, bidirectional, unidirectional.
//
// Consider network features, model features (correlation length, etc.)




// == RQ3.2: Intervention strategy and effectiveness across individuals
//
// Examine distributions of expected outcome effects (per individual) for different
// interventions. Characterise the individuals found at different parts of the
// distribution (personas, average magnetisation).
//
//
// === Intervention ranking
//
// For each individual, compute ranking over the expected effects of each possible
// intervention.
//
//
// === Who is intervention effective for?
//
