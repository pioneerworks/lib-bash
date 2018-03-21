
lib::osx::display::change-underscan() {
  set +e
  local amount_percentage="$1"
  if [[ -z "${amount_percentage}" ]] ; then
    printf "    usage: $0 <percentage-change> \n"
    printf "       eg: $0 5    # underscan by 5% \n"
    return -1
  fi

  local file="/var/db/.com.apple.iokit.graphics"
  local backup="/tmp/.com.apple.iokit.graphics.bak"

  local amount=$(( 100 * ${amount_percentage} ))

  h1 'This utility allows you to change underscan/overscan' \
     'on monitors that do not offer that option via GUI.'

  lib::run::ask "Continue?"

  info "Great! First we need to identify your monitor."
  hl::yellow "Please make sure that the external monitor is plugged in."
  lib::run::ask "Is it plugged in?"

  info "Making a backup of your current graphics settings..."
  inf "Please enter your password, if asked: "
  set -e
  bash -c 'set -e; sudo ls -1 > /dev/null; set +e'
  ok
  run "sudo rm -f \"${backup}\""
  export LibRun__AbortOnError=${True}
  run "sudo cp -v \"${file}\" \"${backup}\""

  h2  "Now: please change the resolution ${bldylw}on the problem monitor." \
      "NOTE: it's ${italic}not important what resolution you choose," \
      "as long as it's different than what you had previously..." \
      "Finally: exit Display Preferences once you changed resolution."

  run "open /System/Library/PreferencePanes/Displays.prefPane"
  lib::run::ask "Have you changed the resolution and exited Display Prefs? "

  local line=$(sudo diff "${file}" "${backup}" 2>/dev/null | head -1 | /usr/bin/env ruby -ne 'puts $_.to_i')
  [[ -n $DEBUG ]] && info "diff line is at ${line}"
  value=

  if [[ "${line}" -gt 0 ]]; then
    line_pscn_key=$(( $line - 4 ))
    line_pscn_value=$(( $line - 3 ))
    ( awk "NR==${line_pscn_key}{print;exit}" "${file}" | grep -q pscn ) && {
      value=$(awk "NR==${line_pscn_value}{print;exit}" "${file}" | awk 'BEGIN{FS="[<>]"}{print $3}')
      [[ -n $DEBUG ]] && info "current value is ${value}"
    }
  else
    error "It does not appear that anything changed, sorry."
    return -1
  fi

  h2 "Now, please unplug the problem monitor temporarily..."
  lib::run::ask "...and press Enter to continue "

  if [[ -n ${value} ]]; then
    local new_value=$(( $value - ${amount} ))
    export LibRun__AbortOnError=${True}
    run "sudo sed -i.backup \"${line_pscn_value}s/${value}/${new_value}/g\" \"${file}\""
    echo
    h2 "Congratulations!" "Your display underscan value has been changed."
    info "Previous Value  ${bldpur}${value}"
    info "New value:      ${bldgrn}${new_value}"
    hr
    info "${bldylw}IMPORTANT!"
    info "You must restart your computer for the settings to take affect."
  else
    warning "Unable to find the display scan value to change. "
    info "Could it be that you haven't restarted since your last run?"
    echo
    info "Feel free to edit file directly, using:"
    info "eg: ${bldylw}vim ${file} +${line_pscn_value}"
  fi
}
