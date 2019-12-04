#!/bin/bash
source constants.sh
set -ev

rm -f $GEOMAP_DB
sqlite3 $GEOMAP_DB < src/create-geomap-db.sql

sqlite3 $GEOMAP_DB > $OUT/site-data/geomap-data.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates ORDER BY period;
.quit
EOF
