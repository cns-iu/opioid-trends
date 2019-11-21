shopt -s expand_aliases

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export PYTHONPATH=./src
export MYPYPATH=$PYTHONPATH
export GPG_TTY=$(tty)

ORIG=./raw-data/original
OUT=./raw-data/derived/2019-05-31
mkdir -p $ORIG $OUT/site-data

#DB=$OUT/a2agc.db
DB=$ORIG/box-health/R2767_Data.db
EDB=$OUT/box-health/R2767_Data.db.e
DATA_SOURCES="$ORIG/box-health/Final Datasets"

SCHEMA_DIR=./docs/schema
SCHEMA_NAME=IADC
SCHEMA="$SCHEMA_DIR/$SCHEMA_NAME.public.xml"

COLUMN_DISTRIBUTION_OVERRIDES=./column-distribution-overrides.yml
AGGREGATE_DATA="$OUT/aggregate-table-data.yml"

BASE_URL="https://demo.cns.iu.edu/a2agc-dataset/"

alias sqlite="sqlcipher $DB"
alias sqlite3="sqlcipher"

source env.sh
