#!/usr/bin/env bash
#
# A simple menu using select
#

set -euo pipefail

CHOICES=($(echo {0..9}))
NUM_CHOICES=${#CHOICES[*]}

menu(){
   >&2 echo -e "\nPlease make a selection:\n"
   select SELECTED in ${CHOICES[@]}
   do
      if [[ ${REPLY} =~ [a-zA-Z]+ ]]; then
         >&2 echo Please enter a number
      elif [[ ${REPLY} -gt ${#CHOICES[*]} ]]; then
         >&2 echo Please enter a number between 1 - ${NUM_CHOICES}
      else
         break
      fi
   done

   >&2 echo -e "\nYou have entered ${REPLY} which corresponds to ${SELECTED}\n"
   read -p "Do you want to make another selection: y/N? " CONTINUE

   if [[ ${CONTINUE} == y ]]; then
      menu
   else
      exit
   fi
}
menu
