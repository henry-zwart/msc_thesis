== Plan

- Motivate the problem
- Contributions
- Research questions (thinking these are perhaps better left to later, in favour of
  contributions here)

== Research questions

*Theoretical contributions:*
- *RF1.1:* Extending the causal attitude network model of belief systems to: (i)
  support asymmetric causal effects between beliefs and attitudes, and (ii) model
  intervention dynamics.

*Inferring belief systems:*
- *RQ2.1:* To what extent are causal relations _symmetric_ or _asymmetric_ in models
  of climate change belief systems inferred from observational data?

- *RQ2.2:* How do (symmetric or asymmetric) belief systems relating to climate change
  vary between conservative and liberal individuals?

*Intervention dynamics:*
- *RQ3.1:* How do asymmetric and symmetric beliefs systems inferred from the climate
  attitudes dataset differ with regards to intervention strategy and effectiveness?

- *RQ3.2:* How do intervention outcome and effectiveness vary between individuals with
  different initial conditions, or between conservative and liberal individuals?


== Contributions
+ We present a mathematical model for belief system dynamics that does not assume
  equilibrium and does not assume symmetric influence between cognitive aspects
  (@sec:asymmetric-belief-systems)
+ We describe a novel parameter estimation method for fitting binary Ising models to
  continuous data (@sec:methods).
+ We calibrate said model to data from a recent longitudinal survey including items on
  beliefs and attitudes regarding climate change
  (@sec:results-asymmetry-in-belief-systems).
+ We demonstrate, by way of the calibrated model, the existence of asymmetric influence
  relations between beliefs and attitudes. Furthermore we show that influence relations
  are not _necessarily_ asymmetric, may vary in the degree of asymmetry, and can be
  unidirectional (@sec:results-asymmetry-in-belief-systems).
+ We demonstrate that the decision to represent asymmetric relations in belief system
  models can change intervention dynamics, and therefore conclusions one draws
  regarding intervention effect and effectiveness
  (@sec:results-asymmetry-in-belief-systems).
+ We then show that belief systems may vary significantly between individuals, by
  fitting the proposed model to subsets of the climate attitudes dataset comprising
  conservative and liberal individuals
  (@sec:heterogeneity-in-belief-systems-and-intervention-effects).
+ Finally, we show that reasoning about the effects of interventions on _individuals_
  is, in general, non-trivial. How an individual responds to an intervention typically
  depends on their prior belief system state, including beliefs and attitudes other
  than the target and goal of intervention
  (@sec:heterogeneity-in-belief-systems-and-intervention-effects).


// == Proposed thesis structure
//
// - *Terminology and notation*
//
// - *Introduction:*
//   - Motivate the problem,
//   - Outline contributions (research questions)
//
// - *Asymmetric belief system:*
//   - Define and illustrate the model
//   - Model simulation with Glauber dynamics
//   - How do we model interventions?
//
// - *Methods:*
//   - Counterfactual intervention experiments --- comparing against the no-intervention
//     scenario, measuring differences in effects.
//   - Parameter estimation:
//     - Maximum likelihood estimation
//       - Conditional on a specific binarisation
//       - Marginalising over binarisation process
//     - Regularisation
//
// - *Existence and impacts of asymmetry in belief systems*
//   - Results for:
//     - *RF1:* Show asymmetric model fit
//     - *RQ2.1:* Existence of asymmetric relations. Some, but not all, are significant.
//       Categorising relations into types: symmetric, asymmetric (both directions exist,
//       with different effect sizes), and unidirectional (only one direction exists).
//     - *RQ3.1:* Differences between symmetric and asymmetric models, with regards to
//       intervention strategy (which intervention to do) and effectiveness (magnitude of
//       change compared to the no-intervention case).
//
// - *Individual heterogeneity in belief systems and intervention dynamics*
//   - Second results section
//   - *RQ2.2:* Fit models to conservative and liberal subsets of the data; compare and
//     contrast. Compare with the model from the previous section, i.e., fit on the entire
//     dataset.
//   - *RQ3.2:*
//     - Distribution of intervention effectiveness by individual.
//     - How does intervention ranking vary across individuals?
//     - Characterising how different initial states affect intervention success.
//     - Looking at how other theory-driven features affect success, e.g.:
//       - How receptive is the individual to the intervention?
//
//         The effective baseline ($h_i + sum_j J_(j i) s_j$) determines the probability
//         that $S_i^(t+1) = s$ for a state $s in plus.minus 1$. Evaluating this after
//         intervening provides a measurement for the success of the intervention on the
//         intervention spin itself.
//
//         We could look at how this changes with different intervention strengths (it
//         follows a logistic curve).
//
//       - How consistent is the individual's belief state, as measured by the total system
//         energy?
//
//       - How 'entrenched' is the target attitude?
//
//         Measure $h_k s_k + sum_(j) J_(j k) s_j s_k$, where $k$ is the target attitude.
//
// - *General discussion*
//   - Draw out the key findings from the above two results sections
//   - Make clear the implications for our theory of belief system dynamics
//   - Sensitivity of parameter estimation to unmeasured factors or incorrect structural
//     assumptions. i.e., what happens when we cannot include an influential belief, or
//     when we falsely assume that a relation does or does not exist?
//   - Representational limitations of our model:
//     - Pairwise relations limit what can be modelled. Demonstrate using vaccination
//       example --- we can't capture relations between pairs of attitudes, whose effect
//       sign or magnitude depends on a third belief/attitude.
//     - Polar ($-1, +1$) spin state assumption; some beliefs may be better treated as
//       'on/off', where the 'off' state has _no_ effect on other spins, rather than a
//       negative effect.
//     - More generally, effect sizes may vary depending on specific spin states.
//
// - *Dataset*
//   - Introduce the (insert name here) dataset, give context, survey details
//   - Validation, cleaning, transformations
//   - Question selection, indexes
//   - Binarisation
//
// - *Literature review/related work*
//
// - *Conclusions and future work*
