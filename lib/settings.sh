#!/usr/bin/env bash

export True=1
export False=0

export HomebaseNodeVersion="9.4.0"
export HomebaseNvmVersion="0.33.2"

export HomebasePostgresVersion="9.4"
export HomebasePostgresHostname="localhost"
export HomebasePostgresUsername="postgres"

export HomebaseCurrentOS=$(uname -s)

if [[ -f ".ruby-version" ]]; then
  export HomebaseRubyVersion=$(cat .ruby-version)
else
  export HomebaseRubyVersion="2.2.7"
fi

declare -a HomebaseBrewPackages=(
    autoconf
    autogen
    automake
    awscli
    bash
    bash-completion
    coreutils
    chromedriver
    curl
    direnv
    go
    htop
    imagemagick
    jq
    memcached
    openssl
    phantomjs
    rbenv
    redis
    ruby-build
    the_silver_searcher
    wget
    yarn
  )

export HomebaseBrewPackages
export HomebaseDefaultBackupDir='tmp/pgdump'
