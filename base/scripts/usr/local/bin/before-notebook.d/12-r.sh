#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

if [ "$(id -u)" == 0 ] ; then
  if [ "${NB_USER}" = "root" ] && [ "${NB_UID}" = "$(id -u "${NB_USER}")" ] && [ "${NB_GID}" = "$(id -g "${NB_USER}")" ]; then
    HOME="/home/root"
  fi
  # Create user's R package library
  RLU=$(run_user_group Rscript -e "cat(Sys.getenv('R_LIBS_USER'))")
  run_user_group mkdir -p "$RLU"
else
  # Create user's R package library
  RLU=$(Rscript -e "cat(Sys.getenv('R_LIBS_USER'))")
  mkdir -p "$RLU"
fi
