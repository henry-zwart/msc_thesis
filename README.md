# Master's Thesis: 2025-2026

Reports relating to my MSc. Computational Science Master's Thesis, completed over 2025-2026.
These can be [viewed online](#view-online), or [built locally](#building-reports-locally).

## View online

Whenever `main` receives new changes, all reports are recompiled in GitHub CI and published 
at the following static links to ensure current versions are easily accessible:
- [Thesis proposal](https://henry-zwart.github.io/msc_thesis/proposal.pdf)


## Building reports locally

The reports are compiled using [Typst](https://github.com/typst/typst), and the 
compilation is orchestrated using Make. So long as you have Typst (v0.14.0) installed 
locally, you can rebuild all reports by running:

```sh
make
```

Or any individual report by running `make reports/<REPORT>.pdf`. For instance:

```sh
make reports/proposal.pdf
```

The compiled PDFs are located at `reports/<REPORT>.pdf`.
