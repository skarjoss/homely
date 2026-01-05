#!/usr/bin/env bash

cp -i Homely.sample.yaml Homely.yaml

ALIAS_LINE='alias homely="sudo ruby ~/homely/Homelyfile.rb"'
BASHRC="$HOME/.bashrc"
SOURCED=0

if [ "${BASH_SOURCE[0]}" != "$0" ]; then
  SOURCED=1
fi

if [ -f "$BASHRC" ]; then
  if ! grep -Fq "$ALIAS_LINE" "$BASHRC"; then
    printf '\n%s\n' "$ALIAS_LINE" >> "$BASHRC"
    if [ "$SOURCED" -eq 1 ]; then
      source "$BASHRC"
      echo "Alias homely added and loaded from ~/.bashrc"
    else
      echo "Alias homely added to ~/.bashrc. Open a new shell or run: source ~/.bashrc"
    fi
  else
    if [ "$SOURCED" -eq 1 ]; then
      source "$BASHRC"
      echo "Alias homely already present and loaded from ~/.bashrc"
    else
      echo "Alias homely already present in ~/.bashrc"
    fi
  fi
else
  printf '%s\n' "$ALIAS_LINE" > "$BASHRC"
  if [ "$SOURCED" -eq 1 ]; then
    source "$BASHRC"
    echo "Created ~/.bashrc and loaded homely alias"
  else
    echo "Created ~/.bashrc and added homely alias. Open a new shell or run: source ~/.bashrc"
  fi
fi

echo "Homely initialized!"
