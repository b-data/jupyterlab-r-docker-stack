ARG BASE_IMAGE=debian:bullseye
ARG GIT_VERSION=2.32.0

FROM registry.gitlab.b-data.ch/git/gsi/${GIT_VERSION}/${BASE_IMAGE} as gsi

FROM registry.gitlab.b-data.ch/r/r-ver:4.1.1

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/jupyterlab/r/docker-stack" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG DEBIAN_FRONTEND=noninteractive

ARG NB_USER=jovyan
ARG NB_UID=1000
ARG NB_GID=100
ARG JUPYTERHUB_VERSION=1.4.2
ARG JUPYTERLAB_VERSION=3.1.11
ARG CODE_SERVER_RELEASE=3.10.2
ARG GIT_VERSION=2.32.0
ARG PANDOC_VERSION=2.14.2
ARG CODE_WORKDIR

ENV NB_USER=${NB_USER} \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    JUPYTERHUB_VERSION=${JUPYTERHUB_VERSION} \
    JUPYTERLAB_VERSION=${JUPYTERLAB_VERSION} \
    CODE_SERVER_RELEASE=${CODE_SERVER_RELEASE} \
    GIT_VERSION=${GIT_VERSION} \
    PANDOC_VERSION=${PANDOC_VERSION} \
    CODE_BUILTIN_EXTENSIONS_DIR=/opt/code-server/extensions

## Installing V8 on Linux, the alternative way
## https://ropensci.org/blog/2020/11/12/installing-v8
ENV DOWNLOAD_STATIC_LIBV8=1

COPY --from=gsi /usr/local /usr/local

