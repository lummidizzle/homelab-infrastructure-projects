#!/usr/bin/env bash
set -euo pipefail

# Ensure 'tree' is available
if ! command -v tree >/dev/null 2>&1; then
  echo "Installing 'tree'..."
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf -y install tree
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get -y install tree
  else
    echo "Please install 'tree' manually." >&2
    exit 1
  fi
fi

# Generate the top-level tree (ignore git metadata & OS cruft)
STRUCTURE=$(tree -L 1 -a -I '.git|.github|.DS_Store|Thumbs.db' -F   | sed '1s/.*/homelab-infrastructure-projects\//')

# Wrap in a code fence
BLOCK="
