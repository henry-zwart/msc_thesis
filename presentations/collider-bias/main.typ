#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.2": *
#import themes.university: *

#import "@preview/gantty:0.5.1" as gantty
#import gantty: gantt
#import gantty.header: default-headers-drawer, default-month-header, default-year-header
#import gantty.milestones: default-milestones-drawer
#import gantty.drawers: default-drawer

// Check if 'hand-out' mode specified in sys inputs. If so, collapse slide animations.
#let handout = json.decode(sys.inputs.at("handout", default: "false"))

#show: university-theme.with(
  aspect-ratio: "16-9",
  align: horizon,
  config-common(handout: handout),
  config-info(
    title: [Avoiding collisions when dancing the salsa],
    //subtitle: [Inverse problems and intervention],
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
//= Behaviour and belief <touying:hidden>


#grid(
  columns: 2,
  column-gutter: 10%,
  align: bottom,
  image("figures/P2080044.jpg", height: 80%),
  [#pause #image("figures/salsa_collider.pdf")]
)

== Collider: a common 'consequent'

#slide(composer: (3fr, 2fr))[
  Controlling for $Z$ biases association between $X$ and $Y$.

  *Salsa example:* basic and fancy skills are unrelated, but negatively
  correlated when controlling for awards.
][
  #figure(image("figures/collider.pdf", width: 75%))
]

== Extreme weather hampers belief in climate change (?)

#slide(composer: (1fr, 1.5fr))[
#image("figures/cc_collider_unbiased.pdf")
][
#pause #image("figures/cc_collider_biased.pdf")
]

#slide[
  #image("figures/cc_collider_biased.pdf")
][
  #figure(image("figures/ew_worry_collider.pdf", width: 110% ))
]

