REPORT_TYPES := proposal
PRESENTATION_TYPES := project_plan
REPORTS = \
		$(patsubst %,reports/%.pdf, $(REPORT_TYPES)) \
		$(patsubst %,presentations/%.html, $(PRESENTATION_TYPES))


SITE_SOURCES = $(MKDOCS_CONFIG) $(wildcard site/**/*.md) $(wildcard site/*.md) \
          $(wildcard site/**/*.css) $(wildcard site/**/*.js)

.PHONY: clean serve

all: site/site/index.html

all-reports: $(REPORTS)

# Serve site locally
serve:
	uv run --group docs mkdocs serve -f site/mkdocs.yml

# Build site
site/site/index.html: $(REPORTS) $(SITE_SOURCES)
	cp $(REPORTS) site/docs && uv run --group docs mkdocs build -f site/mkdocs.yml


# Compile project proposal
reports/proposal.pdf: 
	$(MAKE) -C reports/proposal && cp reports/proposal/main.pdf $@

# Compile project-plan presentation
presentations/project_plan.html:
	$(MAKE) -C presentations/project-plan && cp presentations/project-plan/main.html $@


# Remove all generated files 
clean: 
	rm $(REPORTS) 
	rm -rf site/site
	$(MAKE) clean -C reports/proposal
	$(MAKE) clean -C presentations/project-plan

