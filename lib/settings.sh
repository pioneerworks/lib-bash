#!/usr/bin/env bash

export True="1"
export False="0"

export HomebaseNodeVersion="9.4.0"
export HomebaseNvmVersion="0.33.2"

export HomebasePostgresVersion=${PostgreSQLVersion:-"9.4"}
export HomebasePostgresHostname="localhost"
export HomebasePostgresUsername="postgres"

export HomebaseCurrentOS=$(uname -s)

if [[ -f ".ruby-version" ]]; then
  export HomebaseRubyVersion=$(cat .ruby-version)
else
  export HomebaseRubyVersion="2.4.3"
fi

declare -a HomebaseBrewCasks=(
  chromedriver
  gitx
  textmate
  atom
)
export HomebaseBrewCasks

declare -a HomebaseBrewPackages=(
    ag
    autoconf
    autogen
    automake
    awscli
    bash
    bash-completion
    coreutils
    curl
    direnv
    go
    htop
    hub
    imagemagick
    jemalloc
    jq
    memcached
    openssl
    rbenv
    redis
    ruby-build
    rsync
    screen
    the_silver_searcher
    tmux
    wget
    webpack
    yarn
  )

export HomebaseBrewPackages
export HomebaseDefaultBackupDir='tmp/pgdump'
