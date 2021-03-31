FROM registry.gitlab.b-data.ch/jupyterlab/r/r-ver:4.0.5

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
  ## Install patched version or RPostgreSQL
  ## Source: https://gitlab.b-data.ch/benz0li/rpostgresql
  && install2.r --error DBI \
  && curl -sSL https://gitlab.b-data.ch/benz0li/rpostgresql/-/package_files/6/download \
    -o RPostgreSQL_0.6-2.tar.gz \
  && R CMD INSTALL RPostgreSQL_0.6-2.tar.gz \
  && rm RPostgreSQL_0.6-2.tar.gz \
  ## Install other packages in regular fashion
  && install2.r --error BiocManager \
  && install2.r --error \
    --deps TRUE \
    --skipinstalled \
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
