REPORT_TYPES := proposal
REPORTS = $(patsubst %,reports/%.pdf, $(REPORT_TYPES))

.PHONY: clean

all: $(REPORTS)

reports/proposal.pdf: 
	$(MAKE) -C reports/proposal && cp reports/proposal/main.pdf $@

clean: 
	rm $(REPORTS) 
	$(MAKE) clean -C reports/proposal

