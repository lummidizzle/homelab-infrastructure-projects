#!/bin/bash

# Script for Permissions & Ownership Phase
# Author: Olumide ✊
# Location: RHEL10 /tmp/phase2test

PHASE_DIR="/tmp/phase2test"

echo "🔧 Creating test directory and files..."

mkdir -p "$PHASE_DIR"
cd "$PHASE_DIR" || exit

# Create test files and directory
touch testfile.txt suidfile sgidfile stickyfile
mkdir testdir

# Apply basic chmod
chmod 600 testfile.txt
chmod u=rwx,g=rx,o=r testfile.txt
chmod +x testfile.txt

# Ownership (set to oluadmin if user exists)
echo "👤 Setting ownership..."
sudo chown oluadmin:wheel testfile.txt

# Special permissions
chmod u+s suidfile
chmod g+s sgidfile
chmod +t stickyfile
chmod +t testdir

# Output results
echo -e "\n📄 Final permissions:"
ls -l
echo -e "\n📁 Directory permissions:"
ls -ld testdir

echo "✅ Permissions lab setup complete!"
