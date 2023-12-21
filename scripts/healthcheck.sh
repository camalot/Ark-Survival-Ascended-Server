#!/bin/bash

PID_FILE="/usr/games/ark_server.pid"

# Function to check if the server process is running
is_process_running() {
  if [ -f "$PID_FILE" ]; then
    local pid
    pid="$(cat "$PID_FILE")"
    if ps -p "$pid" >/dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

is_server_updating() {
  if [ -f "/usr/games/updating.flag" ]; then
    return 0
  else
    return 1
  fi
}

if is_process_running; then
  exit 0
fi

if is_server_updating; then
  exit 0
fi

exit 1
