ARG BUILD_ON_IMAGE=glcr.b-data.ch/jupyterlab/r/base
ARG R_VERSION=4.4.1

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG BUILD_START

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    BUILD_DATE=${BUILD_START}

USER root

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    cmake \
    default-libmysqlclient-dev \
    #libxml2-dev \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    #libtiff-dev \
    libxtst6 \
    unixodbc-dev \
  && install2.r --error --skipinstalled -n $NCPUS BiocManager \
  && install2.r --error --deps TRUE --skipinstalled -n $NCPUS \
    tidyverse \
    dplyr \
    devtools \
    formatR \
  ## dplyr database backends
  && install2.r --error --skipinstalled -n $NCPUS \
    arrow \
    duckdb \
    fst \
  ## Get rid of libharfbuzz-dev and its dependencies (incl. python3)
  && apt-get -y purge libharfbuzz-dev \
  && apt-get -y autoremove \
  && apt-get -y install --no-install-recommends libharfbuzz-icu0 \
  ## Strip libraries of binary packages installed from P3M
  && RLS=$(Rscript -e "cat(Sys.getenv('R_LIBS_SITE'))") \
  && strip ${RLS}/*/libs/*.so \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
