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

# This this global to upload all assets there.
export LibAws__DefaultUploadBucket=${LibAws__DefaultUploadBucket:-""}
export LibAws__DefaultUploadFolder=${LibAws__DefaultUploadFolder:-""}
export LibAws__DefaultRegion=${LibAws__DefaultRegion:-"us-west-2"}

aws::s3::upload() {
  local pathname="$1"

  local year=$(date +'%Y')
  local date=$(date +'%Y-%m-%d')

  if [[ -z "${LibAws__DefaultUploadBucket}" || -z "${LibAws__DefaultUploadFolder}" ]]; then
    error "Required AWS S3 configuration is not defined." \
        "Please set variables: ${bldylw}LibAws__DefaultUploadFolder" \
        "and ${bldylw}LibAws__DefaultUploadBucket" \
        "before using this function."
    return 1
  fi

  if [[ ! -f "${pathname}" ]]; then
    error "Local file was not found: ${bldylw}${pathname}"
    return 1
  fi

  local file=$(basename ${pathname})
  local remote_file="${file}"

  # remove the date from file, in case it's at the end or something
  [[ "${remote_file}" =~ "${date}" ]] && remote_file=$(echo "${remote_file}" | sed "s/${date}//g")

  # prepend the date to the beginning of the file unless already in the file
  [[ "${remote_file}" =~ "${date}" ]] || remote_file="${date}.${file}"

  # clean up spaces
  remote_file=$(echo "${remote_file}" | sed 's/ /-/g')

  local remote="s3://${LibAws__DefaultUploadBucket}/${LibAws__DefaultUploadFolder}/${year}/${remote_file}"
  
  run "aws s3 cp \"${pathname}\" \"${remote}\""

  if [[ ${LibRun__LastExitCode} -eq 0 ]] ; then
    local remoteUrl="https://s3-${LibAws__DefaultRegion}.amazonaws.com/${LibAws__DefaultUploadBucket}/${LibAws__DefaultUploadFolder}/${year}/${remote_file}"
    echo
    info "NOTE: You should now be able to access your resource at the following URL:"
    hr
    info "${bldylw}${remoteUrl}"
    hr
  else
    error "AWS S3 upload failed with code ${LibRun__LastExitCode}"
  fi
  return ${LibRun__LastExitCode}
}
