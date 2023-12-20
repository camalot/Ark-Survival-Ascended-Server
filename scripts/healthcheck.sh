#!/bin/bash

PID_FILE="/usr/games/ark_server.pid"


# Function to check if the server process is running
is_process_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p $pid > /dev/null 2>&1; then
            if [ "${DISPLAY_POK_MONITOR_MESSAGE}" = "TRUE" ]; then
                echo "ARK server process (PID: $pid) is running."
            fi
            return 0
        else
            echo "ARK server process (PID: $pid) is not running."
            return 1
        fi
    else
        echo "PID file not found."
        return 1
    fi
}

is_server_updating() {
    if [ -f "/usr/games/updating.flag" ]; then
        echo "Server is currently updating."
        return 0
    else
        return 1
    fi
}


if is_process_running; then
    if is_server_updating; then
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi
