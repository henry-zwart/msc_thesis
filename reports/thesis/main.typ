#import "@local/drifting-cls-thesis:0.1.0": blue-link, thesis


#let author = (
  first-name: "Henry",
  surname: "Zwart",
)

#let supervision-team = (
  supervisor: blue-link("https://www.vvvasconcelos.net/")[Vítor Vasconcelos],
  examiner: blue-link("https://scholar.google.com/citations?user=jDmcdsUAAAAJ&hl=en")[Johan Bollen],
  assessor: blue-link("https://sustainability.stanford.edu/people/sara-constantino")[Sara Constantino],
)

#let group = (
  name: "Computational Science Lab",
  site: "https://uva.computationalscience.nl/",
)

#let dept = (
  name: "Informatics Institute",
  site: "https://ivi.uva.nl/",
)

#let faculty = (
  name: "Faculty of Science",
  site: "http://www.uva.nl/en/about-the-uva/organisation/organisational-structure/content/faculties/faculty-of-science-fnwi/faculty-of-science-fnwi.html",
)


#let degree = "Master of Science in Computational Science"

//#let quotation = (attrib: [Richard P. Feynman], quote-text: [What I cannot create, I do not understand.])
#let quotation = none

#let title = [Asymmetric Belief Networks#linebreak() Inference and Intervention]
#let title = [Interventions in Asymmetric#linebreak() Belief Systems]
#let title = [Asymmetric Influence and Interventions in #linebreak() Climate Change Belief Systems]
#let title = "Asymmetric Influence and Interventions in\nClimate Change Belief Systems"

#let abstract = include "sections/abstract.typ"
#let declaration-of-authorship = include "sections/declaration_of_authorship.typ"

#let acknowledgements = [Thank the people that have helped: supervisors, family, etc.]


#let abbreviations = [
  / CSL: #strong[C]omputational #strong[S]cience #strong[L]ab

  / UvA: #strong[U]niversiteit #strong[v]an #strong[A]msterdam
]

// #let frontmatter-pages = (
//   (title: [Use of AI], body: include "sections/use_of_ai.typ"),
// )

#let signature = image("signature.png", height: 2cm)

#let derivation-appendix = include "sections/appendix_derivations.typ"
#let extra-results-appendix = include "sections/appendix_extra_results.typ"
#let dataset-appendix = include "sections/appendix_dataset.typ"

#show: thesis.with(
  title: title,
  author: author,
  supervision-team: supervision-team,
  degree: degree,
  group: group,
  dept: dept,
  faculty: faculty,
  quotation: quotation, //# TODO: Decide if I want to include a quotation
  abstract: abstract,
  declaration-of-authorship-body: declaration-of-authorship,
  acknowledgements: acknowledgements,
  abbreviations: abbreviations,
  references: bibliography("references.bib", style: "apa"),
  additional-frontmatter: (),
  signature: signature,
  appendices: (derivation-appendix, extra-results-appendix, dataset-appendix),
  caption-width: 95%,
)

// = Notes (things to remember, to-dos)
// #include "sections/notes.typ"

= Terminology and notation <sec:notation>
#include "sections/notation.typ"

= Introduction <sec:introduction>
#include "sections/introduction.typ"

= The Kinetic Belief System model (KBS) <chp:kinetic-belief-system>
#include "sections/kinetic_belief_system.typ"

= Parameter estimation in the KBS model <chp:parameter-estimation>
#include "sections/parameter_estimation.typ"

= A KBS model of climate beliefs <sec:calibration>
#include "sections/calibration.typ"

= Experimental Methods <sec:methods>
#include "sections/methods.typ"

= Existence and impact of asymmetry in belief systems <sec:results-asymmetry-in-belief-systems>
#include "sections/asymmetry_results.typ"

= Heterogeneous belief systems and intervention effects <sec:heterogeneity-in-belief-systems-and-intervention-effects>
#include "sections/heterogeneity_results.typ"

= Discussion <sec:discussion>
#include "sections/discussion.typ"

= Conclusions <sec:conclusions>
#include "sections/conclusion.typ"

= Ethics and Data Management
#include "sections/ethics_and_data_management.typ"

= Climate beliefs dataset <sec:dataset>
#include "sections/dataset.typ"
