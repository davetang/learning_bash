#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
# Helper functions to be sourced from a main script
#

CHECK_TOOL(){
   local tool=$1
   if [[ ! -x $(command -v ${tool}) ]]; then
     >&2 echo Could not find ${tool}
     exit 1
   fi
}

CHECK_FUNC(){
   if [[ $(type -t $1) == function ]]; then
      echo 0
   else
      echo 1
   fi
}

NOW(){
   date '+%Y/%m/%d %H:%M:%S'
}

LOG(){
   local prefix="[$(date +%Y/%m/%d\ %H:%M:%S)]: "
   >&2 echo "${prefix} $@"
}

ADD(){
   sum=0
   for i in $@; do
      sum=$(( ${sum} + ${i} ))
   done
   echo ${sum}
}

RANDOM_STR(){
   echo $(date) $RANDOM $RANDOM | md5sum | cut -f1 -d' '
}

GET_TARBALL_DIR(){
   tar -tzf $1 | cut -f1 -d'/' | sort -u
}
