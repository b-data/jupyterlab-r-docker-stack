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
    echo "Setting TZ to $TZ"
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
  if [ "$LANG" != "en_US.UTF-8" ]; then
    echo "Setting LANG to $LANG"
    update-locale --reset LANG=$LANG
  fi

  # Create R user package library
  RLU=$(su $NB_USER -c "Rscript -e \"cat(Sys.getenv('R_LIBS_USER'))\"")
  su $NB_USER -c "mkdir -p $RLU"

  # Update code-server settings
  su $NB_USER -c "mkdir -p /home/$NB_USER/.local/share/code-server/User"
  if [[ ! -f "/home/$NB_USER/.local/share/code-server/User/settings.json" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.local/share/code-server/User/settings.json \
      /home/$NB_USER/.local/share/code-server/User/settings.json"
  fi

  su $NB_USER -c "mv /home/$NB_USER/.local/share/code-server/User/settings.json \
    /home/$NB_USER/.local/share/code-server/User/settings.json.bak"
  su $NB_USER -c "sed -i ':a;N;\$!ba;s/,\n\}/\n}/g' \
    /home/$NB_USER/.local/share/code-server/User/settings.json.bak"
  su $NB_USER -c "jq -s '.[0] * .[1]' \
    /var/backups/skel/.local/share/code-server/User/settings.json \
    /home/$NB_USER/.local/share/code-server/User/settings.json.bak > \
    /home/$NB_USER/.local/share/code-server/User/settings.json"

  ## QGIS Desktop: Put inital settings in place
  su $NB_USER -c "mkdir -p /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/QGIS"
  if [[ ! -f "/home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
  fi

  ## QGIS Desktop: Copy plugin 'Processing Saga NextGen Provider'
  su $NB_USER -c "mkdir -p /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  if [[ ! -d "/home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen" ]]; then
    su $NB_USER -c "cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
      /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  fi
else
  # Warn if the user wants to change the timezone but hasn't started the
  # container as root.
  if [ "$TZ" != "Etc/UTC" ]; then
    echo "WARNING: Setting TZ to $TZ but /etc/localtime and /etc/timezone remain unchanged!"
  fi

  # Warn if the user wants to change the locale but hasn't started the
  # container as root.
  if [[ ! -z "$LANGS" ]]; then
    echo "WARNING: Container must be started as root to add locale(s)!"
  fi
  if [[ "$LANG" != "en_US.UTF-8" ]]; then
    echo "WARNING: Container must be started as root to update locale!"
    echo "Resetting LANG to en_US.UTF-8"
    LANG=en_US.UTF-8
  fi

  # Create R user package library
  RLU=$(Rscript -e "cat(Sys.getenv('R_LIBS_USER'))")
  /bin/bash -c "mkdir -p $RLU"

  # Update code-server settings
  mkdir -p /home/$NB_USER/.local/share/code-server/User
  if [[ ! -f "/home/$NB_USER/.local/share/code-server/User/settings.json" ]]; then
    cp -a /var/backups/skel/.local/share/code-server/User/settings.json \
      /home/$NB_USER/.local/share/code-server/User/settings.json
  fi

  mv /home/$NB_USER/.local/share/code-server/User/settings.json \
    /home/$NB_USER/.local/share/code-server/User/settings.json.bak
  sed -i ':a;N;$!ba;s/,\n\}/\n}/g' \
    /home/$NB_USER/.local/share/code-server/User/settings.json.bak
  jq -s '.[0] * .[1]' \
    /var/backups/skel/.local/share/code-server/User/settings.json \
    /home/$NB_USER/.local/share/code-server/User/settings.json.bak > \
    /home/$NB_USER/.local/share/code-server/User/settings.json

  ## QGIS Desktop: Put inital settings in place
  mkdir -p /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/QGIS
  if [[ ! -f "/home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini
  fi

  ## QGIS Desktop: Copy plugin 'Processing Saga NextGen Provider'
  mkdir -p /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/python/plugins
  if [[ ! -d "/home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen" ]]; then
    cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
      /home/$NB_USER/.local/share/QGIS/QGIS3/profiles/default/python/plugins
  fi
fi

# Remove old .zcompdump files
rm -f /home/$NB_USER/.zcompdump*
