#!/usr/bin/env bash

# Define paths
ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
ARK_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server"
CLUSTER_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ShooterGame"
SAVED_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame/Saved"
CONFIG_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame/Saved/Config"
WINDOWS_SERVER_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame/Saved/Config/WindowsServer"

# Get PUID and PGID from environment variables, or default to 1000
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

echo "PUID: $PUID"
echo "PGID: $PGID"

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

# Function to copy default configuration files if they don't exist
copy_default_configs() {
  mkdir -p "$ASA_DIR" "$ARK_DIR" "$CLUSTER_DIR" "$SAVED_DIR" "$CONFIG_DIR" "$WINDOWS_SERVER_DIR"
  # Copy GameUserSettings.ini if it does not exist
  if [ ! -f "${WINDOWS_SERVER_DIR}/GameUserSettings.ini" ]; then
    cp /usr/games/defaults/GameUserSettings.ini "$WINDOWS_SERVER_DIR"
  fi

  # Copy Game.ini if it does not exist
  if [ ! -f "${WINDOWS_SERVER_DIR}/Game.ini" ]; then
    cp /usr/games/defaults/Game.ini "$WINDOWS_SERVER_DIR"
  fi
}

take_ownership() {
  # there are somethings that need "repair" of ownership if PUID/GUID changed from the default of 1000
  # these things still need to be identified

  # some know issues:
  # - crontab : crontab: your UID isn't in the passwd file.
  # - sudo : sudo: you do not exist in the passwd database
  # - open /usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame/Saved/Config/WindowsServer/GameUserSettings.ini: permission denied

  echo "Taking ownership of files and folders for PUID:GUID $PUID:$PGID"
  sudo groupmod -o -g "$PGID" games
  sudo usermod -o -u "$PUID" -g games games
  for dir in "/usr/games" "/usr/games/.wine" "$ASA_DIR" "$ARK_DIR" "$CLUSTER_DIR" "$SAVED_DIR" "$CONFIG_DIR" "$WINDOWS_SERVER_DIR"; do
    sudo chown -R "$PUID":"$PGID" "$dir"
    sudo chmod -R 755 "$dir"
  done
  echo "Finished taking ownership of files and folders for PUID:GUID $PUID:$PGID"
}

# Call copy_default_configs function
copy_default_configs
take_ownership

# Start monitor_ark_server.sh in the background
/usr/games/scripts/monitor_ark_server.sh &

# Continue with the main application
exec /usr/games/scripts/launch_ASA.sh
