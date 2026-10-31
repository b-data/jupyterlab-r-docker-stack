ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=13
ARG BUILD_ON_IMAGE=glcr.b-data.ch/jupyterlab/r/geospatial
ARG R_VERSION
ARG QGIS_VERSION
ARG PDAL_VERSION

ARG SAGA_VERSION
ARG OTB_VERSION

FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS files

ARG OTB_VERSION

ARG NB_UID=1000
ENV NB_GID=100

RUN mkdir /files

COPY conf/user /files
COPY scripts /files

RUN if [ "$(uname -m)" = "x86_64" ]; then \
    ## QGIS: Set OTB application folder and OTB folder
    qgis4Ini="/files/var/backups/skel/.local/share/QGIS/QGIS4/profiles/default/QGIS/QGIS4.ini"; \
    if [ -n "${OTB_VERSION}" ]; then \
      echo "\n[Processing]" >> ${qgis4Ini}; \
      echo "Configuration\OTB_APP_FOLDER=/usr/local/lib/otb/applications" >> \
        ${qgis4Ini}; \
      echo "Configuration\OTB_FOLDER=/usr/local\n" >> ${qgis4Ini}; \
    fi \
  fi \
  && chown -R ${NB_UID}:${NB_GID} /files/var/backups/skel \
  ## Ensure file modes are correct when using CI
  ## Otherwise set to 777 in the target image
  && find /files -type d -exec chmod 755 {} \; \
  && find /files -type f -exec chmod 644 {} \; \
  && find /files/usr/local/bin -type f -exec chmod 755 {} \;

FROM glcr.b-data.ch/qgis/qgissi/${QGIS_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} AS qgissi
FROM glcr.b-data.ch/saga-gis/saga-gissi${SAGA_VERSION:+/}${SAGA_VERSION:-:none}${SAGA_VERSION:+/$BASE_IMAGE}${SAGA_VERSION:+:$BASE_IMAGE_TAG} AS saga-gissi
FROM glcr.b-data.ch/orfeotoolbox/otbsi${OTB_VERSION:+/}${OTB_VERSION:-:none}${OTB_VERSION:+/$BASE_IMAGE}${OTB_VERSION:+:$BASE_IMAGE_TAG} AS otbsi

FROM ${BUILD_ON_IMAGE}:${R_VERSION} AS pre-env1

FROM ${BUILD_ON_IMAGE}:${R_VERSION} AS pre-env1-saga

ARG SAGA_VERSION

ENV SAGA_VERSION=${SAGA_VERSION}

FROM pre-env1${SAGA_VERSION:+-saga} AS pre-env2

FROM pre-env1${SAGA_VERSION:+-saga} AS pre-env2-otb

ARG OTB_VERSION

ENV OTB_VERSION=${OTB_VERSION} \
    GDAL_DRIVER_PATH=disable \
    OTB_APPLICATION_PATH=/usr/local/lib/otb/applications \
    OTB_INSTALL_DIR=/usr/local

FROM pre-env2${OTB_VERSION:+-otb} AS build

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG QGIS_VERSION
ARG PDAL_VERSION
ARG BUILD_START

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    QGIS_VERSION=${QGIS_VERSION} \
    PDAL_VERSION=${PDAL_VERSION} \
    BUILD_DATE=${BUILD_START}

USER root

ENV HOME=/root \
    ## GRASS GIS: Make sure the distro's python is used
    GRASS_PYTHON=/usr/bin/python3

WORKDIR ${HOME}

