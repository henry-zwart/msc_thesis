#import "@local/drifting-cls-thesis:0.1.0": caption

== Fitting model

*Regularisation:*

- Motivate: dealing with small sample size + large parameter count
- Theory: How is it implemented?
- Effects: How does regularisation affect sparsity?
- Parameter choice: Largest $lambda$ with EBIC within 2 of minimum EBIC.

The number of estimated parameters is relatively large compared to the number of
observations (1700). This is particularly true for the asymmetric model, which features
$n(n+1)$ parameters (72 for $n=8$ beliefs). This can easily result in unreliable
parameter estimates with high variance. To reduce the impact of the small sample size
on model reliability, we employ a variation of *LASSO* (#strong[L]east #strong[a]bsolute
#strong[s]hrinkage and #strong[s]election #strong[p]parameter) regularisation, which
penalises non-zero parameter values which do not contribute significantly to the
optimal likelihood. We use the following adjusted objective function:

$
  f(bold(theta)) = cal(L)_D (bold(theta)) - lambda sum_(theta in bold(theta)) sqrt(theta^2 + epsilon)
$ <eqn:results-regularisation>

where $epsilon$ is chosen to be small, such that the order of magnitude of
$sqrt(epsilon)$ is less than that of the smallest desired value of $theta$. We take
$epsilon = 10^(-8)$. The parameter $lambda in RR^+$ determines the regularisation
strength. Higher values result in sparser models, and $lambda = 0$ corresponds to
no regularisation.

We select the $lambda$ which minimises the EBIC (extended bayesian information
criterion) for the fit model, while maximising the amount of regularisation.
Specifically we select the maximum $lambda$ which is close to the minimal EBIC:

$
  lambda = max {hat(lambda) in RR^+ : |op("EBIC")(hat(lambda)) - op("EBIC")_"min"| < 2 }
$ <eqn:results-regularisation-strength>



#figure(
  image("../results/figures/model_fit/regularisation_ebic.pdf"),
  caption: caption(short: [Regularisation strength EBIC (duplicate)], long: [TODO]),
) <fig:results-regularisation-ebic>

#let regularisation-lambda = json("../results/data/model_fit/optimised_regularisation.json")

#regularisation-lambda.ising



== RQ2.1: symmetry or asymmetry of relations in fit models

Fit asymmetric model. Use L1 regularisation to shrink parameters. Use bootstrapping to
estimate uncertainty.

Plot directional differences. Characterise relations as symmetric, bidirectional,
unidirectional.

== RQ3.1: Intervention strategy and effectiveness under sym/asym assumptions

Fit models using bootstrapping. Consider both effects of intervention (how does
intervening at $S$ affect other spins) and strategies (how does intervening at
different spins affect this _one_). Repeat for varying levels/strengths of
intervention.

For strategy, estimate expected ranking of interventions at both collective and
individual levels. For the former, measure collective effect, then rank interventions,
then take mean across repeats. For the latter, measure expected individual effect, rank
interventions, then take mean across individuals.
