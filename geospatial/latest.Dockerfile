ARG R_VERSION

FROM registry.gitlab.b-data.ch/jupyterlab/r/verse:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    gdal-bin \
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
    geosphere \
  ## Archived on 2022-05-04 as check problems were not corrected in time.
  && Rscript -e "devtools::install_version('RandomFields', version = '3.3.14')" \
  ## Archived on 2022-05-04 as requires archived package 'RandomFields'.
  && Rscript -e "devtools::install_version('geoR', version = '1.8-1')" \
  ## from bioconductor
  && R -e "BiocManager::install('rhdf5', update=FALSE, ask=FALSE, Ncpus = Sys.getenv('NCPUS'))" \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

## Install wgrib2 for NOAA's NOMADS / rNOMADS forecast files
#RUN cd /opt \
#  && wget https://www.ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz \
#  && tar -xvf wgrib2.tgz \
#  && rm -rf wgrib2.tgz \
#  && cd grib2 \
#  ## arm64: Needs to be compiled with USE_NETCDF4=1, USE_JASPER=0
#  ## https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/index.html
#  && if [ $(dpkg --print-architecture) = "arm64" ]; then \
#    sed -i 's/^USE_NETCDF4=0/USE_NETCDF4=1/' makefile; \
#    sed -i 's/^USE_NETCDF3=1/USE_NETCDF3=0/' makefile; \
#    sed -i 's/^USE_JASPER=1/USE_JASPER=0/' makefile; \
#    NETCDF4_SRC=`sed -n 's/   netcdf4src=\(.*\)/\1/p' makefile`; \
#    wget ftp://ftp.unidata.ucar.edu/pub/netcdf/$NETCDF4_SRC; \
#    HDF5_SRC=`sed -n 's/   hdf5src:=\(.*\)/\1/p' makefile`; \
#    HDF5_MAJ_MIN_PAT=`echo $HDF5_SRC | \
#      sed -n 's/hdf5-\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\).*/\1/p'`; \
#    HDF5_MAJ_MIN=`echo $HDF5_MAJ_MIN_PAT | \
#      sed -n 's/\([[:digit:]]\+\.[[:digit:]]\+\).*/\1/p'`; \
#    wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$HDF5_MAJ_MIN/hdf5-$HDF5_MAJ_MIN_PAT/src/$HDF5_SRC; \
#  fi \
#  && CC=gcc FC=gfortran make \
#  && ln -s /opt/grib2/wgrib2/wgrib2 /usr/local/bin/wgrib2

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}
