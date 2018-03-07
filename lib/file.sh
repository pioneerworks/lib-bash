#!/usr/bin/env bash

# Makes a file executable but only if it already contains
# a "bang" line at the top.
#
# Usage: __lib::file::make_executable ${pathname}
__lib::file::make_executable() {
  local file=$1

  if [[ -f ${file} && -n $(head -1 $1 | egrep '#!.*(bash|ruby|env)') ]]; then
    printf "making file ${bldgrn}${file}${clr} executable since it's a script...\n"
    chmod 755 ${file}
    return 0
  else
    return 1
  fi
}

__lib::file::remote_size() {
  local url=$1
  printf $(($(curl -sI $url | grep -i 'Content-Length' | awk '{print $2}') + 0))
}

__lib::file::size_bytes() {
  local file=$1
  printf $(($(wc -c < $file) + 0))
}

# Usage:
#   (( $(lib::file::exists_and_newer_than "/tmp/file.txt" 30) )) && echo "Yes!"
lib::file::exists_and_newer_than() {
  [[ -n "$(find ${LibChef__IPCache} -mmin -${2} -print 2>/dev/null)" ]]
}

lib::file::install_with_backup() {
  local source=$1
  local dest=$2
  if [[ ! -f ${source} ]]; then
    error "file ${source} can not be found"
    return -1
  fi

  if [[ -f "${dest}" ]]; then
    if [[ -z $(diff ${dest} ${source} 2>/dev/null) ]]; then
      info: "${dest} is up to date"
      return 0
    else
      (( ${LibFile__ForceOverwrite} )) || {
        info "file ${dest} already exists, skipping (use -f to overwrite)"
        return 0
      }
      inf "making a backup of ${dest} (${dest}.bak)"
      cp "${dest}" "${dest}.bak" >/dev/null
      ok:
    fi
  fi

  run "mkdir -p $(dirname ${dest}) && cp ${source} ${dest}"
}
