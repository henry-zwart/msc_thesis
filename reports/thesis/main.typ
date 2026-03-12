#import "@local/drifting-cls-thesis:0.1.0": thesis

#let author = (
  first-name: "Henry",
  surname: "Zwart",
)

#let group = (
  name: "Computational Science Lab",
  site: "https://uva.computationalscience.nl/"
)

#let dept = (
  name: "Informatics Institute",
  site: "https://ivi.uva.nl/"
)

#let faculty = (
  name: "Faculty of Science",
  site: "http://www.uva.nl/en/about-the-uva/organisation/organisational-structure/content/faculties/faculty-of-science-fnwi/faculty-of-science-fnwi.html"
)

#let degree = "Master of Science in Computational Science"

#let quotation = (attrib: [Richard P. Feynman], quote-text: [What I cannot create, I do not understand.])

#let abstract = include "sections/abstract.typ"

#let acknowledgements = [Thank the people that have helped: supervisors, family, etc.]

#let abbreviations = [
/ CSL: #strong[C]omputational #strong[S]cience #strong[L]ab

/ UvA: #strong[U]niversiteit #strong[v]an #strong[A]msterdam
]

#show: thesis.with(
  title: "Asymmetric Belief Networks
  Inference and Intervention",
  author: author,
  degree: degree,
  group: group,
  dept: dept,
  faculty: faculty,
  quotation: quotation,
  abstract: abstract,
  acknowledgements: acknowledgements,
  abbreviations: abbreviations,
)

= Introduction

== Exploring subsections
 
#lorem(100)

#lorem(40)

=== And sub-subsections!

#lorem(200)

#lorem(150)

#lorem(120)

== Sub-section 2

#lorem(150)

#lorem(200)

= Literature review

#lorem(100)

#lorem(150)

#lorem(130)

= Methods

#lorem(200)

#lorem(300)

#lorem(200)

= Experiments and results

#lorem(250)

#lorem(250)

#lorem(50)

#lorem(125)

= Discussion

#lorem(300)

#lorem(120)

#lorem(200)

= Conclusion and future work

#lorem(100)

#lorem(150)

#lorem(100)

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

