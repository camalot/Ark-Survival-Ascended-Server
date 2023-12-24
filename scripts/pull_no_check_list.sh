#!/usr/bin/env bash
source /usr/games/scripts/logger.sh

if [ "${ENABLE_NO_CHECK_LIST,,}" != "true" ]; then
  debug "No check list not enabled, exiting: '${ENABLE_NO_CHECK_LIST,,}'"
  exit 0
fi
if [[ -z "${NO_CHECK_LIST_URL// /}" ]]; then
  echo "No check list URL not set, exiting: '$NO_CHECK_LIST_URL'"
  exit 0
fi

ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
NO_CHECK_LIST_FILE="$ASA_DIR/Binaries/Win64/PlayersJoinNoCheckList.txt"

if [ ! -f "$NO_CHECK_LIST_FILE" ]; then
  warn "No check list file not found, exiting: '$NO_CHECK_LIST_FILE'"
  exit 0
fi

# curl url and save to file
info "Downloading no check list from $NO_CHECK_LIST_URL"
curl -s -o "$NO_CHECK_LIST_FILE" "$NO_CHECK_LIST_URL" || exit 1
info "No check list downloaded successfully"
