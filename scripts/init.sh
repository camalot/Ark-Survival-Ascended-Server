#!/bin/bash

# Define paths
ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
ARK_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server"
CLUSTER_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ShooterGame"
SAVED_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame/Saved"
CONFIG_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame/Saved/Config"
WINDOWS_SERVER_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame/Saved/Config/WindowsServer"

# Get PUID and PGID from environment variables, or default to 1001
PUID="${PUID:-1001}"
PGID="${PGID:-1001}"

# Function to check if vm.max_map_count is set to a sufficient value
check_vm_max_map_count() {
  local required_map_count
  required_map_count=262144
  local current_map_count
  current_map_count=$(cat /proc/sys/vm/max_map_count)

  if [ "$current_map_count" -lt "$required_map_count" ]; then
    echo "ERROR: The vm.max_map_count on the host system is too low ($current_map_count) and needs to be at least $required_map_count."
    echo "To fix this issue temporarily (until the next reboot), run the following command on your Docker host:"
    echo "sudo sysctl -w vm.max_map_count=$required_map_count"
    echo "For a permanent fix, add the following line to /etc/sysctl.conf on your Docker host and then run 'sysctl -p':"
    echo "vm.max_map_count=$required_map_count"
    echo ""
    echo "sudo -s echo "vm.max_map_count=$required_map_count" >> /etc/sysctl.conf && sudo sysctl -p"
    echo ""
    echo "After making this change, please restart the Docker container."
    exit 1
  fi
}

# Check vm.max_map_count before proceeding
check_vm_max_map_count

# Fix games user uid & gid then re set the owner of wine folders
groupmod -o -g "$PGID" games
usermod -o -u "$PUID" -g games games
chown -R games:games "$WINEPREFIX"

# Create directories if they do not exist and set permissions
for DIR in "$ASA_DIR" "$ARK_DIR" "$CLUSTER_DIR" "$SAVED_DIR" "$CONFIG_DIR" "$WINDOWS_SERVER_DIR"; do
  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
  fi
  chown -R "$PUID":"$PGID" "$DIR"
  chmod -R 755 "$DIR"
done

# Function to copy default configuration files if they don't exist
copy_default_configs() {
  # Copy GameUserSettings.ini if it does not exist
  if [ ! -f "${WINDOWS_SERVER_DIR}/GameUserSettings.ini" ]; then
    cp /usr/games/defaults/GameUserSettings.ini "$WINDOWS_SERVER_DIR"
    chown "$PUID":"$PGID" "${WINDOWS_SERVER_DIR}/GameUserSettings.ini"
    chmod 755 "${WINDOWS_SERVER_DIR}/GameUserSettings.ini"
  fi

  # Copy Game.ini if it does not exist
  if [ ! -f "${WINDOWS_SERVER_DIR}/Game.ini" ]; then
    cp /usr/games/defaults/Game.ini "$WINDOWS_SERVER_DIR"
    chown "$PUID":"$PGID" "${WINDOWS_SERVER_DIR}/Game.ini"
    chmod 755 "${WINDOWS_SERVER_DIR}/Game.ini"
  fi
}

# Call copy_default_configs function
copy_default_configs

# Start monitor_ark_server.sh in the background
/usr/games/scripts/monitor_ark_server.sh &

# Continue with the main application
exec /usr/games/scripts/launch_ASA.sh
