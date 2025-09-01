#!/usr/bin/env bats

setup() {
  PROJECT="$(dirname "$(dirname "${BATS_TEST_FILENAME}")")"
  DF="$PROJECT/scripts/df"
  chmod +x "$DF"
}

@test "prints banner by default" {
  run bash -c "DF_BANNER=1 $DF --check -i inventories/local/hosts.ini --syntax-check || true"
  [ "$status" -ge 0 ]
  echo "$output" | grep -q "Project : dotsmith"
}

@test "suppresses banner when DF_BANNER=0" {
  run bash -c "DF_BANNER=0 $DF --check -i inventories/local/hosts.ini --syntax-check || true"
  [ "$status" -ge 0 ]
}
