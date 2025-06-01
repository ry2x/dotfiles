#!/bin/bash

# Get list of upgradable packages and let user select multiple with fzf
selected_pkgs=$(yay -Qu | awk '{print $1}' | fzf -m --prompt="️⚙️ Select packages to upgrade: ex <package_name> <package_name> > ")

# Trim leading/trailing whitespace (in case)
selected_pkgs=$(echo "$selected_pkgs" | xargs)

if [ -z "$selected_pkgs" ]; then
  echo "❌ No packages selected. Exiting."
  exit 0
fi

echo "Upgrading the following packages:"
echo "$selected_pkgs"

# Run yay upgrade and capture output and exit status
output=$(yay -S --noconfirm $selected_pkgs 2>&1)
status=$?

echo
if [ $status -eq 0 ]; then
  echo "✅ Successfully upgraded packages:"
  echo "$selected_pkgs"
else
  echo "❌ Error occurred during upgrade!"
  echo "Error details:"
  echo "$output"
  echo
  echo "Partial upgrade output:"
  echo "$selected_pkgs"
fi
