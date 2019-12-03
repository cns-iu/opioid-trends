#!/bin/bash
source constants.sh
set -ev

sqlite << EOF
.header on
.mode csv
.output ${OUT}/site-data/aggregate.csv
.read ${SRC}/database/aggregate.sql
.quit
EOF
