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
 * [Docker helpers](lib/docker.sh)
 * [Ruby](lib/ruby.sh), [sym](lib/sym.sh) (encryption) and [utility](lib/utility.sh) helpers
 * and finally, [*RunLib*](lib/run.sh) — a BASH runtime framework that executes commands, while measuring their duration and following a set of flags to decide what to do on error, and so on.

Each library will have a set of private functions, typically named `__lib::util::blah`, and public functions, named as `lib::util::foo`, with shortcuts such as `foo` created when makes sense.

## Usage

### How to integrate it with your project?

1. Add `bin/lib-bash` to `.gitignore`
2. In your common bash helper, eg. `bin/lib.bash`, add the following code:

```bash
curl -fsSL "https://raw.githubusercontent.com/pioneerworks/lib-bash/master/bin/bootstrap" | /usr/bin/env bash -x
```

The code above will automatically checkout this repo under `bin/lib-bash`, and load all files from the `lib` subdirectory of the project.

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
