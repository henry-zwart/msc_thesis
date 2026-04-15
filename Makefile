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

REPORT_TYPES := thesis
#proposal reading_summary climate-attitudes-eda

PRESENTATION_TYPES := project_plan april-enlens-talk  # collider-bias feb-echo-talk

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


QUARTO_REPORTS := \
		outputs/reports/index_eda_full/index_eda.html \
		outputs/reports/index_eda_reduced/index_eda.html \
		outputs/reports/index_eda_reduced_no_imputation/index_eda.html \
		outputs/reports/indices/indices.html
QUARTO_REPORTS := outputs/reports/index_eda_reduced_no_imputation/index_eda.html  \
		outputs/reports/indices_no_imputation/indices.html \
		outputs/reports/indices/indices.html


DATASETS := \
	    ${CA_BUILT_ASSETS}/base/metadata.json \
	    ${CA_BUILT_ASSETS}/full_imp/metadata.json \
	    ${CA_BUILT_ASSETS}/reduced/metadata.json \
	    ${CA_BUILT_ASSETS}/reduced_imp/metadata.json \
	    ${CA_BUILT_ASSETS}/reduced_no_imputation/metadata.json \
	    ${CA_BUILT_ASSETS}/behaviour/metadata.json \
	    ${CA_BUILT_ASSETS}/behaviour_imp/metadata.json

.PHONY: clean serve data-assets quarto-reports all-reports

all: site/site/index.html outputs/project_timeline.png all-reports quarto-reports

all-reports: $(REPORTS)

quarto-reports: $(QUARTO_REPORTS)

data-assets: $(DATASETS)

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
	@uv run --only-group docs mkdocs build -f site/mkdocs.yml --quiet
	@printf "Site    → Done.\n"


# Compile project timeline
outputs/project_timeline.png: \
			timeline/main.typ \
			timeline/gantt.yaml \
			| outputs
	typst compile $< $@ -f png


