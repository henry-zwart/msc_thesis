#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.2": *
#import themes.university: *

#import "@preview/gantty:0.5.1" as gantty
#import gantty: gantt
#import gantty.header: default-headers-drawer, default-month-header, default-year-header
#import gantty.milestones: default-milestones-drawer
#import gantty.drawers: default-drawer

// Check if 'hand-out' mode specified in sys inputs. If so, collapse slide animations.
#let handout = json.decode(sys.inputs.at("handout", default: "true"))

#show: university-theme.with(
  aspect-ratio: "16-9",
  align: horizon,
  config-common(handout: handout),
  config-info(
    title: [Asymmetric Networks of Belief],
    subtitle: [Inverse problems and intervention],
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

#title-slide()
#set par(spacing: 1.2em)
//= Behaviour and belief <touying:hidden>

== What drives behaviour? 

e.g. healthy eating; transportation; mask-wearing; vaccination; ...

#v(1fr)
#set text(size: 19pt)
#show math.equation: set text(size: 22pt)

#grid(
  columns: (0.91fr, 0.09fr),
  [
    #pause
    $ P_A_i (a) = op("logistic")(#pin(1)alpha_(i,a)#pin(2) + #pin(3)beta_("cost", a)#pin(4) + #pin(5)beta_("peer", a))#pin(6) $

    #pause
    #pinit-point-from((3,4), pin-dx: 0em, pin-dy: -1.5em, body-dx: -1em, body-dy: -1.3em, offset-dx: 0em, offset-dy: -6em, thickness: 1.5pt)[e.g. strategic games]
    #pause
    #pinit-point-from((5,6), pin-dx: 0em, pin-dy: -1.5em, body-dx: -1em, body-dy: -1.3em, offset-dx: 0em, offset-dy: -3.5em, thickness: 1.5pt)[e.g. social strategies; peer pressure @mittalAnticonformistsCatalyzeSocietal2024]
    #pause
    #pinit-point-from((1,2), pin-dx: 0em, pin-dy: 1.3em, body-dx: -17em, body-dy: 0.7em, offset-dx: 0em, offset-dy: 4em, fill: maroon, thickness: 1.5pt, text(fill: maroon)[Individual differences (e.g. beliefs, preferences)])
  ]
)

#v(0.75fr)


#pause
*Remark:* Population-level behaviour depends on _individual_ beliefs.

#pause
*Remark (2):* Individual beliefs don't live in isolation!



== Networks of Belief theory

#show figure: set text(size: 12pt)
//#v(1em)
*Focus:* Social network + internal beliefs $->$ population-level phenomena
#figure(
  image("figures/network_of_belief.png", width: 45%),
  caption: [Network of belief model diagram from original paper @dalegeNetworksBeliefsIntegrative2025]
)

#v(1em)

Simplified internal beliefs: fully-connected, undirected, one 'focal' belief.

#pause
_Are these assumptions always reasonable?_

== Belief structure matters for intervention

#pause

Intervention is active -- we want the system energy to decrease in a particular direction.

Belief structure can affect intervention...

#v(0.5em)
#{
  set text(size: 18pt)
  grid(
    columns: (1fr, 1fr),
    align: center,
    [#pause #grid(rows: (0.2fr,1fr, 2fr), align: center + top, strong[Effectiveness], image("figures/stargraph_in.pdf", width: 65%), image("figures/stargraph_out.pdf", width: 65%))],
    [#pause #grid(rows: (0.2fr, 1fr, 2fr), align: center + top, strong[Outcome],  block({
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
      image("figures/vaccination_intervention.pdf", width: 80%),
    )]
  )
}

== Project overview

#{
  set par(
    justify: true,
    justification-limits: (   // Character-level justification for tidier documents 
      tracking: (min: -0.01em, max: 0.02em),
    )
  )
  [
  *Inverse problem:* Inferring real belief relations from data (existence, strength, direction).

  Longitudinal survey of climate attitudes in the USA.
  
  $ 
     H(bold(b)) := sum_i tau_i b_i - sum_(i j) #pin(7)omega_(i j)#pin(8) b_i b_j 
  $ <eq:nb-internal-dissonance>
  #pinit-point-from((8), pin-dx: 0em, pin-dy: -1.3em, body-dx: 0em, body-dy: -1em, offset-dx: 1em, offset-dy: -2.5em, fill: maroon, thickness: 1.5pt, text(fill: maroon)[allow $omega_(i j) != omega_(j i)$])

  Causal discovery to reduce free variables (existence, direction).  

  *Intervention:* How could effectiveness/outcome depend on structural + causal assumptions?  
  ]
}

#v(1em)
#pause
Several questions to consider: #pause
- How realistic is NB for belief networks (e.g., doesn't distinguish different kinds of beliefs)? #pause
- Inverse problem requires fixed set of beliefs --- how to get there from data?  #pause
- (I'm probably well over my five minutes!)

== Timeline

// // Setup the gantt binding to style as we wish for our project
#let gantt = gantt.with(
  drawer: (
    // Import the stylistic defaults
    ..default-drawer,
    // But change the headers to only show the month header
    headers: default-headers-drawer.with(
      headers: (default-year-header(), default-month-header(),),
    ),
    milestones: default-milestones-drawer.with(
      today-content: none
    )
  ),
)

#figure(
  {
    set text(size: 12pt)
    gantt(yaml("gantt.yaml"))
  },
 ) <fig:gantt-chart>

== References

#show bibliography: set text(size: 16pt) 
#bibliography("references.bib")
