#let document-setup(
  title: "Document title",
  subtitle: none,
  author: "First-name Last-name",
  pdf_title: none,
  header_title: "Header title",
  header_logo: none,
  hide_plan: false,
  plan_font_fill: luma(140),
  body,
) = {
  set document(
    author: author, 
    title: {
      if pdf_title == none {title} else {pdf_title}
    },
  )
  
  // Page setup
  set page(
    paper: "a4",
    numbering: "1",
    columns: 1,
    margin: (x: 1.6cm, y: 1.8cm),
    header: {
      let header_img = box(header_logo)
      let header_title = text(
        size: 11pt, 
        weight: 100, 
        font: "Libertinus Serif", 
        context {
          if counter(page).get().first() == 1 {
              header_title
          } else {
              author
          }
        },
      )
      grid(
        columns: (auto, 1fr, auto),
        align: (left, center, right + top),
        header_img, h(1fr), header_title
      )
    }
  )

  set par(
    justify: true,
    justification-limits: (   // Character-level justification for tidier documents 
      tracking: (min: -0.01em, max: 0.02em),
    )
  )

  // Body text
  set text(font: "Libertinus Serif", size: 11pt)

  // Figures
  set figure(placement: auto)
  show figure.where(kind: image): it => {
    set text(size: 9pt)
    it
  }
  show figure.where(kind: table): it => {
    set text(size: 9pt)
    it
  }

  // Make urls blue
  show link: set text(fill: blue)

  // Planning/draft text
  // Show in a different colour to main text, or hide
  show <plan>: it => {
    set text(fill: plan_font_fill)
    if not hide_plan {
      it
    }
  }

  set math.equation(numbering: "(1)")

  show std.bibliography: set text(size: 10pt)
  set std.bibliography(title: text(10pt)[References])
  
  body
}

#let proposal(
  title: "Proposal title", 
  subtitle: none, 
  author: none, 
  supervisors: (),
  abstract: none,
  bibliography: none,
  body
) = {
  place(
    top,
    float: true,
    scope: "parent",
    clearance: 20pt,
    {
      set par(justify: false)
      block(width: 100%,
        align(center, {
          text(18pt, weight: "bold", title)
        })
      )
      v(1.5em)

      grid(
        columns: (auto, auto), 
        align: (right, left), 
        gutter: 1em,
          [*Author:*], author,
          [*Supervision team:*], supervisors.join(", ", last: ", and "),
      )
    })

  if abstract != none {
    [#text(weight: "semibold", [Abstract]) #h(0.5em) #{emph(abstract)}]
  }

  body

  // Show bibliography on a new page
  pagebreak()
  bibliography
}


#let report(
  title: "Report title", 
  subtitle: none, 
  author: none, 
  abstract: none,
  bibliography: none,
  body
) = {
  place(
    top,
    float: true,
    scope: "parent",
    clearance: 20pt,
    {
      set par(justify: false)
      block(width: 100%,
        align(center, {
          text(18pt, weight: "bold", title)
        })
      )
      v(1.5em)
    })

  if abstract != none {
    [#text(weight: "semibold", [Abstract]) #h(0.5em) #{emph(abstract)}]
  }

  body

  // Show bibliography on a new page
  pagebreak()
  bibliography
}

// Wrap content in 'plan' environment
// - Shows in a different colour from main text (luma(140), grey)
// - Can be hidden by passing `hide_plan: true` to proposal template
#let plan(body) = [#text(body) <plan>]

#let glossary(term, body) = link("https://henry-zwart.github.io/msc_thesis/glossary/#" + term, body)
