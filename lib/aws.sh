#!/usr/bin/env bash

# Usage:
#   aws::rds::hostname 'database-name'
# Eg:
#   aws::rds::hostname
aws::rds::hostname() {
  local name=${1}
  [[ -z $(which jq) ]] && out=$(lib::brew::install::package jq 2>/dev/null 1>/dev/null)
  [[ -z $(which aws) ]] && out=$(lib::brew::install::package awscli 2>/dev/null 1>/dev/null)

  [[ -n ${name} ]] && aws rds describe-db-instances | jq '.[][].Endpoint.Address' | hbsed 's/"//g'  | egrep "^${name}\."
  [[ -z ${name} ]] && aws rds describe-db-instances | jq '.[][].Endpoint.Address' | hbsed 's/"//g'
}
