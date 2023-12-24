#!/usr/bin/env bash
# shellcheck disable=SC1091
source /usr/games/scripts/logger.sh

if [ "${ENABLE_WHITELIST,,}" != "true" ]; then
  debug "Whitelist not enabled, exiting: '${ENABLE_WHITELIST,,}'"
  exit 0
fi

if [[ -z "${WHITELIST_URL// /}" ]]; then
  debug "Whitelist URL not set, exiting: '$WHITELIST_URL'"
  exit 0
fi

ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
WHITELIST_FILE="$ASA_DIR/Binaries/Win64/PlayersExclusiveJoinList.txt"

if [ ! -f "$WHITELIST_FILE" ]; then
  warn "Whitelist file not found, exiting: '$WHITELIST_FILE'"
  exit 0
fi

# curl url and save to file
info "Downloading whitelist from $WHITELIST_URL"
curl -s -o "$WHITELIST_FILE" "$WHITELIST_URL" || exit 1
info "Whitelist downloaded successfully"
