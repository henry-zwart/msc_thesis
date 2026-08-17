#import "@local/drifting-cls-thesis:0.1.0": caption
#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *
#show: show-theorion

= Additional results <sec:appendix-extra-results>

#set figure(outlined: false)

#figure(
  image("../results/figures/asymmetry_results/outbound_effects_10.pdf"),
  caption: caption(
    short: [Outbound intervention effects ($t=10$)],
    long: [
      Outbound effect of intervention on belief state
      (@def:asymmetry-results-effect-of-intervention) for interventions targeting
      `Weather Worry`, `CC Worry`, and `Politics`, in symmetric and asymmetric belief
      system models calibrated to the climate beliefs dataset. Measurements taken at
      $t=10$ (approximately five years in the models' timescale). Intervention strength:
      $delta_h = 2.5$. Confidence intervals display 1.96 standard deviations around the
      mean effect, measured across 500 repeated simulations.
    ],
  ),
) <fig:apdx-extra-results-outbound-effects-10>

#figure(
  image("../results/figures/model_fit/ideology_edge_accuracy.pdf"),
  caption: caption(
    short: [Edge accuracy in ideology-specific models.],
    long: [Edge accuracy in ideology-specific models.],
  ),
) <fig:apdx-extra-results-ideology-accuracy>


#figure(
  image("../results/figures/model/directional_differentials/ideology.pdf"),
  caption: caption(
    short: [Directional differentials for ideology-specific-models.],
    long: [Directional differentials for ideology-specific-models.],
  ),
) <fig:apdx-extra-results-ideology-differentials>

#figure(
  image("../results/figures/model_fit/ideology_edge_diffs.pdf"),
  caption: caption(
    short: [Differences in interaction effect between ideological models.],
    long: [Differences in interaction effect between ideological models.],
  ),
) <fig:apdx-extra-results-ideology-edge-diffs>
