#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Gert Gerber

set -euo pipefail

# Directory to search (default: current dir)
SEARCH_DIR="${1:-.}"

# Output file
OUTPUT_FILE="collected_files.txt"

# Exclude patterns (directories, files, wildcards)
EXCLUDES=(
    ".git/"           # relative directory
    ".github/"        # relative directory
    "*.md"            # wildcard pattern
    "secret.txt"      # specific file
    "LICENSE"         # specific file
    "dotfiles/roles/" # relative directory
    "docs/"           # relative directory
    "tests/"          # relative directory
    "examples/"       # relative directory
)

# Convert SEARCH_DIR to absolute path
SEARCH_DIR_ABS=$(realpath "$SEARCH_DIR")

# Clear output file
> "$OUTPUT_FILE"

# Build find command with exclusions
FIND_CMD=(find "$SEARCH_DIR_ABS" -type f)

for pattern in "${EXCLUDES[@]}"; do
    if [[ "$pattern" == */ ]]; then
        # Exclude directories (any files under this dir)
        FIND_CMD+=(! -path "$SEARCH_DIR_ABS/$pattern*")
    elif [[ "$pattern" == *\** ]]; then
        # Exclude wildcard filenames
        FIND_CMD+=(! -name "$pattern")
    else
        # Exclude specific files
        FIND_CMD+=(! -path "$SEARCH_DIR_ABS/$pattern")
    fi
done

# Execute find and append content with headers using -exec
"${FIND_CMD[@]}" -exec bash -c '
for FILE; do
    BASENAME=$(realpath --relative-to="$0" "$FILE")
    {
        echo "########################################"
        echo "# Filename:  $BASENAME"
        echo "########################################"
        cat "$FILE"
        echo
        echo "*********** File End ************************************"
        echo
    } >> "$1"
done
' "$SEARCH_DIR_ABS" "$OUTPUT_FILE" {} +

# Set readable permissions
chmod 644 "$OUTPUT_FILE"

echo "✅ All files collected into: $OUTPUT_FILE"


################################################################################
# Run for current folder:
# ./collect_files.sh
# Or for a specific folder:
# ./collect_files.sh /path/to/scan
#
# Notes:
# - This script collects all files in the specified directory and its subdirectories,
#   appending their contents to a single output file named collected_files.txt.
# - EXCLUDES can contain:
#     - Relative directories: "some/dir/"
#     - Absolute directories: "/home/user/dir/"
#     - Specific files: "some/file.txt"
#     - Wildcards: "*.md"
# - Pruned directories are completely skipped with all contents.
# - Files can be excluded by adding them to EXCLUDES:
#   EXCLUDES=(
#       "some/other/excluded1/"                # Exclude entire directory
#       "some/other/excluded/file.txt"         # Exclude specific file
#       "some/other/excluded/*.txt"            # Exclude all .txt files in a specific directory
#       "*.md"                                 # Exclude all .md files regardless of location
#   )
################################################################################