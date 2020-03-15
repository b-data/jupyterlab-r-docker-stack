#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

mkdir -p `Rscript -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))'`

mv .local/share/code-server/User/settings.json \
  .local/share/code-server/User/settings.json.bak
sed -i ':a;N;$!ba;s/,\n\}/\n}/g' .local/share/code-server/User/settings.json.bak
jq -s '.[0] * .[1]' /var/tmp/settings.json \
  .local/share/code-server/User/settings.json.bak > \
  .local/share/code-server/User/settings.json

exec /usr/local/bin/start-notebook.sh "$@"
