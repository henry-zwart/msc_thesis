## Jan 12 - Jan 18 2026
### Monday

#### Weekly standup
Completed last week:

- Reading papers from Sara; ongoing, completed 4.5/5 ([#26](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=145733292&issue=henry-zwart%7Cmsc_thesis%7C26))
- Started 'reading summaries' document for critical reflection and notes on papers

This week:

- Finish reading papers from Sara ([#26](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=145733292&issue=henry-zwart%7Cmsc_thesis%7C26))
- Assess climate attitudes data for similar vars/beliefs as in above papers ([#27](https://github.com/henry-zwart/msc_thesis/issues/27))
- Review, summarise model families for belief modelling ([#31](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=148672585&issue=henry-zwart%7Cmsc_thesis%7C31))
- Continue broader literature review reading ([#28](https://github.com/henry-zwart/msc_thesis/issues/28))

## Jan 5 - Jan 11 2026
### Summary
#### Week overview
- A somewhat slow week, on account of a snowy Amsterdam, and easing back into study.
- Mostly working through the papers Sara shared prior to the holiday ([#26](https://github.com/users/henry-zwart/projects/5?pane=issue&itemId=145733292&issue=henry-zwart%7Cmsc_thesis%7C26)):
    - Progress: $3.5/5$ read, with plan to finish the remaining ones before Monday.
    - I noticed some potential methodological issues in Brandt et al. 
      2019[@brandtWhatCentralPolitical2019]. To discuss with Vítor?
- Some minor workflow updates:
    - Started writing short summaries for each paper, including some critical reflection, with 
      the intention that these feed into my writing later down the track (to view: 
      `make outputs/reports/reading_summary.pdf`).
    - Switched to using the ['mkdocs-bibtex'](https://github.com/shyamd/mkdocs-bibtex) plugin to 
      handle references in the project site (e.g., in the 
      [glossary](https://henry-zwart.github.io/msc_thesis/glossary/)), where I had previously been 
      using footnotes. This has a caveat that the plugin is no longer maintained. Given that there 
      exist no other plugins for this purpose, if I run into issues I may consider writing my own plugin,
      or potentially taking over maintenance of this one.

#### Next week
- Reviewing the nature of the beliefs/attitudes studied in the papers Sara has shared, and assessing
  the climate attitudes dataset for similar variables.
- Review model families used for modelling belief systems (e.g., Ising model, Bayesian network, partial 
  correlation network). Describe each and compare/contrast. Write up a short summary. 

### Sunday
- Finished van Noord et al. (2025)
- Wrote standup paragraph for upcoming week

### Friday
- Caught up with Shania over coffee
- Finished reading Powell et al. (2023), made summary
- Started reading van Noord et al. (2025)
- Read through document from Vítor regarding thesis introduction
- Thinking about writing plan going forward

#### Thoughts on writing plan
My project proposal had a tentative due date for my literature review of Feb 2. However, since both
the literature review and introduction should be targeted and overwhelmingly relevant to my thesis 
research, it doesn't make much sense to start properly drafting these until I have made progress on
my own work. 

Instead I should focus on the reading summaries I have started on this week, with the intention that
these should eventually feed into my writing. It is also safe to begin writing contained descriptions
of relevant background models (e.g., the Ising model, Bayesian networks, etc.) with the same intent.

To help ensure my summaries will be sufficient to inform my later writing it may also be worth reviewing
some texts on literature reviews and thesis writing.

### Thursday
- Reading Powell et al. (2023)
- Tried (unsuccessfully) to fix Typst autoformatting in neovim

### Wednesday
- Started on EDA/extraction of climate attitudes dataset
- Finished reading Brandt 2022
    - Found some possible issues in their statistical analysis due to choice of controls. Will
      detail in reading summaries report.

### Tuesday
- Mostly reading, summarising notes on Brandt et al. 2019
- Started on Brandt 2022
- Set up a new report for literature review reading summaries (`make outputs/reading_summary.pdf`)

### Monday
- Slow start, as I took the morning off to explore snowy Amsterdam.
- Started working through the papers Sara shared before the break. Today I've read Brandt et al. (2019).
- Katinka sent me Gabriela's thesis, and I've added this to my reading list in Zotero.

#### Weekly standup
Completed over holiday:

- R&R!
- Started planning literature review scope.

This week:

- Follow-up work from meeting with Sara:
    - Reading papers shared during meeting [#26](https://github.com/henry-zwart/msc_thesis/issues/26).
    - EDA on climate attitudes dataset (load data, understand content; assess for similar variables as used in papers 
      mentioned above) [#27](https://github.com/henry-zwart/msc_thesis/issues/27).
- Continue broader literature review reading [#28](https://github.com/henry-zwart/msc_thesis/issues/28).
- Add Gabriela Torres' thesis to reading list [#29](https://github.com/henry-zwart/msc_thesis/issues/29).


## Dec 15 - Dec 21 2025
### Wednesday
- Information theory exam - now finished with courses!
- Meeting with Vítor, Katinka, Kyuri, and Sara.

Meeting:

- Discussing this project and broader context of work for internal belief models/interventions.
- Fortnightly meetings planned with Vítor, Sara. Thursdays, 5-6pm, starting 22 January.

To-do:

- Identifying relevant variables in climate attitudes dataset, for comparison with existing belief state 
  models [#26](https://github.com/henry-zwart/msc_thesis/issues/26).
    - Read papers Sara sent regarding internal belief models of climate policy; identify other relevant literature.
    - Assess whether the climate attitudes dataset contains similar variables/factors to those used in this work. 
- EDA on climate attitudes dataset [#27](https://github.com/henry-zwart/msc_thesis/issues/27).
- Given variables identified above, which (causal/directed) structures make sense theoretically (e.g., star graphs as 
  'attractor' vs 'repeller').

Other notes:

- One of Vítor's previous students (Gabriela Torres) looked at causal relations in the climate 
  attitudes dataset, relating beliefs regarding (i) COVID-19 and (ii) climate policy, with trust in
  institutions(?) as a shared influence. Will be good to read her thesis.


## Dec 8 - Dec 14 2025
### Summary
#### Week overview:
- Prepared and presented a (not-so-)short presentation on project plan
- Reading up on cog. psychological and philosophical theories of belief
- Set up a few additional workflows in repo (glossary, presentations)
- Thinking about representing causal implications in Ising model 

#### Next week:
- Mostly exam prep Monday + Tuesday, then done with courses from Wednesday!
- After that, continue reading for literature review 
- Ask about example literature reviews, e.g., from past students, or in general.

### Sunday
#### Representing causal implication in an Ising model
To model causal relations in an Ising model it is not sufficient to allow directional interaction terms
to vary independently. Suppose for beliefs $p$ and $q$ that we wish for the model to capture the relation

$$p \implies q$$

The interaction energy with weight $\omega_{p \to q}$ is typically modelled as

$$h_{p\to q} = \omega_{p\to q} \cdot p\cdot q$$

We also consider the following alternative formulation, derived according to de Morgan's law to explicitly 
preserve the relationship $(p \implies q) \Leftrightarrow (\neg p \vee q)$:

$$h_{p\to q}' = \omega_{p\to q} \cdot [1 - p(1-q)]$$

Suppose that belief states are $1$ (believes) and $0$ (doesn't believe), then these relations are defined by 
the following truth table

<div class="centre-table" markdown>

| $p$   | $q$   | $p \implies q$   | $h_{p\to q}$ | $h_{p\to q}'$ |
| :---: | :---: | :--------------: | :---:        | :---:         |
| $1$   | $1$   | $1$              | $1$          | $1$           |
| $1$   | $0$   | $0$              | $0$          | $0$           |
| $0$   | $1$   | $1$              | $0$          | $1$           |
| $0$   | $0$   | $1$              | $0$          | $1$           |

</div>

Thus $h_{p\to q}$ fails to capture the semantics of implication, while $h_{p\to q}'$ does capture these 
for belief states of $\{0, 1\}$. 

#### Distinction between not-believing and no-belief
While the meaning of "$X$ believes in $p$" is unambiguous, its converse is not. Suppose $p$ is the belief:

  _"Cats are the ideal pet."_

To say that $X$ does not believe in $p$ could either mean that they believe in $\neg p$:

  _"Cats are terrible pets."_

or that they have no strong beliefs, either way, concerning cats as pets.

This raises the question of whether we can simply collapse these two interpretations for modelling purposes. However, this seems 
unlikely. For instance, an individual can "hold a belief without subscribing to all of its consequents" (need to find where this 
quote was from --- Alan Musgrave?). In other words, we can adopt a belief in $p$ before accepting the beliefs that $p$ implies. 

On the other hand, it is intuitively different to adopt a belief which implies a consequent $q$, when one a priori believes $\neg q$.
In the first case, $p$ can be adopted or not adopted with no resulting change in the belief system energy. In the second, adopting $p$
causes a decrease (increase) in the system energy. 

This suggests that what we instead want is a way to represent ambivalent beliefs such that their interaction energy with positive 
and negative antecedents is identical, and equal to the interaction energy of a consistent belief relation. 


### Friday
- Finished presentation
- Presented project plan
- Reading: cognitive science + philosophical theories of belief

### Tuesday
- Began working on a short presentation for Friday.

### Monday
- Looking at cognitive theories of belief and belief change
    - Appears to be support for the notion that in order to change a belief, it 
      is not always necessary to intervene directly on that belief (i.e., causal 
      relations are important). Furthermore that intervening on a belief directly 
      can cause a blow-back effect, since this 'reactivates' the prior belief.
- Have started a [glossary](glossary.md) to keep track of relevant terminology.

## Dec 1 - Dec 7 2025 
### Summary
#### Week overview:
- Confirmed that I have access to the climate attitudes data already.
- Set up research log to track progress and issues, and static site to collate information 
  on the project.
- Started thinking about literature review; read paper[^1] on the topic. 

#### Next week:
- Identify areas to explore in literature review; questions to answer.
- Continue reading.

### Sunday
- Read paper on how to write literature reviews[^1].

[^1]: J. W. Knopf, “Doing a Literature Review,” APSC, vol. 39, no. 1, pp. 127–132, Jan. 2006, doi: 10.1017/S1049096506060264 

### Tuesday
- Confirmed that I already have access to the climate attitudes data (on OneDrive).
- Created project log to track progress, identify issues.
- Created (this) static site to collate information & reports related to 
  the project.

## Nov 24 - Nov 30 2025
### Summary
#### Week overview:
- Submitted thesis proposal, and had it accepted
- Confirmed examiner (Johan Bollen) and assessor (Sara Constantino)

#### Next week:
- Access plan for climate attitudes data, incl. privacy/governance/usage conditions.
- Literature review planning

#### Notes for Monday stand-up:
- Joined remotely due to appointment
- Working part-time on project while I finish my final course. I expect to 
    be full-time on research from January.

### Sunday
- Submitted project proposal
- Project proposal accepted

### Saturday
- Confirm examiner (Johan Bollen) and assessor (Sara Constantino)
- Final draft of project proposal
