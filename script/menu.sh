#!/usr/bin/env bash
#
# A simple menu
#

set -euo pipefail

choices=($(echo {0..9}))
num_choices=${#choices[*]}

check_choice(){
   if [[ ${1} =~ [a-zA-Z]+ ]]; then
      >&2 echo Please enter a number
   elif [[ ${1} -gt ${#choices[*]} ]]; then
      >&2 echo Please enter a number between 1 - ${num_choices}
   else
      break
   fi
}

menu(){
   >&2 echo -e "\nPlease make a selection:\n"
   select selected in ${choices[@]}
   do
      check_choice ${REPLY}
   done

   >&2 echo -e "\nYou have selected ${selected}\n"
   read -p "Do you want to make another selection: y/N? " continue

   if [[ ${continue} == y ]]; then
      menu
   else
      exit
   fi
}
menu
