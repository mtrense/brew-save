# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo stores a snapshot of Homebrew packages (taps, formulae, casks) as a Brewfile, along with a script to regenerate it from the current system.

## Key Files

- `generate-brewfile.sh` — Bash script that queries `brew info --json=v2` and `jq` to produce an aligned Brewfile with description comments
- `Brewfile` — The generated output; checked in as a record of installed packages

## Usage

```bash
# Regenerate the Brewfile from currently installed packages
./generate-brewfile.sh > Brewfile

# Restore packages on a new machine
brew bundle --file=Brewfile
```

## Script Details

`generate-brewfile.sh` requires `brew` and `jq` in PATH. It uses `set -euo pipefail`. The jq expression filters formulae to only those `installed_on_request`, sorts them, aligns columns, and appends `# description` comments. The `.gitignore` excludes the Brewfile itself (it's committed manually after review).
