FROM registry.gitlab.b-data.ch/jupyterlab/r/r-ver:4.1.2

ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
  cmake \
  #libxml2-dev \
  #libcairo2-dev \
  libfribidi-dev \
  libgit2-dev \
  libharfbuzz-dev \
  libmariadb-dev \
  libpq-dev \
  libsasl2-dev \
  libsqlite3-dev \
  libssh2-1-dev \
  libtiff-dev \
  libxtst6 \
  unixodbc-dev \
  && install2.r --error --skipinstalled BiocManager \
  && install2.r --error --deps TRUE --skipinstalled \
    tidyverse \
    dplyr \
    devtools \
    formatR \
  ## dplyr database backends
  && Rscript -e "devtools::install_version('duckdb', version = '0.3.1')" \
  && install2.r --error --skipinstalled \
    arrow \
    fst \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
