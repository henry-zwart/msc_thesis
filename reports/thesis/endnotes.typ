////////////////////////////////////////////////////////////////////
// Test harness for endnote development
//   based on work by bluss and nleanda, with help from many others
//
//   There are no external dependencies, although the code is
//   easily adaptable to the margialia and hydra packages.
////////////////////////////////////////////////////////////////////
//
// Endnote options, the last of each group is the default
//
//   RESET at each level-1 heading
#let ENRESET = true  // reset the displayed note numbers
#let ENRESET = false   // default false, true with caution
//
//   HEADERS in notes chapter
#let ENHEADERS = false // no special headers
// #let ENHEADERS = "note"// Note 23  or  Notes 36--52
// #let ENHEADERS = "page"// Notes for page 23  or  Notes for pages 36--52
// #let ENHEADERS = "both"// Notes for page 23   Notes 36--52
//
//  NUMBERING, any Typst #numbering regime, default "1"
//    if array, first applies to text flag, last to notes display
#let ENNUMBERING = ("1", "①") // example
#let ENNUMBERING = ("1", "i") // example
#let ENNUMBERING = "1"       // default
//
//   CHAPTERS show chapter breaks as level 2 heads in notes
#let ENCHAPTERS = false // no chapter breaks as sections
//#let ENCHAPTERS = true  // display chapter breaks as sections
//
//   Message defaults
//    if you have notes before the first chapter, perhaps set this
#let ENHEAD = none
//#let ENHEAD = [Endnotes, by note number]
//
//   English literals, change as you like
#let ENPANICPAGE = "ERROR: note page numbers, no page numbering"
#let ENINTRO = []
#let ENCHAPTERTITLE = [Notes]
#let ENSECTIONTITLE = [#smallcaps[Notes for]]
#let ENNOTE = [Note]
#let ENNOTES = [Notes]
#let ENNOTESFORPAGE = [Notes for page]
#let ENNOTESFORPAGES = [Notes for pages]

////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
// utility functions
//   llap protrudes its body into the left margin

#let llap(body) = {
  show: box.with(width: 0pt)
  show: align.with(right)
  body
}

// endnotes are numbered, so use * † ‡ sequence for footnotes
//    use std.footnote, footnote may be redefined for outline issues
#set std.footnote(numbering: "*")

// key contribution from nleanba, enables referencability
#show ref: it => {
  if it.element != none and it.element.func() == metadata {
    link(it.element.location())[#it.element.value]
  } else {
    it
  }
}

#let encnt = counter("endnote")
#let encnt-serial = counter("endnote-serial")

#let endnote(body, enref: none) = {
  encnt.step()
  encnt-serial.step()
  context {
    let enpagenum = str(here().page()) // from beginning of doc
    let enpagefmt = counter(page).display()
    let enserial = str(encnt-serial.get().first())
    let endflag = std.numbering(ENNUMBERING.first(), ..encnt.get())
    let endisplay = std.numbering(ENNUMBERING.last(), ..encnt.get())
    let labelname = "_endnote:serial:" + enserial
    let link = x => x
    if query(label(labelname)).len() > 0 {
      link = std.link.with(label(labelname))
    }
    // style endnote flag here
    link[#super(endflag)]
    [#metadata((
      endisplay: endisplay, // displayed endnote number
      enserial: enserial, // sequential number
      enpagefmt: enpagefmt, // origin page formatted
      enpagenum: enpagenum, // origin page integer
      enref: enref, // optional reference string
      labelname: labelname, // unique label string
      content: body, // text of the endnote
    ))<_endnote>]
  }
}

#let split-array-by(arr, func) = {
  let chunks = ()
  let chunk = ()
  for elt in arr {
    if func(elt) {
      if chunk != () { chunks.push(chunk) }
      chunk = ()
    }
    chunk.push(elt)
  }
  if chunk != () { chunks.push(chunk) }
  chunks
}

