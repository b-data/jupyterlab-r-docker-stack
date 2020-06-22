#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Create R user package library
mkdir -p `Rscript -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))'`

# Update Code Server settings
mv .local/share/code-server/User/settings.json \
  .local/share/code-server/User/settings.json.bak
sed -i ':a;N;$!ba;s/,\n\}/\n}/g' .local/share/code-server/User/settings.json.bak
jq -s '.[0] * .[1]' /var/tmp/settings.json \
  .local/share/code-server/User/settings.json.bak > \
  .local/share/code-server/User/settings.json

# Remove old .zcompdump files
rm -f .zcompdump*

exec /usr/local/bin/start-notebook.sh "$@"
