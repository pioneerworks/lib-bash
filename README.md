## LIB-BASH — Reusable BASH components with automated tests

[![Build Status](https://travis-ci.org/pioneerworks/lib-bash.svg?branch=master)](https://travis-ci.org/pioneerworks/lib-bash)

This folder contains Homebase Internal BASH Library, which is shared between several projects.

We have adopted the [Google Bash Style Guide](https://google.github.io/styleguide/shell.xml), and it's recommended that anyone committing to this repo reads the guides to understand the conventions, gotchas and anti-patterns.

### Whats Here?

The utilities contained herein are of various types, such as:

 * array helpers, such as `array-contains-element` function
 * version helpers, such as functions `lib::util::ver-to-i` which convert a string version like '1.2.0' into an integer that can be used in comparisons; another function `lib::util::i-to-ver` converts an integer back into the string format. This is used, for example, by the auto-incrementing Docker image building tools availble in [`docker.sh`](lib/docker.sh)
 * [AWS helpers](lib/aws.sh), requires `awscli` and credentials setup.
 * [output helpers](lib/output.sh), such as colored boxes, header and lines
 * [file helpers](lib/file.sh)
 * [docker helpers](lib/docker.sh)
 * [ruby](lib/ruby.sh), [sym](lib/sym.sh) (encryption) and [utility](lib/utility.sh) helpers
 * and finally, [*LibRun*](lib/runtime.sh) — a BASH runtime framework that executes commands, while measuring their duration and following a set of flags to decide what to do on error, and so on.

Each library will have a set of private functions, typically named `__lib::util::blah`, and public functions, named as `lib::util::foo`, with shortcuts such as `foo` created when makes sense.

## Usage

### How to integrate it with your project?

In order to install this library into your environment, we recommend the following code in your primary "bash environment" file for a given project:

```bash
#
# Append this code in your primary shared library file, such as `bin/lib.bash`
#
export LibBash__BootstrapUrl="https://raw.githubusercontent.com/pioneerworks/lib-bash/master/bin/bootstrap"
export LibBash__ScriptPath="bin/bootstrap"

lib::bash::bootstrap() {
  local __bootstrapPath=${1}
  local __bootstrapUrl=${2}

  if [[ -s ${__bootstrapPath} ]]; then
    source ${__bootstrapPath}
  else
    if [[ -z $(which curl) && -n $(type lib::brew::install::package) ]] && lib::brew::install::package curl
    if [[ -z $(which curl) ]] && {
      printf "Can't find curl, please install it, eg. using brew...\n"
      exit 2
    }
    curl -fsSL ${__bootstrapUrl} > ${__bootstrapPath}
    source ${__bootstrapPath} lib-bash
  fi
}

lib::bash::bootstrap ${LibBash__ScriptPath} ${LibBash__BootstrapUrl}
# optional:
# lib::bash::source "folder with local bash scripts", eg:
# lib::bash::source "bin/lib/local"
```

The code above will automatically checkout this repo  `lib-bash` at the same level as the current project, but it will add a symlink from your projects `bin/lib-bash` folder to `../lib-bash/lib` where all the files are.

### Writing Scripts that use the Library Functions

Your scripts should almost always start with:

```bash
#!/usr/bin/env bash
# If you want to be able to tell if the script is run or sourced:
( [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
  [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && _s_=1 || _s_=0
# This exits if the file is being sourced instead of run.
(( $_s_ )) && {
  echo; printf "${txtred}This script should be run, not sourced.${clr}\n"
  echo; exit 1
}

# Finally, this loads all the bash libraries:
[[ -f lib/Loader.bash  ]] && source lib/Loader.bash
[[ -f bin/lib-bash/Loader.bash  ]] && source bin/lib-bash/lib/Loader.bash
```

### Naming Conventions

We use the following naming conventions:

 1. Namespaces are separated by `::`
 2. Private functions are prefixed with `__`, eg `__lib::output::hr1`
 3. Public functions do not need to be namespaced, or be prefixed with `__`

### Writing tests

We are using [`bats`](https://github.com/sstephenson/bats.git) for unit testing.

Please provide a properly named test for your new library, and a couple of test cases.

See existing tests for examples.


### Contributing

Submit a pull request!
