#!/usr/bin/env bash

# Override these variables before using this library with your username/API key.
export BITLY_LOGIN
export BITLY_API_KEY

# Description:
#      If BITLY_LOGIN and BITLY_API_KEY are set, shortens the URL using Bitly.
#      Otherwise, prints the original URL.
#
# Usage:
#
#      export BITLY_LOGIN=awesome-user
#      export BITLY_API_KEY=F_09097907778FFFDFDFKFGLASKKLJ
#      export long="https://s3-us-west-2.amazonaws.com/mybucket/long/very-long-url/2018-08-01.sweet.sweet.donut.right.about.now.html"
#
#      export short=$(lib::url::shorten ${long})
#
#      open ${short}  # opens in the browser
#      # => http://bit.ly/d9f02
#
lib::url::shorten() {
  local longUrl="$1"

  if [[ -z "${BITLY_LOGIN}" || -z "${BITLY_API_KEY}" ]]; then
    printf "${longUrl}\n"
  else
    $(lib::url::downloader) "http://api.bit.ly/v3/shorten?login=${BITLY_LOGIN}&apiKey=${BITLY_API_KEY}&format=txt&longURL=${longUrl}"
  fi
}



lib::url::downloader() {
  local downloader=

  if [[ -z "${LibUrl__Downloader}" ]]; then

    [[ -z "${downloader}" && -n $(which curl) ]] && downloader="$(which curl) -fsSL --connect-timeout 5 "
    [[ -z "${downloader}" && -n $(which wget) ]] && downloader="$(which wget) -q -O --connect-timeout=5 - "

    [[ -z "${downloader}" ]] && {
      error "Neither Curl nor WGet appear in the \$PATH... HALP?"
      return 1
    }

    export LibUrl__Downloader="${downloader}"
  fi

  printf "${LibUrl__Downloader}"
}
