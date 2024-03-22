#!/bin/bash
# Copyright (c) 2024 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

CRAN_ORIG=$(sed -n "s/.*CRAN='\(.*\)'),.*$/\1/p" "$(R RHOME)/etc/Rprofile.site")
CRAN_ORIG_P3M=${CRAN_ORIG//packagemanager.posit.co/p3m.dev}

# Update CRAN mirror
if [[ "$CRAN" != "$CRAN_ORIG" ]]; then
  _log "Setting CRAN mirror to $CRAN"
  sed -i "s|$CRAN_ORIG|$CRAN|g" "$(R RHOME)/etc/Rprofile.site"
fi

# Use binary packages
if [[ "$R_BINARY_PACKAGES" == "1" || "$R_BINARY_PACKAGES" == "yes" ]]; then
  if [[ "$CRAN" == "$CRAN_ORIG" || "$CRAN" == "$CRAN_ORIG_P3M" ]]; then
    . /etc/os-release
    # Update environment variable CRAN
    _log "Updating CRAN mirror:"
    _log "- from: $CRAN"
    CRAN=${CRAN//cran/"cran/__linux__/$VERSION_CODENAME"}
    export CRAN
    # Set options repos and HTTPUserAgent in Rprofile.site
    [[ "$CRAN" == "$CRAN_ORIG_P3M" ]] && sed -i "s/packagemanager.posit.co/p3m.dev/g" \
      "$(R RHOME)/etc/Rprofile.site"
    sed -i "s|cran|cran/__linux__/$VERSION_CODENAME|g" \
      "$(R RHOME)/etc/Rprofile.site"
    echo '# https://docs.rstudio.com/rspm/admin/serving-binaries/#binaries-r-configuration-linux' \
      >> "$(R RHOME)/etc/Rprofile.site"
    echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
      >> "$(R RHOME)/etc/Rprofile.site"
    _log "- to:   $CRAN"
  else
    _log "WARNING: Use $CRAN_ORIG for switching to binary packages!"
  fi
fi
