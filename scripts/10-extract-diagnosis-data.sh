#!/bin/bash
source constants.sh
set -ev

rm -f $DIAGNOSIS_DB
sqlite3 $DIAGNOSIS_DB < src/create-diagnosis-db.sql

sqlite3 $DIAGNOSIS_DB > $OUT/site-data/diagnosis-data.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates;
.quit
EOF

sqlite3 $DIAGNOSIS_DB > $OUT/site-data/diagnosis-data-row-based.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates_row_based ORDER BY data_variable, period;
.quit
EOF