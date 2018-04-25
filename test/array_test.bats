load test_helper

@test "lib::array::contains-element() when element exists" {
  declare -a array=("a string" "test2000" "hello" "one")
  run $(lib::array::contains-element test2000 "${array[@]}")
  [ "$status" -eq 0 ]
}

@test "lib::array::contains-element() when element does not exists" {
  declare -a array=("a string" "test2000" "hello" "one")
  run $(lib::array::contains-element boo "${array[@]}")
  [ "$status" -eq 1 ]
}

@test "array-contains-element() when element exists, using return value" {
  declare -a array=("a string" "test2000" "hello" "one")
  run $(array-contains-element test2000 "${array[@]}")
  [ "$status" -eq 0 ]
}

@test "array-contains-element() when element exists using output value" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array-contains-element test2000 "${array[@]}") == "true" ]]
}

@test "array-contains-element() when element does not exist using return value" {
  declare -a array=("a string" "test2000" "hello" "one")
  run $(array-contains-element hello "${array[@]}")
  [ "$status" -eq 0 ]
}

@test "array-contains-element when element does not exist using output" {
  declare -a array=("a string" "test2000" "hello" "one")
  [[ $(array-contains-element 123 "${array[@]}") == "false" ]]
}
