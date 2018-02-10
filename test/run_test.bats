load test_helper

@test "Run with a successful command and defaults" {
  source lib/runtime.sh
  export LibRun__DryRun=${True}
  run lib::run "ls"
  [[ "${status}" -eq 0 ]]
  [[ "${LibRun__LastExitCode}" -eq 0 ]]
}

@test "Run with a unsuccessful command and defaults" {
  source lib/runtime.sh
  export LibRun__DryRun=${False}
  run "lib::run lssdf"
  [[ "${status}" -eq 127 ]]
}
