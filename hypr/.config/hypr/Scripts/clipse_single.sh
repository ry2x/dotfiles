#!/usr/bin/env bash

# Find all processes matching kitty and clipse pattern and extract their PIDs
pids=$(ps aux | grep -i "kitty" | grep -i "clipse" | grep -v grep | awk '{print $2}')

# Check if any matching processes were found
if [ -z "$pids" ]; then
    # echo "No clipse processes found running in kitty"
    kitty --title=Clipse clipse
    exit 0
fi

# Kill each found process
for pid in $pids; do
    # echo "Killing process with PID: $pid"
    kill "$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null
done

# echo "All clipse processes terminated"
exit 0
