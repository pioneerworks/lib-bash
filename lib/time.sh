#!/usr/bin/env bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2017 PioneerWorks, Inc. All rights reserved.
#——————————————————————————————————————————————————————————————————————————————

__lib::time::coreutils() {
  brew install coreutils 2>&1 |cat > /dev/null
  code=$?
  if [[ ${code} != 0 || -z $(which gdate) ]]; then
    error "Can'tinstall coreutils, exit code ${code}"
    printf "Please run ${bldylw}brew install coreutils${clr} to proceed."
    exit ${code}
  fi
}

# milliseconds
__lib::run::millis() {
  export HomebaseCurrentOS=${HomebaseCurrentOS:-$(uname -s)}
  if [[ "${HomebaseCurrentOS}" == "Darwin" ]] ; then
    [[ -z $(which gdate) ]] && __lib::time::coreutils
    printf $(($(gdate +%s%N)/1000000 - 1000000000000))
  else
    printf $(($(date +%s%N)/1000000 - 1000000000000))
  fi
}

lib::time::epoch-to-iso() {
  local epoch=$1
  date -r ${epoch} -u "+%Y-%m-%dT%H:%M:%S%z" | sed 's/0000/00:00/g'
}

lib::time::epoch-to-local() {
  local epoch=$1
  [[ -z ${epoch} ]] && epoch=$(epoch)
  date -r ${epoch} "+%m/%d/%Y, %r"
}

lib::time::epoch::minutes-ago() {
  local mins=${1}

  [[ -z ${mins} ]] && mins=1
  local seconds=$(( ${mins} * 60 ))
  local epoch=$(epoch)
  echo $(( ${epoch} - ${seconds} ))
}

epoch() {
  date +%s
}

millis() {
  __lib::run::millis
}

today() {
  date +'%Y-%m-%d'
}
