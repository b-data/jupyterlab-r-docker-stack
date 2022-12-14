# CUDA-enabled JupyterLab R images

GPU-accelerated, multi-arch (`linux/amd64`, `linux/arm64/v8`) images:

* [`registry.gitlab.b-data.ch/jupyterlab/cuda/r/base`](https://gitlab.b-data.ch/jupyterlab/cuda/r/base/container_registry)
* [`registry.gitlab.b-data.ch/jupyterlab/cuda/r/tidyverse`](https://gitlab.b-data.ch/jupyterlab/cuda/r/tidyverse/container_registry)
* [`registry.gitlab.b-data.ch/jupyterlab/cuda/r/verse`](https://gitlab.b-data.ch/jupyterlab/cuda/r/verse/container_registry)
* [`registry.gitlab.b-data.ch/jupyterlab/cuda/r/geospatial`](https://gitlab.b-data.ch/jupyterlab/cuda/r/geospatial/container_registry)

Images available for R versions ≥ 4.2.2.

:microscope: Check out `jupyterlab/cuda/r/verse` at
https://demo.cuda.jupyter.b-data.ch.  
:point_right: You can ask [b-data](mailto:request@b-data.ch?subject=[CUDA%20Jupyter]%20Request%20to%20whitelist%20GitHub%20account) to whitelist your GitHub account for access.

**Features**

The same as the [JupyterLab R images](README.md#jupyterlab-r-docker-stack)
plus

* CUDA runtime,
  [CUDA math libraries](https://developer.nvidia.com/gpu-accelerated-libraries),
  [NCCL](https://developer.nvidia.com/nccl) and
  [cuDNN](https://developer.nvidia.com/cudnn)
  * including development libraries and headers
* TensortRT and TensorRT plugin libraries
  * including development libraries and headers
* R configured to use NVBLAS, with fallback on OpenBLAS
  * using standard R terminal instead of radian

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install](#install)
* [Usage](#usage)
* [Similar projects](#similar-projects)

## Prerequisites

The same as the [JupyterLab R images](README.md#prerequisites) plus

* NVIDIA GPU
* NVIDIA Linux driver
* NVIDIA Container Toolkit

:information_source: The host running the CUDA-enabled images only requires the
NVIDIA driver, the CUDA toolkit does not have to be installed.

## Install

To install the NVIDIA Container Toolkit, follow the instructions for your
platform:

* [Installation Guide &mdash; NVIDIA Cloud Native Technologies documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#supported-platforms)

## Usage

### Build image (base)

latest:

```bash
cd base && docker build \
  --build-arg BASE_IMAGE=ubuntu
  --build-arg BASE_IMAGE_TAG=20.04
  --build-arg BUILD_ON_IMAGE=registry.gitlab.b-data.ch/cuda/r/ver
  --build-arg R_VERSION=4.2.2
  --build-arg CUDA_IMAGE_FLAVOR=devel
  -t jupyterlab/cuda/r/base \
  -f latest.Dockerfile .
```

version:

```bash
cd base && docker build \
  --build-arg BASE_IMAGE=ubuntu
  --build-arg BASE_IMAGE_TAG=20.04
  --build-arg BUILD_ON_IMAGE=registry.gitlab.b-data.ch/cuda/r/ver
  --build-arg CUDA_IMAGE_FLAVOR=devel
  -t jupyterlab/cuda/r/base:MAJOR.MINOR.PATCH \
  -f MAJOR.MINOR.PATCH.Dockerfile .
```

For `MAJOR.MINOR.PATCH` ≥ `4.2.2`.

### Run container

self built:

```bash
docker run -it --rm \
  --gpus '"device=all"' \
  -p 8888:8888 \
  -v $PWD:/home/jovyan \
  jupyterlab/cuda/r/base[:MAJOR.MINOR.PATCH]
```

from the project's GitLab Container Registries:

* [`jupyterlab/cuda/r/base`](https://gitlab.b-data.ch/jupyterlab/cuda/r/base/container_registry)  
  ```bash
  docker run -it --rm \
    --gpus '"device=all"' \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/cuda/r/base[:MAJOR[.MINOR[.PATCH]]]
  ```
* [`jupyterlab/cuda/r/tidyverse`](https://gitlab.b-data.ch/jupyterlab/cuda/r/tidyverse/container_registry)  
  ```bash
  docker run -it --rm \
    --gpus '"device=all"' \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/cuda/r/tidyverse[:MAJOR[.MINOR[.PATCH]]]
  ```
* [`jupyterlab/cuda/r/verse`](https://gitlab.b-data.ch/jupyterlab/cuda/r/verse/container_registry)  
  ```bash
  docker run -it --rm \
    --gpus '"device=all"' \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/cuda/r/verse[:MAJOR[.MINOR[.PATCH]]]
  ```
* [`jupyterlab/cuda/r/geospatial`](https://gitlab.b-data.ch/jupyterlab/cuda/r/geospatial/container_registry)  
  ```bash
  docker run -it --rm \
    --gpus '"device=all"' \
    -p 8888:8888 \
    -v $PWD:/home/jovyan \
    registry.gitlab.b-data.ch/jupyterlab/cuda/r/geospatial[:MAJOR[.MINOR[.PATCH]]]
  ```

The use of the `-v` flag in the command mounts the current working directory on
the host (`$PWD` in the example command) as `/home/jovyan` in the container.  
The server logs appear in the terminal.

## Similar projects

* [iot-salzburg/gpu-jupyter](https://github.com/iot-salzburg/gpu-jupyter)
* [prp/jupyter-stack](https://gitlab.nrp-nautilus.io/prp/jupyter-stack)

**What makes this project different:**

1. Multi-arch: `linux/amd64`, `linux/arm64/v8`
1. Based on [`nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04`](https://hub.docker.com/r/nvidia/cuda/tags?page=1&name=11.8.0-cudnn8-devel-ubuntu20.04)
    * including development libraries and headers
1. TensortRT and TensorRT plugin libraries
    * including development libraries and headers
1. IDE: [code-server](https://github.com/coder/code-server) next to
   [JupyterLab](https://github.com/jupyterlab/jupyterlab)
1. Just Python – no [Conda](https://github.com/conda/conda) /
   [Mamba](https://github.com/mamba-org/mamba)
