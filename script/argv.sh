#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

# default settings
alpha=0
beta=0
gamma=42
delta=1984
version=0.1.0

usage(){
>&2 cat << EOF
Usage: $0
   [ -a | --alpha ]
   [ -b | --beta ]
   [ -g | --gamma input ]
   [ -d | --delta input ]
   [ -v | --version ]
   <infile> [infiles]
EOF
exit 1
}

print_ver(){
   >&2 echo ${version}
   exit 0
}

args=$(getopt -a -o abhg:d:v --long alpha,beta,help,gamma:,delta:,version -- "$@")
if [[ $? -gt 0 ]]; then
  usage
fi

eval set -- ${args}
while :
do
  case $1 in
    -a | --alpha)   alpha=1    ; shift   ;;
    -b | --beta)    beta=1     ; shift   ;;
    -h | --help)    usage      ; shift   ;;
    -v | --version) print_ver  ; shift   ;;
    -g | --gamma)   gamma=$2   ; shift 2 ;;
    -d | --delta)   delta=$2   ; shift 2 ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    *) >&2 echo Unsupported option: $1
       usage ;;
  esac
done

if [[ $# -eq 0 ]]; then
  usage
fi

>&2 echo "alpha   : ${alpha}"
>&2 echo "beta    : ${beta} "
>&2 echo "gamma   : ${gamma}"
>&2 echo "delta   : ${delta}"
>&2 echo "version : ${version}"
>&2 echo "Parameters remaining are: $@"
exit 0
