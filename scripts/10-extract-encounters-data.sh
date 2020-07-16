#!/bin/bash
source constants.sh
set -ev

# Data extraction goes here!
rm -f $ENCOUNTERS_DB
sqlite3_ext $ENCOUNTERS_DB < src/chronic.sql
sqlite3 $ENCOUNTERS_DB < src/create-encounters-db.sql

sqlite3 $ENCOUNTERS_DB > $OUT/site-data/encounters-category-data.csv << EOF
.header on
.mode csv
SELECT * FROM CATEGORY_COUNTS;
.quit
EOF

sqlite3 $ENCOUNTERS_DB > $OUT/site-data/encounters-insurance-data.csv << EOF
.header on
.mode csv
SELECT * FROM INSURANCE_COUNTS_AGG;
.quit
EOF
