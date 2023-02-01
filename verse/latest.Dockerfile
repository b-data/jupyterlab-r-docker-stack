ARG BUILD_ON_IMAGE=registry.gitlab.b-data.ch/jupyterlab/r/tidyverse
ARG R_VERSION
ARG CODE_BUILTIN_EXTENSIONS_DIR=/opt/code-server/lib/vscode/extensions
ARG QUARTO_VERSION=1.2.335
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
    HOME=/root \
    CTAN_REPO=${CTAN_REPO} \
    PATH=/opt/TinyTeX/bin/linux:/opt/quarto/bin:$PATH \
    BUILD_DATE=${BUILD_START}

WORKDIR ${HOME}

## Add LaTeX, rticles and bookdown support
RUN dpkgArch="$(dpkg --print-architecture)" \
  && wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
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
  && if [ ${dpkgArch} = "amd64" ]; then \
    ## Install quarto
    curl -sLO https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz; \
    mkdir -p /opt/quarto; \
    tar -xzf quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz -C /opt/quarto --no-same-owner --strip-components=1; \
    rm quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz; \
    ## Remove quarto pandoc
    rm /opt/quarto/bin/tools/pandoc; \
    ## Link to system pandoc
    ln -s /usr/bin/pandoc /opt/quarto/bin/tools/pandoc; \
  fi \
  ## Admin-based install of TinyTeX:
  && wget -qO- "https://yihui.org/tinytex/install-unx.sh" \
    | sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
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
  && install2.r --error --skipinstalled -n $NCPUS PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE --skipinstalled -n $NCPUS \
    blogdown \
    bookdown \
    distill \
    quarto \
    rticles \
    rmdshower \
    rJava \
    xaringan \
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
    '^libmagick\+\+-6.q16-[0-9]+$' \
  ## Install code-server extensions
  && if [ ${dpkgArch} = "amd64" ]; then \
    code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension quarto.quarto; \
  fi \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension James-Yu.latex-workshop \
  ## Clean up
  && rm -rf /tmp/* \
    /root/.config \
    /root/.local \
    /root/.vscode-remote \
    /root/.wget-hsts \
  && rm -rf /var/lib/apt/lists/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER}

WORKDIR ${HOME}
