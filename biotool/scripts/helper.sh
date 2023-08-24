#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#

check_tool(){
   tool=$1
   if [[ ! -x $(command -v ${tool}) ]]; then
     >&2 echo Could not find ${tool}
     exit 1
   fi
}
