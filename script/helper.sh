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

check_func(){
   if [[ $(type -t $1) == function ]]; then
      echo 0
   else
      echo 1
   fi
}

now(){
   date '+%Y/%m/%d %H:%M:%S'
}

add(){
   sum=0
   for i in $@; do
      sum=$(( ${sum} + ${i} ))
   done
   echo ${sum}
}
