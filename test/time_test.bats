load test_helper

@test "millis()" {
  source lib/settings.sh
  source lib/time.sh
  local then=$(millis)
  sleep 0.1
  local now=$(millis)
  [[ ${now} -gt 0 ]]
  [[ ${now} -gt ${then} ]]
  [[ $(( ${now} - ${then})) -gt 100 ]]
  [[ $(( ${now} - ${then})) -lt 200 ]]
}

@test "epoch()" {
  source lib/settings.sh
  source lib/time.sh
  local then=$(epoch)
  sleep 1
  local now=$(epoch)
  [[ ${now} -gt 0 ]]
  [[ ${now} -gt ${then} ]]
  [[ $(( ${now} - ${then})) -gt 0 ]]
  [[ $(( ${now} - ${then})) -lt 2 ]]
}
