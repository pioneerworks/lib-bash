#!/usr/bin/env bash
#——————————————————————————————————————————————————————————————————————————————
# © 2016-2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2017 PioneerWorks, Inc. All rights reserved.
#——————————————————————————————————————————————————————————————————————————————

export HomebaseCurrentOS=${HomebaseCurrentOS:-$(uname -s)}

# Install necessary dependencies on OSX
__lib::time::osx::coreutils() {
  # install gdate quietly
  brew install coreutils 2>&1 |cat > /dev/null
  code=$?
  if [[ ${code} != 0 || -z $(which gdate) ]]; then
    error "Can not install coreutils brew package, exit code ${code}"
    printf "Please run ${bldylw}brew install coreutils${clr} to install gdate utility."
    exit ${code}
  fi
}

# milliseconds
__lib::run::millis() {
  if [[ "${HomebaseCurrentOS}" == "Darwin" ]] ; then
    [[ -z $(which gdate) ]] && __lib::time::osx::coreutils
    printf $(($(gdate +%s%N)/1000000 - 1000000000000))
  else
    printf $(($(date +%s%N)/1000000 - 1000000000000))
  fi
}

# Returns the date command that constructs a date from a given
# epoch number. Appears to be different on Linux vs OSX.
lib::time::date-from-epoch() {
  local epoch_ts="$1"
  if [[ "${HomebaseCurrentOS}" == "Darwin" ]] ; then
    printf "date -r ${epoch_ts}"
  else
    printf "date --date='@${epoch_ts}'"
  fi
}
lib::time::epoch-to-iso() {
  local epoch_ts=$1
  eval "$(lib::time::date-from-epoch ${epoch_ts}) -u \"+%Y-%m-%dT%H:%M:%S%z\"" | sed 's/0000/00:00/g'
}

lib::time::epoch-to-local() {
  local epoch_ts=$1
  [[ -z ${epoch_ts} ]] && epoch_ts=$(epoch)
  eval "$(lib::time::date-from-epoch ${epoch_ts}) \"+%m/%d/%Y, %r\""
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
