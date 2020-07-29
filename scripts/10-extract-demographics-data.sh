#!/bin/bash
source constants.sh
set -ev

rm -f $DEMOGRAPHICS_DB
sqlite3 $DEMOGRAPHICS_DB < src/create-demographics-db.sql

sqlite3 $DEMOGRAPHICS_DB > $OUT/site-data/demographics-data.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates;
.quit
EOF

sqlite3 $DEMOGRAPHICS_DB > $OUT/site-data/demographics-data-row-based.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates_row_based ORDER BY data_variable, period;
.quit
EOF
