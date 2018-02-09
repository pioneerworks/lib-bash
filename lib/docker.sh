#!/usr/bin/env bash
#
#———————————————————————————————————————————————————————————————————————————————
# © 2016 — 2017 Author: Konstantin Gredeskoul
# © 2017 PioneerWorks, Inc. All rights reserved.
#
# In this library we "document in code" our agreements about running docker.
# We express basic Docker compose commands as library functions that
# "memorize" the frequently used flags and other options, so that we dont' have
# to think about it.
#———————————————————————————————————————————————————————————————————————————————

#===============================================================================
# Private Functions
#===============================================================================

__lib::docker::output-colors() {
  printf "${bldblu}"
  printf "${txtpur}" >&2
}

__lib::docker::reset-colors() {
  printf "${clr}"
  printf "${clr}" >&2
}

__lib::docker::exec() {
  local cmd="$*"
  info "[boot] ${bldylw}${cmd}"
  __lib::docker::output-colors
  ${cmd}
  code=$?
  if [[ ${code} != 0 ]]; then
    error: "[done] ${bldylw}${cmd}"
    error  "[done] command exited with code ${bldylw}${code}"
    return ${code}
  else
    info: "[done] ${bldylw}${cmd}"
  fi
  __lib::docker::reset-colors
  echo
}

__lib::docker::last-version() {
  local versions=$(docker images ${HomebaseDockerRepo} | egrep -v 'TAG|latest|none' | awk '{print $2}')

  local max=0
  for v in ${versions}; do
    vi=$(lib::util::ver-to-i ${v})
    [[ ${vi} -gt ${max} ]] && max=${vi}
  done

  lib::util::i-to-ver ${max}
}

__lib::docker::next-version() {
  local version=$(__lib::docker::last-version)
  local vi=$(( $(lib::util::ver-to-i ${version}) + 1 ))
  printf $(lib::util::i-to-ver ${vi})
}
#===============================================================================
# Public Functions
#===============================================================================

# Docker Actions
lib::docker::actions::build() {
  __lib::docker::exec "docker-compose build -m 1G --force-rm --pull"
}

lib::docker::actions::clean() {
  __lib::docker::exec "docker-compose rm"
}

lib::docker::actions::up() {
  __lib::docker::exec "docker-compose up"
}

lib::docker::actions::start() {
  __lib::docker::exec "docker-compose start"
}

lib::docker::actions::stop() {
  __lib::docker::exec "docker-compose stop"
}

lib::docker::actions::pull() {
  local tag=${1:-'latest'}
  __lib::docker::exec "docker pull ${HomebaseDockerRepo}:${tag}"
}

lib::docker::actions::tag() {
  local tag=${1}
  [[ -z ${tag} ]] && return
  __lib::docker::exec docker tag ${HomebaseDockerRepo} "${HomebaseDockerRepo}:${tag}"
}

# Usage:
#  - lib::docker::actions::push  (auto-increments the version, and pushes it + latest
#  - lib::docker::actions::push 1.1.0  # manually supply version, and push it; also set latest to this version.

lib::docker::actions::push() {
  local tag=${1:-$(__lib::docker::next-version)}

  lib::docker::actions::tag latest

  [[ -n ${tag} ]] && lib::docker::actions::tag ${tag}

  __lib::docker::exec docker push "${HomebaseDockerRepo}:${tag}"

  [[ ${tag} != 'latest' ]] && __lib::docker::exec docker push "${HomebaseDockerRepo}:latest"
}

#———————————————————————————————————————————————————————————————————————————————
# Composite Commands
#———————————————————————————————————————————————————————————————————————————————

lib::docker::actions::setup() {
  lib::setup::docker
  lib::docker::pull
  lib::docker::build
}

lib::docker::actions::update() {
  lib::docker::build
  lib::docker::push
}

lib::docker::abort_if_down() {
  inf 'Checking if Docker is running...'
  docker ps 2>/dev/null 1>/dev/null
  code=$?

  if [[ ${code} == 0 ]]; then
    ok:
  else
    not_ok:
    error "docker ps returned ${code}, is Docker running?"
    exit 127
  fi
}
