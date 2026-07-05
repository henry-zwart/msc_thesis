#import "@local/drifting-cls-thesis:0.1.0": caption

== Plan

Second results section, on individual heterogeneity in belief system structure, and
intervention dynamics.


- *RQ2.2:* Fit models to conservative and liberal subsets of the data; compare and
  contrast. Compare with the model from the previous section, i.e., fit on the entire
  dataset.
- *RQ3.2:*
  - Distribution of intervention effectiveness by individual.
  - How does intervention ranking vary across individuals?
  - Characterising how different initial states affect intervention success.
  - Looking at how other theory-driven features affect success, e.g.:
    - How receptive is the individual to the intervention?

      The effective baseline ($h_i + sum_j J_(j i) s_j$) determines the probability
      that $S_i^(t+1) = s$ for a state $s in plus.minus 1$. Evaluating this after
      intervening provides a measurement for the success of the intervention on the
      intervention spin itself.

      We could look at how this changes with different intervention strengths (it
      follows a logistic curve).

    - How consistent is the individual's belief state, as measured by the total system
      energy?

    - How 'entrenched' is the target attitude?

      Measure $h_k s_k + sum_(j) J_(j k) s_j s_k$, where $k$ is the target attitude.


== RQ2.2: differences between belief systems for different (types of) individuals

// Do for both symmetric and asymmetric. Use L1 regularisation to shrink parameters. Use
// bootstrapping to estimate uncertainty around inferred parameters. Characterise relations
// as symmetric, bidirectional, unidirectional.
//
// Consider network features, model features (correlation length, etc.)

#figure(
  image(
    "../results/figures/model/ideology_fit/network.pdf",
  ),
  caption: caption(
    short: [_Conservative_ and _Liberal_ belief networks],
    long: [
      Prefixes: A (attitude), B (belief); node labels: CC (climate change), CCA (climate
      change anthropogenic), CCW (climate change worry), CCWO (climate change worry
      others), CCI (climate change impacts), CCP (climate change policies), WW (weather
      worry).
    ],
  ),
) <fig:results-rq22-ideology-networks>



== RQ3.2: Intervention strategy and effectiveness across individuals

Examine distributions of expected outcome effects (per individual) for different
interventions. Characterise the individuals found at different parts of the
distribution (personas, average magnetisation).


=== Intervention ranking

For each individual, compute ranking over the expected effects of each possible
intervention.

#figure(
  image("../results/figures/model/intervention_individual_ranking/05_climate_policy.pdf"),
  caption: caption(
    short: [Ranked intervention effects per-individual, weak, targeting climate policy],
    long: [Ranked intervention effects per-individual, weak, targeting climate policy],
  ),
)

#figure(
  image("../results/figures/model/intervention_individual_ranking/80_climate_policy.pdf"),
  caption: caption(
    short: [Ranked intervention effects per-individual, perfect, targeting climate policy],
    long: [Ranked intervention effects per-individual, perfect, targeting climate policy],
  ),
)

=== Who is intervention effective for?

#figure(
  image("../results/figures/model/heterogeneous_effects/climate_policy.pdf"),
  caption: caption(
    short: [Characterisation of responsiveness to intervention],
    long: [*TODO*],
  ),
)
