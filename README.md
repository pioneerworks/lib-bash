## LIB-BASH — Reusable BASH components with automated tests

[![Build Status](https://travis-ci.com/pioneerworks/lib-bash.svg?token=NB4h8vmPKru2tx5DjD9n&branch=master)](https://travis-ci.com/pioneerworks/lib-bash)

This folder contains Homebase Internal BASH Library, which is shared between several projects.  

The utilities contained herein are of various types, such as:

 * array helpers, such as `array-contains-element` function
 * AWS helpers, requires `awscli` and credentials setup.
 * output helpers, such as colored boxes, header and lines
 * file helpers
 * Docker helpers
 * Ruby, sym (encryption) and utility helpers
 * and finally, the *RunLib* — runtime library framework that executes commands, while measuring their duration and following a set of flags to decide what to do on error, and so on.

Each library will have a set of private functions, typically named `__lib::util::blah`, and public functions, named as `lib::util::foo`, with shortcuts such as `foo` created when makes sense.

## Usage

### Writing Scripts that use the Library Functions

Your scripts should almost always start with:

```bash
#!/usr/bin/env bash

( [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} =~ :file$ ]] || \
  [[ -n $BASH_VERSION && $0 != "$BASH_SOURCE" ]]) && _s_=1 || _s_=0

# This exits if the file is being sourced instead of run.
(( $_s_ )) && {
  echo; printf "${txtred}This script should be run, not sourced.${clr}\n"
  echo; exit 1
}

# This verifies you are running the script from RAILS_ROOT, because
# otherwise it's hard to find and load BASH libraries:
[[ -f "lib/Loader.bashu" ]] || {
  echo "You should be running this from the RAILS_ROOT folder"
  (( $_s_ )) && return 1 || exit 1
}

# Finally, this loads all the bash libraries:
[[ -f lib/Loader.bash  ]] && source lib/Loader.bash
```

### Naming Conventions

We use the following naming conventions:

 1. Namespaces are separated by `::`
 2. Private functions are prefixed with `__`, eg `__lib::output::hr1`
 3. Public functions do not need to be namespaced, or be prefixed with `__`

### Contributing

Submit a pull request!
