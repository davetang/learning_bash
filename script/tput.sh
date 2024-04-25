#!/usr/bin/env bash
#
# See https://linuxcommand.org/lc3_adv_tput.php
#

set -euo pipefail

# Start bold text
BOLD="$(tput bold 2>/dev/null || echo '')"

# setaf <value>	Set foreground color
GREY="$(tput setaf 0 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
BLUE="$(tput setaf 4 2>/dev/null || echo '')"
MAGENTA="$(tput setaf 5 2>/dev/null || echo '')"
CYAN="$(tput setaf 6 2>/dev/null || echo '')"

# Start underlined text
UNDERLINE="$(tput smul 2>/dev/null || echo '')"

# Turn off all attributes
NO_COLOR="$(tput sgr0 2>/dev/null || echo '')"

print_wrap(){
   printf "$1 The quick brown fox jumped over the lazy dog\n"
}

print_wrap ${BOLD}
print_wrap ${GREY}
print_wrap ${RED}
print_wrap ${GREEN}
print_wrap ${YELLOW}
print_wrap ${BLUE}
print_wrap ${MAGENTA}
print_wrap ${CYAN}
print_wrap ${UNDERLINE}
print_wrap ${NO_COLOR}
exit 0
