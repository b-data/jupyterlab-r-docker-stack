#!/bin/bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

if [ "$(id -u)" == 0 ] ; then
  # Put inital QGIS settings in place
  run_user_group mkdir -p "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/QGIS"
  if [[ ! -f "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    run_user_group cp -a --no-preserve=ownership \
      /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
  fi

  run_user_group mkdir -p "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  
  # Copy plugin 'Processing Saga NextGen Provider'
  run_user_group rm -rf "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen"
  run_user_group cp -a --no-preserve=ownership \
    /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
    "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  
  # Copy plugin 'OrfeoToolbox Provider'
  if [[ ! -d "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins/orfeoToolbox_provider" ]]; then
    if [[ -d /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/orfeoToolbox_provider ]]; then
      run_user_group cp -a --no-preserve=ownership \
        /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/orfeoToolbox_provider \
        "/home/$NB_USER${DOMAIN:+@$DOMAIN}/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
    fi
  fi
else
  # Put inital QGIS settings in place
  mkdir -p "$HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS"
  if [[ ! -f "$HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" ]]; then
    cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini \
      "$HOME/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini"
  fi

  mkdir -p "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  
  # Copy plugin 'Processing Saga NextGen Provider'
  rm -rf "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen"
  cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/processing_saga_nextgen \
    "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
  
  # Copy plugin 'OrfeoToolbox Provider'
  if [[ ! -d "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins/orfeoToolbox_provider" ]]; then
    if [[ -d /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/orfeoToolbox_provider ]]; then
      cp -a /var/backups/skel/.local/share/QGIS/QGIS3/profiles/default/python/plugins/orfeoToolbox_provider \
        "$HOME/.local/share/QGIS/QGIS3/profiles/default/python/plugins"
    fi
  fi
fi
