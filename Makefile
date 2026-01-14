# Expand prerequisites twice, so that we capture the '%' in wildcards
.SECONDEXPANSION:

# Each recipe runs in a single shell.
.ONESHELL:

REPORT_TYPES := proposal reading_summary climate-attitudes-eda
PRESENTATION_TYPES := project_plan
REPORTS = \
		$(patsubst %,outputs/reports/%.pdf, $(REPORT_TYPES)) \
		$(patsubst %,outputs/slides/%.html, $(PRESENTATION_TYPES)) \
		$(patsubst %,outputs/slides/%.pdf, $(PRESENTATION_TYPES))

SITE_REPORT_TYPES := proposal
SITE_PRESENTATION_TYPES := project_plan
SITE_REPORTS = \
		$(patsubst %,outputs/reports/%.pdf, $(SITE_REPORT_TYPES)) \
		$(patsubst %,outputs/slides/%.html, $(SITE_PRESENTATION_TYPES)) \
		$(patsubst %,outputs/slides/%.pdf, $(SITE_PRESENTATION_TYPES))


SITE_SOURCES = $(MKDOCS_CONFIG) $(wildcard site/**/*.md) $(wildcard site/*.md) \
          $(wildcard site/**/*.css) $(wildcard site/**/*.js)

.PHONY: clean serve extract-rdata all-reports

all: site/site/index.html all-reports

all-reports: $(REPORTS)

# Serve site locally
serve:
	uv run --group docs mkdocs serve -f site/mkdocs.yml

# Build site
site/site/index.html: $(SITE_REPORTS) $(SITE_SOURCES)
	@printf "Site    → Copying sources...\n"
	@for d in site/docs/reports site/docs/slides; do \
	  if [ -e "$d" ]; then \
	    printf "Site    → Error: $d already exists" >&2; \
	    exit 1; \
	  fi; \
	done
	@cp -r outputs/* site/docs
	@printf "Site    → Building site...\n"
	@uv run --group docs mkdocs build -f site/mkdocs.yml
	@printf "Site    → Done.\n"


# Compile project reports
outputs/reports/%.pdf: reports/%/main.typ \
			$$(wildcard reports/%/sections/*.typ) \
			| outputs/reports
	@printf "Compile → Report '$*'.\n"
	@$(MAKE) -C reports/$* && cp reports/$*/main.pdf $@

# Compile project presentations to PDF
outputs/slides/%.pdf: | outputs/slides
	@printf "Compile → Presentation '$*' to PDF.\n"
	@$(MAKE) -C presentations/$* main.pdf && cp presentations/$*/main.pdf $@

# Compile project presentations to HTML (for presenting)
outputs/slides/%.html: | outputs/slides
	@printf "Compile → Presentation '$*' to HTML.\n"
	@$(MAKE) -C presentations/$* main.html && cp presentations/$*/main.html $@


# == Create results and output directories
outputs/slides: outputs
	@mkdir outputs/slides

outputs/reports: outputs
	@mkdir outputs/reports

outputs:
	@mkdir outputs


# Extract climate attitudes Rdata 
extract-rdata: analysis/extract_ca_data.r
	@$(MAKE) results -C analysis


# Remove all generated files 
clean: 
	rm -rf outputs
	rm -rf site/site
	@$(MAKE) clean -C reports/proposal
	@$(MAKE) clean -C reports/reading_summary
	@$(MAKE) clean -C reports/climate-attitudes-eda
	@$(MAKE) clean -C presentations/project_plan

