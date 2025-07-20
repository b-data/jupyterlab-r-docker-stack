#!/bin/bash
# Copyright (c) 2024 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Set environment variables in Renviron.site
exclude_vars="HOME LD_LIBRARY_PATH OLDPWD PATH PWD RSTUDIO_VERSION SHLVL"
for var in $(compgen -e); do
  [[ ! $exclude_vars =~ $var ]] && echo "$var='${!var//\'/\'\\\'\'}'" \
    >> "$(R RHOME)/etc/Renviron.site"
done

if [ "$(id -u)" == 0 ]; then
  RS_USD="/home/$NB_USER${DOMAIN:+@$DOMAIN}/.config/rstudio"
  # Install RStudio settings
  run_user_group mkdir -p "$RS_USD"
  if [[ ! -f "$RS_USD/rstudio-prefs.json" ]]; then
    run_user_group cp -a --no-preserve=ownership \
      /var/backups/skel/.config/rstudio/rstudio-prefs.json \
      "$RS_USD/rstudio-prefs.json"
  fi
  # Create user's working folder
  run_user_group mkdir -p "/home/$NB_USER${DOMAIN:+@$DOMAIN}/working"
else
  RS_USD="$HOME/.config/rstudio"
  # Install RStudio settings
  mkdir -p "$RS_USD"
  if [[ ! -f "$RS_USD/rstudio-prefs.json" ]]; then
    cp -a /var/backups/skel/.config/rstudio/rstudio-prefs.json \
      "$RS_USD/rstudio-prefs.json"
  fi
  # Create user's working folder
  mkdir -p "$HOME/working"
fi
