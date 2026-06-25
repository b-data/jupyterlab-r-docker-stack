ARG BUILD_ON_IMAGE=glcr.b-data.ch/jupyterlab/r/verse
ARG R_VERSION=4.6.0

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG BUILD_START

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    BUILD_DATE=${BUILD_START}

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    #libgl1-mesa-dev \
    #libglu1-mesa-dev \
    libhdf4-alt-dev \
    #libhdf5-dev \
    libjq-dev \
    #libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    #libsqlite3-dev \
    #libssl-dev \
    libudunits2-dev \
    nco \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    #unixodbc-dev
  && install2.r --error --skipinstalled -n $NCPUS \
    #RColorBrewer \
    BH \
    RcppArmadillo \
    RNetCDF \
    classInt \
    deldir \
    gstat \
    hdf5r \
    mapdata \
    mapview \
    ncdf4 \
    proj4 \
    raster \
    rgl \
    sf \
    sfarrow \
    sp \
    spacetime \
    spatstat \
    spatialreg \
    spdep \
    stars \
    terra \
    tidync \
    tmap \
    geoR \
    geosphere \
  ## rlas: Archived on 2026-06-09 as ASAN issues were not corrected despite
  ## multiple notifications.
  && curl -sLO https://cran.r-project.org/src/contrib/Archive/rlas/rlas_1.9.3.tar.gz \
  && R CMD INSTALL rlas_1.9.3.tar.gz \
  && rm rlas_1.9.3.tar.gz \
  ## lidR: Archived on 2026-06-09 as requires archived package 'rlas'.
  && curl -sLO https://cran.r-project.org/src/contrib/Archive/lidR/lidR_4.3.2.tar.gz \
  && R CMD INSTALL lidR_4.3.2.tar.gz \
  && rm lidR_4.3.2.tar.gz \
  ## from bioconductor
  && R -e "BiocManager::install('rhdf5', update = FALSE, ask = FALSE)" \
  ## Strip libraries of binary packages installed from P3M
  && RLS=$(Rscript -e "cat(Sys.getenv('R_LIBS_SITE'))") \
  && strip ${RLS}/*/libs/*.so \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.config/R

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
