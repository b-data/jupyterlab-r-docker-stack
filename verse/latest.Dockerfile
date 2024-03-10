ARG BUILD_ON_IMAGE=glcr.b-data.ch/jupyterlab/r/tidyverse
ARG R_VERSION
ARG CODE_BUILTIN_EXTENSIONS_DIR=/opt/code-server/lib/vscode/extensions
ARG QUARTO_VERSION=1.4.551
ARG CTAN_REPO=https://mirror.ctan.org/systems/texlive/tlnet

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG CODE_BUILTIN_EXTENSIONS_DIR
ARG QUARTO_VERSION
ARG CTAN_REPO
ARG BUILD_START

USER root

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    QUARTO_VERSION=${QUARTO_VERSION} \
    CTAN_REPO=${CTAN_REPO} \
    BUILD_DATE=${BUILD_START}

ENV HOME=/root \
    PATH=/opt/TinyTeX/bin/linux:/opt/quarto/bin:$PATH

WORKDIR ${HOME}

## Add LaTeX, rticles and bookdown support
RUN dpkgArch="$(dpkg --print-architecture)" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    default-jdk \
    fonts-roboto \
    ghostscript \
    hugo \
    lbzip2 \
    libbz2-dev \
    libglpk-dev \
    libgmp3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libharfbuzz-dev \
    libhunspell-dev \
    libicu-dev \
    liblzma-dev \
    #libpcre2-dev \
    libmagick++-dev \
    libopenmpi-dev \
    libpoppler-cpp-dev \
    librdf0-dev \
    ## Installing libnode-dev uninstalls nodejs
    ## https://github.com/jeroen/V8/issues/100
    #libnode-dev \
    librsvg2-bin \
    qpdf \
    texinfo \
  ## Install R package redland
  && install2.r --error --skipinstalled -n $NCPUS redland \
  ## Explicitly install runtime library sub-deps of librdf0-dev
  && apt-get install -y \
    libcurl4-openssl-dev \
    libxslt-dev \
    librdf0 \
    redland-utils \
    rasqal-utils \
    raptor2-utils \
  ## Get rid of librdf0-dev and its dependencies (incl. libcurl4-gnutls-dev)
  && apt-get -y autoremove \
  ## Install quarto
  && curl -sLO https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz \
  && mkdir -p /opt/quarto \
  && tar -xzf quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz -C /opt/quarto --no-same-owner --strip-components=1 \
  && rm quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz \
  ## Remove quarto pandoc
  && rm /opt/quarto/bin/tools/$(uname -m)/pandoc \
  ## Link to system pandoc
  && ln -s /usr/bin/pandoc /opt/quarto/bin/tools/$(uname -m)/pandoc \
  ## Tell APT about the TeX Live installation
  ## by building a dummy package using equivs
  && apt-get install -y --no-install-recommends equivs \
  && cd /tmp \
  && wget https://github.com/scottkosty/install-tl-ubuntu/raw/master/debian-control-texlive-in.txt \
  && equivs-build debian-* \
  && mv texlive-local*.deb texlive-local.deb \
  && dpkg -i texlive-local.deb \
  && apt-get -y purge equivs \
  && apt-get -y autoremove \
  ## Admin-based install of TinyTeX:
  && wget -qO- "https://yihui.org/tinytex/install-unx.sh" \
    | sh -s - --admin --no-path \
  && mv ${HOME}/.TinyTeX /opt/TinyTeX \
  && sed -i "s|${HOME}/.TinyTeX|/opt/TinyTeX|g" \
    /opt/TinyTeX/texmf-var/fonts/conf/texlive-fontconfig.conf \
  && ln -rs /opt/TinyTeX/bin/$(uname -m)-linux \
    /opt/TinyTeX/bin/linux \
  && /opt/TinyTeX/bin/linux/tlmgr path add \
  && tlmgr update --self \
  ## TeX packages as requested by the community
  && curl -sSLO https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt \
  && tlmgr install $(cat pkgs-yihui.txt | tr '\n' ' ') \
  && rm -f pkgs-yihui.txt \
  ## TeX packages as in rocker/verse
  && tlmgr install \
    context \
    pdfcrop \
  ## TeX packages as in jupyter/scipy-notebook
  && tlmgr install \
    cm-super \
    dvipng \
  ## TeX packages specific for nbconvert
  && tlmgr install \
    oberdiek \
    titling \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:${NB_GID} /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  ## Make the TeX Live fonts available as system fonts
  && cp /opt/TinyTeX/texmf-var/fonts/conf/texlive-fontconfig.conf \
    /etc/fonts/conf.d/09-texlive.conf \
  && fc-cache -fsv \
  && install2.r --error --skipinstalled -n $NCPUS PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE --skipinstalled -n $NCPUS \
    blogdown \
    bookdown \
    distill \
    quarto \
    rticles \
    rJava \
    xaringan \
  ## Install rmdshower
  ## Archived on 2023-08-18 as email to the maintainer is undeliverable.
  && curl -sLO https://cran.r-project.org/src/contrib/Archive/rmdshower/rmdshower_2.1.1.tar.gz \
  && R CMD INSTALL rmdshower_2.1.1.tar.gz \
  ## Install Cairo: R Graphics Device using Cairo Graphics Library
  ## Install magick: Advanced Graphics and Image-Processing in R
  && install2.r --error --skipinstalled -n $NCPUS \
    Cairo \
    magick \
  ## Get rid of libharfbuzz-dev
  && apt-get -y purge libharfbuzz-dev \
  ## Get rid of libmagick++-dev
  && apt-get -y purge libmagick++-dev \
  ## and their dependencies (incl. python3)
  && apt-get -y autoremove \
  && apt-get -y install --no-install-recommends \
    imagemagick \
  ## Install code-server extensions
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension quarto.quarto \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension James-Yu.latex-workshop \
  ## Strip libraries of binary packages installed from PPM
  && strip $(R RHOME)/site-library/*/libs/*.so \
  ## Update default PATH settings in /etc/profile.d/00-reset-path.sh
  && sed -i 's|/opt/code-server/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin|/opt/TinyTeX/bin/linux:/opt/quarto/bin:/opt/code-server/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin|g' /etc/profile.d/00-reset-path.sh \
  && sed -i 's|/opt/code-server/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games|/opt/TinyTeX/bin/linux:/opt/quarto/bin:/opt/code-server/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games|g' /etc/profile.d/00-reset-path.sh \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.config \
    ${HOME}/.local \
    ${HOME}/.vscode-remote \
    ${HOME}/.wget-hsts

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER}

WORKDIR ${HOME}
