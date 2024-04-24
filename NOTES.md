# Notes

This docker stack uses modified startup scripts from
[jupyter/docker-stacks](https://github.com/jupyter/docker-stacks).  
:information_source: Nevertheless, all [Docker Options](https://github.com/jupyter/docker-stacks/blob/main/docs/using/common.md#docker-options)
and [Permission-specific configurations](https://github.com/jupyter/docker-stacks/blob/main/docs/using/common.md#permission-specific-configurations)
can be used for the images of this docker stack.

## Tweaks

In comparison to
[jupyter/docker-stacks](https://github.com/jupyter/docker-stacks)
and/or
[rocker-org/rocker-versioned2](https://github.com/rocker-org/rocker-versioned2),
these images are tweaked as follows:

### Jupyter startup scripts

Shell script [/usr/local/bin/start.sh](base/scripts/usr/local/bin/start.sh) is
modified to

* allow *bind mounting* of a home directory.
* reset `CODE_WORKDIR` for custom `NB_USER`s.

### Jupyter startup hooks

The following startup hooks are put in place:

* [/usr/local/bin/start-notebook.d/10-populate.sh](base/scripts/usr/local/bin/start-notebook.d/10-populate.sh)
  to populate a *bind mounted* home directory `/home/jovyan`.
* [/usr/local/bin/before-notebook.d/10-env.sh](base/scripts/usr/local/bin/before-notebook.d/10-env.sh) to
  * update timezone according to environment variable `TZ`.
  * add locales according to environment variable `LANGS`.
  * set locale according to environment variable `LANG`.
* [/usr/local/bin/before-notebook.d/11-home.sh](base/scripts/usr/local/bin/before-notebook.d/11-home.sh)
  to create user's projects and workspaces folder.
* [/usr/local/bin/before-notebook.d/12-r.sh](base/scripts/usr/local/bin/before-notebook.d/12-r.sh)
  to create user's R package library.
* [/usr/local/bin/before-notebook.d/13-update-cran.sh](base/scripts/usr/local/bin/before-notebook.d/13-update-cran.sh) to
  * update CRAN mirror according to environment variable `CRAN`.
  * use binary packages according to environment variable `R_BINARY_PACKAGES`.
* [/usr/local/bin/before-notebook.d/30-code-server.sh](base/scripts/usr/local/bin/before-notebook.d/30-code-server.sh)
  to update code-server settings.
* [/usr/local/bin/before-notebook.d/70-qgis.sh](qgisprocess/scripts/usr/local/bin/before-notebook.d/70-qgis.sh) to
  * put inital QGIS settings in place.
  * copy plugin 'Processing Saga NextGen Provider'.
* [/usr/local/bin/before-notebook.d/90-limits.sh](base/scripts/usr/local/bin/before-notebook.d/90-limits.sh)
  to set the *soft limit* for *the maximum amount of virtual memory* based on
  the amount of *physical* and *virtual memory* of the host.

### Custom scripts

[/usr/local/bin/busy](base/scripts/usr/local/bin/busy) is executed during
`screen`/`tmux` sessions to update the last-activity timestamps on JupyterHub.

:information_source: This prevents the [JupyterHub Idle Culler Service](https://github.com/jupyterhub/jupyterhub-idle-culler)
from shutting down idle or long-running Jupyter Notebook servers, allowing for
unattended computations.

### Environment variables

* `CRAN`: The CRAN mirror URL.
* `R_BINARY_PACKAGES`: R package type to use.
  * unset: Source packages. (default)
  * `1`/`yes`: Binary packages.
* `DOWNLOAD_STATIC_LIBV8=1`: R (V8): Installing V8 on Linux, the alternative
  way.
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
* `PARENT_IMAGE`: The image it was derived from.
* `BUILD_DATE`: The date it was built (ISO 8601 format).
* `CTAN_REPO`: The CTAN mirror URL. (verse+ images)

**`MRAN`**

Environment variable `MRAN` is deprecated:

> After January 31, 2023, we \[Microsoft\] will no longer maintain the CRAN Time
> Machine snapshots.

Current situation regarding *frozen* images:

* R version < 4.2.2: MRAN retired; CRAN snapshots broken.
* 4.2.2 ≤ R version < 4.3.1: No CRAN snapshots available.
    * Use [renv](https://rstudio.github.io/renv/) to create **r**eproducible
      **env**ironments for your R projects.
* R version ≥ 4.3.1: CRAN snapshots reinstated (PPM).

### Shell

The default shell is Zsh, further enhanced with

* Framework: [Oh My Zsh](https://ohmyz.sh/)
* Theme: [Powerlevel10k](https://github.com/romkatv/powerlevel10k#oh-my-zsh)
* Font: [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts)

### Extensions (code-server)

Pre-installed extensions are treated as *built-in* and therefore cannot be
updated at user level.

### TeX packages (verse+ images)

In addition to the TeX packages used in
[rocker/verse](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_texlive.sh),
[jupyter/scipy-notebook](https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile)
and required for `nbconvert`, the
[packages requested by the community](https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt)
are installed.

## Settings

### Default

* R: `$(R RHOME)/etc/Rprofile.site`
  * IRkernel: Only enable `image/svg+xml` and `application/pdf` for plot
    display.
  * R Extension (code-server): Disable help panel and revert to old behaviour.
* [IPython](base/conf/ipython/usr/local/etc/ipython/ipython_config.py):
  * Only enable figure formats `svg` and `pdf` for IPython.
* [JupyterLab](base/conf/jupyterlab/usr/local/share/jupyter/lab/settings/overrides.json):
  * Theme > Selected Theme: JupyterLab Dark
  * Terminal > Font family: MesloLGS NF
  * Python LSP Server: Example settings according to [jupyter-lsp/jupyterlab-lsp > Installation > Configuring the servers](https://github.com/jupyter-lsp/jupyterlab-lsp#configuring-the-servers)
  * R LSP Server: Example settings according to [jupyter-lsp/jupyterlab-lsp > Installation > Configuring the servers](https://github.com/jupyter-lsp/jupyterlab-lsp#configuring-the-servers)
* [code-server](base/conf/user/var/backups/skel/.local/share/code-server/User/settings.json)
  * Text Editor > Tab Size: 2
  * Extensions > GitLens — Git supercharged
    * General > Show Welcome On Install: false
    * General > Show Whats New After Upgrade: false
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
  * [Powerlevel10k](base/conf/user/var/backups/skel/.p10k.zsh): `p10k configure`
    * Does this look like a diamond (rotated square)?: (y)  Yes.
    * Does this look like a lock?: (y)  Yes.
    * Does this look like a Debian logo (swirl/spiral)?: (y)  Yes.
    * Do all these icons fit between the crosses?: (y)  Yes.
    * Prompt Style: (3)  Rainbow.
    * Character Set: (1)  Unicode.
    * Show current time?: (2)  24-hour format.
    * Prompt Separators: (1)  Angled.
    * Prompt Heads: (1)  Sharp.
    * Prompt Tails: (1)  Flat.
    * Prompt Height: (2)  Two lines.
    * Prompt Connection: (2)  Dotted.
    * Prompt Frame: (2)  Left.
    * Connection & Frame Color: (2)  Light.
    * Prompt Spacing: (2)  Sparse.
    * Icons: (2)  Many icons.
    * Prompt Flow: (1)  Concise.
    * Enable Transient Prompt?: (n)  No.
    * Instant Prompt Mode: (3)  Off.

### Customise

* R: Create file `~/.Rprofile`
  * Valid plot mimetypes: `image/png`, `image/jpeg`, `image/svg+xml`,
    `application/pdf`.  
    :information_source: MIME type `text/plain` must always be specified.
* IPython: Create file `~/.ipython/profile_default/ipython_config.py`
  * Valid figure formats: `png`, `retina`, `jpeg`, `svg`, `pdf`.
* JupyterLab: Settings > Advanced Settings Editor
* code-server: Manage > Settings

* Zsh
  * Oh My Zsh: Edit `~/.zshrc`.
  * Powerlevel10k: Run `p10k configure` or edit `~/.p10k.zsh`.
    * Update command:
      `git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull`

## Python

The Python version is selected as follows:

* The latest [Python version numba is compatible with](https://numba.readthedocs.io/en/stable/user/installing.html#numba-support-info).

This Python version is installed at `/usr/local/bin`.

# Additional notes on CUDA

The CUDA and OS versions are selected as follows:

* CUDA: The lastest version that has image flavour `devel` including cuDNN
  available.
* OS: The latest version that has TensortRT libraries for `amd64` available.  
  :information_source: It is taking quite a long time for these to be available
  for `arm64`.

## Tweaks

* Provide NVBLAS-enabled `R_` and `Rscript_`.
  * Enabled at runtime and only if `nvidia-smi` and at least one GPU are
    present.

### Environment variables

**Versions**

* `CUDA_VERSION`

**Miscellaneous**

* `CUDA_IMAGE`: The CUDA image it is derived from.

## Settings

### Default

* code-server
  * Extensions > R > Rterm: Linux: `/usr/local/bin/R`

## Basic Linear Algebra Subprograms (BLAS)

These images use OpenBLAS by default.

To have `R` and `Rscript` use NVBLAS instead,

1. copy the NVBLAS-enabled executables to `~/.local/bin`  
   ```bash
   for file in $(which {R,Rscript}); do
     cp "$file"_ "$HOME/.local/bin/$(basename "$file")";
   done
   ```
1. set Extensions > R > Rterm > Linux: `/home/USER/.local/bin/R` in code-server
   settings  
   :point_right: Substitute `USER` with your user name.

and restart the R terminal.

:information_source: The
[xgboost](https://cran.r-project.org/package=xgboost) package benefits greatly
from NVBLAS, if it is
[installed correctly](https://xgboost.readthedocs.io/en/stable/build.html).

# Additional notes on subtag `devtools`

Node.js is installed with corepack enabled by default. Use it to manage Yarn
and/or pnpm:

* [Installation | Yarn - Package Manager > Updating the global Yarn version](https://yarnpkg.com/getting-started/install#updating-the-global-yarn-version)
* [Installation | pnpm > Using Corepack](https://pnpm.io/installation#using-corepack)

## System Python

Package `libsecret-1-dev` depends on `python3` from the system's package
repository.

The system's Python version is installed at `/usr/bin`.  

:information_source: Because [a more recent Python version](#python) is
installed at `/usr/local/bin`, it takes precedence over the system's Python
version.
