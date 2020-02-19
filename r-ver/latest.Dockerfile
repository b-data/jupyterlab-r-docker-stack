FROM registry.gitlab.b-data.ch/r/r-ver:3.6.2

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://gitlab.b-data.ch/jupyterlab/r/docker-stack" \
      maintainer="Olivier Benz <olivier.benz@b-data.ch>"

ARG NB_USER
ARG NB_UID
ARG NB_GID
ARG JUPYTERHUB_VERSION
ARG JUPYTERLAB_VERSION
ARG CODE_SERVER_RELEASE
ARG VS_CODE_VERSION
ARG CODE_WORKDIR
ARG PANDOC_VERSION

ENV NB_USER=${NB_USER:-jovyan} \
    NB_UID=${NB_UID:-1000} \
    NB_GID=${NB_GID:-100} \
    JUPYTERHUB_VERSION=${JUPYTERHUB_VERSION:-1.0.0} \
    JUPYTERLAB_VERSION=${JUPYTERLAB_VERSION:-1.2.6} \
    CODE_SERVER_RELEASE=${CODE_SERVER_RELEASE:-2.1698} \
    VS_CODE_VERSION=${VS_CODE_VERSION:-1.41.1} \
    CODE_BUILTIN_EXTENSIONS_DIR=/opt/code-server/extensions \
    PANDOC_VERSION=${PANDOC_VERSION:-2.9}

USER root

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    curl \
    file \
    git \
    gnupg \
    less \
    libclang-dev \
    lsb-release \
    man-db \
    multiarch-support \
    nano \
    procps \
    psmisc \
    python3-venv \
    python3-virtualenv \
    ssh \
    sudo \
    vim \
    wget \
    ## Current ZeroMQ library for R pbdZMQ
    libzmq3-dev \
    pkg-config \    
    ## Required for R languageserver
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
  ## Clean up
  && rm -rf /var/lib/apt/lists/* \
  ## Install pandoc
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-amd64.deb \
  && rm pandoc-${PANDOC_VERSION}-1-amd64.deb \
  ## configure git not to request password each time
  && git config --system credential.helper "cache --timeout=3600" \
  ## Add user
  && useradd -m -s /bin/bash -N -u ${NB_UID} ${NB_USER}

## Install code-server
RUN mkdir -p ${CODE_BUILTIN_EXTENSIONS_DIR} \
  && cd /opt/code-server \
  && curl -sL https://github.com/cdr/code-server/releases/download/${CODE_SERVER_RELEASE}/code-server${CODE_SERVER_RELEASE}-vsc${VS_CODE_VERSION}-linux-x86_64.tar.gz | tar zxvf - --strip-components=1 \
  && curl -sL https://upload.wikimedia.org/wikipedia/commons/9/9a/Visual_Studio_Code_1.35_icon.svg -o vscode.svg \
  && cd /

ENV PATH=/opt/code-server:$PATH

## Install JupyterLab
RUN curl -sLO https://bootstrap.pypa.io/get-pip.py \
  && python3 get-pip.py \
  && rm get-pip.py \
  ## Install Python packages
  && pip3 install \
    jupyterhub==${JUPYTERHUB_VERSION} \
    jupyterlab==${JUPYTERLAB_VERSION} \
    notebook==6.0.3 \
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
  ## Install JupyterLab extensions
  && pip3 install jupyter-server-proxy jupyterlab-git \
  && jupyter serverextension enable --py jupyter_server_proxy --sys-prefix \
  && jupyter labextension install @jupyterlab/server-proxy --no-build \
  && jupyter labextension install @jupyterlab/git --no-build \
  && jupyter lab build \
  && echo '{\n  "@jupyterlab/apputils-extension:themes": {\n    "theme": "JupyterLab Dark"\n  }\n}' > /usr/local/share/jupyter/lab/settings/overrides.json \
  ## Install code-server extensions
  && cd /tmp \
  && curl -sL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/alefragnani/vsextensions/project-manager/10.9.1/vspackage -o alefragnani.project-manager-10.9.1.vsix.gz \
  && gunzip alefragnani.project-manager-10.9.1.vsix.gz \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension alefragnani.project-manager-10.9.1.vsix \
  && curl -sL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/christian-kohler/vsextensions/path-intellisense/1.4.2/vspackage -o christian-kohler.path-intellisense-1.4.2.vsix.gz \
  && gunzip christian-kohler.path-intellisense-1.4.2.vsix.gz \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension christian-kohler.path-intellisense-1.4.2.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension eamodio.gitlens \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension piotrpalarz.vscode-gitignore-generator \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension redhat.vscode-yaml \
  && curl -sL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Ikuyadeu/vsextensions/r/1.2.2/vspackage -o Ikuyadeu.r-1.2.2.vsix.gz \
  && gunzip Ikuyadeu.r-1.2.2.vsix.gz \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension Ikuyadeu.r-1.2.2.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension REditorSupport.r-lsp \
  ## Needed to get R LSP to work (Broken extension? https://github.com/cdr/code-server/issues/1187)
  && cd /opt/code-server/extensions/reditorsupport.r-lsp-0.1.4/ \
  && npm install \
  && cd / \
  ## Clean up (Node.js)
  && rm -rf /tmp/* \
  && apt-get remove --purge -y nodejs $DEPS \
  && apt-get autoremove -y \
  && apt-get autoclean -y \
  && rm -rf /var/lib/apt/lists/* \
    /root/.cache \
    /root/.config \
    /root/.local \
    /root/.npm \
    /usr/local/share/.cache

## Install the R kernel for JupyterLab
RUN install2.r --error --deps TRUE \
    IRkernel \
    languageserver \
  && Rscript -e "IRkernel::installspec(user = FALSE)" \
  && rm -rf /tmp/* \
    /root/.local

## Install Tini
RUN curl -sL https://github.com/krallin/tini/releases/download/v0.18.0/tini -o /usr/local/bin/tini \
  && chmod +x /usr/local/bin/tini

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER} \
    CODE_WORKDIR=${CODE_WORKDIR:-/home/${NB_USER}/projects} \
    SHELL=/bin/bash

WORKDIR ${HOME}

RUN mkdir -p .local/share/code-server/User \
  && echo '{\n    "telemetry.enableTelemetry": false,\n    "gitlens.advanced.telemetry.enabled": false,\n    "r.rterm.linux": "/usr/local/bin/R",\n    "r.rterm.option": [\n        "--no-save",\n        "--no-restore"\n    ],\n    "r.sessionWatcher": true,\n}' > .local/share/code-server/User/settings.json

## Copy local files as late as possible to avoid cache busting
COPY *.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

EXPOSE 8888

## Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["init-notebook.sh"]
