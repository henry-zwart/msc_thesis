#let proposal(
  title: "Proposal title", 
  subtitle: none, 
  author: none, 
  header_logo: none,
  bibliography: none,
  bib_style: "ieee",
  body
) = {
  set document(author: author, title: title)
  
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
        author,
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

  set math.equation(numbering: "(1)")

  show std.bibliography: set text(size: 10pt)
  set std.bibliography(title: text(10pt)[References], style: bib_style)

  place(
    top,
    float: true,
    scope: "parent",
    clearance: 20pt,
    {
      block(width: 100%,
        align(center, {
          text(22pt, weight: "bold", title)
          linebreak()
          if subtitle != none {
            v(0.5em)
            text(16pt, subtitle)
          }
        })
      )
    })

  body

  bibliography
}
