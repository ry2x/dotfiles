#!/bin/bash

# Get list of upgradable packages
# Add an "ALL" option to the list for upgrading all packages
upgradable_pkgs=$(paru -Qu | awk '{print $1}')
fzf_options="(ALL) Upgrade all packages\n$upgradable_pkgs"

# Let user select multiple with fzf, or choose to upgrade all
selected_option=$(echo -e "$fzf_options" | fzf -m --prompt="️⚙️ Select packages to upgrade (or ALL):")

# Trim leading/trailing whitespace (in case)
selected_option=$(echo "$selected_option" | xargs)

if [ -z "$selected_option" ]; then
  echo "❌ No packages selected. Exiting."
  exit 0
fi

if [[ "$selected_option" == *"(ALL) Upgrade all packages"* ]]; then
  echo "Upgrading all available packages."
  # Run paru upgrade all and capture output and exit status
  output=$(paru -Syu --noconfirm 2>&1)
  status=$?

  echo
  if [ $status -eq 0 ]; then
    echo "✅ Successfully upgraded all packages."
  else
    echo "❌ Error occurred during upgrade!"
    echo "Error details:"
    echo "$output"
  fi
else
  # Extract only the package names if the "ALL" option was not selected
  selected_pkgs=$(echo "$selected_option" | grep -v "(ALL) Upgrade all packages")

  if [ -z "$selected_pkgs" ]; then
    echo "❌ No packages selected. Exiting."
    exit 0
  fi

  echo "Upgrading the following packages:"
  echo "$selected_pkgs"

  # Run paru upgrade and capture output and exit status
  output=$(paru -S $selected_pkgs 2>&1)
  status=$?

  echo
  if [ $status -eq 0 ]; then
    echo "✅ Successfully upgraded selected packages:"
    echo "$selected_pkgs"
  else
    echo "❌ Error occurred during upgrade!"
    echo "Error details:"
    echo "$output"
    echo
    echo "Partial upgrade output:"
    echo "$selected_pkgs"
  fi
fi

# Always wait for user input before exiting at the very end
echo
read -n 1 -s -r -p "Press any key to continue..."
echo
