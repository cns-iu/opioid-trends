#!/bin/bash
source constants.sh
set -ev

# Only run if there isn't an existing indiana.topojson
if [ ! -e docs/geomap/indiana.topojson ]
then

  if [ "$(which topo2geo)" = "" ]; then
    npm install --prefix=~/.local -g topojson ndjson-cli
  fi

  if [ ! -e $OUT/counties-10m.json ]; then
    SRC_TOPOJSON=https://cdn.jsdelivr.net/npm/us-atlas@3/counties-10m.json
    wget -O $OUT/counties-10m.json $SRC_TOPOJSON
  fi

  topo2geo -n counties=- < $OUT/counties-10m.json \
    | ndjson-filter '/^18/.test(d.id)' \
    | geo2topo -n counties=- \
    > docs/geomap/indiana.topojson
fi