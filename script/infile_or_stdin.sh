#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

usage(){
>&2 cat << EOF
   Usage

            $ $0 (<infile> | <stdin>)

   Examples

            Read from a file

            $ $0 /etc/resolv.conf

            Read from STDIN

            $ whoami | $0 -

EOF
exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

input=$1
cat ${input}

exit 0
