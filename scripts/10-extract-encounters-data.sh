#!/bin/bash
source constants.sh
set -ev

# Data extraction goes here!
rm -f $ENCOUNTERS_DB
sqlite3 $ENCOUNTERS_DB < src/create-encounters-db.sql

sqlite3 $ENCOUNTERS_DB > $OUT/site-data/encounters-data.csv << EOF
.header on
.mode csv
SELECT * FROM CATEGORY_COUNTS;
.quit
EOF
