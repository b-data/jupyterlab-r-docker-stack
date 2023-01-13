# Notes

This docker stack uses modified startup scripts from
[jupyter/docker-stacks](https://github.com/jupyter/docker-stacks).

Nevertheless, all [Docker Options](https://github.com/jupyter/docker-stacks/blob/main/docs/using/common.md#docker-options)
and [Permission-specific configurations](https://github.com/jupyter/docker-stacks/blob/main/docs/using/common.md#permission-specific-configurations)
can be used for the images of this docker stack.

## Tweaks

In comparison to
[jupyter/docker-stacks](https://github.com/jupyter/docker-stacks)
and/or
[rocker-org/rocker-versioned2](https://github.com/rocker-org/rocker-versioned2),
these images are tweaked as follows:

### Startup scripts

Shell script [/usr/local/bin/start.sh](base/scripts/usr/local/bin/start.sh) is
modified to

* allow *bind mounting* of a home directory.
* reset `CODE_WORKDIR` for custom `NB_USER`s.

### Startup Hooks

The following startup hooks are put in place:

* [/usr/local/bin/start-notebook.d/populate.sh](base/scripts/usr/local/bin/start-notebook.d/populate.sh)
  to populate a *bind mounted* home directory `/home/jovyan`.
* [/usr/local/bin/before-notebook.d/init.sh](base/scripts/usr/local/bin/before-notebook.d/init.sh) to
  * update timezone according to environment variable `TZ`.
  * add locales according to environment variable `LANGS`.
  * set locale according to environment variable `LANG`.
  * create R user library.
  * update code-server settings.

### Custom scripts

[/usr/local/bin/busy](base/scripts/usr/local/bin/busy) is executed during
`screen`/`tmux` sessions to update the last-activity timestamps on JupyterHub.

:information_source: This prevents the [JupyterHub Idle Culler Service](https://github.com/jupyterhub/jupyterhub-idle-culler)
from shutting down idle or long-running Jupyter Notebook servers, allowing for
unattended computations.

### Environment variables

* `DOWNLOAD_STATIC_LIBV8=1`: R (V8): Installing V8 on Linux, the alternative way.
* `RETICULATE_MINICONDA_ENABLED=0`: R (reticulate): Disable prompt to install
  miniconda.
* `CS_DISABLE_GETTING_STARTED_OVERRIDE=1`: code-server: Hide the coder/coder
  promotion in Help: Getting Started

**Versions**

* `R_VERSION`
* `PYTHON_VERSION`
* `JUPYTERHUB_VERSION`
* `JUPYTERLAB_VERSION`
* `CODE_SERVER_VERSION`
* `GIT_VERSION`
* `GIT_LFS_VERSION`
* `PANDOC_VERSION`
* `QUARTO_VERSION` (verse+ images)

**Miscellaneous**

* `BASE_IMAGE`: Its very base, a [Docker Official Image](https://hub.docker.com/search?q=&type=image&image_filter=official).
* `PARENT_IMAGE`: The image it was built on.
* `BUILD_DATE`: The date (UTC) it was built.
* `CRAN`: The CRAN mirror URL.
* `CTAN_REPO`: The CTAN mirror URL.

**`MRAN`**

Environment variable `MRAN` is deprecated:

> After January 31, 2023, we \[Microsoft\] will no longer maintain the CRAN Time
> Machine snapshots.

For *frozen* images (R versions ≥ 4.2.2), `CRAN` is no longer set to an `MRAN`
snapshot in `$(R RHOME)/etc/Rprofile.site`.

:point_right: Use [renv](https://rstudio.github.io/renv/) to create
**r**eproducible **env**ironments for your R projects as these will also work
without the images of this docker stack.

### Shell

The default shell is Zsh, further enhanced with

* Framework: [Oh My Zsh](https://ohmyz.sh/)
* Theme: [Powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh)
* Font: [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts)

### Extensions (code-server)

Pre-installed extensions are treated as *built-in* and therefore cannot be
updated at user level.

### TeX packages

In addition to the TeX packages used in
[rocker/verse](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_texlive.sh),
[jupyter/scipy-notebook](https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile)
and required for `nbconvert`, the
[packages requested by the community](https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt)
are installed.

## Settings

### Default

* R: `$(R RHOME)/etc/Rprofile.site`
  * IRkernel: Only enable `image/svg+xml` and `application/pdf` for plot display.
  * R Extension (code-server): Disable help panel and revert to old behaviour.
* [Terminal IPython](base/conf/ipython/usr/local/etc/ipython/ipython_config.py):
  * Only enable figure formats `svg` and `pdf` for Terminal IPython.
* [IPython kernel](base/conf/ipython/usr/local/etc/ipython/ipython_kernel_config.py):
  * Only enable figure formats `svg` and `pdf` for IPython Kernel (Jupyter
    Notebooks).
* [JupyterLab](base/conf/jupyterlab/usr/local/share/jupyter/lab/settings/overrides.json):
  * Theme > Selected Theme: JupyterLab Dark
  * Terminal > Font family: MesloLGS NF
  * Python LSP Server: Example settings according to [jupyter-lsp/jupyterlab-lsp > Installation > Configuring the servers](https://github.com/jupyter-lsp/jupyterlab-lsp#configuring-the-servers)
  * R LSP Server: Example settings according to [jupyter-lsp/jupyterlab-lsp > Installation > Configuring the servers](https://github.com/jupyter-lsp/jupyterlab-lsp#configuring-the-servers)
* [code-server](base/conf/user/var/backups/skel/.local/share/code-server/User/settings.json)
  * Text Editor > Tab Size: 2
  * Extensions > Gitlens > Graph > Status Bar: Enabled: off
    * Graph commands disabled where possible
  * Extensions > R
    * Bracketed Paste: true
    * Plot: Use Httpgd: true
    * Rterm: Linux: `/usr/local/bin/radian`
    * Rterm: Option: `["--no-save", "--no-restore"]`
    * Workspace Viewer: Show Object Size: true
  * Application > Telemetry: Telemetry Level: off
  * Features > Terminal > Integrated: Font Family: MesloLGS NF
  * Workbench > Appearance > Color Theme: Default Dark+
* Zsh
  * Oh My Zsh: `~/.zshrc`
    * Set PATH so it includes user's private bin if it exists
    * Update last-activity timestamps while in screen/tmux session
  * [Powerlevel10k](base/conf/user/var/backups/skel/.p10k.zsh)

### Customise

* R: Create file `~/.Rprofile`
  * Valid plot mimetypes: `image/png`, `image/jpeg`, `image/svg+xml`, `application/pdf`.
    :information_source: MIME type `text/plain` must always be specified.
* Terminal IPython: Create file `~/.ipython/profile_default/ipython_config.py`
  * Valid figure formats: `png`, `retina`, `jpeg`, `svg`, `pdf`.
* IPython kernel: Create file `~/.ipython/profile_default/ipython_kernel_config.py`
  * Valid figure formats: `png`, `retina`, `jpeg`, `svg`, `pdf`.
* JupyterLab: Settings > Advanced Settings Editor
* code-server: Manage > Settings

* Zsh
  * Oh My Zsh: Edit `~/.zshrc`.
  * Powerlevel10k: Run `p10k configure` or edit `~/.p10k.zsh`.

## Python

The Python version is selected as follows:

* The latest [Python version numba is compatible with](https://numba.readthedocs.io/en/stable/user/installing.html#compatibility).

This Python version is installed at `/user/local/bin`.

# Notes on CUDA

The CUDA and OS versions are selected as follows:

* CUDA: The lastest version that has image flavour `devel` including cuDNN
  available.
* OS: The latest version that has TensortRT libraries for both `amd64` and
  `arm64` available.

## Tweaks

* Provide NVBLAS-enabled R and Rscript and radian.
  * Enabled at runtime and only if `nvidia-smi` and at least one GPU are
    present.

### Environment variables

**Versions**

* `CUDA_VERSION`

**Miscellaneous**

* `CUDA_IMAGE`: The CUDA image it is derived from.

# Notes on subtag `devtools`

Node.js is installed with corepack enabled by default. Use it to manage Yarn
and/or pnpm:

* [Installation | Yarn - Package Manager > Updating the global Yarn version](https://yarnpkg.com/getting-started/install#updating-the-global-yarn-version)
* [Installation | pnpm > Using Corepack](https://pnpm.io/installation#using-corepack)

## OS Python

Package `libsecret-1-dev` depends on `python3` from the OS' package repository.

The OS' Python version is installed at `/usr/bin`.  

:information_source: Because the [recent Python version](#python) is installed
at `/user/local/bin`, it precedes the OS' Python version.
