ARG BUILD_ON_IMAGE=registry.gitlab.b-data.ch/jupyterlab/r/base
ARG R_VERSION

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    cmake \
    default-libmysqlclient-dev \
    #libxml2-dev \
    #libcairo2-dev \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libtiff-dev \
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
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
