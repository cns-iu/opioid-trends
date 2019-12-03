#!/bin/bash
source constants.sh
set -ev

sqlite < ${SRC}/database/indices.sql