## Install QGIS
COPY --from=qgissi /usr /usr
## Install SAGA GIS
COPY --from=saga-gissi /usr /usr
## Install Orfeo Toolbox
COPY --from=otbsi /usr/local /usr/local

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    ## Multimedia files trancoding
    ffmpeg \
    ## QGIS: Additional runtime dependencies
    '^libexiv2-[0-9]+$' \
    '^libgdal[0-9]+$' \
    '^libgeographiclib[0-9]+$' \
    libgeos-c1v5 \
    '^libgsl[0-9]+$' \
    libjs-jquery \
    libjs-leaflet \
    '^libprotobuf-lite[0-9]+$' \
    libqca-qt6-plugins \
    '^libqscintilla2-qt6-[0-9]+$' \
    libqt6core6t64 \
    libqt6gui6 \
    libqt6keychain1 \
    libqt6multimediawidgets6 \
    libqt6network6 \
    libqt6quickcontrols2-6 \
    libqt6quickwidgets6 \
    libqt6serialport6 \
    libqt6sql6 \
    libqt6widgets6 \
    libqt6xml6 \
    '^libsfcgal[0-9]+$' \
    '^libspatialindex[0-9]+$' \
    '^libzip[0-9]+$' \
    ocl-icd-libopencl1 \
    ## https://github.com/qgis/QGIS/pull/63784
    pyqt6-dev-tools \
    ## QGIS 4 depends on libpython3.x (the shared Python runtime library)
    ## The following package is installed for a lightweight integration
    python3-pyqt6.qtqml \
    qml6-module-qtcharts \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-effects \
    qml6-module-qtquick-layouts \
    qt6-3d-assimpsceneimport-plugin \
    qt6-3d-defaultgeometryloader-plugin \
    qt6-3d-gltfsceneio-plugin \
    qt6-3d-scene2d-plugin \
    qt6-image-formats-plugins \
    qt6-svg-plugins \
    ## QGIS: Python 3 Support
    gdal-bin \
    libfcgi0ldbl \
    libsqlite3-mod-spatialite \
    python3-gdal \
    python3-jinja2 \
    python3-lxml \
    python3-matplotlib \
    python3-owslib \
    python3-plotly \
    python3-psycopg2 \
    python3-pygments \
    python3-pyproj \
    python3-pyqt6 \
    python3-pyqt6.qsci \
    python3-pyqt6.qtmultimedia \
    python3-pyqt6.qtpositioning \
    python3-pyqt6.qtserialport \
    python3-pyqt6.qtsvg \
    python3-pyqt6.sip \
    python3-yaml \
    qt6-tools-dev-tools \
    ## PDAL: Additional runtime dependencies
    '^libhdf5-cpp-[0-9]+.*$' \
  && apt-get -y install --no-install-recommends \
    ## QGIS: Additional runtime recommendations
    grass \
    ## QGIS: Additional runtime suggestions
    gpsbabel \
    ## SAGA GIS: Supplementary runtime dependencies [^1]
    libdxflib3 \
    libhpdf-2.3.0 \
    libsvm3 \
    libwxgtk3.*-dev \
    $(test -z "${SAGA_VERSION}" && echo "saga") \
  ## Orfeo Toolbox: Supplementary runtime dependencies
  && if [ "$(uname -m)" = "x86_64" ]; then \
    apt-get -y install --no-install-recommends \
      '^libboost-filesystem[0-9].[0-9]+.[0-9]$' \
      '^libboost-serialization[0-9].[0-9]+.[0-9]$' \
      libglew2.* \
      '^libinsighttoolkit[0-9].[0-9]+$' \
      libmuparser2v5 \
      libmuparserx4.* \
      '^libopencv-core[0-9][0-9.][0-9][a-z]?$' \
      '^libopencv-ml[0-9][0-9.][0-9][a-z]?$' \
      libtinyxml-dev; \
    if [ -n "${OTB_VERSION}" ]; then \
      if [ "$(echo ${OTB_VERSION} | cut -c 1)" -lt "8" ]; then \
        apt-get -y install --no-install-recommends \
          '^libopenthreads[0-9]+$' \
          libossim1; \
      fi; \
      ## Orfeo Toolbox: Clean up installation
      bash -c 'rm -rf /usr/local/{otbenv.profile,recompile_bindings.sh,tools}'; \
      if [ -f /usr/local/README ]; then \
        mv /usr/local/README /usr/local/share/doc/otb; \
      fi; \
      if [ -f /usr/local/LICENSE ]; then \
        mv /usr/local/LICENSE /usr/local/share/doc/otb; \
      fi \
    else \
      mkdir -p /usr/lib/otb; \
      ln -rs /usr/lib/$(uname -m)-linux-gnu/otb/applications \
        /usr/lib/otb/applications; \
    fi \
  fi \
  ## GRASS GIS: Configure dynamic linker run time bindings
  && echo "$(grass --config path)/lib" | tee /etc/ld.so.conf.d/libgrass.conf \
  && ldconfig \
  ## SAGA GIS: Add en_GB.UTF-8 and update locale
  && sed -i "s/# $LANG/$LANG/g" /etc/locale.gen \
  && sed -i "s/# en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen \
  && locale-gen \
  ## [^1]: SAGA GIS: libvigraimpex11 is not available for jammy
  && if $(! grep -q "jammy" /etc/os-release); then \
    apt-get -y install --no-install-recommends '^libvigraimpex[0-9]+$'; \
  fi \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache \
    ${HOME}/.grass*

