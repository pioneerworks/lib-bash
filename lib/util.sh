#!/usr/bin/env bash

# Note, this functino does not actually work as a function, but only with ZSH
# where it always detects "script" and never "sourced" unless you put them
# first line of the as your first line in the script.
#
# Therefore, it is here for the reference.

# This returns true if the argument is numeric
lib::util::is-numeric() {
  [[ -z $(echo ${1} | sed -E 's/^[0-9]+$//g') ]]
}

lib::util::ver-to-i() {
  version=${1}
  echo ${version} | awk 'BEGIN{FS="."}{ printf "1%02d%03.3d%03.3d", $1, $2, $3}'
}

# Convert a result of __lib::ver-to-i() back to a regular version.
lib::util::i-to-ver() {
  version=${1}
  /usr/bin/env ruby -e "ver='${version}'; printf %Q{%d.%d.%d}, ver[1..2].to_i, ver[3..5].to_i, ver[6..8].to_i"
}

# Returns name of the current shell, eg 'bash'
lib::util::shell-name() {
  echo $(basename $(printf $SHELL))
}

lib::util::arch() {
  echo -n "${HomebaseCurrentOS}-$(uname -m)-$(uname -p)" | tr 'A-Z' 'a-z'
}

lib::util::shell-init-files() {
  shell_name=$(lib::util::shell-name)
  if [[ ${shell_name} == "bash" ]]; then
    echo ".bash_${USER} .bash_profile .bashrc .profile"
  elif [[ ${shell_name} == "zsh" ]]; then
    echo ".zsh_${USER} .zshrc .profile"
  fi
}

lib::util::append-to-init-files() {
  local string="$1"       # what to append
  local search="${2:-$1}" # what to grep for

  is_installed=

  declare -a shell_files=($(lib::util::shell-init-files))

  for init_file in ${shell_files[@]}; do
    file=${HOME}/${init_file}
    [[ -f ${file} && -n $(grep "${search}" ${file}) ]] && {
      is_installed=${file}
      break
    }
  done

  if [[ -z "${is_installed}" ]]; then
    for init_file in ${shell_files[@]}; do
      file=${HOME}/${init_file}
      [[ -f ${file} ]] && {
        echo "${string}" >> ${file}
        is_installed="${file}"
        break
      }
    done
  fi

  printf "${is_installed}"
}

lib::util::whats-installed() {
  declare -a hb_aliases=($(alias | grep -E 'hb\..*=' | sed 's/alias//g; s/=.*$//g'))
  h2 "Installed homebase aliases:" ' ' "${hb_aliases[@]}"

  h2 "Installed DB Functions:"
  info "hb.db  [ ms | r1 | r2 | c ]"
  info "hb.ssh <server-name-substring>, eg hb.ssh web"
}

lib::util::lines-in-folder() {
  local folder=${1:-'.'}
  find ${folder} -type f -exec wc -l {} \;| awk 'BEGIN{a=0}{a+=$1}END{print a}'
}

lib::util::functions-matching() {
  local prefix=${1}
  set | egrep "^${prefix}" | sed -E 's/.*:://g; s/[\(\)]//g;' | tr '\n ' ' '
}