# Compile project reports
outputs/reports/%.pdf: reports/%/main.typ \
			$$(wildcard reports/%/sections/*.typ) \
			| outputs/reports
	@printf "Compile → Report '$*'.\n"
	@$(MAKE) -C reports/$* && cp reports/$*/main.pdf $@

# Compile project presentations to PDF
outputs/slides/%.pdf: \
			presentations/%/main.pdf \
			| outputs/slides
	cp presentations/$*/main.pdf $@

outputs/slides/%.html: \
			presentations/%/main.html \
			| outputs/slides
	cp presentations/$*/main.html $@

include presentations/april-enlens-talk/Makefile
include presentations/project_plan/Makefile

include Makefile.experiments


# outputs/reports/index_eda_%/index_eda.html: \
# 			reports/index-eda/index_eda.qmd \
# 			${CA_BUILT_ASSETS}/%_imp/metadata.json \
# 			| outputs/reports
# 	@printf "Quarto  → Build 'index_eda_$*.html'...\n"
# 	@uv run quarto render $< \
# 			--execute-daemon-restart \
# 			--output-dir index_eda_$* \
# 			-P ds_name:$* && \
# 		printf "Quarto  → Removing old 'index_eda_$*.html'...\n"
# 		rm -rf $(@D) && \
# 		printf "Quarto  → Moving new 'index_eda_$*.html' to destination...\n"
# 		mv reports/index-eda/index_eda_$* $(@D)

include Makefile.quarto

# outputs/reports/index_eda_reduced_no_imputation/index_eda.html: \
# 			reports/index-eda/index_eda.qmd \
# 			${CA_BUILT_ASSETS}/reduced_no_imputation/metadata.json \
# 			| outputs/reports
# 	@printf "Quarto  → Build 'index_eda_reduced_no_imputation.html'...\n"
# 	@uv run quarto render $< \
# 			--execute-daemon-restart \
# 			--output-dir index_eda_reduced_no_imputation \
# 			-P ds_name:reduced_no_imputation && \
# 		printf "Quarto  → Removing old 'index_eda_reduced_no_imputation.html'...\n"
# 		rm -rf $(@D) && \
# 		printf "Quarto  → Moving new 'index_eda_reduced_no_imputation.html' to destination...\n"
# 		mv reports/index-eda/index_eda_reduced_no_imputation $(@D)
#
# outputs/reports/indices/indices.html: \
# 			reports/indices/indices.qmd \
# 			${CA_BUILT_ASSETS}/reduced_imp/metadata.json \
# 			| outputs/reports
# 	@printf "Quarto  → Build 'indices.html' (with imputation)...\n"
# 	@uv run quarto render $< \
# 			--execute-daemon-restart \
# 			--output-dir indices \
#  			-P with_imputation:true && \
# 		printf "Quarto  → Removing old 'indices.html'...\n"
# 		rm -rf $(@D) && \
# 		printf "Quarto  → Moving new 'indices.html' to destination...\n"
# 		mv reports/indices/indices $(@D)
#
# outputs/reports/indices_no_imputation/indices.html: \
# 			reports/indices/indices.qmd \
# 			${CA_BUILT_ASSETS}/reduced_no_imputation/metadata.json \
# 			| outputs/reports
# 	@printf "Quarto  → Build 'indices.html' (no imputation)...\n"
# 	@uv run quarto render $< \
# 			--execute-daemon-restart \
# 			--output-dir indices \
#  			-P with_imputation:false && \
# 		printf "Quarto  → Removing old 'indices.html'...\n"
# 		rm -rf $(@D) && \
# 		printf "Quarto  → Moving new 'indices.html' to destination...\n"
# 		mv reports/indices/indices $(@D)

# === Thesis ===
include Makefile.thesis

# == Create results and output directories
outputs/slides: | outputs
	@mkdir -p outputs/slides

outputs/reports: | outputs
	@mkdir -p outputs/reports

outputs:
	@mkdir -p outputs

# === Dataset construction ===
include Makefile.dataset

# ${CA_BUILT_ASSETS}/behaviour_imp/metadata.json: \
# 			${CA_BUILT_ASSETS}/base/metadata.json \
# 			src/climate_attitudes/datasets/behaviour.py
# 	@printf "Dataset → Build CC behaviour dataset (imputed)...\n"
# 	@uv run cadata create dataset --name behaviour --force --with-imputation
#
# ${CA_BUILT_ASSETS}/behaviour/metadata.json: \
# 			${CA_BUILT_ASSETS}/base/metadata.json \
# 			src/climate_attitudes/datasets/behaviour.py
# 	@printf "Dataset → Build CC behaviour dataset...\n"
# 	@uv run cadata create dataset --name behaviour --force
#
# ${CA_BUILT_ASSETS}/reduced_imp/metadata.json: \
# 			${CA_BUILT_ASSETS}/base/metadata.json \
# 			src/climate_attitudes/datasets/reduced.py
# 	@printf "Dataset → Build reduced dataset (imputed)...\n"
# 	@uv run cadata create dataset --name reduced --force --with-imputation --with-indices --index efa
#
# ${CA_BUILT_ASSETS}/reduced/metadata.json: \
# 			${CA_BUILT_ASSETS}/base/metadata.json \
# 			src/climate_attitudes/datasets/reduced.py
# 	@printf "Dataset → Build reduced dataset...\n"
# 	@uv run cadata create dataset --name reduced --force
#
# ${CA_BUILT_ASSETS}/reduced_no_imputation/metadata.json: \
# 			${CA_BUILT_ASSETS}/base/metadata.json \
# 			src/climate_attitudes/datasets/reduced_no_imputation.py
# 	@printf "Dataset → Build reduced dataset (only full values)...\n"
# 	@uv run cadata create dataset --name reduced_no_imputation --force --with-indices --index efa --filter-null --waves [3,4]
#
# ${CA_BUILT_ASSETS}/full_imp/metadata.json: \
# 			${CA_BUILT_ASSETS}/base/metadata.json \
# 			src/climate_attitudes/datasets/full.py
# 	@printf "Dataset → Build full dataset (imputed)...\n"
# 	@uv run cadata create dataset --name full --force --with-imputation
#
#
# ${CA_BUILT_ASSETS}/base/metadata.json: \
# 			src/climate_attitudes/dataset.py \
# 			src/climate_attitudes/data_extract.py \
# 			src/climate_attitudes/schema/dataset.py \
# 			src/climate_attitudes/schema/extract.py \
# 			${CA_RAW_ASSETS}/w1w2w3w4w5_indices_weights_jul12_2022.parquet \
# 			${CA_RAW_ASSETS}/Codebook_220528.xlsx \
# 			${CA_STATIC_ASSETS}/item_columns.json \
# 			${CA_STATIC_ASSETS}/item_groups.csv \
# 			${CA_STATIC_ASSETS}/categories.csv \
# 			${CA_STATIC_ASSETS}/error_items.csv \
# 			${CA_STATIC_ASSETS}/variable_names.csv \
# 			${CA_STATIC_ASSETS}/ideology_type.csv \
# 			${CA_STATIC_ASSETS}/lee_2025_items.csv
# 	@printf "Dataset → Build base dataset...\n"
# 	@uv run cadata create base-dataset --prune-error-participants --filter-valid


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
	@rm -rf outputs
	@rm -rf site/site
	@$(MAKE) clean -C reports/proposal
	@$(MAKE) clean -C reports/reading_summary
	@$(MAKE) clean -C reports/climate-attitudes-eda
	@$(MAKE) clean -C presentations/project_plan

