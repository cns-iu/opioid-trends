#!/bin/bash
source constants.sh
set -ev

rm -f $FILLS_DB
sqlite3_ext $FILLS_DB < src/chronic.sql
sqlite3 $FILLS_DB < src/create-fills-db.sql

sqlite3 $FILLS_DB > $OUT/site-data/fills-data.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates;
.quit
EOF

sqlite3 $FILLS_DB > $OUT/site-data/fills-data-row-based.csv << EOF
.header on
.mode csv
SELECT * FROM all_aggregates_row_based;
.quit
EOF
