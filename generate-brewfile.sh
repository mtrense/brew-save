#!/bin/bash
set -euo pipefail

# Generate a Brewfile from currently installed Homebrew formulas and casks,
# with descriptions as inline comments.
# Expects `brew` and `jq` to be present in PATH.

taps=$(brew tap 2>/dev/null | sort)
json=$(brew info --json=v2 --installed 2>/dev/null)

# Taps
echo "$taps" | while read -r tap; do
  echo "tap \"$tap\""
done
echo

echo "$json" | jq -r '
  # Build entries: [instruction, description]
  [ (.formulae | sort_by(.name)[] | select(.installed[].installed_on_request) | ["brew \"\(.name)\"", (.desc // "")]),
    (.casks    | sort_by(.token)[] | ["cask \"\(.token)\"", (.desc // "")]) ]
  |
  # Find the longest instruction for alignment
  (map(.[0] | length) | max) as $max
  |
  .[] |
  if .[1] != "" then
    .[0] + (" " * ($max - (.[0] | length) + 2)) + "# " + .[1]
  else
    .[0]
  end
'
