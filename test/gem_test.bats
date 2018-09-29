#!/usr/bin/env bats

source lib/hbsed.sh
source lib/gem.sh
source lib/util.sh

@test "lib::gem::gemfile::version returns correct version" {
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  rm -f ${LibGem__GemListCache}
  touch ${LibGem__GemListCache}
  cp -f test/Gemfile.lock .
  result=$(lib::gem::gemfile::version activesupport)
  echo "result is [${result}]"
  [[ "${result}" == "5.0.7" ]]
  [[ -d test ]] && ( rm -f Gemfile.lock ; true ) 
} 

@test "lib::gem::global::latest-version returns the correct version" {
  export LibGem__GemListCache=/tmp/gem_list_test.txt
  gem_cache="${LibGem__GemListCache}"
  echo "activesupport (5.1.0, 5.2.0, 4.2.7)" > ${gem_cache}
  result=$(lib::gem::global::latest-version activesupport)
  [[ "${result}" == "5.2.0" ]]
  [[ -f ${gem_cache} ]] && ( rm -f ${gem_cache}; true )
}
