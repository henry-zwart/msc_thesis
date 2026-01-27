#import "lib.typ": report, document-setup

#let title = "Climate attitudes dataset EDA"
#let author = "Henry Zwart"
#let pdf_title = [Climate attitudes dataset EDA (#datetime.today().display())]

#show: document-setup.with(
  title: title,
  author: author,
  pdf_title: pdf_title,
  header_title: "Climate attitudes EDA",
  header_logo: image("uva_logo_nl.svg", width: 60%),
  hide_plan: true,
)

#show: report.with(
  title: title, 
  bibliography: bibliography("references.bib", full: false, style: "apa"),
)

#show table.cell.where(y: 0): set text(weight: "bold")

#outline()

#show heading.where(level: 1): it => {
  pagebreak()
  it
}

#include "sections/variables.typ"
