#!/bin/bash
source constants.sh
set -ev

cp CHANGELOG.md docs
rm -rf site/data

mkdocs build

rm -f docs/CHANGELOG.md

mkdir -p site/data
cp -r $OUT/site-data/* site/data
