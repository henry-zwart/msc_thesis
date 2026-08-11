#import "@local/drifting-cls-thesis:0.1.0": thesis


#let author = (
  first-name: "Henry",
  surname: "Zwart",
)

#let supervision-team = (
  supervisor: link("https://www.vvvasconcelos.net/")[Vítor Vasconcelos],
  examiner: link("https://scholar.google.com/citations?user=jDmcdsUAAAAJ&hl=en")[Johan Bollen],
  assessor: link("https://sustainability.stanford.edu/people/sara-constantino")[Sara Constantino],
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

#let abstract = include "sections/abstract.typ"

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
  acknowledgements: acknowledgements,
  abbreviations: abbreviations,
  references: bibliography("references.bib", style: "apa"),
  additional-frontmatter: (),
  signature: signature,
  appendices: (derivation-appendix, extra-results-appendix, dataset-appendix),
)

// = Notes (things to remember, to-dos)
// #include "sections/notes.typ"

// = Terminology and notation <sec:notation>
// #include "sections/notation.typ"

= Introduction <sec:introduction>
#include "sections/introduction.typ"

= The Kinetic Belief System model <chp:kinetic-belief-system>
#include "sections/kinetic_belief_system.typ"

= Parameter estimation <chp:parameter-estimation>
#include "sections/parameter_estimation.typ"

= Methods <sec:methods>
#include "sections/methods.typ"

// = Model Calibration <sec:calibration>
// #include "sections/calibration.typ"

= Existence and impact of asymmetry in belief systems <sec:results-asymmetry-in-belief-systems>
#include "sections/asymmetry_results.typ"

= Heterogeneous belief systems and intervention effects <sec:heterogeneity-in-belief-systems-and-intervention-effects>
#include "sections/heterogeneity_results.typ"

= Discussion <sec:discussion>
#include "sections/discussion.typ"

// = Related work <sec:related-work>
// #include "sections/literature_review.typ"

= Conclusions <sec:conclusions>
#include "sections/conclusion.typ"

= Climate beliefs dataset <sec:dataset>
#include "sections/dataset.typ"

= Ethics and Data Management
A new requirement for the thesis is that there must be a short section in which you
reflect on the ethical aspects of your project. This requirement is related to one of
the final objectives that a graduated student of the Master of Computational Science
must meet: “The graduate of the program has insight into the social significance of
Computational Science and the responsibilities of experts in this field within science
and in society". You don't need to devote an entire chapter to this; a short section
or paragraph is sufficient.

I acknowledge that the thesis adheres to the ethical code
(https://student.uva.nl/en/topics/ethics-in-research) and research data management
policies (https://rdm.uva.nl/en) of UvA and IvI.

The following table lists the data used in this thesis (including source codes).
I confirm that the list is complete and the listed data are sufficient to reproduce
the results of the thesis. If a prohibitive non-disclosure agreement is in effect at
the time of submission "NDA" is written under "Availability" and "License" for the
concerned data items.

