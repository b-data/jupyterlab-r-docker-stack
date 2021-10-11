#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

if [ "$(ls -A "/home/${NB_USER}" 2> /dev/null)" == "" ]; then
    echo "Copying home dir to /home/${NB_USER}"
    cp -a /var/tmp/jovyan/. /home/${NB_USER}
fi
