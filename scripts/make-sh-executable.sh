#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Gert Gerber
set -euo pipefail

ROOT="."
DRY_RUN=0

# Usage: ./make-sh-executable.sh [path] [--dry-run|-n]
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    *) ROOT="$arg" ;;
  esac
done

if [[ ! -d "$ROOT" ]]; then
  echo "Path not found or not a directory: $ROOT" >&2
  exit 1
fi

if (( DRY_RUN )); then
  echo "Would make executable (no changes):"
  find "$ROOT" -type f -name '*.sh' -not -perm /111 -print
else
  # Only touch files missing any execute bit
  find "$ROOT" -type f -name '*.sh' -not -perm /111 -print -exec chmod +x {} \;
fi