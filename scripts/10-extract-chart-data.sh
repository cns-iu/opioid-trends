#!/bin/bash
source constants.sh
set -ev

rm -f $CHART_DB
sqlite3 $CHART_DB < src/create-chart-db.sql

sqlite3 $CHART_DB > $OUT/site-data/chart-data.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates ORDER BY period;
.quit
EOF