## Install QGIS related stuff
RUN apt-get update \
  ## Install QGIS-Plugin-Manager
  && apt-get -y install --no-install-recommends python3-pip \
  && export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && /usr/bin/pip install qgis-plugin-manager \
  ## Install PDAL Python support and plugins
  && apt-get -y install --no-install-recommends python3-dev \
  && /usr/bin/pip install pdal pdal-plugins \
  && mv /usr/local/lib/python*/dist-packages/pdal* \
    /usr/lib/python3/dist-packages \
  ## QGIS: Make sure qgis_mapserver and qgis_process find the qgis module
  && cp -a $(which qgis_mapserver) $(which qgis_mapserver)_ \
  && echo '#!/bin/bash' > $(which qgis_mapserver) \
  && echo "PYTHONPATH=/usr/lib/python3/dist-packages $(which qgis_mapserver)_ \"\${@}\"" >> \
    $(which qgis_mapserver) \
  && cp -a $(which qgis_process) $(which qgis_process)_ \
  && echo '#!/bin/bash' > $(which qgis_process) \
  && echo "PYTHONPATH=/usr/lib/python3/dist-packages $(which qgis_process)_ \"\${@}\"" >> \
    $(which qgis_process) \
  ## Install qgisprocess, the R interface to QGIS
  && install2.r --error --skipinstalled -n $NCPUS qgisprocess \
  ## Strip libraries of binary packages installed from P3M
  && RLS=$(Rscript -e "cat(Sys.getenv('R_LIBS_SITE'))") \
  && strip ${RLS}/*/libs/*.so \
  ## Clean up
  && if [ -n "$PYTHON_VERSION" ]; then \
    apt-get -y purge python3-pip python3-dev; \
    apt-get -y autoremove; \
  fi \
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache \
    ${HOME}/.config \
    ${HOME}/.local

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER} \
    ## Qt: Support running on headless computer
    QT_QPA_PLATFORM=offscreen

WORKDIR ${HOME}

## Copy files as late as possible to avoid cache busting
COPY --from=files /files /
COPY --from=files /files/var/backups/skel ${HOME}

RUN mkdir -p ${HOME}/.local/share/QGIS/QGIS4/profiles/default/python/plugins \
  && cd ${HOME}/.local/share/QGIS/QGIS4/profiles/default/python/plugins \
  && qgis-plugin-manager init \
  && qgis-plugin-manager update \
  ## QGIS: Enable plugins
  && qgis_process plugins enable grassprovider \
  && rm -rf .cache_qgis_plugin_manager \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf \
    ${HOME}/.cache/QGIS \
    ${HOME}/.cache/qgis_process* \
    ${HOME}/.config \
    ${HOME}/.grass* \
  ## Create backup of QGIS settings
  && cp -a ${HOME}/.local/share/QGIS /var/backups/skel/.local/share

FROM build AS post-env

FROM build AS post-env-otb

ENV PYTHONPATH=${PYTHONPATH:+$PYTHONPATH:}/usr/local/lib/otb/python

FROM post-env${OTB_VERSION:+-otb} AS qgisprocess
