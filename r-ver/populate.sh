#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

if [ "$(ls -A "/home/jovyan" 2> /dev/null)" == "" ]; then
    cp -a /var/tmp/jovyan/. /home/jovyan
fi
