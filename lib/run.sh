#!/usr/bin/env bash
##——————————————————————————————————————————————————————————————————————————————
## © 2016-2017 Author: Konstantin Gredeskoul
## Ported from the licensed under the MIT license Project Pullulant, at
## https://github.com/kigster/pullulant
##
## Any modifications, © 2017 PioneerWorks, Inc. All rights reserved.
##——————————————————————————————————————————————————————————————————————————————

# This variable is set by each call to #run()
export LibRun__LastExitCode=${False}

# You can globally set these constants below to alternatives, and they will be
# used after each #run() call as the basis for the library variables that
# control the next call to #run().

export LibRun__AbortOnError__Default=${False}
export LibRun__ShowCommandOutput__Default=${False}
export LibRun__AskOnError__Default=${False}

__lib::run::initializer() {
  export LibRun__AbortOnError=${LibRun__AbortOnError__Default}
  export LibRun__AskOnError=${LibRun__AskOnError__Default}
  export LibRun__ShowCommandOutput=${LibRun__ShowCommandOutput__Default}
}

export LibRun__DryRun=${False}
export LibRun__Verbose=${False}

export commands_ignored=0
export commands_failed=0
export commands_completed=0

# Run it while the library is loading.
__lib::run::initializer

__lib::run::env() {
  export run_stdout=/tmp/bash-run.$$.stdout
  export run_stderr=/tmp/bash-run.$$.stderr

  export commands_ignored=${commands_ignored:-0}
  export commands_failed=${commands_failed:-0}
  export commands_completed=${commands_completed:-0}
}

__lib::run::cleanup() {
  rm -f ${run_stdout}
  rm -f ${run_stderr}
}

# To print and not run, set ${LibRun__DryRun}
__lib::run() {
  local cmd="$*"
  __lib::run::env

  if [[ ${LibRun__DryRun} == ${True} ]]; then
    info "${clr}[dry run] ${bldgrn}${cmd}"
    return 0
  else
    __lib::run::exec "$@"
  fi
}

__lib::run::bundle::exec::with-output() {
  export LibRun__ShowCommandOutput=${True}
  __lib::run::bundle::exec "$@"
}

# Runs the command in the context of the "bundle exec",
# and aborts on error.
__lib::run::bundle::exec() {
  local cmd="$*"
  __lib::run::env
  local w=$(( $(__lib::output::screen-width) - 10 ))
  if [[ ${LibRun__DryRun} == ${True} ]]; then
    local line="${clr}[dry run] bundle exec ${bldgrn}${cmd}"
    info "${line:0:${w}}..."
    return 0
  else
    __lib::run::exec "bundle exec ${cmd}"
  fi
}

# This prints
__lib::run::millis() {
  if [[ ${HomebaseCurrentOS} == "Darwin" ]] ; then
    [[ -z $(which gdate) ]] && (lib::brew::install::package coreutils) 1>&2
    printf $(($(gdate +%s%N)/1000000))
  else
    printf $(($(date +%s%N)/1000000))
  fi
}

#
# This is the workhorse of the entire BASH library.
# It basically executes a statement, while processing it's output, error output,
# and status code in a consistent way, controllable via several global variables.
# These variables are reset back to defaults after each run. The defaults hide
# both stdout and error, and do NOT abort on failure.
#
# See: #__lib::run::initializer for the list of global variables.
__lib::run::exec() {
  command="$*"

  if [[ ${LibRun__Verbose} -eq ${True} ]] ; then
    lib::run::inspect
    hr
  fi

  [[ -z ${CI} ]] && w=$(( $(__lib::output::screen-width) - 10 ))
  [[ -n ${CI} ]] && w=1000

  printf "         ${clr}❯ ${bldylw}%s " "${command:0:${w}}"
  lib::output::color::on
  set +e

  start=$(millis)

  if [[ ${LibRun__ShowCommandOutput} -eq ${True} ]] ; then
    echo
    eval "${command}"
  else
    eval "${command}" 2>${run_stderr} 1>${run_stdout}
  fi

  export LibRun__LastExitCode=$?

  duration=$(( $(millis) - ${start}))

  if [[ ${LibRun__LastExitCode} -eq 0 ]] ; then
    ok
    duration ${duration}; echo
    commands_completed=$((${commands_completed} + 1))
  else
    warn " ${txtblk}${bakylw}[ exit code = ${LibRun__LastExitCode} ]${clr}"
    not_ok
    duration ${duration}; echo

    # Print stderr generated during command execution.
    [[ ${LibRun__ShowCommandOutput} -eq ${False} && -s ${run_stderr} ]] \
      && stderr ${run_stderr}

    if [[ ${LibRun__AskOnError} == ${True} ]] ; then
      lib::run::ask 'Ignore this error and continue?'

    elif [[ ${LibRun__AbortOnError} == ${True} ]] ; then
      export commands_failed=$(($commands_failed + 1))
      error "Aborting, due to 'abort on error' being set to true."
      info "Failed command: ${bldylw}${command}"
      echo

      [[ -s ${run_stdout} ]] && {
        hr
        printf "${clr}Standard Output:${bldgrn}\n"
        cat ${run_stdout}
      }

      [[ -s ${run_stderr} ]] && {
        hr
        printf "${clr}Standard Error:${bldred}\n"
        cat ${run_stderr}
      }

      exit ${LibRun__LastExitCode}
    else
      export commands_ignored=$(($commands_ignored + 1))
    fi
  fi

  __lib::run::initializer
  __lib::run::cleanup

  return ${LibRun__LastExitCode}
}

