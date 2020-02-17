#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

mkdir -p `Rscript -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))'`

exec /usr/local/bin/start-notebook.sh "$@"
