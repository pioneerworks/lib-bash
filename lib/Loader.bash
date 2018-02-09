#!/usr/bin/env bash

[[ -f lib/Loader.bash ]] || {
  echo "Please run this from the Project's root"
  (( $_s_ )) && return 1 || exit 1
}

lib::bash-source() {
  local folder=${1}

  # Let's list all lib files
  declare -a files=($(ls -1 ${folder}/*.*sh))

  for bash_file in ${files[@]}; do
    [[ -n ${DEBUG} ]] && printf "sourcing ${txtgrn}$bash_file${clr}...\n" >&2
    set +e
    [[ ${bash_file} != "lib/Loader.bash" ]] && source ${bash_file}
  done
}

lib::bash-source "lib"
