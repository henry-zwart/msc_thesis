#import "lib.typ": proposal

#let title = "(Placeholder) Behavioural implications of intervening on internal belief networks under varying structural assumptions"
#let author = "Henry Zwart"
#let pdf_title = [Thesis proposal (#datetime.today())]

#show: proposal.with(
  title: title, 
  author: author, 
  pdf_title: pdf_title,
  header_logo: image("uva_logo_nl.svg", width: 60%),
  //abstract: include("sections/abstract.typ"),
  bibliography: bibliography("references.bib", full: true, style: "apa"),
)


#include "sections/problem_and_methods.typ"

== Proposed timeline
#include "sections/timeline.typ"
