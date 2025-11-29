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

## Contributing

This project uses [pre-commit](https://pre-commit.com/) to ensure no pesky typos 
or PEP8-violating code chunks make it through into GitHub. Pre-commit will run 
automatically whenever you commit code, but only if it is installed _and_ initialised 
for this repo. Note, the following instructions assume you are using [uv](https://docs.astral.sh/uv/) 
to handle your Python environments (we strongly recommend you do). If this isn't the case, 
substitute the first step for the instructions on the pre-commit [installation page](https://pre-commit.com/#install). 

```sh
# We can use uv to install pre-commit!
$ uv tool install pre-commit --with pre-commit-uv --force-reinstall

# Check that pre-commit installed alright (should say 4.5.0 or similar)
$ pre-commit --version

# After installing pre-commit, you'll need to initialise it.
# This installs all pre-commit hooks, the scripts which run before a commit.
$ pre-commit install

# It's a good idea to run pre-commit now on all files.
$ pre-commit run --all-files
```
