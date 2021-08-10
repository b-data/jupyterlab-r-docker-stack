FROM registry.gitlab.b-data.ch/jupyterlab/r/tidyverse:4.1.0

ARG DEBIAN_FRONTEND=noninteractive

ARG CTAN_REPO=${CTAN_REPO:-http://mirror.ctan.org/systems/texlive/tlnet}
ENV CTAN_REPO=${CTAN_REPO}

USER root

ENV PATH=/opt/TinyTeX/bin/x86_64-linux:$PATH \
    HOME=/root

WORKDIR ${HOME}

## Add LaTeX, rticles and bookdown support
RUN wget "https://travis-bin.yihui.name/texlive-local.deb" \
  && dpkg -i texlive-local.deb \
  && rm texlive-local.deb \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ## for rJava
    default-jdk \
    ## Nice Google fonts
    fonts-roboto \
    ## used by some base R plots
    ghostscript \
    ## used to install PhantomJS
    lbzip2 \
    ## used to build rJava and other packages
    libbz2-dev \
    libicu-dev \
    liblzma-dev \
    libpcre2-dev \
    ## system dependency of hunspell (devtools)
    libhunspell-dev \
    ## system dependency of hadley/pkgdown
    libmagick++-dev \
    ## system dependency of pdftools
    libpoppler-cpp-dev \
    ## rdf, for redland / linked data (depends on libcurl4-gnutls-dev)
    librdf0-dev \
    ## for V8-based javascript wrappers
    libnode-dev \
    ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
    qpdf \
    ## For building PDF manuals
    texinfo \
    ## for git via ssh key
    #ssh \
    ## just because
    #less \
    #vim \
    ## parallelization
    #libzmq3-dev \
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
