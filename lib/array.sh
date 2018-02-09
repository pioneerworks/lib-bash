#!/usr/bin/env bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016-2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2017 PioneerWorks, Inc. All rights reserved.
#———————————————————————————————————————————————————————————————————————————————

# Returns "true" if the first argument is a member of the array
# passed as the second argument:
#
#     declare -a array=("a string" "test2000")
#     if [[ $(array-contains-element "a string" "${array[@]}") == "true" ]]; then
#       ...
#     fi
#
# @param: search string
# @param: array to search as a string
# @output: prints "true" or "false"
#
array-contains-element() {
  local e
  local r="false"
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && r="true"; done
  echo -n $r
  [[ $r == "false" ]] && return 1
  return 0
}
