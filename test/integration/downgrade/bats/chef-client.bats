#!/usr/bin/env bats

@test "chef-client binary is found in PATH" {
  run which chef-client
  [ "$status" -eq 0 ]
}

@test "chef-client binary version verified" {
  run chef-client --version
  [ "$status" -eq 0 ]
  [ "$output" = "Chef: 12.2.1" ]
}
