#!/usr/bin/env bash

export True=1
export False=0

export LibBash__SearchTarget="Loader.bash"
export LibBash__Loader=$(find -L . -maxdepth 3 -type f -name "${LibBash__SearchTarget}" -print 2>/dev/null | tail -1)

if [[ -z ${LibBash__Loader} ]]; then
  printf "${bldred}ERROR: ${clr}Can not find ${bldylw}${LibBash__SearchTarget}${clr} file, aborting."
  (( $_s_ )) && return 1 || exit 1
fi

export LibBash__LibDir=$(dirname "${LibBash__Loader}")

lib::bash-source() {
  local folder=${1}

  [[ -n ${DEBUG} ]] && printf "sourcing folder ${bldylw}$folder${clr}...\n" >&2
  # Let's list all lib files
  declare -a files=($(ls -1 ${folder}/*.sh))

  for bash_file in ${files[@]}; do
    [[ -n ${DEBUG} ]] && printf "sourcing ${txtgrn}$bash_file${clr}...\n" >&2
    source ${bash_file}
  done
}

[[ -n ${LibBash__LibDir} ]] && lib::bash-source "${LibBash__LibDir}"

