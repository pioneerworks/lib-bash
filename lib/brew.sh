#!/usr/bin/env bash
#———————————————————————————————————————————————————————————————————————————————
# © 2016 — 2017 Author: Konstantin Gredeskoul
# Ported from the licensed under the MIT license Project Pullulant, at
# https://github.com/kigster/pullulant
#
# Any modifications, © 2017 PioneerWorks, Inc. All rights reserved.
#———————————————————————————————————————————————————————————————————————————————

lib::brew::upgrade() {
  if [[ -z "$(which brew)" ]]; then
    warn "brew is not installed...."
    return 1
  fi

  run "brew update --force"
  run "brew upgrade"
  run "brew cleanup -s"
}

lib::brew::setup() {
  declare -a brew_packages=$@

  local brew=$(which brew 2>/dev/null)

  if [[ -z "${brew}" ]]; then
    curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/master/install" > /tmp/brew.rb
    info "installing Homebrew from scratch, this is so exciting!..."
    run "/usr/bin/ruby < /tmp/brew.rb"
  else
    info "Homebrew is already installed – version: $(brew --version)"
  fi

  # Let's install that goddamn brew-cask
  run "brew tap caskroom/cask"

  # Let's run this damn upgrade
  lib::brew::upgrade
}

lib::brew::relink() {
  local package=${1}
  local verbose=
  [[ -n ${opts_verbose} ]] && verbose="--verbose"
  run "brew link ${verbose} ${package} --overwrite"
}

lib::brew::cache_installed() {
  if [[ -z "${installed_brew_packages[*]}" ]] ; then
    set +e
    export installed_brew_packages="$(brew list -1 | tr '\n' ' ')"
  fi
}

lib::brew::already_installed() {
  local package=${1}

  lib::brew::cache_installed
  declare -a installed_packages=(${installed_brew_packages})
  if [[ $(array-contains-element ${package} ${installed_packages[@]} ) == "true" ]]; then
    printf "true"
  fi
}

lib::brew::install::package() {
  local package=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  inf "checking brew package ${bldylw}${package}"
  if [[ $(lib::brew::already_installed ${package}) == "true" ]]; then
    ok:
  else
    kind_of_ok:
    run "brew install ${package} ${force} ${verbose}"
    if [[ ${LibRun__LastExitCode} != 0 ]]; then
      not_ok:
      warning "${package} failed to install, attempting to overwrite"
      export LibRun__AbortOnError=${False}
      run "brew link ${package} --overwrite ${force} ${verbose}"
    fi
  fi
}

lib::brew::install::cask() {
  local package=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  inf "verifying brew package ${bldylw}${package}"
  if [[ -n $(brew cask list | grep ${package}) ]]; then
    ok:
    run "brew update ${package} ${force} ${verbose}"
  else
    kind_of_ok:
    run "brew cask install ${package} ${force} ${verbose}"
    if [[ ${LibRun__LastExitCode} != 0 ]]; then
      warning "${package} failed to install, attempting to overwrite"
    fi
  fi
}

lib::brew::uninstall::package() {
  local package=$1
  local force=
  local verbose=

  [[ -n ${opts_force} ]] && force="--force"
  [[ -n ${opts_verbose} ]] && verbose="--verbose"

  export LibRun__AbortOnError=${False}
  run "brew unlink ${package} ${force} ${verbose}"

  export LibRun__AbortOnError=${False}
  run "brew uninstall ${package} ${force} ${verbose}"
}

# set $opts_verbose to see more output
# set $opts_force to true to force it

lib::brew::install::packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in $@; do
    lib::brew::install::package ${package}
  done
}

lib::brew::reinstall::packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in $@; do
    lib::brew::uninstall::package ${package}
    lib::brew::install::package ${package}
  done
}

lib::brew::uninstall::packages() {
  local force=
  [[ -n ${opts_force} ]] && force="--force"

  for package in $@; do
    lib::brew::uninstall::package ${package}
  done
}
