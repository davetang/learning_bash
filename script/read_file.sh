#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR=$(realpath $(dirname $0))
DATADIR=${SCRIPTDIR}/../data

readarray mtcars < ${DATADIR}/mtcars.tsv

for i in ${!mtcars[@]}; do
  echo ${mtcars[${i}]}
done
