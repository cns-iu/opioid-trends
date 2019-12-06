#!/bin/bash
source constants.sh
set -ev

rm -rf site/data

mkdocs build

mkdir -p site/data
cp -r $OUT/site-data/* site/data
