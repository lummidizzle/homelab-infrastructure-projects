#!/bin/bash

# Set repo path
REPO_DIR="$HOME/homelab-infrastructure-projects"
cd "$REPO_DIR" || exit 1

# Timestamp
NOW=$(date +"%Y-%m-%d %H:%M:%S")

# Git add, commit, and push
git add -A
git commit -m "Weekly sync - $NOW"
git push origin main

