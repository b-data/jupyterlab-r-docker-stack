FROM registry.gitlab.b-data.ch/jupyterlab/r/r-ver:4.1.3

ARG NCPUS=1

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
  && install2.r --error --skipinstalled -n $NCPUS BiocManager \
  && install2.r --error --deps TRUE --skipinstalled -n $NCPUS \
    tidyverse \
    dplyr \
    devtools \
    formatR \
  ## dplyr database backends
  && if [ $(dpkg --print-architecture) = "arm64" ]; then \
    ## https://github.com/duckdb/duckdb/issues/3049
    cp -a $(R RHOME)/etc/Makeconf $(R RHOME)/etc/Makeconf.bak; \
    sed -i 's/fpic/fPIC/g' $(R RHOME)/etc/Makeconf; \
    install2.r --error --skipinstalled -n $NCPUS duckdb; \
    mv $(R RHOME)/etc/Makeconf.bak $(R RHOME)/etc/Makeconf; \
  else \
    install2.r --error --skipinstalled -n $NCPUS duckdb; \
  fi \
  && install2.r --error --skipinstalled -n $NCPUS \
    arrow \
    fst \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
