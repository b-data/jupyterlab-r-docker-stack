FROM registry.gitlab.b-data.ch/jupyterlab/r/r-ver:4.0.4

USER root

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
  #libxml2-dev \
  libcairo2-dev \
  libfribidi-dev \
  libgit2-dev \
  libharfbuzz-dev \
  libsqlite3-dev \
  libmariadbd-dev \
  libmariadbclient-dev \
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  libtiff-dev \
  && install2.r --error BiocManager \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    devtools \
    formatR \
    #remotes \
    selectr \
    caTools \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
