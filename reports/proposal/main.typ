#import "lib.typ": proposal, plan

#let title = "(Placeholder) Behavioural implications of intervening on asymmetric internal belief networks"
#let author = "Henry Zwart"
#let supervisor = "Vítor V. Vasconcelos"
#let pdf_title = [Thesis proposal (#datetime.today().display())]

#show: proposal.with(
  title: title, 
  author: author, 
  supervisor: supervisor,
  pdf_title: pdf_title,
  header_logo: image("uva_logo_nl.svg", width: 60%),
  bibliography: bibliography("references.bib", full: true, style: "apa"),
  hide_plan: false,
)


#include "sections/problem.typ"

#include "sections/methods.typ"

== Proposed timeline
#include "sections/timeline.typ"
