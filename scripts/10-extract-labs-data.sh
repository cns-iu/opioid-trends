#!/bin/bash
source constants.sh
set -ev

# Data extraction goes here!
rm -f $LABS_DB
sqlite3 $LABS_DB < src/create-labs-db.sql

sqlite3 $LABS_DB > $OUT/site-data/labs-all-agg-data.csv << EOF
.header on
.mode csv
SELECT * FROM FILLS_AGG;
.quit
EOF

sqlite3 $LABS_DB > $OUT/site-data/labs-chronic-agg-data.csv << EOF
.header on
.mode csv
SELECT * FROM CHRONIC_FILLS_AGG;
.quit
EOF
