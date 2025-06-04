#!/bin/bash

count=$(yay -Qu | wc -l)

if [ "$count" -eq 0 ]; then
  message=" "
else
  message=" "
fi

echo "$message"