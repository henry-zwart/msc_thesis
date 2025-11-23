all: reports/proposal.pdf

reports/proposal.pdf: 
	$(MAKE) -C reports/proposal && \
		cp reports/proposal/main.pdf $@