# This errors out if the command provided finishes successfully, but quicker than
# expected. Expected duration is the first numeric argument, command is the rest.
lib::run::with-min-duration() {
  local min_duration=$1; shift
  local command="$*"

  local started=$(millis)
  info "starting a command with the minimum duration of ${bldylw}${min_duration} seconds"
  run "${command}"
  local result=$?

  local duration=$((  ( $(millis) - ${started} ) / 1000 ))

  if [[ ${result} -eq 0 && ${duration} -lt ${min_duration} ]]; then
    error "An operation ${bldylw}${command}${txtred} finished too quickly." \
         "The threshold was set to ${bldylw}${min_duration}${txtred} seconds, but it only took ${bldylw}${duration}${txtred} secs"
    (( $_s_ )) && return 1 || exit 1
  elif [[ ${duration} -gt ${min_duration} ]]; then
    info "minimum duration operation ran in ${duration} seconds."
  fi

  return ${result}
}

# Ask the user if they want to proceed, defaulting to Yes.
# Choosing no exits the program. The arguments are printed as a question.
lib::run::ask() {
  local question=$*

  inf "${bldcyn}${question}${clr} [Y/n] ${bldylw}"

  read a

  echo
  if [[ ${a} == 'y' || ${a} == 'Y' || ${a} == '' ]]; then
    info: "${txtgrn}Great, let's do this ☺ "
    return 0
  else
    warning: "${txtylw}OK, no problem. Exiting.${clr}"
    (( $_s_ )) || exit 1
    (( $_s_ )) && return 1
  fi
}

lib::run::inspect() {
  info "\n${bldylw}CONFIGURATION:"
  info "${bldylw}${LibRun__AbortOnError__Default}${txtblu} == LibRun__AbortOnError__Default"
  info "${bldylw}${LibRun__AbortOnError}${txtblu} == LibRun__AbortOnError\n"
  info "${bldylw}${LibRun__DryRun}${txtblu} == LibRun__DryRun"
  info "${bldylw}${LibRun__Verbose}${txtblu} == LibRun__Verbose"
  info "${bldylw}${LibRun__LastExitCode}${txtblu} == LibRun__LastExitCode"
  info "${bldylw}${LibRun__ShowCommandOutput}${txtblu} == LibRun__ShowCommandOutput"
  info "\n${bldylw}TOTALS:${clr}"
  info "${bldgrn}${commands_completed}${txtblu} commands completed successfully,"
  info "${bldred}${commands_failed}${txtblu} failed commands, and "
  info "${bldylw}${commands_ignored}${txtblu} failed commands have been ignored."
}

millis() {
  __lib::run::millis
}

with-min-duration() {
  lib::run::with-min-duration "$@"
}

run() {
  __lib::run $@
  return ${LibRun__LastExitCode}
}

with-bundle-exec() {
  __lib::run::bundle::exec "$@"
}

with-bundle-exec-and-output() {
  __lib::run::bundle::exec::with-output "$@"
}

# These are borrowed from
# /usr/local/Homebrew/Library/Homebrew/brew.sh
onoe() {
  if [[ -t 2 ]] # check whether stderr is a tty.
  then
    echo -ne "\033[4;31mError\033[0m: " >&2 # highlight Error with underline and red color
  else
    echo -n "Error: " >&2
  fi
  if [[ $# -eq 0 ]]
  then
    /bin/cat >&2
  else
    echo "$*" >&2
  fi
}

odie() {
  onoe "$@"
  exit 1
}

safe_cd() {
  cd "$@" >/dev/null || odie "Error: failed to cd to $*!"
}
