#!/usr/bin/env bash

if [ -n "$ENABLE_NO_CHECK_LIST" ] || [ "${ENABLE_NO_CHECK_LIST,,}" != "true" ]; then
  exit 0
fi

if [ -n "$NO_CHECK_LIST_URL" ]; then
  exit 0
fi

ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
NO_CHECK_LIST_FILE="$ASA_DIR/Binaries/Win64/PlayersJoinNoCheckList.txt"

if [ ! -f "$NO_CHECK_LIST_FILE" ]; then
  exit 0
fi

# curl url and save to file
curl -s -o "$NO_CHECK_LIST_FILE" "$NO_CHECK_LIST_URL" || exit 1
