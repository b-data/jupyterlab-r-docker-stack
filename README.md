[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a>

| See [CUDA](CUDA.md) for GPU-accelerated images. |
|-------------------------------------------------|

# JupyterLab R docker stack

Multi-arch (`linux/amd64`, `linux/arm64/v8`) images:

* [`registry.gitlab.b-data.ch/jupyterlab/r/base`](https://gitlab.b-data.ch/jupyterlab/r/base/container_registry)
  * [`registry.gitlab.b-data.ch/jupyterlab/r/r-ver`](https://gitlab.b-data.ch/jupyterlab/r/r-ver/container_registry) (4.0.4 ≤ version < 4.2.0)
* [`registry.gitlab.b-data.ch/jupyterlab/r/tidyverse`](https://gitlab.b-data.ch/jupyterlab/r/tidyverse/container_registry)
* [`registry.gitlab.b-data.ch/jupyterlab/r/verse`](https://gitlab.b-data.ch/jupyterlab/r/verse/container_registry)
* [`registry.gitlab.b-data.ch/jupyterlab/r/geospatial`](https://gitlab.b-data.ch/jupyterlab/r/geospatial/container_registry)

Images considered stable for R versions ≥ 4.2.0.  
:point_right: The current state may eventually be backported to versions ≥
4.0.4.

:microscope: Check out `jupyterlab/r/verse` at https://demo.jupyter.b-data.ch.

**Features**

* **JupyterLab**: A web-based interactive development environment for Jupyter
   notebooks, code, and data. The images include
  * **code-server**: VS Code in the browser without MS
    branding/telemetry/licensing.
  * **Git**: A distributed version-control system for tracking changes in source
    code.
  * **Git LFS**: A Git extension for versioning large files.
  * **Pandoc**: A universal markup converter.
  * **Python**: An interpreted, object-oriented, high-level programming language
    with dynamic semantics.
  * **Quarto**: A scientific and technical publishing system built on Pandoc.  
    :information_source: verse image, amd64 only
  * **R**: A language and environment for statistical computing and graphics.
  * **TinyTeX**: A lightweight, cross-platform, portable, and easy-to-maintain
    LaTeX distribution based on TeX Live.  
    :information_source: verse image
  * **Zsh**: A shell designed for interactive use, although it is also a
    powerful scripting language.

The following extensions are pre-installed for **code-server**:

* [.gitignore Generator](https://github.com/piotrpalarz/vscode-gitignore-generator)
* [Git Graph](https://open-vsx.org/extension/mhutchie/git-graph)
* [GitLab Workflow](https://open-vsx.org/extension/GitLab/gitlab-workflow)
* [GitLens — Git supercharged](https://open-vsx.org/extension/eamodio/gitlens)
* [Excel Viewer](https://open-vsx.org/extension/GrapeCity/gc-excelviewer)
* [Jupyter](https://open-vsx.org/extension/ms-toolsai/jupyter)
* [LaTeX Workshop](https://open-vsx.org/extension/James-Yu/latex-workshop)  
  :information_source: verse image
* [Path Intellisense](https://open-vsx.org/extension/christian-kohler/path-intellisense)
* [Project Manager](https://open-vsx.org/extension/alefragnani/project-manager)
* [Python](https://open-vsx.org/extension/ms-python/python)
* [Quarto](https://open-vsx.org/extension/quarto/quarto)  
  :information_source: verse image, amd64 only
* [R](https://open-vsx.org/extension/Ikuyadeu/r)
* [YAML](https://open-vsx.org/extension/redhat/vscode-yaml)

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install](#install)
* [Usage](#usage)
* [Similar projects](#similar-projects)
* [Contributing](#contributing)
* [License](#license)

## Prerequisites

This projects requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

* [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
* [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image (base)

latest:

```bash
cd base && docker build \
  --build-arg R_VERSION=4.2.2 \
  -t jupyterlab/r/base \
  -f latest.Dockerfile .
```

version:

```bash
cd base && docker build \
  -t jupyterlab/r/base:MAJOR.MINOR.PATCH \
  -f MAJOR.MINOR.PATCH.Dockerfile .
```

For `MAJOR.MINOR.PATCH` ≥ `4.2.0`.

### Run container

self built:

```bash
docker run -it --rm \
  -p 8888:8888 \
  -v $PWD:/home/jovyan \
  jupyterlab/r/base[:MAJOR.MINOR.PATCH]
```

from the project's GitLab Container Registries:

* [`jupyterlab/r/base`](https://gitlab.b-data.ch/jupyterlab/r/base/container_registry)  
  ```bash
  docker run -it --rm \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/r/base[:MAJOR[.MINOR[.PATCH]]]
  ```
* [`jupyterlab/r/tidyverse`](https://gitlab.b-data.ch/jupyterlab/r/tidyverse/container_registry)  
  ```bash
  docker run -it --rm \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/r/tidyverse[:MAJOR[.MINOR[.PATCH]]]
  ```
* [`jupyterlab/r/verse`](https://gitlab.b-data.ch/jupyterlab/r/verse/container_registry)  
  ```bash
  docker run -it --rm \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/r/verse[:MAJOR[.MINOR[.PATCH]]]
  ```
* [`jupyterlab/r/geospatial`](https://gitlab.b-data.ch/jupyterlab/r/geospatial/container_registry)  
  ```bash
  docker run -it --rm \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/r/geospatial[:MAJOR[.MINOR[.PATCH]]]
  ```

The use of the `-v` flag in the command mounts the current working directory on
the host (`$PWD` in the example command) as `/home/jovyan` in the container.  
The server logs appear in the terminal.

## Similar projects

* [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks)
* [rocker-org/rocker-versioned2](https://github.com/rocker-org/rocker-versioned2)

**What makes this project different:**

1. Multi-arch: `linux/amd64`, `linux/arm64/v8`  
   :information_source: Since R v4.0.4 (2021-02-15)
1. Base image: [Debian](https://hub.docker.com/_/debian) instead of
   [Ubuntu](https://hub.docker.com/_/ubuntu)
1. IDE: [code-server](https://github.com/coder/code-server) instead of
   [RStudio](https://github.com/rstudio/rstudio)
1. Just Python – no [Conda](https://github.com/conda/conda) /
   [Mamba](https://github.com/mamba-org/mamba)

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) © 2020 b-data GmbH
