#import "@preview/cetz:0.5.0"
#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.2": *
#import themes.university: *

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()


// Check if 'hand-out' mode specified in sys inputs. If so, collapse slide animations.
#let handout = json.decode(sys.inputs.at("handout", default: "false"))

#show: university-theme.with(
  aspect-ratio: "16-9",
  align: horizon,
  config-common(handout: handout),
  config-info(
    title: [Asymmetric Belief Systems],
    subtitle: [ENLENS Status Update],
    author: [Henry Zwart],
    date: datetime.today(),
    institution: [MSc. Computational Science],
  ),
  config-common(
    slide-fn: slide.with(
      setting: body => {
        // Fix moving list items when using pause
        set par(spacing: 1.2em)
        set list(spacing: 1em)
        body
      },
    ),
  ),
)

//#show: simple-theme.with(aspect-ratio: "16-9")

#title-slide()
#set par(spacing: 1.2em)
#set text(size: 19pt)
#show math.equation: set text(size: 22pt)
#show figure: set text(size: 12pt)

== Asymmetric belief systems

*Ising model of attitudes and beliefs:* internal state updates to reduce cognitive dissonance

Asymmetric relations reflect _causal_ or _implicational_ relations between beliefs & attitudes.
#v(1em)

#grid(
  columns: (1fr, 1fr),
  cetz.canvas({
    import cetz.draw: *

    set-style(radius: 1, stroke: 1pt)
    content((0, 0), text(size: 13pt)[CC Harm], name: "cc_harm")
    content((0, 4), text(size: 13pt)[CC Real], name: "cc_real")
    content((0, -4), text(size: 13pt)[CC Policy Support], name: "cc_policy")
    content((-3.5, 0), text(size: 13pt)[CC Anthropogenic], name: "cc_anthro")
    content((3.5, 0), text(size: 13pt)[CC Worry], name: "cc_worry")

    line((name: "cc_harm", anchor: "north"), (name: "cc_real", anchor: "south"))
    line((name: "cc_harm", anchor: "south"), (name: "cc_policy", anchor: "north"))
    line((name: "cc_harm", anchor: "east"), (name: "cc_worry", anchor: "west"))
    line((name: "cc_real", anchor: "south"), (name: "cc_worry", anchor: "north"))
    line((name: "cc_policy", anchor: "north"), (name: "cc_worry", anchor: "south"))
    line((name: "cc_real", anchor: "south"), (name: "cc_anthro", anchor: "north"))
    line((name: "cc_policy", anchor: 90deg), (name: "cc_anthro", anchor: 270deg))
  }),

  [#cetz.canvas({
    import cetz.draw: *

    set-style(radius: 1, stroke: 1pt)
    content((0, 0), text(size: 13pt)[CC Harm], name: "cc_harm")
    content((0, 4), text(size: 13pt)[CC Real], name: "cc_real")
    content((0, -4), text(size: 13pt)[CC Policy Support], name: "cc_policy")
    content((-3.5, 0), text(size: 13pt)[CC Anthropogenic], name: "cc_anthro")
    content((3.5, 0), text(size: 13pt)[CC Worry], name: "cc_worry")

    set-style(stroke: (thickness: 1pt), mark: (start: ">", fill: black))
    line((name: "cc_harm", anchor: "north"), (name: "cc_real", anchor: "south"))
    line((name: "cc_harm", anchor: "east"), (name: "cc_worry", anchor: "west"))
    line((name: "cc_worry", anchor: "north"), (name: "cc_real", anchor: "south"))
    line((name: "cc_anthro", anchor: "north"), (name: "cc_real", anchor: "south"))
    line((name: "cc_policy", anchor: "north"), (name: "cc_worry", anchor: "south"))
    line((name: "cc_policy", anchor: "north"), (name: "cc_harm", anchor: "south"))
    line((name: "cc_policy", anchor: "north"), (name: "cc_anthro", anchor: "south"))
  })],
)







== How do asymmetric relations affect intervention?

#let undirected = cetz.canvas({
  import cetz.draw: *

  set-style(radius: 0.2, stroke: 0.5pt, fill: orange.transparentize(20%))
  circle((0, 0), name: "hub")
  circle((-1.5, 2), name: "tl")
  circle((-1.5, -2), name: "bl")
  circle((1.5, 2), name: "tr")
  circle((1.5, -2), name: "br")
  set-style(fill: purple.transparentize(20%))
  circle((4, 0), name: "target")

  // Spokes
  set-style(stroke: 1pt)
  line((name: "hub", anchor: 120deg), (name: "tl", anchor: 300deg))
  line((name: "hub", anchor: 60deg), (name: "tr", anchor: 240deg))
  line((name: "hub", anchor: 240deg), (name: "bl", anchor: 60deg))
  line((name: "hub", anchor: 300deg), (name: "br", anchor: 120deg))

  // Outside edges
  line((name: "tl", anchor: 0deg), (name: "tr", anchor: 180deg))
  line((name: "tl", anchor: 270deg), (name: "bl", anchor: 90deg))
  line((name: "bl", anchor: 0deg), (name: "br", anchor: 180deg))

  // Attitudes to behaviour
  line((name: "tr", anchor: -10deg), (name: "target", anchor: 130deg))
  line((name: "br", anchor: 10deg), (name: "target", anchor: 230deg))

  content("target.east", text(size: 12pt)[Target], anchor: "west", padding: 0.2)
})

