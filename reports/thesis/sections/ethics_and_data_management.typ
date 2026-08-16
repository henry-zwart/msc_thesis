// A new requirement for the thesis is that there must be a short section in which you
// reflect on the ethical aspects of your project. This requirement is related to one of
// the final objectives that a graduated student of the Master of Computational Science
// must meet: “The graduate of the program has insight into the social significance of
// Computational Science and the responsibilities of experts in this field within science
// and in society". You don't need to devote an entire chapter to this; a short section
// or paragraph is sufficient.

#let ethics-in-research = footnote[
  Ethics in Research at UvA: #link("https://student.uva.nl/en/topics/ethics-in-research")
]

#let rda-policies = footnote[
  Research data management policies at UvA: #link("https://rdm.uva.nl/en")
]
#let nl-code-of-conduct-integrity = footnote[
  Netherlands Code of Conduct for Research Integrity:
  #link("https://www.nwo.nl/en/netherlands-code-of-conduct-for-research-integrity")
]


I acknowledge that the thesis adheres to the ethical code and research data management
policies of UvA and IvI.#ethics-in-research#super[,]#rda-policies

Where our findings relate to real phenomena we have clarified the context of
interpretation, as is necessary in all research using computational modelling to address
questions about the natural world. During the production of this thesis we have
been committed to the standards outlined in the Netherlands Code of Conduct for Research
Integrity.#nl-code-of-conduct-integrity In addition, generative AI has not been used for
any aspect of this thesis.

The following table lists the data used in this thesis (including source code).
I confirm that the list is complete and the listed data are sufficient to reproduce
the results of the thesis.

#show table: set text(size: 9pt)
#set table(stroke: none)
#table(
  columns: (0.7fr, 0.45fr, 0.2fr),
  align: left,
  table.header[Description][Availability][License],
  table.hline(stroke: 0.5pt),
  [Ising Python package, KBS model implementation],
  [DOI: 10.5281/zenodo.21933349],
  [MIT],
  [Repository with experiment code, thesis documents],
  [DOI: 10.5281/zenodo.21933642],
  [MIT],
  [Typst thesis template],
  [DOI: 10.5281/zenodo.21933474],
  [MIT],
  [Longitudinal Panel of Perceptions About Climate Change and Covid survey],
  [Available on request],
  [N/A],
)
