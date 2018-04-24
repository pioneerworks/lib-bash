#!/usr/bin/env bash
#g
# GEM dependencies
#
# This extracts a lib::gem::version from Gemfile.lock. If not found,
# default (argument) is used. This helps prevent version mismatch
# between the very few gem dependencies of the zeus subsystem, and Rails.

export LibGem__GemListCache=/tmp/gem_list.txt
export LibGem__GemInstallFlags="--no-ri --no-rdoc --force --quiet"

lib::gem::version() {
  local gem=$1
  local default=$2
  local version

  if [[ -f './Gemfile.lock' ]]; then
    version=$(egrep "${gem} \(\d+\.\d+\.\d+\(\.\d+\)?\)" Gemfile.lock | awk '{print $2}' | sed 's/[()]//g')
  else
    lib::gem::load-list
    version=$(gem list | egrep "${gem}" | awk '{print $2}' | sed -E 's/[(),]//g')
  fi

  version=${version:-${default}} # fallback to the default if not found
  printf "%s" ${version}
}

# this ensures the cache is only at most 30 minutes old
lib::gem::load-list() {
  if [[ ! -s "${LibGem__GemListCache}" || -z $(find "${LibGem__GemListCache}" -mmin -30) ]]; then
    run "gem list > ${LibGem__GemListCache}"
  fi
}


lib::gem::ensure-gem-version() {
  local gem=$1
  local gem_version=$2

  if [[ -z $(gem list | grep "${gem} (${gem_version})") ]]; then
    run "gem uninstall --all --force -x -I ${gem}"
    run "gem install ${gem} --version ${gem_version} ${LibGem__GemInstallFlags}"
  else
    info "gem ${gem} version ${gem_version} is already installed."
  fi
}

lib::gem::is-installed() {
  local gem=$1
  local version=$2

  lib::gem::load-list

  if [[ -z ${version} ]]; then
    egrep "${gem} \(" "${LibGem__GemListCache}"
  else
    egrep "${gem} \(" "${LibGem__GemListCache}" | grep "${version}"
  fi
}

# Install the gem, but use the version argument as a default. Final version
# is determined from Gemfile.lock using the +lib::gem::version+ above.
lib::gem::install() {
  local gem_name=$1
  local gem_version=$2
  local gem_version_flags=
  local gem_version_name=

  gem_version=$(lib::gem::version ${gem_name} ${gem_version})

  if [[ -z ${gem_version} ]]; then
    gem_version_name=latest
    gem_version_flags=
  else
    gem_version_name="${gem_version}"
    gem_version_flags="--version ${gem_version}"
  fi

  if [[ -z $(lib::gem::is-installed ${gem_name} ${gem_version}) ]]; then
    info "installing ${bldylw}${gem_name} ${bldgrn}(${gem_version_name})${txtblu}..."
    run "gem install ${gem_name} ${gem_version_flags} ${LibGem__GemInstallFlags}"
    rbenv rehash >/dev/null
    return ${LibRun__LastExitCode}
  else
    info: "gem ${bldylw}${gem_name} (${bldgrn}${gem_version_name}${bldylw})${txtblu} is already installed"
  fi
}
