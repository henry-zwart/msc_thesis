#import "@local/drifting-cls-thesis:0.1.0": caption
#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *
#show: show-theorion

= Additional results

#figure(
  image("../results/figures/asymmetry_results/outbound_effects_10.pdf"),
  outlined: false,
  caption: caption(
    short: [Outbound intervention effects ($t=10$)],
    long: [
      Outbound effect of intervention (@def:asymmetry-results-effect-of-intervention)
      for interventions targeting `Weather Worry`, `CC Worry`, and
      `Politics`, in symmetric and asymmetric belief system models calibrated to the
      climate beliefs dataset. Measurements taken at $t=10$ (approximately five years in
      the models' timescale). Intervention strength: $delta_h = 2.5$. Confidence
      intervals display 1.96 standard deviations around the mean effect, measured
      across 500 repeated simulations.
    ],
  ),
) <fig:apdx-extra-results-outbound-effects-10>

