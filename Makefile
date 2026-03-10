# Include environment variables from .env if exists 
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Expand prerequisites twice, so that we capture the '%' in wildcards
.SECONDEXPANSION:

# Each recipe runs in a single shell.
.ONESHELL:

RUN_R := docker run -it --rm  -v $$(pwd):/code -v ${CA_RAW_ASSETS}:/raw-data -w /code msc-thesis-r:latest

REPORT_TYPES := proposal reading_summary climate-attitudes-eda
PRESENTATION_TYPES := project_plan  # collider-bias feb-echo-talk
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

ASSETS := \
		${CA_BUILT_ASSETS}/item.parquet \
		${CA_BUILT_ASSETS}/question.parquet \
		${CA_BUILT_ASSETS}/columns.parquet \
		${CA_BUILT_ASSETS}/participant.parquet \
		${CA_BUILT_ASSETS}/response.parquet 

.PHONY: clean serve data-assets all-reports

all: site/site/index.html all-reports

all-reports: $(REPORTS)

data-assets: $(ASSETS)

# Serve site locally
serve:
	uv run --only-group docs mkdocs serve -f site/mkdocs.yml

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
	@uv run --only-group docs mkdocs build -f site/mkdocs.yml
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
outputs/slides: | outputs
	@mkdir -p outputs/slides

outputs/reports: | outputs
	@mkdir -p outputs/reports

outputs:
	@mkdir -p outputs


# Extract raw climate attitudes data
${CA_BUILT_ASSETS}/.extract: src/climate_attitudes/schema/extract.py \
			${CA_RAW_ASSETS}/w1w2w3w4w5_indices_weights_jul12_2022.parquet \
			${CA_RAW_ASSETS}/Codebook_220528.xlsx \
			${CA_STATIC_ASSETS}/item_columns.json \
			${CA_STATIC_ASSETS}/error_items.csv \
			${CA_STATIC_ASSETS}/ideology_type.csv \
			${CA_STATIC_ASSETS}/lee_2025_items.csv \
			| ${CA_BUILT_ASSETS}/extract
	uv run cadata extract && touch $@


${CA_BUILT_ASSETS}/extract: 
	mkdir -p $@

# == Convert Rdata response files to parquet.
# WARNING: Takes ~12 minutes
#
# ${CA_RAW_ASSETS}/%.parquet: \
# 			rscripts/convert_rdata_to_parquet.r \
# 			${CA_RAW_ASSETS}/%.Rdata \
# 			.docker-r
# 	$(RUN_R) bash -c "Rscript $< /raw-data/$*.rdata /raw-data/$*.parquet"
#
# .docker-r: rscripts/Dockerfile
# 	docker build -t msc-thesis-r rscripts && touch $@

# Remove all generated files 
clean: 
	rm -rf outputs
	rm -rf site/site
	@$(MAKE) clean -C reports/proposal
	@$(MAKE) clean -C reports/reading_summary
	@$(MAKE) clean -C reports/climate-attitudes-eda
	@$(MAKE) clean -C presentations/project_plan
	rm .docker-r
	rm ${CA_BUILT_ASSETS}/.extract

