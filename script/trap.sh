#!/usr/bin/env bash

set -euo pipefail

TMPDIR=$(mktemp -d)
>&2 echo ${TMPDIR} was created

trap ">&2 echo Removing ${TMPDIR}; rm -rf ${TMPDIR}" SIGINT SIGTERM

sleep 600

>&2 echo Done
exit 0
