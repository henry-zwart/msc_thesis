REPORT_TYPES := proposal
REPORTS = $(patsubst %,reports/%.pdf, $(REPORT_TYPES))

SITE_SOURCES = $(MKDOCS_CONFIG) $(wildcard site/**/*.md) $(wildcard site/*.md) \
          $(wildcard site/**/*.css) $(wildcard site/**/*.js)

.PHONY: clean serve

all: site/site/index.html

# Serve site locally
serve:
	uv run --group docs mkdocs serve -f site/mkdocs.yml

# Build site
site/site/index.html: reports/proposal.pdf $(SITE_SOURCES)
	cp $< site/docs && uv run --group docs mkdocs build -f site/mkdocs.yml


# Compile project proposal
reports/proposal.pdf: 
	$(MAKE) -C reports/proposal && cp reports/proposal/main.pdf $@


# Remove all generated files 
clean: 
	rm $(REPORTS) 
	rm -rf site/site
	$(MAKE) clean -C reports/proposal

