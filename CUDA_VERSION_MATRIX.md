# CUDA Version Matrix

Topmost entry = Tag `latest`

| R     | Python  | SAGA[^1] | CUDA   | cuBLAS    | cuDNN     | NCCL   | TensorRT  | Linux distro |
|:------|:--------|:---------|:-------|:----------|:----------|:-------|:----------|:-------------|
| 4.4.1 | 3.12.4  | 7.3.0    | 12.5.1 | 12.5.3.2  | 8.9.7.29  | 2.22.3 | 10.2.0.19 | Ubuntu 22.04 |
| 4.4.0 | 3.12.4  | 7.3.0    | 12.5.0 | 12.5.2.13 | 8.9.7.29  | 2.21.5 | 10.0.1.6  | Ubuntu 22.04 |
| 4.3.3 | 3.11.9  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.6.50  | 2.15.5 | 8.5.3[^2] | Ubuntu 22.04 |
| 4.3.2 | 3.11.8  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.6.50  | 2.15.5 | 8.5.3[^2] | Ubuntu 22.04 |
| 4.3.1 | 3.11.6  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.0.131 | 2.15.5 | 8.5.3[^2] | Ubuntu 22.04 |
| 4.3.0 | 3.11.4  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.0.131 | 2.15.5 | 8.5.3[^2] | Ubuntu 22.04 |
| 4.2.3 | 3.10.11 | n/a      | 11.8.0 | 11.11.3.6 | 8.7.0.84  | 2.15.5 | 8.5.3[^2] | Ubuntu 22.04 |
| 4.2.2 | 3.10.10 | n/a      | 11.8.0 | 11.11.3.6 | 8.7.0.84  | 2.16.2 | 8.5.3     | Ubuntu 20.04 |

[^1]: qgisprocess image  
[^2]: `amd64` only

## PyTorch/TensorFlow compatibility

| Python | CUDA | PyTorch[^3]    | TensorFlow[^4]        |
|:-------|:-----|:---------------|:----------------------|
| 3.12   | 12.5 | 2.2 ≤ version  | 2.16 ≤ version        |
| 3.11   | 11.8 | 2.0 ≤ version  | 2.12 ≤ version < 2.15 |
| 3.10   | 11.8 | 1.12 ≤ version | 2.8  ≤ version < 2.15 |

[^3]: Installs its own CUDA binaries
[^4]: The expected TensorRT version is symlinked to the installed TensorRT
version.  
❗️ This relies on backwards compatibility of TensorRT, which may not always be
given.

## Recommended NVIDIA driver (Regular)

| CUDA   | Linux driver version | Windows driver version[^5] |
|:-------|:---------------------|:---------------------------|
| 12.5.1 | ≥ 555.42.06          | ≥ 555.85                   |
| 12.5.0 | ≥ 555.42.02          | ≥ 555.85                   |
| 11.8.0 | ≥ 520.61.05          | ≥ 520.06                   |

[^5]: [GPU support in Docker Desktop | Docker Docs](https://docs.docker.com/desktop/gpu/)  
[Nvidia GPU Support for Windows · Issue #19005 · containers/podman](https://github.com/containers/podman/issues/19005)

## Supported NVIDIA drivers (LTSB)

Only works with
[NVIDIA Data Center GPUs](https://resources.nvidia.com/l/en-us-gpu) or
[select NGC-Ready NVIDIA RTX boards](https://docs.nvidia.com/certification-programs/ngc-ready-systems/index.html).

| CUDA   | Driver version 535[^6] | Driver version 470[^7] |
|:-------|:----------------------:|:----------------------:|
| 12.5.1 | 🟢                      | 🟢                      |
| 12.5.0 | 🟢                      | 🟢                      |
| 11.8.0 | 🟡                      | 🟢                      |

🟢: Works due to the CUDA forward compat package  
🟡: Supported due to backward compatibility

[^6]: EOL: June 2026  
[^7]: EOL: July 2024
