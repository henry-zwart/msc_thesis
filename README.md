# Master's Thesis: 2025-2026

Work relating to my MSc. Computational Science Master's Thesis, completed over 2025-2026.

Whenever `main` receives new changes, all _completed_ reports are recompiled in GitHub CI and published 
at a [static site](https://henry-zwart.github.io/msc_thesis/) to ensure current versions 
are easily accessible. 

Ongoing or draft reports must be compiled locally, or accessed via the links below:

- $$\color{green}\text{(Public)}$$ [Project proposal](https://henry-zwart.github.io/msc_thesis/proposal.pdf)

> [!IMPORTANT]
> While this repository is private, the associated static site is *publicly-accessible*. 
> Access to unfinished/ongoing work is restricted by means of access to this repository.
> Such work should not be published to the static site; however, it is okay to publish 
> links which refer to documents stored directly in the repo, i.e., for which access is 
> authenticated by GitHub.


## Building reports locally

**Requirements:**
- [Typst](https://github.com/typst/typst) (>= v0.14.0)
- [uv](https://docs.astral.sh/uv/) (>= 0.9.0)

Report compilation is orchestrated with Make, so reproducing them is straightforward. 
To compile all reports, just run:

```sh
# The `-j` flag is used to compile the reports in parallel
make all-reports -j
```

Alternatively, you can generate an individual report by running `make reports/<REPORT>.pdf`. 
For instance:

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
