include ../.env

RUN-R := docker run -it --rm -v $$(pwd):/code -v ${ASSETS_DIR}:/data msc-thesis-r

.PHONY: clean

results: .docker-r
	$(RUN-R) bash -c "Rscript extract_ca_data.r"

.docker-r: Dockerfile
	docker build -t msc-thesis-r . && \
		touch $@

clean:
	rm .docker-r
