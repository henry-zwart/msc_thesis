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


== Behavioural intervention at the belief-level



Internal states influence individual behaviour; but also have endogenous dynamics. 

// - Some swans are black $==>$ finite induction is problematic.

- COVID-19 is airborne $==>$ positive attitude toward mask-wearing.

- Experienced extreme weather $==>$ increased concern about future events. 

#v(1em)
#figure(
  image("figures/belief-behaviour-dynamics.pdf", width: 90%),
)






#pagebreak()
Belief system structure can affect:

#v(0.5em)
#{
  set text(size: 18pt)
  grid(
    columns: (1fr, 1fr),
    align: center,
    [#grid(rows: (0.2fr,1fr, 2fr), align: center + top, strong[Effectiveness], image("proposal-figures/stargraph_in.pdf", width: 65%), image("proposal-figures/stargraph_out.pdf", width: 65%))],
    [#grid(rows: (0.2fr, 1fr, 2fr), align: center + top, strong[Outcome],  block({
      set align(left)
      set text(size: 18pt)
      [
        #v(0.5em)
        #strong[V]accination #linebreak()
        #strong[F]amily #linebreak()
        Relative #strong[D]anger#linebreak()
        #strong[E]xperience
        #v(1em)
      ]
      }),
      image("proposal-figures/vaccination_intervention.pdf", width: 80%),
    )]
  )
}
#v(-2.5em)

Reasoning about belief-level intervention requires considering how changes propagate. 

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
  ]
  )
)
#v(1em)
*Note:* We are _not_ considering social influences on belief system dynamics.

== Methods

Maybe just show figure here (e.g., Network of Belief diagram) and discuss.

- Endogenous belief updating driven by cognitive dissonance reduction (Ising model; 
  beliefs as nodes).

- Causal discovery to fix some of the relation directions

- _Not_ considering social effects.

== Current state & next steps

#show figure: set text(size: 10pt)
#grid(
  columns: (1fr, 1.4fr),
  align: (left, right + top),
  [
    #set par(spacing: 2em)
    So far, mostly *dataset curation*:
    - Longitudinal study on climate beliefs & attitudes in US
    - Six waves (though not all are used)
    - Relevant questions aggregated into 9 cognitive items

    Just starting theoretical work!

  ],
  figure(
    image("figures/partial-correlation-network.pdf", width: 80%),
    gap: -2em,
    caption: [
      Regularised partial correlation network for climate beliefs & attitudes dataset
      (waves 3 and 4; no imputation). 
    ]
  )
)

== References

#show bibliography: set text(size: 16pt) 
#bibliography("references.bib")
