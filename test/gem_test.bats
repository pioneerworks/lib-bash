#!/usr/bin/env bats

source lib/gem.sh
source lib/util.sh
source lib/hbsed.sh


@test "lib::gem::gemfile::version returns correct version" {
  set -e
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  rm -f ${LibGem__GemListCache}
  touch ${LibGem__GemListCache}
  cp -f test/Gemfile.lock .
  result=$(lib::gem::gemfile::version activesupport)
  echo "result is [${result}], pwd is $(pwd), gemfile is $(ls -al Gemfile.lock)"
  echo "doing grep:"
  egrep  "^    activesupport \(\d+\.\d+\.\d+(\.\d+)?\)" Gemfile.lock | gawk '{print $2}' | hbsed 's/[()]//g'
  [[ "${result}" == "5.0.7" ]]
  [[ -d test ]] && ( rm -f Gemfile.lock ; true ) 
} 

@test "lib::gem::global::latest-version returns the correct version" {
  set -e
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  gem_cache="${LibGem__GemListCache}"
  echo "activesupport (5.1.0, 5.2.0, 4.2.7)" > ${gem_cache}
  result=$(lib::gem::global::latest-version activesupport)
  [[ "${result}" == "5.2.0" ]]
  [[ -f ${gem_cache} ]] && ( rm -f ${gem_cache}; true )
}
