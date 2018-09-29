#!/usr/bin/env bats

source lib/hbsed.sh
source lib/gem.sh

@test "lib::gem::version returns correct version" {
  cp -f test/Gemfile.lock .
  result=$(lib::gem::version activesupport)
  [[ "${result}" == "5.0.7" ]]
  [[ -d test ]] && rm -f Gemfile.lock && true
}
