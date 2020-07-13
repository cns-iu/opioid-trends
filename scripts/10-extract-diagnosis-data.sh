#!/bin/bash
source constants.sh
set -ev

rm -f $CHART_DB
sqlite3 $CHART_DB < src/create-diagnosis-db.sql

sqlite3 $CHART_DB > $OUT/site-data/diagnosis-data.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates ORDER BY period;
.quit
EOF

sqlite3 $CHART_DB > $OUT/site-data/diagnosis-data-row-based.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates_row_based ORDER BY data_variable, period;
.quit
EOF