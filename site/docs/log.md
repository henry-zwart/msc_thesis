## Dec 8 - Dec 14 2025

### Sunday
#### Representing causal implication in an Ising model
To model causal relations in an Ising model it is not sufficient to allow directional interaction terms
to vary independently. Suppose for beliefs $p$ and $q$ that we wish for the model to capture the relation

$$p \implies q$$

This is captured iff $p \vee \neg q$. That is, if the belief state is one of $\{(\neg p, \neg q), (\neg p, q), (p, q)\}$,
and is not $(p, \neg q)$. Suppose that beliefs take on the values $0$ (not believed) and $1$ (believed). Then for any 
asymmetric interaction weight $\omega_{p\to q} \cdot p\cdot q = 1 \Leftrightarrow p = q = 1$. In particular
the interaction energy is zero whenever one of the beliefs is not held, so is semantically different to the causal implication
we are trying to model.

Instead, we would like the interaction energy to be $1 \Leftrightarrow \neg p \vee q$. This can be achieved by redefining the 
interaction term as

$$\omega_{p\to q} \cdot [1 - p(1-q)]$$

Which follows from de Morgan's law, $\neg p \vee q \Leftrightarrow \neg (p \wedge \neg q)$. By inspection we see that the above
interaction term is $1$ whenever $p = 0$ or $q = 1$, satisfying the semantics of implication.

#### Distinction between not-believing and no-belief
While the meaning of "$X$ believes in $p$" is unambiguous, its converse is not. To say that $X$ does not believe in $p$ could 
either mean that they believe in $\neg p$ (e.g., $X$ believes that cats are the ideal pet, contrasts $X$ believes that cats are 
terrible pets), or that they have no strong beliefs concerning $p$ (e.g., $X$ has never owned a cat, so has no opinions either way).

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
