FROM registry.gitlab.b-data.ch/jupyterlab/r/tidyverse:4.0.0

# Version-stable CTAN repo from the tlnet archive at texlive.info, used in the
# TinyTeX installation: chosen as the frozen snapshot of the TeXLive release
# shipped for the base Debian image of a given rocker/r-ver tag.
# Debian buster => TeXLive 2018, frozen release snapshot 2019/02/27
ARG CTAN_REPO=${CTAN_REPO:-https://www.texlive.info/tlnet-archive/2019/02/27/tlnet}
ENV CTAN_REPO=${CTAN_REPO}

USER root

ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/ \
    HOME=/root
COPY vsix/* /tmp/

WORKDIR ${HOME}

## Add LaTeX, rticles and bookdown support
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ## for rJava
    default-jdk \
    ## Nice Google fonts
    fonts-roboto \
    ## used by some base R plots
    ghostscript \
    ## used to build rJava and other packages
    libbz2-dev \
    libicu-dev \
    liblzma-dev \
    libpcre2-dev \
    ## system dependency of hunspell (devtools)
    libhunspell-dev \
    ## system dependency of hadley/pkgdown
    libmagick++-dev \
    ## rdf, for redland / linked data
    librdf0-dev \
    ## for V8-based javascript wrappers
    libv8-dev \
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
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ## Use tinytex for LaTeX installation
  #&& install2.r --error tinytex \
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
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && if /opt/TinyTeX/bin/*/tex -v | grep -q 'TeX Live 2018'; then \
      ## Patch the Perl modules in the frozen TeX Live 2018 snapshot with the newer
      ## version available for the installer in tlnet/tlpkg/TeXLive, to include the
      ## fix described in https://github.com/yihui/tinytex/issues/77#issuecomment-466584510
      ## as discussed in https://www.preining.info/blog/2019/09/tex-services-at-texlive-info/#comments
      wget -P /tmp/ ${CTAN_REPO}/install-tl-unx.tar.gz \
      && tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp/ \
      && cp -Tr /tmp/install-tl-*/tlpkg/TeXLive /opt/TinyTeX/tlpkg/TeXLive \
      && rm -r /tmp/install-tl-*; \
    fi \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install ae inconsolata listings metafont mfware parskip pdfcrop tex xcolor \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:users /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  && install2.r --error PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE \
    bookdown rticles rmdshower rJava \
  ## Install Node.js
  && curl -sL https://deb.nodesource.com/setup_12.x | bash \
  && DEPS="libpython-stdlib \
    libpython2-stdlib \
    libpython2.7-minimal \
    libpython2.7-stdlib \
    python \
    python-minimal \
    python2 python2-minimal \
    python2.7 \
    python2.7-minimal" \
  && apt-get install -y --no-install-recommends nodejs $DEPS \
  ## Install code-server extensions
  && cd /tmp \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension James-Yu.latex-workshop-8.9.0.vsix \
  ## Needed to get LaTeX Workshop to work (Broken extension? https://github.com/cdr/code-server/issues/1187)
  && cd /opt/code-server/extensions/james-yu.latex-workshop-8.9.0 \
  && npm install \
  ## Clean up (Node.js)
  && rm -rf /tmp/* \
  && apt-get remove --purge -y nodejs $DEPS \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/* \
    /root/.cache \
    /root/.config \
    /root/.local \
    /root/.npm
#
## Consider including:
# - yihui/printr R package (when released to CRAN)
# - libgsl0-dev (GSL math library dependencies)

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER}

WORKDIR ${HOME}
