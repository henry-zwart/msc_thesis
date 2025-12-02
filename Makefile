REPORT_TYPES := proposal
REPORTS = $(patsubst %,reports/%.pdf, $(REPORT_TYPES))

.PHONY: clean

all: site/site/index.html


# Build site
site/site/index.html: reports/proposal.pdf
	cp $< site/docs && uv run mkdocs build -f site/mkdocs.yml


# Compile project proposal
reports/proposal.pdf: 
	$(MAKE) -C reports/proposal && cp reports/proposal/main.pdf $@


# Remove all generated files 
clean: 
	rm $(REPORTS) 
	rm -rf site/site
	$(MAKE) clean -C reports/proposal

