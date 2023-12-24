#!/usr/bin/env bash

debug() {
  if [ "${DEBUG,,}" = "true" ]; then
    # Print debug message to stdout, change color to cyan
    echo -e "\033[0;36mDEBUG: $1\033[0m"
  fi
}

info() {
  # Print info message to stdout, change color to green
  echo -e "\033[0;32mINFO: $1\033[0m"
}

error() {
  # Print error message to stderr, change color to red
  echo -e "\033[0;31mERROR: $1\033[0m" >&2
}

warn() {
  # Print warning message to stderr, change color to yellow
  echo -e "\033[0;33mWARNING: $1\033[0m" >&2
}
