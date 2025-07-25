#!/bin/bash

# Script to create a user with home, shell, sudo privileges
# Designed for RHEL 10+
# Author: Olumide 💪

LOGFILE="/var/log/user_create.log"
USER="$1"

if [[ -z "$USER" ]]; then
  echo "Usage: $0 <username>"
  exit 1
fi

echo "🔧 Creating user: $USER"

# Check if user exists
if id "$USER" &>/dev/null; then
  echo "⚠️ User '$USER' already exists. Exiting."
  exit 2
fi

# Create user with home dir and bash shell
sudo useradd -m -s /bin/bash "$USER"
echo "✅ User '$USER' created."

# Set password interactively
echo "🔐 Set password for $USER:"
sudo passwd "$USER"

# Add user to wheel group (sudo)
sudo usermod -aG wheel "$USER"
echo "✅ Added '$USER' to wheel group."

# Show user info
echo "📄 User info:"
id "$USER"
getent passwd "$USER"

# Log action
echo "$(date '+%F %T') - Created user: $USER" | sudo tee -a "$LOGFILE"

echo "🎉 User '$USER' created successfully on RHEL 10!"

