FROM registry.gitlab.b-data.ch/jupyterlab/r/verse:4.0.5

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    liblwgeom-dev \
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
  && install2.r --error \
    #RColorBrewer \
    RandomFields \
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
    spdep \
    geoR \
    geosphere \
    ## from bioconductor
    ## ‘rhdf5’ and ‘rhdf5filters’ have non-zero exit status on aarch64
    && R -e "BiocManager::install('rhdf5', update = FALSE, ask = FALSE)" \
    ## Clean up
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
