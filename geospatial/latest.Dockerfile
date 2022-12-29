ARG BUILD_ON_IMAGE=registry.gitlab.b-data.ch/jupyterlab/r/verse
ARG R_VERSION

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION}

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
    libhdf5-dev \
    libjq-dev \
    #libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    #libsqlite3-dev \
    #libssl-dev \
    libudunits2-dev \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    #unixodbc-dev
  && install2.r --error --skipinstalled -n $NCPUS \
    #RColorBrewer \
    RNetCDF \
    classInt \
    deldir \
    gstat \
    hdf5r \
    lidR \
    mapdata \
    maptools \
    mapview \
    ncdf4 \
    proj4 \
    raster \
    rgdal \
    rgeos \
    rlas \
    sf \
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
  ## from bioconductor
  && R -e "BiocManager::install('rhdf5', update = FALSE, ask = FALSE)" \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
