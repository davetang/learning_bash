#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

program=$(basename $0)
script_dir=$(dirname $0)
version=0.1.0
description="Tools for doing x and y"

sub_help(){
>&2 cat << EOF

Program: ${program} (${description})
Version: ${version}

Usage:   $0 <command> [options]

Commands:

     foo            calls argv.sh
     bar            performs bar
     help           display this help message
     version        display version

EOF
exit 1
}

# call another script
sub_foo(){
   ${script_dir}/argv.sh $@
}

sub_bar(){
   >&2 echo bar $@
}

sub_version(){
   >&2 echo ${version}
}

if [[ $# -lt 1 ]]; then
   sub_help
fi

subcommand=$1
shift

if [[ $(type -t sub_${subcommand}) == function ]]; then
   sub_${subcommand} $@
else
   >&2 echo "[main] unrecognised command '${subcommand}'"
   exit 1
fi

exit 0
