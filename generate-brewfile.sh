#!/bin/bash
set -euo pipefail

# Generate a Brewfile from currently installed Homebrew formulas and casks,
# with Mac App Store apps (via `mas`), and descriptions as inline comments.
# Expects `brew` and `jq` to be present in PATH. `mas` is optional.

taps=$(brew tap 2>/dev/null | sort)
json=$(brew info --json=v2 --installed 2>/dev/null)

# Taps
echo "$taps" | while read -r tap; do
  [ -n "$tap" ] && echo "tap \"$tap\""
done
echo

# Mac App Store entries: [instruction, app_name] parsed from `mas list`
mas_entries="[]"
if command -v mas &>/dev/null; then
  mas_entries=$(mas list 2>/dev/null | sed 's/^ *//' | sort -t' ' -k2 | awk '{
    id = $1
    # strip id and trailing version in parens to get the app name
    sub(/^[0-9]+[[:space:]]+/, "")
    sub(/[[:space:]]+\([^)]*\)[[:space:]]*$/, "")
    name = $0
    printf "[\"mas \\\"%s\\\", id: %s\",\"%s\"],\n", name, id, name
  }' | { entries=$(cat); echo "[${entries%,}]"; })
fi

echo "$json" | jq -r --argjson mas "$mas_entries" '
  # Build entries: [instruction, description]
  [ (.formulae | sort_by(.name)[] | select(.installed[].installed_on_request) | ["brew \"\(.name)\"", (.desc // "")]),
    (.casks    | sort_by(.token)[] | ["cask \"\(.token)\"", (.desc // "")]) ]
  + ($mas | map([.[0], .[1]]))
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
