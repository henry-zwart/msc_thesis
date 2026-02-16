#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.2": *
#import themes.university: *

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()


// Check if 'hand-out' mode specified in sys inputs. If so, collapse slide animations.
#let handout = json.decode(sys.inputs.at("handout", default: "false"))

#show: university-theme.with(
  aspect-ratio: "16-9",
  align: horizon,
  config-common(handout: handout),
  config-info(
    title: [Asymmetric networks of beliefs],
    subtitle: [Echo talk],
    author: [Henry Zwart],
    date: datetime.today(),
    institution: [MSc. Computational Science],
  ),
  config-common(
      slide-fn: slide.with(
        setting: body => {
          // Fix moving list items when using pause
          set par(spacing: 1.2em)
          set list(spacing: 1em)
          body
        },
      ),
    ),
)

//#show: simple-theme.with(aspect-ratio: "16-9")

#title-slide()
#set par(spacing: 1.2em)
== Reminder of research goals

- Identify climate-change belief systems: How do beliefs and attitudes relate/reinforce,
  and how does this vary across population groups? 

- Measure (simulated) implications of belief system structure on behavioural intervention 
  effectiveness and outcome.

- Validate findings regarding effective intervention against related experimental work, and 
  classical theories of belief change.

== So far . . .

+ Data preparation

+ Initial exploratory data analysis 

== Data validation

Longitudinal data comprises six waves with variable participation.

Over 600 questions, which can vary with:
+ Different waves,
+ New and repeating participants,
+ Responses to other questions,
+ Experimental treatment.

*Validation* required to ensure that:
+ Questions are displayed exactly when we expect, and 
+ All responses fit the expected format.

== Data validation: Stage 1 (Schema)
Check that the expected columns are present with the correct data type, and all non-null 
response values are valid.

*Pandera* schema does most of the heavy lifting. 

#{
  set text(size: 12pt)
  [
    #codly(languages: codly-languages)
    ```python
    class ResponseSchema(BaseSchema):
        response_id: pl.UInt32
        wave: int = pa.Field(isin=WAVES)
        participant_id: pl.UInt32                                       # Columns are non-nullable by default
        dem_age: int = pa.Field(gt=0, le=99)                            # Age limits as specified in codebook
      
        cc1: int = pa.Field(isin=[0, 1, 99], nullable=True)             # Q: Climate change is happening (T/F/?)
        cc_scam: int = pa.Field(isin=[1, 2, 3, 4, 5], nullable=True)    # Q: Climate change is a scam 
        ...

    ResponseSchema.validate(response_df)                                # Falls over if any schema req. not met 
    ```
  ]
}

== Data validation: Stage 2 (null response $<==>$ null expected)
Question responses should be non-null iff 
- Question is shown (in wave, to participant type), and 
- Any conditional-display logic is satisfied.

*Three checks:*
$
"Not asked in wave" &==> "response is null" \

"Conditional logic not satisfied" &==> "response is null" \

"Question is displayed" &==> "response is not null"
$

Identifies 33 errors among 163 questions currently considered.

== Additional data cleaning

*Null ID participants:* Removed from dataset since cannot be linked across waves. 

*Treatment columns:*
- Coalesced treatment-specific responses into single column, and treatment indicators into an index column. 
- Added `variant` columns for real-valued treatments (e.g. policy costs). 

#{
  set text(size: 16pt)
  grid(
    rows: 2,
    columns: (1.75fr, 1fr),
    row-gutter: 0.5em,
    align: horizon,
    [*Before*],
    [*After*],
    image("figures/coalesce_before.png"),
    image("figures/coalesce_after.png"),
  )
}

*Categorical columns:* Converted integer-valued responses to enums: 
+ Human-readability, and
+ Consistent category values across waves. 

#{
  set text(size: 16pt)
  grid(
    rows: (1em, auto),
    columns: (1fr, 2.23fr),
    row-gutter: 0.5em,
    column-gutter: 1em,
    align: horizon,
    [*Before*],
    [*After*],
    image("figures/enums_before.png", height: 50%),
    image("figures/enums_after.png", height: 50%),
  )
}

== Mapping survey questions to cognitive states
Working from #cite(<leeVariationsClimateChange2025>, form: "author") (2025) as basis paper. 

Eight cognitive states:

#{
  set text(size: 16pt)
  figure(table(
    columns: 3,
    align: (left, left, center),
    stroke: none,
    row-gutter: 0.25em,
    table.header[*Type*][*State*][*Well-represented*],
    table.hline(),
    [Belief], [Climate change is happening], [$checkmark$],
    [], [Climate change is anthropogenic], [$checkmark$],
    table.hline(),
    [Risk perception], [Climate change worry], [$checkmark$],
    [], [Climate change personal harm], [],
    [], [Climate change future gen. harm], [$checkmark$],
    table.hline(),
    [Policy support], [Fossil fuel reduction], [],
    [], [Renewable energy increase], [],
    [], [Govt. priority for climate change], [],
  )
)
}

*Criteria:* Assessed in multiple waves, positive/negative responses both meaningful.

== Lee 2025 representative questions: Pairwise correlation 

#figure(
  image("figures/lee_correlations.pdf")
)

== Lee 2025 representative questions: Response transitions

#figure(
  image("figures/lee_transitions.pdf")
)

== Extended question set

#figure(
  image("figures/all_corr.pdf")
)


== References

#show bibliography: set text(size: 16pt) 
#bibliography("references.bib")
