#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

if [ $(id -u) == 0 ] ; then
    # Create R user package library
    su - $NB_USER -c "mkdir -p `Rscript -e \
      'cat(path.expand(Sys.getenv("R_LIBS_USER")))'`"

    # Update Code Server settings
    su - $NB_USER -c "mv .local/share/code-server/User/settings.json \
      .local/share/code-server/User/settings.json.bak"
    su - $NB_USER -c "sed -i ':a;N;$!ba;s/,\n\}/\n}/g' \
      .local/share/code-server/User/settings.json.bak"
    su - $NB_USER -c "jq -s '.[0] * .[1]' /var/tmp/settings.json \
      .local/share/code-server/User/settings.json.bak > \
      .local/share/code-server/User/settings.json"
else
    # Create R user package library
    mkdir -p `Rscript -e 'cat(path.expand(Sys.getenv("R_LIBS_USER")))'`

    # Update Code Server settings
    mv .local/share/code-server/User/settings.json \
      .local/share/code-server/User/settings.json.bak
    sed -i ':a;N;$!ba;s/,\n\}/\n}/g' \
      .local/share/code-server/User/settings.json.bak
    jq -s '.[0] * .[1]' /var/tmp/settings.json \
      .local/share/code-server/User/settings.json.bak > \
      .local/share/code-server/User/settings.json
fi

# Change file mode of .p10k.zsh.sample
chmod 644 .p10k.zsh.sample

# Remove old .zcompdump files
rm -f .zcompdump*
