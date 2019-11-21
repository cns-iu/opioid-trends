#!/bin/bash
source constants.sh
set -ev

rm -f $SCHEMA_NAME
ln -s $DB $SCHEMA_NAME

java -Xmx3G -jar libs/schemaspy-6.0.0.jar -configFile schemaspy.properties -db $SCHEMA_NAME

rm -f $SCHEMA_NAME
