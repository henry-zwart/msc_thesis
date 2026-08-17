// TODO: Outline terminology, notation. e.g., vector notation, random variables, etc.
//
= Notation <sec:notation>

#{
  set text(size: 11pt)
  set list(spacing: 1.6em)
  [
    - *Scalars* are denoted using regular weight lowercase variables, e.g., $x$.

    - *Vectors* are denoted using boldface lowercase variables, e.g., $bold(x)$.

    - *Matrices* are denoted using boldface uppercase variables, e.g., $bold(X)$.

    - *Sets* are denotes using regular weight uppercase variables, e.g., $X$.

    - *Random variables* are denoted using the uppercase version of the sample variable,
      or the script typeface when the sample variable is uppercase. e.g., for a scalar $a$
      or vector $bold(a)$, we denote the random variable as $A$ or $bold(A)$, respectively,
      whereas for a set $B$ we denote the random variable as $cal(B)$.

    - Unless otherwise stated, $log$ refers to the natural logarithm.

    - For $n in NN$, $[n]$ denotes the *index set*, such that $[n] := {1, ..., n}$.

    We adopt specific notation for belief systems and beliefs. In particular:
    - *Models* are referred to using variants of the variable $cal(M)$, e.g., $cal(M)_"asymmetric"$.

    - *Generic beliefs*, in the generic concept sense, as discussed at the start of
      @sec:model-modelling-belief-system-dynamics, are denoted using the uppercase letter
      $S$.

    - *Particular beliefs*, in the specific instance sense, as discussed at the start of
      @sec:model-modelling-belief-system-dynamics, are denoted using the lowercase letter
      $s$.

    - *Belief random variables* are denoted using the symbol $sigma$, possibly with a
      subscript.

    - *Belief data variables*, as measured by a survey (for instance), and corresponding
      to a measurements of particular belief state, are denoted using the symbol $x$.

    For instance, the generic concept 'belief regarding the contents of the box' would be
    denoted as $S$. This takes on specific values, such as 'the box is empty', denoted as
    $s$, which are realisations of the random variable $sigma$. If we were to measure an
    individual's belief about the contents of the box, the data variable would be denoted
    as $x$.

  ]
}
