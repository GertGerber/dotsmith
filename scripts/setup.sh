#!/bin/bash
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Gert Gerber

# Update package lists only if needed
sudo apt update -y

# Function to install a package if not installed
install_if_missing() {
  if ! dpkg -s "$1" >/dev/null 2>&1; then
    echo "Installing $1..."
    sudo apt install -y "$1"
  else
    echo "$1 is already installed."
  fi
}

# Install required packages
install_if_missing git
install_if_missing gh

# Upgrade system (optional, remove if you don’t want upgrades every run)
sudo apt upgrade -y

# GitHub CLI authentication (token should exist in mytoken.txt)
if [ -f mytoken.txt ]; then
  echo "Logging into GitHub CLI..."
  gh auth login --with-token < mytoken.txt
else
  echo "mytoken.txt not found. Skipping GitHub login."
fi

# Configure Git user if not already set
if ! git config --global user.name >/dev/null; then
  git config --global user.name "GertGerber"
fi

if ! git config --global user.email >/dev/null; then
  git config --global user.email "ggerber@outlook.co.nz"
fi

read -p "Enter new username: " newusername
if id "$newusername" &>/dev/null; then
  echo "User '$newusername' already exists."
else
  sudo useradd -m -s /bin/bash "$newusername"
  sudo usermod -aG sudo "$newusername"
  echo "Set a password for $newusername:"
  sudo passwd "$newusername"
  echo "User '$newusername' created with sudo privileges."
fi

# # Remove user
# read -p "Enter username to remove: " deluser
# if id "$deluser" &>/dev/null; then
#   sudo userdel -r "$deluser"
#   echo "User '$deluser' and their home directory have been removed."
# else
#   echo "User '$deluser' does not exist."
# fi