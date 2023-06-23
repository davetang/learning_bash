#!/usr/bin/env bash
set -o nounset
set -o errexit

# the grep command will cause the script to exit because grep returns an exit
# code > 0 when it has no matches
# grep nothing README.md

script_dir=$(realpath $(dirname $0))
infile=${script_dir}/../README.md

# use the following construct to ignore a "failing" command
if ! grep -q not_going_to_find_this ${infile} ; then
   >&2 echo "Failure ignored; continuing..."
fi

if grep -q e ${infile} ; then
   >&2 echo "The letter [e] was found in ${infile}"
fi

>&2 echo "Done"
exit 0
