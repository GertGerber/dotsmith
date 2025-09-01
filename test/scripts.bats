#!/usr/bin/env bats

@test "sample script test" {
  run bash -lc 'echo hello'
  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]
}
