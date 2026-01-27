# Include environment variables from .env if exists 
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

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

ASSETS := \
		${CA_BUILT_ASSETS}/item.parquet \
		${CA_BUILT_ASSETS}/question.parquet \
		${CA_BUILT_ASSETS}/item_columns.parquet \
		${CA_BUILT_ASSETS}/participant.parquet \
		${CA_BUILT_ASSETS}/response.parquet 

.PHONY: clean serve data-assets all-reports

all: site/site/index.html all-reports

all-reports: $(REPORTS)

data-assets: $(ASSETS)

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


# Build climate attitudes data assets
${CA_BUILT_ASSETS}/response.parquet: src/climate_attitudes/builder/response.py \
			src/climate_attitudes/builder/schema.py \
			${CA_RAW_ASSETS}/w1w2w3w4w5_indices_weights_jul12_2022.parquet \
			${CA_BUILT_ASSETS}/question.parquet
	uv run cadata build response


${CA_BUILT_ASSETS}/participant.parquet: src/climate_attitudes/builder/participant.py \
			src/climate_attitudes/builder/schema.py \
			${CA_RAW_ASSETS}/w1w2w3w4w5_indices_weights_jul12_2022.parquet
	uv run cadata build participant

${CA_BUILT_ASSETS}/item_columns.parquet: src/climate_attitudes/builder/item_columns.py \
			src/climate_attitudes/builder/schema.py \
			${CA_STATIC_ASSETS}/item_columns.json \
			${CA_BUILT_ASSETS}/codebook.parquet 
	uv run cadata build item-columns


${CA_BUILT_ASSETS}/question.parquet: src/climate_attitudes/builder/question.py \
			src/climate_attitudes/builder/schema.py \
			${CA_BUILT_ASSETS}/codebook.parquet \
			${CA_BUILT_ASSETS}/item.parquet
	uv run cadata build question

${CA_BUILT_ASSETS}/item.parquet: src/climate_attitudes/builder/item.py \
			src/climate_attitudes/builder/schema.py \
			${CA_BUILT_ASSETS}/codebook.parquet \
			${CA_STATIC_ASSETS}/error_items.parquet \
			${CA_STATIC_ASSETS}/ideology_type.parquet \
			${CA_STATIC_ASSETS}/lee_2025_items.parquet
	uv run cadata build item

${CA_BUILT_ASSETS}/codebook.parquet: src/climate_attitudes/builder/codebook.py \
			src/climate_attitudes/builder/schema.py \
			${CA_RAW_ASSETS}/Codebook_220528.xlsx \
			| ${CA_BUILT_ASSETS}
	uv run cadata build codebook

${CA_BUILT_ASSETS}: 
	mkdir -p $@

${CA_RAW_ASSETS}/%.parquet: \
			rscripts/convert_rdata_to_parquet.r \
			${CA_RAW_ASSETS}/%.Rdata \
			.docker-r
	$(RUN_R) bash -c "Rscript -c $< /raw-data/$*.rdata /raw-data/$*.parquet"

.docker-r: rscripts/Dockerfile
	docker build -t msc-thesis-r rscripts && touch $@

# Remove all generated files 
clean: 
	rm -rf outputs
	rm -rf site/site
	@$(MAKE) clean -C reports/proposal
	@$(MAKE) clean -C reports/reading_summary
	@$(MAKE) clean -C reports/climate-attitudes-eda
	@$(MAKE) clean -C presentations/project_plan
	rm .docker-r

