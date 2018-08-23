#!/usr/bin/env bash

__lib::progress::abort() {
  export abort_progress_bar=1
}

__lib::progress::draw-emtpy-bar() {
  local width=${1:-"9"}
  cursor.rewind
  printf "["
  for j in $(seq 0 ${width}); do
    printf ' '
  done
  printf "]"
}

# Usage: 
# 
#    lib::progress::bar 10 0.3 5
#
# Arguments:
#    1st: width of the bar
#    2nd: floating point number of seconds to sleep between steps
#    3rd: number of loops to show.
#
lib::progress::bar() {
  local seconds=${1:-"9"}
  local delay_seconds=${2:-"0.5"}
  local loops=${3:-"1"}

  export abort_progress_bar=0

  trap "__lib::progress::abort" INT STOP

  cursor.rewind
  printf "${bldgrn}"

  for count in $(seq 1 ${loops}); do
    __lib::progress::draw-emtpy-bar ${seconds}
    cursor.rewind 2

    for j in $(seq 0 ${seconds}); do
      sleep ${delay_seconds}
      printf "▉"
      [[ ${abort_progress_bar} -eq 1 ]] && return
    done

    __lib::progress::draw-emtpy-bar ${seconds}
    cursor.rewind
  done
  printf "${clr}"
}


