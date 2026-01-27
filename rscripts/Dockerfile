FROM ubuntu:24.04

WORKDIR /code

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get install -y tzdata && \
	echo "Europe/Amsterdam" > /etc/timezone && \
	dpkg-reconfigure -f noninteractive tzdata

RUN apt-get -y install locales && \
	locale-gen en_NZ.UTF-8 && \
	dpkg-reconfigure locales

RUN apt-get update && \
	apt-get install --yes --no-install-recommends \
	gnupg ca-certificates software-properties-common dirmngr wget curl git-core && \
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=en_NZ.UTF-8
ENV LANGUAGE=en_NZ:en

# R dependencies
RUN apt-get update &&  \
	apt-get install -y --no-install-recommends libssl-dev libssh2-1-dev libcurl4-openssl-dev libxml2-dev && \
	apt upgrade --yes && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install R
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	r-base-dev r-recommended r-base && \
	apt upgrade --yes && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -q -O- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc \
	| tee -a /etc/apt/trusted.gpg.d/cranapt_key.asc
RUN add-apt-repository "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu jammy main"

# Packages
RUN apt-get install -y --no-install-recommends \
	r-cran-dotenv && \
	apt upgrade --yes && \
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN R -e 'Sys.setenv("NOT_CRAN" = TRUE); install.packages("arrow")'
