#!/usr/bin/env bash

if [ -n "$ENABLE_WHITELIST" ] || [ "${ENABLE_WHITELIST,,}" != "true" ]; then
  exit 0
fi

if [ -n "$WHITELIST_URL" ]; then
  exit 0
fi

ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
WHITELIST_FILE="$ASA_DIR/Binaries/Win64/PlayersExclusiveJoinList.txt"

if [ ! -f "$WHITELIST_FILE" ]; then
  exit 0
fi

# curl url and save to file
curl -s -o "$WHITELIST_FILE" "$WHITELIST_URL" || exit 1
