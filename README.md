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
#!/usr/bin/env bash

# lib-bash initialization:
BootstrapScript="bin/bootstrap"
if [[ -d "../lib-bash" && -s "../lib-bash/bin/bootstrap" ]]; then
  cp ../lib-bash/bin/bootstrap "${BootstrapScript}"
else
  if [[ ! -L "bin/lib-bash" || ! -s "bin/bootstrap" ]]; then
    curl -fsSL https://raw.githubusercontent.com/pioneerworks/lib-bash/master/bin/bootstrap > "${BootstrapScript}"
  fi
fi

[[ -s "bin/bootstrap" ]] && source "${BootstrapScript}" "lib-bash"
[[ -L "bin/lib-bash" ]]  && source "bin/lib-bash/Loader.bash"

# optional to source a local library of all .sh files in a given folder (non-recursively)
# uncomment the following line
# lib::bash::source "bin/lib"
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


## Helpful Scripts

### Changing OSX Underscan for Old Monitors

If you are stuck working on a monitor that does not support switching digit input from TV to PC, NOR does OS-X show the "underscan" slider in the Display Preferences, you may be forced to change the underscan manually. The process is a bit tricky, but we have a helpful script to do that:

```bash
$ source lib/Loader.bash
$ lib::osx::display::change-underscan 5
```

This will reduce underscan by 5% compared to the current value. The total value is 10000, and is stored in the file `/var/db/.com.apple.iokit.graphics`. The tricky part is determining which of the display entries map to your problem monitor. This is what the script helps with.

Do not forget to restart after the change.

Acknowledgements: the script is an automation of the method offered on [this blog post](http://ishan.co/external-monitor-underscan).

### Contributing

Submit a pull request!
