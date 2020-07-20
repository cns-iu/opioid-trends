#!/bin/bash
source constants.sh
set -ev

# Data extraction goes here!
rm -f $LABS_DB
sqlite3_ext $LABS_DB < src/chronic.sql
sqlite3 $LABS_DB < src/create-labs-db.sql

sqlite3 $LABS_DB > $OUT/site-data/labs-all-agg-data.csv << EOF
.header on
.mode csv
SELECT * FROM LABS_AGG;
.quit
EOF