#let directed_intervene_at_hub = cetz.canvas({
  import cetz.draw: *

  set-style(radius: 0.2, stroke: 0.5pt, fill: orange.transparentize(20%))
  circle((0, 0), name: "hub")
  set-style(radius: 0.2, stroke: 0.5pt, fill: gray.transparentize(50%))
  circle((-1.5, 2), name: "tl")
  circle((-1.5, -2), name: "bl")
  circle((1.5, 2), name: "tr")
  circle((1.5, -2), name: "br")
  set-style(fill: purple.transparentize(20%))
  circle((4, 0), name: "target")

  // Spokes
  set-style(stroke: (thickness: 1pt, paint: green), mark: (end: ">", fill: green))
  line((name: "hub", anchor: 120deg), (name: "tl", anchor: 300deg))
  line((name: "hub", anchor: 60deg), (name: "tr", anchor: 240deg))
  line((name: "hub", anchor: 240deg), (name: "bl", anchor: 60deg))
  line((name: "hub", anchor: 300deg), (name: "br", anchor: 120deg))

  // Outside edges
  line((name: "tl", anchor: 0deg), (name: "tr", anchor: 180deg))
  line((name: "tl", anchor: 270deg), (name: "bl", anchor: 90deg))
  line((name: "bl", anchor: 0deg), (name: "br", anchor: 180deg))

  // Attitudes to behaviour
  line((name: "tr", anchor: -10deg), (name: "target", anchor: 130deg))
  line((name: "br", anchor: 10deg), (name: "target", anchor: 230deg))

  content("target.east", text(size: 12pt)[Target], anchor: "west", padding: 0.2)
})

#let directed_intervene_at_tl = cetz.canvas({
  import cetz.draw: *

  set-style(radius: 0.2, stroke: 0.5pt, fill: orange.transparentize(20%))
  circle((-1.5, 2), name: "tl")
  set-style(radius: 0.2, stroke: 0.5pt, fill: gray.transparentize(50%))
  circle((0, 0), name: "hub")
  circle((-1.5, -2), name: "bl")
  circle((1.5, 2), name: "tr")
  circle((1.5, -2), name: "br")
  set-style(fill: purple.transparentize(20%))
  circle((4, 0), name: "target")

  // Spokes
  set-style(stroke: (thickness: 1pt, paint: red), mark: (end: ">", fill: red))
  line((name: "tl", anchor: 300deg), (name: "hub", anchor: 120deg))
  line((name: "tr", anchor: 240deg), (name: "hub", anchor: 60deg))
  line((name: "bl", anchor: 60deg), (name: "hub", anchor: 240deg))
  line((name: "br", anchor: 120deg), (name: "hub", anchor: 300deg))

  // Outside edges
  set-style(stroke: (thickness: 1pt, paint: green), mark: (end: ">", fill: green))
  line((name: "tl", anchor: 0deg), (name: "tr", anchor: 180deg))
  line((name: "tl", anchor: 270deg), (name: "bl", anchor: 90deg))
  line((name: "bl", anchor: 0deg), (name: "br", anchor: 180deg))

  // Attitudes to behaviour
  line((name: "tr", anchor: -10deg), (name: "target", anchor: 130deg))
  line((name: "br", anchor: 10deg), (name: "target", anchor: 230deg))

  content("target.east", text(size: 12pt)[Target], anchor: "west", padding: 0.2)
})

#let directed_intervene_at_tl_2 = cetz.canvas({
  import cetz.draw: *

  set-style(radius: 0.2, stroke: 0.5pt, fill: orange.transparentize(20%))
  circle((-1.5, 2), name: "tl")
  set-style(radius: 0.2, stroke: 0.5pt, fill: gray.transparentize(50%))
  circle((0, 0), name: "hub")
  circle((-1.5, -2), name: "bl")
  circle((1.5, 2), name: "tr")
  circle((1.5, -2), name: "br")
  set-style(fill: purple.transparentize(20%))
  circle((4, 0), name: "target")

  // Spokes
  set-style(stroke: (thickness: 1pt, paint: red), mark: (end: ">", fill: red))
  line((name: "hub", anchor: 120deg), (name: "tl", anchor: 300deg))
  line((name: "hub", anchor: 240deg), (name: "bl", anchor: 60deg))
  set-style(stroke: (thickness: 1pt, paint: green), mark: (end: ">", fill: green))
  line((name: "hub", anchor: 60deg), (name: "tr", anchor: 240deg))
  line((name: "hub", anchor: 300deg), (name: "br", anchor: 120deg))

  // Outside edges
  set-style(stroke: (thickness: 1pt, paint: green), mark: (end: ">", fill: green))
  line((name: "tl", anchor: 0deg), (name: "tr", anchor: 180deg))
  line((name: "tl", anchor: 270deg), (name: "bl", anchor: 90deg))
  line((name: "bl", anchor: 0deg), (name: "br", anchor: 180deg))

  // Attitudes to behaviour
  line((name: "tr", anchor: -10deg), (name: "target", anchor: 130deg))
  line((name: "br", anchor: 10deg), (name: "target", anchor: 230deg))

  content("target.east", text(size: 12pt)[Target], anchor: "west", padding: 0.2)
})

