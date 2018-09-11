#!/usr/bin/env bats

source lib/hbsed.sh

function moo() {
  echo "config/moo.enc" | hbsed 's/\.(sym|enc)$//g'
}

@test "hbsed() runs the correct sed" {
  result=$(moo)
  [[ "${result}" == "config/moo" ]]
}
