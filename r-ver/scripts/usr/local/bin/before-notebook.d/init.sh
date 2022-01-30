#!/bin/bash
# Copyright (c) 2020 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Set defaults for environment variables in case they are undefined
LANG=${LANG:=en_US.UTF-8}
TZ=${TZ:=Etc/UTC}

if [ "$(id -u)" == 0 ] ; then
  # Update timezone if needed
  if [ "$TZ" != "Etc/UTC" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
      && echo $TZ > /etc/timezone
  fi

  # Add/Update locale if needed
  if [ ! -z "$LANGS" ]; then
    for i in $LANGS; do
      sed -i "s/# $i/$i/g" /etc/locale.gen
    done
  fi
  if [ "$LANG" != "en_US.UTF-8" ]; then
    sed -i "s/# $LANG/$LANG/g" /etc/locale.gen
  fi
  if [[ "$LANG" != "en_US.UTF-8" || ! -z "$LANGS" ]]; then
    locale-gen
  fi
  update-locale --reset LANG=$LANG

  # Create R user package library
  RLU=$(sed -n "s|^R_LIBS_USER=\${R_LIBS_USER-'\(.*\)'}|\1|p" \
    /usr/local/lib/R/etc/Renviron)
  su $NB_USER -c "mkdir -p $RLU"

  # Update code-server settings
  su $NB_USER -c "mv .local/share/code-server/User/settings.json \
    .local/share/code-server/User/settings.json.bak"
  su $NB_USER -c "sed -i ':a;N;\$!ba;s/,\n\}/\n}/g' \
    .local/share/code-server/User/settings.json.bak"
  su $NB_USER -c "jq -s '.[0] * .[1]' \
    /var/tmp/skel/.local/share/code-server/User/settings.json \
    .local/share/code-server/User/settings.json.bak > \
    .local/share/code-server/User/settings.json"
else
  # Warn if the user wants to change the timezone but hasn't run the container
  # as root.
  if [ "$TZ" != "Etc/UTC" ]; then
    echo "Container must be run as root to change timezone"
  fi

  # Warn if the user wants to change the locale but hasn't run the container as
  # root.
  if [[ "$LANG" != "en_US.UTF-8" || ! -z "$LANGS" ]]; then
    echo "Container must be run as root to update or add locale"
  fi

  # Create R user package library
  RLU=$(sed -n "s|^R_LIBS_USER=\${R_LIBS_USER-'\(.*\)'}|\1|p" \
    /usr/local/lib/R/etc/Renviron)
  /bin/bash -c "mkdir -p $RLU"

  # Update code-server settings
  mv .local/share/code-server/User/settings.json \
    .local/share/code-server/User/settings.json.bak
  sed -i ':a;N;$!ba;s/,\n\}/\n}/g' \
    .local/share/code-server/User/settings.json.bak
  jq -s '.[0] * .[1]' \
    /var/tmp/skel/.local/share/code-server/User/settings.json \
    .local/share/code-server/User/settings.json.bak > \
    .local/share/code-server/User/settings.json
fi

# Remove old .zcompdump files
rm -f .zcompdump*
