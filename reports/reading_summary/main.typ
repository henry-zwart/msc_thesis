#import "lib.typ": report, document-setup

#let title = "Reading summaries"
#let author = "Henry Zwart"
#let pdf_title = [Literature review reading summaries (#datetime.today().display())]

#show: document-setup.with(
  title: title,
  author: author,
  pdf_title: pdf_title,
  header_title: "Literature review",
  header_logo: image("uva_logo_nl.svg", width: 60%),
  hide_plan: true,
)

#show: report.with(
  title: title, 
  bibliography: bibliography("references.bib", full: false, style: "apa"),
)

#include "sections/papers.typ"
