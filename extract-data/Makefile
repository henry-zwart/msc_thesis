include ../.env

RUN-R := docker run -it --rm -v $$(pwd):/code -v ${ASSETS_DIR}:/data msc-thesis-r

.PHONY: clean

all: \
	${ASSETS_DIR}/climate-attitudes/w1w2w3w4w5_indices_weights_jul12_2022.parquet \
	${ASSETS_DIR}/climate-attitudes/w6_cleaned_weights_june12_2023.parquet

${ASSETS_DIR}/%.parquet: \
				convert_rdata_to_parquet.r \
				${ASSETS_DIR}/%.Rdata \
				.docker-r
	$(RUN-R) bash -c "Rscript $< /data/$*.rdata /data/$*.parquet"

.docker-r: Dockerfile
	docker build -t msc-thesis-r . && \
		touch $@

clean:
	rm .docker-r
