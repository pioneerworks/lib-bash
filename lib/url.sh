#!/usr/bin/env bash

# Override these variables before using this library with your username/API key.
export LibUrl__BitlyUsername
export LibUrl__BitlyApiKey

# If this variable is set, and no API key or username is defined,
# then the lib::url::shorten function will display an error and not print any URL.
# If it's not set, and API key or username is missing, then the function
# simply skips over the shortening and prints out the original input URL.

export LibUrl__BitlyValidation=${LibUrl__BitlyValidation:-"1"}

# Usage:
#      source bin/Loader.bash
#
#      export LibUrl__BitlyUsername=awesome-user
#      export LibUrl__BitlyApiKey=F_09097907778FFFDFDFKFGLASKKLJ
#
#      export long="https://s3-us-west-2.amazonaws.com/mybucket/long/very-long-url/2018-08-01.sweet.sweet.donut.right.about.now.html"
#      export short=$(lib::url::shorten ${long})
#
#      open ${short}  # opens in the browser
#      # => http://bit.ly/d9f02
#
lib::url::shorten() {
  local longUrl="$1"

  if [[ -n ${LibUrl__BitlyValidation} ]]; then
    [[ -z "${LibUrl__BitlyUsername}" ]] && {
      error "Please set your BitLy Username"
      return 1
    }

    [[ -z "${LibUrl__BitlyApiKey}" ]] && {
      error "Please set your BitLy Api Key, found in your settings on Bit.Ly"
      return 2
    }

  else
    [[ -z "${LibUrl__BitlyUsername}" ||  -z "${LibUrl__BitlyApiKey}" ]] && {
      printf "${longUrl}"
      return 0
    }
  fi

  $(lib::url::downloader) "http://api.bit.ly/v3/shorten?login=${LibUrl__BitlyUsername}&apiKey=${LibUrl__BitlyApiKey}&format=txt&longURL=${longUrl}"
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
