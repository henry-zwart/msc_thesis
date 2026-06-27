#import "@local/drifting-cls-thesis:0.1.0": caption


== RQ2.2: differences between belief systems for different (types of) individuals

Fit separate models based on demographic conditions:
- Male, female
- Urban, suburban, rural

Experiences:
- Extreme weather
- ...?

And maybe particular belief states:
- In climate change
- Political stance (dem, rep, indep)

Do for both symmetric and asymmetric. Use L1 regularisation to shrink parameters. Use
bootstrapping to estimate uncertainty around inferred parameters. Characterise relations
as symmetric, bidirectional, unidirectional.

Consider network features, model features (correlation length, etc.)

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

Conditional logic: for a given target belief/attitude, identify the conditions under
which each strategy is preferred. Examine this under the distribution implied by the
data.
