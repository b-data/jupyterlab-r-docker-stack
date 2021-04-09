FROM registry.gitlab.b-data.ch/r/r-ver:4.0.5

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://gitlab.b-data.ch/jupyterlab/r/docker-stack" \
      maintainer="Olivier Benz <olivier.benz@b-data.ch>"

ARG NB_USER
ARG NB_UID
ARG NB_GID
ARG JUPYTERHUB_VERSION
ARG JUPYTERLAB_VERSION
ARG CODE_SERVER_RELEASE
ARG CODE_WORKDIR
ARG PANDOC_VERSION

ENV NB_USER=${NB_USER:-jovyan} \
    NB_UID=${NB_UID:-1000} \
    NB_GID=${NB_GID:-100} \
    JUPYTERHUB_VERSION=${JUPYTERHUB_VERSION:-1.3.0} \
    JUPYTERLAB_VERSION=${JUPYTERLAB_VERSION:-3.0.13} \
    CODE_SERVER_RELEASE=${CODE_SERVER_RELEASE:-3.9.3} \
    CODE_BUILTIN_EXTENSIONS_DIR=/opt/code-server/extensions \
    PANDOC_VERSION=${PANDOC_VERSION:-2.10.1}

USER root

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    curl \
    file \
    git \
    gnupg \
    jq \
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
    screen \
    ssh \
    sudo \
    tmux \
    vim \
    wget \
    zsh \
    ## Current ZeroMQ library for R pbdZMQ
    libzmq3-dev \
    pkg-config \    
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
  && curl -sLO https://dl.b-data.ch/pandoc/releases/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  && rm pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  ## configure git not to request password each time
  && git config --system credential.helper "cache --timeout=3600" \
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
    jupyterlab-git==0.30.0b3 \
    notebook \
    nbconvert \
    radian \
  ## Remove python3-dev
  && if [ "$dpkgArch" = "arm64" ]; then \
    apt-get remove --purge -y $DEPS; \
  fi \
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
  && jupyter labextension install @jupyterlab/server-proxy --no-build \
  && jupyter labextension install @jupyterlab/git --no-build \
  && jupyter lab build \
  && echo '{\n  "@jupyterlab/apputils-extension:themes": {\n    "theme": "JupyterLab Dark"\n  }\n}' > /usr/local/share/jupyter/lab/settings/overrides.json \
  ## Install code-server extensions
  && cd /tmp \
  && curl -sLO https://dl.b-data.ch/vsix/alefragnani.project-manager-12.1.0.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension alefragnani.project-manager-12.1.0.vsix \
  && curl -sLO https://dl.b-data.ch/vsix/fabiospampinato.vscode-terminals-1.12.9.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension fabiospampinato.vscode-terminals-1.12.9.vsix \
  && curl -sLO https://open-vsx.org/api/GitLab/gitlab-workflow/3.17.0/file/GitLab.gitlab-workflow-3.17.0.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension GitLab.gitlab-workflow-3.17.0.vsix \
  && curl -sLO https://open-vsx.org/api/ms-python/python/2020.10.332292344/file/ms-python.python-2020.10.332292344.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension ms-python.python-2020.10.332292344.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension christian-kohler.path-intellisense \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension eamodio.gitlens \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension piotrpalarz.vscode-gitignore-generator \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension redhat.vscode-yaml \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension grapecity.gc-excelviewer \
  && curl -sLO https://open-vsx.org/api/Ikuyadeu/r/1.6.5/file/Ikuyadeu.r-1.6.5.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension Ikuyadeu.r-1.6.5.vsix \
  && curl -sLO https://open-vsx.org/api/REditorSupport/r-lsp/0.1.14/file/REditorSupport.r-lsp-0.1.14.vsix \
  && code-server --extensions-dir ${CODE_BUILTIN_EXTENSIONS_DIR} --install-extension REditorSupport.r-lsp-0.1.14.vsix \
  && mkdir -p /usr/local/bin/start-notebook.d \
  && mkdir -p /usr/local/bin/before-notebook.d \
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
    /usr/local/share/.cache \
    /etc/apt/sources.list.d/nodesource* \
  && apt-key del 0A1C1655A0AB68576280

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
