FROM registry.gitlab.b-data.ch/jupyterlab/r/tidyverse:4.1.1

ARG DEBIAN_FRONTEND=noninteractive

ARG CTAN_REPO=${CTAN_REPO:-https://www.texlive.info/tlnet-archive/2021/11/01/tlnet}
ENV CTAN_REPO=${CTAN_REPO}

USER root

ENV PATH=/opt/TinyTeX/bin/x86_64-linux:$PATH \
    HOME=/root

WORKDIR ${HOME}

## Add LaTeX, rticles and bookdown support
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    default-jdk \
    fonts-roboto \
    ghostscript \
    lbzip2 \
    libbz2-dev \
    libicu-dev \
    liblzma-dev \
    libpcre2-dev \
    libhunspell-dev \
    libmagick++-dev \
    libpoppler-cpp-dev \
    librdf0-dev \
    ## Installing libnode-dev uninstalls nodejs
    ## https://github.com/jeroen/V8/issues/100
    #libnode-dev \
    qpdf \
    texinfo \
    libopenmpi-dev \
  ## Install R package redland
  && install2.r --error --skipinstalled redland \
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
  && apt-get clean \
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
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr update --self \
  && tlmgr install \
    ae \
    ## context fails to install on aarch64 with no output
    #context \
    listings \
    makeindex \
    parskip \
    pdfcrop \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:users /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  && install2.r --error PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE \
    blogdown bookdown rticles rmdshower rJava xaringan \
  ## Install code-server extensions
  && cd /tmp \
  && curl -sLO https://open-vsx.org/api/James-Yu/latex-workshop/8.19.2/file/James-Yu.latex-workshop-8.19.2.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension James-Yu.latex-workshop-8.19.2.vsix \
  ## Clean up
  && rm -rf /tmp/*

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER}

WORKDIR ${HOME}
