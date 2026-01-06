#import "lib.typ": proposal, plan, document-setup

#let title = "Interventions on Asymmetric Belief Networks"
#let author = "Henry Zwart"
#let supervisors = ("Vítor V. Vasconcelos", "Kyuri Park", "Johan Bollen", "Sara Constantino")
#let pdf_title = [Thesis proposal (#datetime.today().display())]

#show: document-setup.with(
  title: title,
  author: author,
  pdf_title: pdf_title,
  header_title: [Thesis proposal],
  header_logo: image("uva_logo_nl.svg", width: 60%),
  hide_plan: true,
)
#show: proposal.with(
  title: title, 
  author: author, 
  supervisors: supervisors,
  bibliography: bibliography("references.bib", full: false, style: "apa"),
)

#include "sections/problem.typ"

== Research methods
#include "sections/methods.typ"

== Proposed timeline
#include "sections/timeline.typ"
