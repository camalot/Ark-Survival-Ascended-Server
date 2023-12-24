#!/usr/bin/env bash

debug() {
  if [ "${DEBUG,,}" = "true" ]; then
    local message
    message="$*"
    # if message is empty, don't print anything
    if [ -z "$message" ]; then
      return
    fi

    # Print debug message to stdout, change color to cyan
    echo -e "\033[0;36m[DEBUG] $message\033[0m"
  fi
}

info() {
  local message
  message="$*"
  # if message is empty, don't print anything
  if [ -z "$message" ]; then
    return
  fi
  # Print info message to stdout, change color to green
  echo -e "\033[0;32m[INFO] $message\033[0m"
}

error() {
  local message
  message="$*"
  # if message is empty, don't print anything
  if [ -z "$message" ]; then
    return
  fi
  # Print error message to stderr, change color to red
  echo -e "\033[0;31m[ERROR] $message\033[0m" >&2
}

warn() {
  local message
  message="$*"
  # if message is empty, don't print anything
  if [ -z "$message" ]; then
    return
  fi
  # Print warning message to stderr, change color to yellow
  echo -e "\033[0;33m[WARNING] $message\033[0m" >&2
}
