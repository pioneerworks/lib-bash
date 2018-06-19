#!/usr/bin/env bats

source lib/hbsed.sh

function moo() {
  echo "config/moo.enc" | hbsed 's/\.(sym|enc)$//g'
}

export os=$(uname -s)

if [[ ${os} == "Darwin" ]]; then
  @test "hbsed() without gnu-sed installed" {
    if [[ -n $(which brew) ]]; then
      brew uninstall --force --quiet gnu-sed 2>&1 | cat >/dev/null
      result=$(moo)
      [[ "${result}" == "config/moo" ]]
    else
      false
    fi
  }

  @test "hbsed() with gnu-sed installed" {
    if [[ -n $(which brew) ]]; then
      brew install --force --quiet gnu-sed 2>&1 | cat >/dev/null
      result=$(moo)
      [[ "${result}" == "config/moo" ]]
    else
      false
    fi
  }

fi

@test "hbsed() runs the correct sed" {
  result=$(moo)
  [[ "${result}" == "config/moo" ]]
}