#grid(
  columns: (1fr, 1fr),
  rows: (1fr, 1fr),
  align: horizon,
  undirected, [#pause #directed_intervene_at_hub],
  [#pause #directed_intervene_at_tl], [#pause #directed_intervene_at_tl_2],
)

// == Behavioural intervention at the belief-level
//
//
//
// Internal states influence individual behaviour; but also have endogenous dynamics.
//
// // - Some swans are black $==>$ finite induction is problematic.
//
// - COVID-19 is airborne $==>$ positive attitude toward mask-wearing.
//
// - Experienced extreme weather $==>$ increased concern about future events.
//
// #v(1em)
// #figure(
//   image("figures/belief-behaviour-dynamics.pdf", width: 90%),
// )
//
//
//
//
//
//
// #pagebreak()
// Belief system structure can affect:
//
// #v(0.5em)
// #{
//   set text(size: 18pt)
//   grid(
//     columns: (1fr, 1fr),
//     align: center,
//     [#grid(
//       rows: (0.2fr, 1fr, 2fr),
//       align: center + top,
//       strong[Effectiveness],
//       image("proposal-figures/stargraph_in.pdf", width: 65%),
//       image("proposal-figures/stargraph_out.pdf", width: 65%),
//     )],
//     [#grid(
//       rows: (0.2fr, 1fr, 2fr),
//       align: center + top,
//       strong[Outcome],
//       block({
//         set align(left)
//         set text(size: 18pt)
//         [
//           #v(0.5em)
//           #strong[V]accination #linebreak()
//           #strong[F]amily #linebreak()
//           Relative #strong[D]anger#linebreak()
//           #strong[E]xperience
//           #v(1em)
//         ]
//       }),
//       image("proposal-figures/vaccination_intervention.pdf", width: 80%),
//     )],
//   )
// }
// #v(-2.5em)
//
// Reasoning about belief-level intervention requires considering how changes propagate.

== Research goals

#show figure: set text(size: 12pt)
//#v(1em)
#grid(
  columns: (1fr, 1.5fr),
  align: (left, center + horizon),
  [
    #set list(spacing: 2em)
    - *Model extension:* Cognitive dissonance with asymmetric relations.

    - *Theoretical dynamics:* Comparison via simulation on hypothetical structures.

    - *Empirical study:* Structural & dynamical differences in belief systems inferred from survey data.
  ],
  figure(
    image("figures/network_of_belief.png", width: 80%),
    caption: [
      Network of belief diagram; Dalege et al. (2025) @dalegeNetworksBeliefsIntegrative2025.
    ],
  ),
)
#v(1em)
*Note:* We are _not_ considering social influences on belief system dynamics.

// == Methods
//
// Maybe just show figure here (e.g., Network of Belief diagram) and discuss.
//
// - Endogenous belief updating driven by cognitive dissonance reduction (Ising model;
//   beliefs as nodes).
//
// - Causal discovery to fix some of the relation directions
//
// - _Not_ considering social effects.

== Current state & next steps

#show figure: set text(size: 10pt)
#grid(
  columns: (1fr, 1.4fr),
  align: (left, right + top),
  [
    #set par(spacing: 2em)
    So far, mostly dataset curation:
    - Longitudinal study on climate beliefs & attitudes in US
    - Six waves (though not all are used)
    - Schema-level, response-level validation
    - Relevant questions aggregated into 8 cognitive items


  ],
  figure(
    image("figures/partial-correlation-network.pdf", width: 80%),
    gap: -2em,
    caption: [
      Regularised partial correlation network for climate beliefs & attitudes dataset
      (waves 3 and 4; no imputation).
    ],
  ),
)

== Model extension

Extending symmetric network Ising model to permit independently-varying directed edges:
- $gamma_i$: Tendency of spin $i$ in absence of interactions (e.g., perceived norms)
- $A_(i j)$: Directed binary adjacency matrix ($i -> j$)
- $beta_(i j)$: Interaction strength, describes pressure on $s_i$ due to state of $s_j$

#v(1em)
$
  PP[s_i (t+1) = s] = exp[-(1/T) s (#pin(1)gamma_i#pin(2) + sum_j A_(j i) beta_(j i) s_j)]/(sum_(s' in {-1, +1})exp[-(1/T) s (gamma_i + sum_j A_(j i) beta_(j i) s_j)])
$



== References

#show bibliography: set text(size: 16pt)
#bibliography("references.bib")
