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
    version=$(egrep "${gem} \(\d+\.\d+\.\d+\(\.\d+\)?\)" Gemfile.lock | awk '{print $2}' | hbsed 's/[()]//g')
  else
    lib::gem::cache-installed
    version=$(cat ${LibGem__GemListCache} | egrep "${gem}" | awk '{print $2}' | hbsed -E 's/[(),]//g')
  fi

  version=${version:-${default}} # fallback to the default if not found
  printf "%s" ${version}
}

# this ensures the cache is only at most 30 minutes old
lib::gem::cache-installed() {
  if [[ ! -s "${LibGem__GemListCache}" || -z $(find "${LibGem__GemListCache}" -mmin -30 2>/dev/null) ]]; then
    run "gem list > ${LibGem__GemListCache}"
  fi
}

lib::gem::cache-refresh() {
  rm -f ${LibGem__GemListCache}
  lib::gem::cache-installed
}

lib::gem::ensure-gem-version() {
  local gem=$1
  local gem_version=$2

  [[ -z ${gem} || -z ${gem_version} ]] && return

  lib::gem::cache-installed

  if [[ -z $(cat  ${LibGem__GemListCache} | grep "${gem} (${gem_version})") ]]; then
    lib::gem::uninstall ${gem} 
    lib::gem::install ${gem} ${gem_version}
  else
    info "gem ${gem} version ${gem_version} is already installed."
  fi
}

lib::gem::is-installed() {
  local gem=$1
  local version=$2

  lib::gem::cache-installed

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
    if [[ ${LibRun__LastExitCode} -eq 0 ]]; then
      rbenv rehash >/dev/null 2>/dev/null
      lib::gem::cache-refresh
    else
      error "Unable to install gem ${bldylw}${gem_name}"
    fi
    return ${LibRun__LastExitCode}
  else
    info: "gem ${bldylw}${gem_name} (${bldgrn}${gem_version_name}${bldylw})${txtblu} is already installed"
  fi
}

lib::gem::uninstall() {
  local gem_name=$1
  local gem_version=$2 # optional

  if [[ -z $(lib::gem::is-installed ${gem_name} ${gem_version}) ]]; then
    info "gem ${bldylw}${gem_name}${txtblu} is not installed"
    return
  fi

  local gem_flags="-x -I --force"
  if [[ -z ${gem_version} ]] ; then
    gem_flags="${gem_flags} -a"
  else
    gem_flags="${gem_flags} --version ${gem_version}"
  fi

  run "gem uninstall ${gem_name} ${gem_flags}"
  lib::gem::cache-refresh
}

## Shortcuts

function g-i() {
  lib::gem::install "$@"
}

function g-u() {
  lib::gem::uninstall "$@"
}
