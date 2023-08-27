#!/usr/bin/env bash

set -euo pipefail

num_param=1

usage(){
   echo "Usage: $0 <file.qmd> [output_name]"
   exit 1
}

if [[ $# -lt ${num_param} ]]; then
   usage
fi

infile=$1
if [[ ! -e ${infile} ]]; then
  >&2 echo ${infile} does not exist
  exit 1
fi

if [[ ! ${infile} =~ \.qmd$ ]]; then
  >&2 echo ${infile} is not a Quarto file
  exit 1
fi

outfile=$(basename ${infile} .qmd).md
if [[ $# -eq 2 ]]; then
   outfile=$2
fi

check_depend (){
   tool=$1
   if [[ ! -x $(command -v ${tool}) ]]; then
     >&2 echo Could not find ${tool}
     exit 1
   fi
}

dependencies=(docker)
for tool in ${dependencies[@]}; do
   check_depend ${tool}
done

now(){
   date '+%Y/%m/%d %H:%M:%S'
}

SECONDS=0

>&2 printf "[ %s %s ] Start job\n\n" $(now)

r_version=4.3.1
docker_image=davetang/quarto:${r_version}
package_dir=${HOME}/r_packages_${r_version}
if [[ ! -d ${package_dir} ]]; then
   mkdir ${package_dir}
fi

# Environment variables
# https://github.com/denoland/deno is a modern runtime for JavaScript and TypeScript
# Set DENO_DIR to avoid the following error
# error: Could not create TypeScript compiler cache location: "/.cache/deno/gen"

# see https://github.com/quarto-dev/quarto-cli/discussions/2559#discussioncomment-5947349
# Set XDG to avoid the following error
# error: Uncaught PermissionDenied: Permission denied (os error 13), mkdir '/.cache/quarto'
#             Deno.mkdirSync(dir, {

docker run \
   --rm \
   --env DENO_DIR=/tmp/quarto_deno_cache_home \
   --env XDG_CACHE_HOME=/tmp/quarto_cache_home \
   --env XDG_DATA_HOME=/tmp/quarto_data_home \
   -v $(pwd):$(pwd) \
   -v ${package_dir}:/packages \
   -w $(pwd) \
   -u $(id -u):$(id -g) \
   ${docker_image} \
   render ${infile} --output ${outfile}

rm -rf ./deno-x86_64-unknown-linux-gnu

>&2 printf "\n[ %s %s ] Work complete\n" $(now)

duration=$SECONDS
>&2 echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
exit 0
