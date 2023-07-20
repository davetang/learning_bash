#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

# xargs documentation
#
# -P max-procs, --max-procs=max-procs
# Run up to max-procs processes at a time; the default is 1. If max-procs is
# 0, xargs will run as many processes as possible at a time. Use the -n option
# or the -L option with -P; otherwise chances are that only one exec will be
# done. While xargs is running, you can send its process a SIGUSR1 signal to
# increase the number of commands to run simultaneously, or a SIGUSR2 to
# decrease the number. You cannot decrease it below 1. xargs never terminates
# its commands; when asked to decrease, it merely waits for more than one
# existing command to terminate before starting another.
#
# -n max-args, --max-args=max-args
# Use at most max-args arguments per command line. Fewer than max-args
# arguments will be used if the size (see the -s option) is exceeded, unless
# the -x option is given, in which case xargs will exit.

# bash -c
# If the -c option is present, then commands are read from string.
>&2 echo Using 1 max-proc
for i in {0..9}; do
   echo ${i}
done | xargs -I{} bash -c "echo {}; sleep 1"

>&2 echo Using 5 max-procs with no -max-args
for i in {0..9}; do
   echo ${i}
done | xargs -I{} -P 5 bash -c "echo {}; sleep 1"

>&2 echo Using 5 max-procs with 1 max-args
for i in {0..9}; do
   echo ${i}
done | xargs -n 1 -I{} -P 5 bash -c "echo {}; sleep 1"

>&2 echo Done
exit 0