USER root

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    curl \
    file \
    git \
    gnupg \
    info \
    jq \
    libclang-dev \
    lsb-release \
    man-db \
    nano \
    procps \
    psmisc \
    python3-venv \
    python3-virtualenv \
    screen \
    sudo \
    tmux \
    vim \
    wget \
    zsh \
    ## Additional git runtime dependencies
    libcurl3-gnutls \
    liberror-perl \
    ## Additional git runtime recommendations
    less \
    ssh-client \
    ## Current ZeroMQ library for R pbdZMQ
    libzmq3-dev \
    ## Required for R languageserver
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
  ## Clean up
  && rm -rf /var/lib/apt/lists/* \
  ## Install font MesloLGS NF
  && mkdir -p /usr/share/fonts/truetype/meslo \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -o /usr/share/fonts/truetype/meslo/MesloLGS\ NF\ Regular.ttf \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -o /usr/share/fonts/truetype/meslo/MesloLGS\ NF\ Bold.ttf \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -o /usr/share/fonts/truetype/meslo/MesloLGS\ NF\ Italic.ttf \
  && curl -sL https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -o /usr/share/fonts/truetype/meslo/MesloLGS\ NF\ Bold\ Italic.ttf \
  && fc-cache -fv \
  ## Install pandoc
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  && rm pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  ## Install pandoc templates
  && git clone --recursive --branch ${PANDOC_VERSION} https://github.com/jgm/pandoc-templates \
  && rm -rf /opt/pandoc/templates \
  && mkdir -p /opt/pandoc/templates \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && rm -rf /root/.pandoc \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \
  ## Set default branch name to main
  && git config --system init.defaultBranch main \
  ## Store passwords for one hour in memory
  && git config --system credential.helper "cache --timeout=3600" \
  ## Merge the default branch from the default remote when "git pull" is run
  && git config --system pull.rebase false \
  ## Add user
  && useradd -m -s /bin/bash -N -u ${NB_UID} ${NB_USER}

## Install code-server
RUN mkdir -p ${CODE_BUILTIN_EXTENSIONS_DIR} \
  && cd /opt/code-server \
  && curl -sL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_RELEASE}/code-server-${CODE_SERVER_RELEASE}-linux-$(dpkg --print-architecture).tar.gz | tar zxf - --strip-components=1 \
  && curl -sL https://upload.wikimedia.org/wikipedia/commons/9/9a/Visual_Studio_Code_1.35_icon.svg -o vscode.svg \
  && cd /

ENV PATH=/opt/code-server/bin:$PATH

## Install JupyterLab
RUN dpkgArch="$(dpkg --print-architecture)" \
  && curl -sLO https://bootstrap.pypa.io/get-pip.py \
  && python3 get-pip.py \
  && rm get-pip.py \
  ## Install python3-dev to build argon2-cffi on aarch64
  ## https://github.com/hynek/argon2-cffi/issues/73
  && if [ "$dpkgArch" = "arm64" ]; then \
    DEPS=python3-dev; \
    apt-get update; \
    apt-get install -y --no-install-recommends $DEPS; \
  fi \
  ## Install Python packages
  && pip3 install \
    jupyter-server-proxy \
    jupyterhub==${JUPYTERHUB_VERSION} \
    jupyterlab==${JUPYTERLAB_VERSION} \
    jupyterlab-git \
    notebook \
    nbconvert \
    radian \
  ## Remove python3-dev
  && if [ "$dpkgArch" = "arm64" ]; then \
    apt-get remove --purge -y $DEPS; \
  fi \
  ## Install Node.js
  && curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  ## Install JupyterLab extensions
  && jupyter labextension install @jupyterlab/server-proxy --no-build \
  && jupyter labextension install @jupyterlab/git --no-build \
  && jupyter lab build \
  && echo '{\n  "@jupyterlab/apputils-extension:themes": {\n    "theme": "JupyterLab Dark"\n  }\n}' > /usr/local/share/jupyter/lab/settings/overrides.json \
  ## Install code-server extensions
  && cd /tmp \
  && curl -sLO https://dl.b-data.ch/vsix/alefragnani.project-manager-12.4.0.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension alefragnani.project-manager-12.4.0.vsix \
  && curl -sLO https://dl.b-data.ch/vsix/fabiospampinato.vscode-terminals-1.12.9.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension fabiospampinato.vscode-terminals-1.12.9.vsix \
  && curl -sLO https://open-vsx.org/api/GitLab/gitlab-workflow/3.30.0/file/GitLab.gitlab-workflow-3.30.0.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension GitLab.gitlab-workflow-3.30.0.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension ms-python.python \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension christian-kohler.path-intellisense \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension eamodio.gitlens \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension piotrpalarz.vscode-gitignore-generator \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension redhat.vscode-yaml \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension grapecity.gc-excelviewer \
  && curl -sLO https://open-vsx.org/api/Ikuyadeu/r/1.6.8/file/Ikuyadeu.r-1.6.8.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension Ikuyadeu.r-1.6.8.vsix \
  && curl -sLO https://open-vsx.org/api/REditorSupport/r-lsp/0.1.14/file/REditorSupport.r-lsp-0.1.14.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension REditorSupport.r-lsp-0.1.14.vsix \
  && mkdir -p /usr/local/bin/start-notebook.d \
  && mkdir -p /usr/local/bin/before-notebook.d \
  && cd / \
  ## Clean up
  && rm -rf /tmp/* \
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
RUN curl -sL https://github.com/krallin/tini/releases/download/v0.19.0/tini-$(dpkg --print-architecture) -o /usr/local/bin/tini \
  && chmod +x /usr/local/bin/tini

## Switch back to ${NB_USER} to avoid accidental container runs as root
USER ${NB_USER}

ENV HOME=/home/${NB_USER} \
    CODE_WORKDIR=${CODE_WORKDIR:-/home/${NB_USER}/projects} \
    SHELL=/usr/bin/zsh \
    TERM=xterm-256color

WORKDIR ${HOME}

RUN mkdir -p .local/share/code-server/User \
  && echo '{\n    "editor.tabSize": 2,\n    "telemetry.enableTelemetry": false,\n    "gitlens.advanced.telemetry.enabled": false,\n    "r.bracketedPaste": true,\n    "r.rterm.linux": "/usr/local/bin/radian",\n    "r.rterm.option": [],\n    "r.sessionWatcher": true,\n    "workbench.colorTheme": "Default Dark+"\n}' > .local/share/code-server/User/settings.json \
  && cp .local/share/code-server/User/settings.json /var/tmp \
  && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended \
  && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git .oh-my-zsh/custom/themes/powerlevel10k \
  && sed -i 's/ZSH="\/home\/jovyan\/.oh-my-zsh"/ZSH="$HOME\/.oh-my-zsh"/g' .zshrc \
  #&& sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' .zshrc \
  && echo "\n# set PATH so it includes user's private bin if it exists\nif [ -d "\$HOME/bin" ] ; then\n    PATH="\$HOME/bin:\$PATH"\nfi" | tee -a .bashrc .zshrc \
  && echo "\n# set PATH so it includes user's private bin if it exists\nif [ -d "\$HOME/.local/bin" ] ; then\n    PATH="\$HOME/.local/bin:\$PATH"\nfi" | tee -a .bashrc .zshrc \
  && echo "\n# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh." >> .zshrc \
  && echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> .zshrc \
  && cp -a $HOME /var/tmp

## Copy local files as late as possible to avoid cache busting
COPY start*.sh /usr/local/bin/
COPY populate.sh /usr/local/bin/start-notebook.d/
COPY init.sh /usr/local/bin/before-notebook.d/
COPY jupyter_notebook_config.py /etc/jupyter/

EXPOSE 8888

## Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]
