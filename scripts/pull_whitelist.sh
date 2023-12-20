#!/usr/bin/env bash

if [ -n "$ENABLE_WHITELIST" ] || [ "${ENABLE_WHITELIST,,}" != "true" ]; then
  echo "Whitelist not enabled, exiting: '$ENABLE_WHITELIST'"
  exit 0
fi

if [ -n "$WHITELIST_URL" ]; then
  echo "Whitelist URL not set, exiting: '$WHITELIST_URL'"
  exit 0
fi

ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
WHITELIST_FILE="$ASA_DIR/Binaries/Win64/PlayersExclusiveJoinList.txt"

if [ ! -f "$WHITELIST_FILE" ]; then
  echo "Whitelist file not found, exiting: '$WHITELIST_FILE'"
  exit 0
fi

# curl url and save to file
echo "Downloading whitelist from $WHITELIST_URL"
curl -s -o "$WHITELIST_FILE" "$WHITELIST_URL" || exit 1
echo "Whitelist downloaded successfully"
cat "$WHITELIST_FILE"
