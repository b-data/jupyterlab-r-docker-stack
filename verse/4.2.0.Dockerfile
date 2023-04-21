ARG R_VERSION=4.2.0
ARG CODE_BUILTIN_EXTENSIONS_DIR=/opt/code-server/lib/vscode/extensions
ARG CTAN_REPO=https://www.texlive.info/tlnet-archive/2022/06/23/tlnet

FROM registry.gitlab.b-data.ch/jupyterlab/r/tidyverse:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG CODE_BUILTIN_EXTENSIONS_DIR
ARG CTAN_REPO

USER root

ENV HOME=/root \
    CTAN_REPO=${CTAN_REPO} \
    PATH=/opt/TinyTeX/bin/linux:$PATH

WORKDIR ${HOME}

## Add LaTeX, rticles and bookdown support
RUN apt-get update \
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
  && rm -rf /var/lib/apt/lists/* \
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
  && mv ~/.TinyTeX /opt/TinyTeX \
  && ln -rs /opt/TinyTeX/bin/$(uname -m)-linux \
    /opt/TinyTeX/bin/linux \
  && /opt/TinyTeX/bin/linux/tlmgr path add \
  && tlmgr update --self \
  && tlmgr install \
    ae \
    cm-super \
    context \
    dvipng \
    listings \
    makeindex \
    parskip \
    pdfcrop \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:${NB_GID} /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron.site \
  && install2.r --error --skipinstalled -n $NCPUS PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE --skipinstalled -n $NCPUS \
    blogdown \
    bookdown \
    distill \
    rticles \
    rmdshower \
    rJava \
    xaringan \
  ## Install code-server extensions
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension James-Yu.latex-workshop \
  ## Clean up
  && rm -rf /tmp/* \
    /root/.config \
    /root/.local \
    /root/.vscode-remote \
    /root/.wget-hsts

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER}

WORKDIR ${HOME}
