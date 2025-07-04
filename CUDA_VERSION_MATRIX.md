# CUDA Version Matrix

Image tags = R versions

Topmost entry = Tag `latest`

| R     | Python  | SAGA[^1] | CUDA   | cuBLAS    | cuDNN     | NCCL   | TensorRT[^2]             | Linux distro |
|:------|:--------|:---------|:-------|:----------|:----------|:-------|:-------------------------|:-------------|
| 4.5.1 | 3.12.11 | 7.3.0    | 12.9.1 | 12.9.1.4  | 8.9.7.29  | 2.27.3 | 10.12.0.36/<br>10.3.0.26 | Ubuntu 22.04 |
| 4.5.0 | 3.12.11 | 7.3.0    | 12.9.0 | 12.9.0.13 | 8.9.7.29  | 2.26.5 | 10.11.0.33/<br>10.3.0.26 | Ubuntu 22.04 |
| 4.4.3 | 3.12.10 | 7.3.0    | 12.8.1 | 12.8.4.1  | 8.9.7.29  | 2.25.1 | 10.9.0.34/<br>10.3.0.26  | Ubuntu 22.04 |
| 4.4.2 | 3.12.9  | 7.3.0    | 12.8.0 | 12.8.3.14 | 8.9.7.29  | 2.25.1 | 10.8.0.43/<br>10.3.0.26  | Ubuntu 22.04 |
| 4.4.1 | 3.12.7  | 7.3.0    | 12.6.2 | 12.6.3.3  | 8.9.7.29  | 2.23.4 | 10.6.0.26/<br>10.3.0.26  | Ubuntu 22.04 |
| 4.4.0 | 3.12.4  | 7.3.0    | 12.5.0 | 12.5.2.13 | 8.9.7.29  | 2.21.5 | 10.0.1.6                 | Ubuntu 22.04 |
| 4.3.3 | 3.11.9  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.6.50  | 2.15.5 | 8.5.3[^3]                | Ubuntu 22.04 |
| 4.3.2 | 3.11.8  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.6.50  | 2.15.5 | 8.5.3[^3]                | Ubuntu 22.04 |
| 4.3.1 | 3.11.6  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.0.131 | 2.15.5 | 8.5.3[^3]                | Ubuntu 22.04 |
| 4.3.0 | 3.11.4  | 7.3.0    | 11.8.0 | 11.11.3.6 | 8.9.0.131 | 2.15.5 | 8.5.3[^3]                | Ubuntu 22.04 |
| 4.2.3 | 3.10.11 | n/a      | 11.8.0 | 11.11.3.6 | 8.7.0.84  | 2.15.5 | 8.5.3[^3]                | Ubuntu 22.04 |
| 4.2.2 | 3.10.10 | n/a      | 11.8.0 | 11.11.3.6 | 8.7.0.84  | 2.16.2 | 8.5.3                    | Ubuntu 20.04 |

[^1]: qgisprocess image  
[^2]: amd64/arm64  
[^3]: `amd64` only

## PyTorch/TensorFlow compatibility

| Python | CUDA | PyTorch[^4]    | TensorFlow[^5]        |
|:-------|:-----|:---------------|:----------------------|
| 3.12   | 12.9 | version ≥ 2.4  | 2.18 > version ≥ 2.16 |
| 3.12   | 12.8 | version ≥ 2.4  | 2.18 > version ≥ 2.16 |
| 3.12   | 12.6 | version ≥ 2.4  | 2.18 > version ≥ 2.16 |
| 3.12   | 12.5 | version ≥ 2.4  | 2.18 > version ≥ 2.16 |
| 3.11   | 11.8 | version ≥ 2.0  | 2.16 > version ≥ 2.12 |
| 3.10   | 11.8 | version ≥ 1.12 | 2.16 > version ≥ 2.9  |

[^4]: Installs its own CUDA dependencies
[^5]: The expected TensorRT version is symlinked to the installed TensorRT
version.  
❗️ This relies on backwards compatibility of TensorRT, which may not always be
given.

## Recommended NVIDIA driver (Regular)

| CUDA   | Linux driver version | Windows driver version[^6] |
|:-------|:---------------------|:---------------------------|
| 12.9.1 | ≥ 575.57.08          | ≥ 576.57                   |
| 12.9.0 | ≥ 575.51.03          | ≥ 576.02                   |
| 12.8.1 | ≥ 570.124.06         | ≥ 572.61                   |
| 12.8.0 | ≥ 570.117            | ≥ 572.30                   |
| 12.6.2 | ≥ 560.35.03          | ≥ 560.94                   |
| 12.5.0 | ≥ 555.42.02          | ≥ 555.85                   |
| 11.8.0 | ≥ 520.61.05          | ≥ 520.06                   |

[^6]: [GPU support in Docker Desktop | Docker Docs](https://docs.docker.com/desktop/gpu/)  
[Nvidia GPU Support for Windows · Issue #19005 · containers/podman](https://github.com/containers/podman/issues/19005)

## Supported NVIDIA drivers (LTSB)

Only works with
[NVIDIA Data Center GPUs](https://resources.nvidia.com/l/en-us-gpu) or
[select NGC-Ready NVIDIA RTX boards](https://docs.nvidia.com/certification-programs/ngc-ready-systems/index.html).

| CUDA   | Driver version 535[^7] | Driver version 470[^8] |
|:-------|:----------------------:|:----------------------:|
| 12.9.1 | 🟢                      | 🔵                      |
| 12.9.0 | 🟢                      | 🔵                      |
| 12.8.1 | 🟢                      | 🔵                      |
| 12.8.0 | 🟢                      | 🔵                      |
| 12.6.2 | 🟢                      | 🔵                      |
| 12.5.0 | 🟢                      | 🔵                      |
| 11.8.0 | 🟡                      | 🟢                      |

🔵: Supported with the CUDA forward compat package only  
🟢: Supported due to minor-version compatibility[^9]  
🟡: Supported due to backward compatibility

[^7]: EOL: June 2026  
[^8]: EOL: July 2024
[^9]: or the CUDA forward compat package
