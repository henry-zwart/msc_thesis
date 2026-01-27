include ../.env


BUILT_ASSETS := \
		${ASSETS_DIR}/climate_attitudes.db \
		${ASSETS_DIR}/wave.parquet \
		${ASSETS_DIR}/item.parquet \
		${ASSETS_DIR}/question.parquet \
		${ASSETS_DIR}/participant.parquet \
		${ASSETS_DIR}/response.parquet \
		${ASSETS_DIR}/question_response.parquet


RUN-R := docker run \
		-it --rm \
		-v $$(pwd):/code \
		-v ${RAW_ASSETS_DIR}:/raw-data \
		-v ${STATIC_ASSETS_DIR}:/static-assets \
		-v ${ASSETS_DIR}:/assets \
		msc-thesis-r

.PHONY: clean



all: $(BUILT_ASSETS)


$(BUILT_ASSETS): .build_assets


.build_assets: load_data.py \
		${ASSETS_DIR}/building/w1w2w3w4w5_indices_weights_jul12_2022.parquet \
		${ASSETS_DIR}/building/w6_cleaned_weights_june12_2023.parquet \
		${RAW_ASSETS_DIR}/Codebook_220528.xlsx \
		$(wildcard ${STATIC_ASSETS_DIR}/*) 
	uv run $< \
			--assets-dir ${ASSETS_DIR} \
			--static-assets-dir ${STATIC_ASSETS_DIR} \
			--codebook ${RAW_ASSETS_DIR}/Codebook_220528.xlsx && \
		touch $@
	

# ${ASSETS_DIR}/building/%.parquet: \
# 		convert_rdata_to_parquet.r \
# 		${RAW_ASSETS_DIR}/%.Rdata \
# 		.docker-r \
# 		| ${ASSETS_DIR}/building
# 	$(RUN-R) bash -c "Rscript $< /raw-data/$*.rdata /assets/building/$*.parquet"


.docker-r: Dockerfile
	docker build -t msc-thesis-r . && \
		touch $@


${ASSETS_DIR}/building: 
	mkdir $@

clean:
	rm .docker-r .build_assets
	rm -rf ${ASSETS_DIR}
