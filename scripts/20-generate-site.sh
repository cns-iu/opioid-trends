#!/bin/bash
source constants.sh
set -ev

mkdocs build

rm -rf site/data
cp -r $OUT/site-data site/data