#let showendnote(note) = {
  show link: set text(size: 10pt)
  let link = link.with(note.location())
  let item = note.value
  let data = (item.enserial, item.endisplay, item.enpagenum, item.enpagefmt)
  if item.enref != none {
    [#metadata([#item.endisplay])#label(item.enref)]
  }
  [#metadata((data))<en-start>]
  // style endnote number here
  h(1em)
  llap[#link[#str(item.endisplay)#sym.space.en]#label(item.labelname)]
  h(0pt, weak: true) // allows newline after [
  item.content
  [#metadata((data))<en-end>]
}

#let show-heading(head) = {
  let num = none
  if head.numbering != none {
    num = " " + std.numbering(head.numbering, ..counter(heading).at(head.location())) + ":"
  }
  heading(level: 2)[#ENSECTIONTITLE#num #head.body]
  //heading(level: 2)[#smallcaps[Notes for]#num #head.body]
}
//===============================================

#let make-notes(
  enintro: ENINTRO,
  // use enhead to introduce notes before the first chapter
  enhead: ENHEAD,
) = {
  //remove this test if you have numbering where notes are
  //  generated but not for the notes display
  context [#if (
    page.numbering == none
      and (
        ENHEADERS == "page" or ENHEADERS == "both"
      )
  ) {
    panic(ENPANICPAGE)
    return none
  }]
  let placenoteheads(had, hdb) = {
    if calc.odd(here().page()) {
      emph(hdb)
      h(1fr)
      emph(had)
    } else {
      emph(had)
      h(1fr)
      emph(hdb)
    }
  }
  let format-header(a, b) = {
    // a and b are (enserial, endisplay, enpagefmt, enpagenum)
    // a and b are arrays of strings with integer values
    //  serial numbers for compare, formatted for display
    let fn = a.at(0)
    let ffn = a.at(1) // first note
    let fp = a.at(2)
    let ffp = a.at(3) // first page
    let ln = b.at(0)
    let fln = b.at(1) // last note
    let lp = b.at(2)
    let flp = b.at(3) // last page

    if ENHEADERS == "page" {
      if fp == lp {
        placenoteheads([#ENNOTESFORPAGE #ffp], [])
      } else {
        placenoteheads([#ENNOTESFORPAGES #ffp -- #flp], [])
      }
    } else {
      if ENHEADERS == "note" {
        if fn == ln {
          placenoteheads([#ENNOTE #ffn], [])
        } else {
          placenoteheads([#ENNOTES #ffn -- #fln], [])
        }
      } else {
        if ENHEADERS == "both" {
          if fp == lp {
            if fn == ln {
              placenoteheads([#ENNOTESFORPAGE #ffp], [#ENNOTE #ffn])
            } else {
              placenoteheads([#ENNOTESFORPAGE #ffp], [#ENNOTES #ffn -- #fln])
            }
          } else {
            if fn == ln {
              placenoteheads([#ENNOTESFORPAGES #ffp -- #flp], [#ENNOTE #ffn])
            } else {
              placenoteheads([#ENNOTESFORPAGES #ffp -- #flp], [#ENNOTES #ffn -- #fln])
            }
          }
        }
      }
    }
  }
  set page(
    header: context {
      let is-start-chapter() = (
        query(
          heading.where(level: 1).after(here()),
        )
          .map(h => h.location().page())
          .at(0, default: 0)
          == here().page()
      )
      if is-start-chapter() {
        return
      }
      let notenums = query(selector.or(<en-start>, <en-end>))
        .filter(x => x.location().page() == here().page())
        .map(x => x.value)
        .dedup()
      if notenums.len() > 0 {
        return format-header(notenums.at(0), notenums.at(-1, default: none))
      }
      // No paragraph starting or ending on this page
      // -> check if a paragraph starts before and ends after this page
      let prevs = query(selector(<en-start>).before(here()))
      let nexts = query(selector(<en-end>).after(here()))
      if prevs.len() == 0 or nexts.len() == 0 {
        return none
      }
      let prev = prevs.last().value
      let next = nexts.first().value
      if prev != next {
        // should not happen perhaps assert here
        return none
      }
      return format-header(prev, next)
    },
  ) if ENHEADERS != false //

  //===============================================
  //
  // heading(level: 1)[#ENCHAPTERTITLE]
  // if enintro != none {
  //   enintro
  //   parbreak()
  // }
  v(1fr)
  line(length: 30%, stroke: 0.5pt)
  context {
    if enhead != none {
      heading(level: 2, [#enhead])
    }
    let headings-and-endnotes = query(
      selector.or(heading.where(level: 1), <_endnote>),
    )
    // //  next test allows one endnote before the first chapter
    // if headings-and-endnotes.at(0).func() == metadata {
    //   showendnote(headings-and-endnotes.at(0))
    //   let _ = headings-and-endnotes.slice(1)
    // }
    let chunks = split-array-by(headings-and-endnotes, elt => elt.func() == heading)
    for chunk in chunks {
      if chunk.len() <= 1 { continue }
      if ENCHAPTERS { show-heading(chunk.at(0)) }
      let notes = chunk //.slice(1)
      set par(first-line-indent: 0em, spacing: 10pt)
      notes.map(note => { showendnote(note) }).join(parbreak())
    }
  }
}
//
// End endnote setup
///////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
// Begin layout preamble
//
#show heading.where(level: 1): it => {
  if ENRESET { encnt.update(0) }
  it
}

//#set page(numbering: "1")
//#set heading(numbering: "1.1")

This precedes chapter 1 and has an endnote.#endnote[Before chapter 1.]

#make-notes()

// = A chapter
//
// #lorem(10)#endnote[
//   Endnotes can be have columnar material:
//   #linebreak()
//   #columns(2, gutter: 8pt)[#lorem(20)#colbreak()#lorem(25)
//   ]
// ]

// #lorem(10)#endnote(enref: "en:123")[Here is a endnote with a figure:
//   #figure(
//     table(
//       columns: 4,
//       [t], [1], [2], [3],
//       [y], [0.3s], [0.4s], [0.8s],
//     ),
//     caption: [Timing results],
//   )
// ]
//
// #lorem(10)#endnote[And an endnote with an endnote:#endnote[But why?]]
//
// // #lorem(10)#endnote[And an endnote with an endnote with an endnote:#endnote[But why?#endnote[Fails]]]
//
// #lorem(10)#endnote[
//   And an endnote with an footnote:#footnote[Buy what?]]
//
// #lorem(10)#endnote[
//   As you can see, endnotes can be pretty long.
//   #lorem(500)
//
//   #lorem(600)
// ]
//
// #lorem(200)
//
// = Second chapter
//
// This chapter has no endnotes.
//
// = Third chapter
//
// #lorem(200)#endnote[Also see the discussion at note
//   @en:123.] #lorem(10)
//
// #lorem(10)
//
// #lorem(200)#endnote[And another #lorem(200)]
//
// #lorem(10)#endnote[And another #lorem(200)]
//
// #lorem(10)#endnote[And another #lorem(100)]
//
// #lorem(10)#endnote[And another #lorem(100)]
//
// #lorem(200)#endnote[And another #lorem(100)]
//
// #lorem(10)#endnote[And another #lorem(100)]
//
// #lorem(10)#endnote[And another #lorem(100)]
//
// #lorem(10)#endnote[And another #lorem(100)]
//
// #lorem(10)#endnote[And another #lorem(100)]
//
// #lorem(10)#endnote[And another #lorem(30)]
