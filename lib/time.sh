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

epoch() {
  date +%s
}

millis() {
  __lib::run::millis
}

today() {
  date +'%Y-%m-%d'
}
