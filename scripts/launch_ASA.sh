#!/bin/bash

# Initialize environment variables
initialize_variables() {
  export DISPLAY=:0.0
  USERNAME=anonymous
  APPID=2430930
  ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
  CLUSTER_DIR="$ASA_DIR/Cluster"
  CLUSTER_DIR_OVERRIDE="$CLUSTER_DIR"
  # SOURCE_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/"
  # DEST_DIR="$ASA_DIR/Binaries/Win64/"
  PERSISTENT_ACF_FILE="$ASA_DIR/appmanifest_$APPID.acf"

  # Clean and format MOD_IDS if it's set
  if [ -n "$MOD_IDS" ]; then
    # Remove all quotes and extra spaces
    MOD_IDS=$(echo "$MOD_IDS" | tr -d '"' | tr -d "'" | tr -d ' ')
  fi

  RESET_GAME_SETTINGS="${RESET_GAME_SETTINGS:-"FALSE"}"
  if [ "${RESET_GAME_SETTINGS,,}" = "true" ]; then
    # copy the default game.ini and gameusersettings.ini files from /usr/games/defaults/
    echo "Resetting game settings to defaults"
    cp -f /usr/games/defaults/game.ini "$ASA_DIR/Saved/Config/WindowsServer/Game.ini"
    cp -f /usr/games/defaults/gameusersettings.ini "$ASA_DIR/Saved/Config/WindowsServer/GameUserSettings.ini"
  fi

  # Set server admin password from password file if set
  SERVER_ADMIN_PASSWORD_FILE="${SERVER_ADMIN_PASSWORD_FILE:-""}"
  if [ -f "$SERVER_ADMIN_PASSWORD_FILE" ]; then
    SERVER_ADMIN_PASSWORD=$(cat "$SERVER_ADMIN_PASSWORD_FILE")
  fi

  # Set server admin password from environment variable if set
  # this will take precedence over the password file
  SERVER_ADMIN_PASSWORD="${SERVER_ADMIN_PASSWORD:-""}"

  # if the password is not set, generate a random one
  if [ -z "$SERVER_ADMIN_PASSWORD" ]; then
    SERVER_ADMIN_PASSWORD=$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 20 | head -n 1)
    echo "Generated server admin password: $ASA_SERVER_ADMIN_PASSWORD"
  fi

  # Set Server password from password file if set
  SERVER_PASSWORD_FILE="${SERVER_PASSWORD_FILE:-""}"
  if [ -f "$SERVER_PASSWORD_FILE" ]; then
    SERVER_PASSWORD=$(cat "$SERVER_PASSWORD_FILE")
  fi
  # Set Server password from environment variable if set
  # this will take precedence over the password file
  SERVER_PASSWORD="${SERVER_PASSWORD:-""}"
  # validate the password if it's set
  if [ -n "$SERVER_PASSWORD" ]; then
    if ! [[ "$SERVER_PASSWORD" =~ ^[a-zA-Z0-9]+$ ]]; then
      echo "ERROR: The server password must contain only numbers or characters."
      exit 1
    fi
  fi

  # Set the session name
  SESSION_NAME="${SESSION_NAME:-"ASA Server"}"
  CLUSTER_ID="${CLUSTER_ID:-"cluster"}"

  QUERY_PORT="${QUERY_PORT:-27015}"
  is_numeric "QUERY_PORT"
  ASA_PORT="${ASA_PORT:-7777}"
  is_numeric "ASA_PORT"
  RCON_ENABLED="$(get_bool "RCON_ENABLED" "FALSE")"
  RCON_PORT="${RCON_PORT:-27020}"
  is_numeric "RCON_PORT"
  RCON_SERVER_GAME_LOG_BUFFER="${RCON_SERVER_GAME_LOG_BUFFER:-""}"
  is_numeric "RCON_SERVER_GAME_LOG_BUFFER"
  AUTO_SAVE_PERIOD_MINUTES="${AUTO_SAVE_PERIOD_MINUTES:-""}"
  is_numeric "AUTO_SAVE_PERIOD_MINUTES"
  IMPLANT_SUICIDE_CD="${IMPLANT_SUICIDE_CD,-""}"
  is_numeric "IMPLANT_SUICIDE_CD"
  DIFFICULTY_OFFSET="${DIFFICULTY_OFFSET:-""}"
  is_numeric "DIFFICULTY_OFFSET" "0.01" ""
  OVERRIDE_OFFICIAL_DIFFICULTY="${OVERRIDE_OFFICIAL_DIFFICULTY:-""}"
  is_numeric "OVERRIDE_OFFICIAL_DIFFICULTY"
  SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL="${SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL:-""}"
  is_numeric "SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL"
  ITEM_STACK_SIZE_MULTIPLIER="${ITEM_STACK_SIZE_MULTIPLIER:-""}"
  is_numeric "ITEM_STACK_SIZE_MULTIPLIER"
  STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER="${STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER:-""}"
  is_numeric "STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER"
  TRIBE_NAME_CHANGE_COOLDOWN="${TRIBE_NAME_CHANGE_COOLDOWN:-""}"
  is_numeric "TRIBE_NAME_CHANGE_COOLDOWN"

  ENABLE_PVE="$(get_bool "ENABLE_PVE" "")"
  ALLOW_HITMARKERS="$(get_bool "ALLOW_HITMARKERS" "")"
  ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS="$(get_bool "ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS" "")"
  SHOW_MAP_PLAYER_LOCATION="$(get_bool "SHOW_MAP_PLAYER_LOCATION" "")"
  SERVER_CROSSHAIR="$(get_bool "SERVER_CROSSHAIR" "")"
  DISABLE_DINO_DECAY_PVE="$(get_bool "DISABLE_DINO_DECAY_PVE" "")"
  ALWAYS_ALLOW_STRUCTURE_PICKUP="$(get_bool "ALWAYS_ALLOW_STRUCTURE_PICKUP" "")"
  ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES="$(get_bool "ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES" "")"
  ALLOW_FLYER_CARRY_PVE="$(get_bool "ALLOW_FLYER_CARRY_PVE" "")"
  PREVENT_DOWNLOAD_SURVIVORS="$(get_bool "PREVENT_DOWNLOAD_SURVIVORS" "")"
  PREVENT_DOWNLOAD_ITEMS="$(get_bool "PREVENT_DOWNLOAD_ITEMS" "")"
  PREVENT_DOWNLOAD_DINOS="$(get_bool "PREVENT_DOWNLOAD_DINOS" "")"
  PREVENT_UPLOAD_SURVIVORS="$(get_bool "PREVENT_UPLOAD_SURVIVORS" "")"
  PREVENT_UPLOAD_ITEMS="$(get_bool "PREVENT_UPLOAD_ITEMS" "")"
  PREVENT_UPLOAD_DINOS="$(get_bool "PREVENT_UPLOAD_DINOS" "")"

  # Admins / Whitelisting / Blacklisting
  ENABLE_WHITELIST="$(get_bool "ENABLE_WHITELIST" "")"
  WHITELIST_PULL_INTERVAL="${WHITELIST_PULL_INTERVAL:-"5"}"
  is_numeric "WHITELIST_PULL_INTERVAL"
  WHITELIST_URL="${WHITELIST_URL:-""}"
  is_url "WHITELIST_URL"
  USE_EXCLUSIVE_LIST="$ENABLE_WHITELIST"
  ENABLE_NO_CHECK_LIST="$(get_bool "ENABLE_NO_CHECK_LIST" "")"
  NO_CHECK_LIST_PULL_INTERVAL="${NO_CHECK_LIST_PULL_INTERVAL:-"5"}"
  is_numeric "NO_CHECK_LIST_PULL_INTERVAL"
  NO_CHECK_LIST_URL="${NO_CHECK_LIST_URL:-""}"
  is_url "NO_CHECK_LIST_URL"
  ALLOW_CHEATERS_URL="${ALLOW_CHEATERS_URL:-""}"
  is_url "ALLOW_CHEATERS_URL"
  ALLOW_CHEATERS_UPDATE_INTERVAL="${ALLOW_CHEATERS_UPDATE_INTERVAL:-""}"
  is_numeric "ALLOW_CHEATERS_UPDATE_INTERVAL"
  BAN_LIST_URL="${BAN_LIST_URL:-""}"
  is_url "BAN_LIST_URL"

  STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT="${STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT:-""}"
  is_numeric "STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT"
  STRUCTURE_PICKUP_HOLD_DURATION="${STRUCTURE_PICKUP_HOLD_DURATION:-""}"
  is_numeric "STRUCTURE_PICKUP_HOLD_DURATION"
  MAX_STRUCTURES_IN_RANGE="${MAX_STRUCTURES_IN_RANGE:-""}"
  is_numeric "MAX_STRUCTURES_IN_RANGE"
  START_TIME_HOUR="${START_TIME_HOUR:-""}"
  is_numeric "START_TIME_HOUR"
  KICK_IDLE_PLAYERS_PERIOD="${KICK_IDLE_PLAYERS_PERIOD:-""}"
  is_numeric "KICK_IDLE_PLAYERS_PERIOD"
  PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER="${PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER:-""}"
  is_numeric "PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER"
  PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER="${PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER:-""}"
  is_numeric "PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER"
  DINO_DAMAGE_MULTIPLIER="${DINO_DAMAGE_MULTIPLIER:-""}"
  is_numeric "DINO_DAMAGE_MULTIPLIER"
  PVE_DINO_DECAY_PERIOD_MULTIPLIER="${PVE_DINO_DECAY_PERIOD_MULTIPLIER:-""}"
  is_numeric "PVE_DINO_DECAY_PERIOD_MULTIPLIER"
  PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER="${PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER:-""}"
  is_numeric "PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER"
  RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER="${RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER:-""}"
  is_numeric "RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER"
  XP_MULTIPLIER="${XP_MULTIPLIER:-""}"
  is_numeric "XP_MULTIPLIER"
  TAMING_SPEED_MULTIPLIER="${TAMING_SPEED_MULTIPLIER:-""}"
  is_numeric "TAMING_SPEED_MULTIPLIER"
  HARVEST_AMOUNT_MULTIPLIER="${HARVEST_AMOUNT_MULTIPLIER:-""}"
  is_numeric "HARVEST_AMOUNT_MULTIPLIER"
  STRUCTURE_RESISTANCE_MULTIPLIER="${STRUCTURE_RESISTANCE_MULTIPLIER:-""}"
  is_numeric "STRUCTURE_RESISTANCE_MULTIPLIER"
  OXYGEN_SWIM_SPEED_STAT_MULTIPLIER="${OXYGEN_SWIM_SPEED_STAT_MULTIPLIER:-""}"
  is_numeric "OXYGEN_SWIM_SPEED_STAT_MULTIPLIER"
  BABY_IMPRINTING_STAT_SCALE_MULTIPLIER="${BABY_IMPRINTING_STAT_SCALE_MULTIPLIER:-""}"
  is_numeric "BABY_IMPRINTING_STAT_SCALE_MULTIPLIER"
  BABY_CUDDLE_INTERVAL_MULTIPLIER="${BABY_CUDDLE_INTERVAL_MULTIPLIER:-""}"
  is_numeric "BABY_CUDDLE_INTERVAL_MULTIPLIER"
  BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER="${BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER:-""}"
  is_numeric "BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER"
  BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER="${BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER:-""}"
  is_numeric "BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER"
  GLOBAL_SPOILING_TIME_MULTIPLIER="${GLOBAL_SPOILING_TIME_MULTIPLIER:-""}"
  is_numeric "GLOBAL_SPOILING_TIME_MULTIPLIER"
  GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER="${GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER:-""}"
  is_numeric "GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER"
  GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER="${GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER:-""}"
  is_numeric "GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER"
  PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER="${PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER:-""}"
  is_numeric "PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER"
  CROP_GROWTH_SPEED_MULTIPLIER="${CROP_GROWTH_SPEED_MULTIPLIER:-""}"
  is_numeric "CROP_GROWTH_SPEED_MULTIPLIER"
  LAY_EGG_INTERVAL_MULTIPLIER="${LAY_EGG_INTERVAL_MULTIPLIER:-""}"
  is_numeric "LAY_EGG_INTERVAL_MULTIPLIER"
  POOP_INTERVAL_MULTIPLIER="${POOP_INTERVAL_MULTIPLIER:-""}"
  is_numeric "POOP_INTERVAL_MULTIPLIER"
  EGG_HATCH_SPEED_MULTIPLIER="${EGG_HATCH_SPEED_MULTIPLIER:-""}"
  is_numeric "EGG_HATCH_SPEED_MULTIPLIER"
  CROP_DECAY_SPEED_MULTIPLIER="${CROP_DECAY_SPEED_MULTIPLIER:-""}"
  is_numeric "CROP_DECAY_SPEED_MULTIPLIER"
  MATING_INTERVAL_MULTIPLIER="${MATING_INTERVAL_MULTIPLIER:-""}"
  is_numeric "MATING_INTERVAL_MULTIPLIER"
  BABY_MATURE_SPEED_MULTIPLIER="${BABY_MATURE_SPEED_MULTIPLIER:-""}"
  is_numeric "BABY_MATURE_SPEED_MULTIPLIER"
  BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER="${BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER:-""}"
  is_numeric "BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER"
  DINO_HARVESTING_DAMAGE_MULTIPLIER="${DINO_HARVESTING_DAMAGE_MULTIPLIER:-""}"
  is_numeric "DINO_HARVESTING_DAMAGE_MULTIPLIER"
  PLAYER_HARVESTING_DAMAGE_MULTIPLIER="${PLAYER_HARVESTING_DAMAGE_MULTIPLIER:-""}"
  is_numeric "PLAYER_HARVESTING_DAMAGE_MULTIPLIER"
  KILL_XP_MULTIPLIER="${KILL_XP_MULTIPLIER:-""}"
  is_numeric "KILL_XP_MULTIPLIER"
  HARVEST_XP_MULTIPLIER="${HARVEST_XP_MULTIPLIER:-""}"
  is_numeric "HARVEST_XP_MULTIPLIER"
  CRAFT_XP_MULTIPLIER="${CRAFT_XP_MULTIPLIER:-""}"
  is_numeric "CRAFT_XP_MULTIPLIER"
  GENERIC_XP_MULTIPLIER="${GENERIC_XP_MULTIPLIER:-""}"
  is_numeric "GENERIC_XP_MULTIPLIER"
  SPECIAL_XP_MULTIPLIER="${SPECIAL_XP_MULTIPLIER:-""}"
  is_numeric "SPECIAL_XP_MULTIPLIER"
  MAX_TAMED_DINOS="${MAX_TAMED_DINOS:-""}"
  is_numeric "MAX_TAMED_DINOS"

  ALLOW_THIRD_PERSON_VIEW="$(get_bool "ALLOW_THIRD_PERSON_VIEW" "TRUE")"
  ENABLE_MOTD="$(get_bool "ENABLE_MOTD" "FALSE")"
}

is_url() {
  local var_name
  var_name="$1"

  # validate that the value is a URL
  if [ -n "$var_name" ]; then
    local value="${!var_name}"
    if [ -n "$value" ]; then
      if ! [[ "$value" =~ ^http:// ]]; then
        echo "ERROR: The $var_name must be a valid URL. It must start with http://; https:// is not supported."
        exit 1
      fi
    fi
  fi
}

get_bool() {
  local var_name
  var_name="$1"
  local default_value
  default_value="$2"

  if [ -n "$var_name" ]; then
    local value="${!var_name,,-"${default_value,,}"}"
    if [ -n "$value" ]; then
      if [ "$value" = "true" ] || [ "$value" = "yes" ] || [ "$value" = "1" ]; then
        echo "True"
      elif [ "$value" = "false" ] || [ "$value" = "no" ] || [ "$value" = "0" ]; then
        echo "False"
      else
        echo ""
      fi
    fi
  fi
}

is_numeric() {
  local var_name
  var_name="$1"
  local min
  min=""
  local max
  max=""

  # validate that the value is a number
  if [ -n "$var_name" ]; then
    local value;
    value="${!var_name}"
    if [ -n "$value" ]; then
      if ! [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo "ERROR: The $var_name must be a number."
        exit 1
      fi
    fi
    if [ -n "$min" ]; then
      if (( $(echo "$value < $min" | bc -l) )); then
        echo "ERROR: The $var_name must be greater than or equal to $min."
        exit 1
      fi
    fi
    if [ -n "$max" ]; then
      if (( $(echo "$value > $max" | bc -l) )); then
        echo "ERROR: The $var_name must be less than or equal to $max."
        exit 1
      fi
    fi
  fi
}


update_ini_settings() {
  local gus_ini
  gus_ini="$ASA_DIR/Saved/Config/WindowsServer/GameUserSettings.ini"
  local game_ini
  game_ini="$ASA_DIR/Saved/Config/WindowsServer/Game.ini"

  # [ServerSettings]
  update_ini_setting "$gus_ini" "ServerSettings" "ServerAdminPassword" "$SERVER_ADMIN_PASSWORD"
  update_ini_setting "$gus_ini" "ServerSettings" "ServerPassword" "$SERVER_PASSWORD"
  update_ini_setting "$gus_ini" "ServerSettings" "DifficultyOffset" "$DIFFICULTY_OFFSET"
  update_ini_setting "$gus_ini" "ServerSettings" "serverPVE" "$ENABLE_PVE"
  update_ini_setting "$gus_ini" "ServerSettings" "DinoDamageMultiplier" "$DINO_DAMAGE_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "XPMultiplier" "$XP_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "TamingSpeedMultiplier" "$TAMING_SPEED_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "HarvestAmountMultiplier" "$HARVEST_AMOUNT_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "StructureResistanceMultiplier" "$STRUCTURE_RESISTANCE_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "MaxTamedDinos" "$MAX_TAMED_DINOS"
  update_ini_setting "$gus_ini" "ServerSettings" "RCONPort" "$RCON_PORT"
  update_ini_setting "$gus_ini" "ServerSettings" "RCONEnabled" "$RCON_ENABLED"
  update_ini_setting_quote "$gus_ini" "ServerSettings" "AllowedCheatersURL" "$ALLOW_CHEATERS_URL"
  update_ini_setting "$gus_ini" "ServerSettings" "AllowedCheatersUpdateInterval" "$ALLOW_CHEATERS_UPDATE_INTERVAL"
  update_ini_setting_quote "$gus_ini" "ServerSettings" "BanListURL" "$BAN_LIST_URL"
  update_ini_setting "$gus_ini" "ServerSettings" "AllowThirdPersonPlayer" "$ALLOW_THIRD_PERSON_VIEW"
  update_ini_setting "$gus_ini" "ServerSettings" "UseExclusiveList" "$USE_EXCLUSIVE_LIST"
  update_ini_setting "$gus_ini" "ServerSettings" "OxygenSwimSpeedStatMultiplier" "$OXYGEN_SWIM_SPEED_STAT_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "ShowMapPlayerLocation" "$SHOW_MAP_PLAYER_LOCATION"
  update_ini_setting "$gus_ini" "ServerSettings" "ServerCrosshair" "$SERVER_CROSSHAIR"
  update_ini_setting "$gus_ini" "ServerSettings" "TheMaxStructuresInRange" "$MAX_STRUCTURES_IN_RANGE"
  update_ini_setting "$gus_ini" "ServerSettings" "StartTimeHour" "$START_TIME_HOUR"
  update_ini_setting "$gus_ini" "ServerSettings" "OverrideOfficialDifficulty" "$OVERRIDE_OFFICIAL_DIFFICULTY"
  update_ini_setting "$gus_ini" "ServerSettings" "ServerAutoForceRespawnWildDinosInterval" "$SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL"
  update_ini_setting "$gus_ini" "ServerSettings" "StructurePreventResourceRadiusMultiplier" "$STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "TribeNameChangeCooldown" "$TRIBE_NAME_CHANGE_COOLDOWN"
  update_ini_setting "$gus_ini" "ServerSettings" "PlatformSaddleBuildAreaBoundsMultiplier" "$PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "AlwaysAllowStructurePickup" "$ALWAYS_ALLOW_STRUCTURE_PICKUP"
  update_ini_setting "$gus_ini" "ServerSettings" "StructurePickupTimeAfterPlacement" "$STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT"
  update_ini_setting "$gus_ini" "ServerSettings" "StructurePickupHoldDuration" "$STRUCTURE_PICKUP_HOLD_DURATION"
  update_ini_setting "$gus_ini" "ServerSettings" "AllowHideDamageSourceFromLogs" "$ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS"
  update_ini_setting "$gus_ini" "ServerSettings" "DisableDinoDecayPvE" "$DISABLE_DINO_DECAY_PVE"
  update_ini_setting "$gus_ini" "ServerSettings" "PvEDinoDecayPeriodMultiplier" "$PVE_DINO_DECAY_PERIOD_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "PvEStructureDecayPeriodMultiplier" "$PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "KickIdlePlayersPeriod" "$KICK_IDLE_PLAYERS_PERIOD"
  update_ini_setting "$gus_ini" "ServerSettings" "PerPlatformMaxStructuresMultiplier" "$PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "RaidDinoCharacterFoodDrainMultiplier" "$RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "ItemStackSizeMultiplier" "$ITEM_STACK_SIZE_MULTIPLIER"
  update_ini_setting "$gus_ini" "ServerSettings" "AutoSavePeriodMinutes" "$AUTO_SAVE_PERIOD_MINUTES"
  update_ini_setting "$gus_ini" "ServerSettings" "RCONServerGameLogBuffer" "$RCON_SERVER_GAME_LOG_BUFFER"
  update_ini_setting "$gus_ini" "ServerSettings" "ImplantSuicideCD" "$IMPLANT_SUICIDE_CD"
  update_ini_setting "$gus_ini" "ServerSettings" "AllowHitMarkers" "$ALLOW_HITMARKERS"
  update_ini_setting "$gus_ini" "ServerSettings" "AllowCrateSpawnsOnTopOfStructures" "$ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES"
  update_ini_setting "$gus_ini" "ServerSettings" "AllowFlyerCarryPvE" "$ALLOW_FLYER_CARRY_PVE"

  # [SessionSettings]
  update_ini_setting "$gus_ini" "SessionSettings" "SessionName" "$SESSION_NAME"
  update_ini_setting "$gus_ini" "SessionSettings" "QueryPort" "$QUERY_PORT"

  # [/Script/Engine.GameSession]
  update_ini_setting "$gus_ini" "/Script/Engine.GameSession" "MaxPlayers" "$MAX_PLAYERS"

  # [/Script/ShooterGame.ShooterGameUserSettings]
  update_ini_setting "$gus_ini" "/Script/ShooterGame.ShooterGameUserSettings" "PreventDownloadSurvivors" "$PREVENT_DOWNLOAD_SURVIVORS"
  update_ini_setting "$gus_ini" "/Script/ShooterGame.ShooterGameUserSettings" "PreventDownloadItems" "$PREVENT_DOWNLOAD_ITEMS"
  update_ini_setting "$gus_ini" "/Script/ShooterGame.ShooterGameUserSettings" "PreventDownloadDinos" "$PREVENT_DOWNLOAD_DINOS"
  update_ini_setting "$gus_ini" "/Script/ShooterGame.ShooterGameUserSettings" "PreventDownloadSurvivors" "$PREVENT_UPLOAD_SURVIVORS"
  update_ini_setting "$gus_ini" "/Script/ShooterGame.ShooterGameUserSettings" "PreventUploadItems" "$PREVENT_UPLOAD_ITEMS"
  update_ini_setting "$gus_ini" "/Script/ShooterGame.ShooterGameUserSettings" "PreventUploadDinos" "$PREVENT_UPLOAD_DINOS"


  # Check if the file exists
  if [ -f "$gus_ini" ]; then
    # Remove existing [MessageOfTheDay] section
    sed -i '/^\[MessageOfTheDay\]/,/^$/d' "$gus_ini"
    # Handle MOTD based on ENABLE_MOTD value
    if [ "${ENABLE_MOTD,,}" = "true" ]; then
      # Prepare MOTD by escaping newline characters
      local escaped_motd;
      escaped_motd=$(echo "$MOTD" | sed 's/\\n/\\\\n/g') # shellcheck disable=SC2001
      update_ini_setting "$gus_ini" "MessageOfTheDay" "Message" "$escaped_motd"
      update_ini_setting "$gus_ini" "MessageOfTheDay" "Duration" "$MOTD_DURATION"
    else
      update_ini_setting "$gus_ini" "MessageOfTheDay" "Message" ""
      update_ini_setting "$gus_ini" "MessageOfTheDay" "Duration" ""
    fi
  else
    echo "$gus_ini not found."
  fi


  # [/Script/ShooterGame.ShooterGameMode]
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "BabyImprintingStatScaleMultiplier" "$BABY_IMPRINTING_STAT_SCALE_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "BabyCuddleIntervalMultiplier" "$BABY_CUDDLE_INTERVAL_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "BabyCuddleGracePeriodMultiplier" "$BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "BabyCuddleLoseImprintQualitySpeedMultiplier" "$BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "GlobalSpoilingTimeMultiplier" "$GLOBAL_SPOILING_TIME_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "GlobalItemDecompositionTimeMultiplier" "$GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "GlobalCorpseDecompositionTimeMultiplier" "$GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "PvPZoneStructureDamageMultiplier" "$PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "CropGrowthSpeedMultiplier" "$CROP_GROWTH_SPEED_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "LayEggIntervalMultiplier" "$LAY_EGG_INTERVAL_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "PoopIntervalMultiplier" "$POOP_INTERVAL_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "EggHatchSpeedMultiplier" "$EGG_HATCH_SPEED_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "CropDecaySpeedMultiplier" "$CROP_DECAY_SPEED_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "MatingIntervalMultiplier" "$MATING_INTERVAL_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "BabyMatureSpeedMultiplier" "$BABY_MATURE_SPEED_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "BabyFoodConsumptionSpeedMultiplier" "$BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "DinoHarvestingDamageMultiplier" "$DINO_HARVESTING_DAMAGE_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "PlayerHarvestingDamageMultiplier" "$PLAYER_HARVESTING_DAMAGE_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "KillXPMultiplier" "$KILL_XP_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "HarvestXPMultiplier" "$HARVEST_XP_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "CraftXPMultiplier" "$CRAFT_XP_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "GenericXPMultiplier" "$GENERIC_XP_MULTIPLIER"
  update_ini_setting "$game_ini" "/Script/ShooterGame.ShooterGameMode" "SpecialXPMultiplier" "$SPECIAL_XP_MULTIPLIER"

}

update_ini_setting_quote() {
  local ini_file
  ini_file="$1"
  local section
  section="$2"
  local setting
  setting="$3"
  local value
  value="$4"

  # Check if the file exists
  if [ -f "$ini_file" ]; then
    if [ -n "$value" ]; then
      echo "Updating [$section] $setting=\"$value\" in $ini_file"
      ini-file set --section "$section" --key "$setting" --value "$value" "$ini_file"
      echo "Quoting [$section] $setting=\"$value\" in $ini_file"
      sed -i "s<${setting}=.*<${setting}=\"${value}\"<g" "$ini_file"
    else
      echo "$ini_file not found."
    fi
  fi
}


update_ini_setting() {
  local ini_file
  ini_file="$1"
  local section
  section="$2"
  local setting
  setting="$3"
  local value
  value="$4"

  # Check if the file exists
  if [ -f "$ini_file" ]; then
    if [ -n "$value" ]; then
      echo "Updating [$section] $setting=$value in $ini_file"
      ini-file set --section "$section" --key "$setting" --value "$value" "$ini_file"
    fi
  else
    echo "$ini_file not found."
  fi
}

# Check if the Cluster directory exists
cluster_dir() {
  if [ -d "$CLUSTER_DIR" ]; then
    echo "Cluster directory already exists. Skipping folder creation."
  else
    echo "Creating Cluster Folder..."
    mkdir -p "$CLUSTER_DIR"
  fi
}

# Determine the map path based on environment variable
determine_map_path() {
  case "$MAP_NAME" in
    "TheIsland")
      MAP_PATH="TheIsland_WP"
      ;;
    "ScorchedEarth")
      MAP_PATH="ScorchedEarth_WP"
      ;;
    *)
    # Check if the custom MAP_NAME already ends with '_WP'
    if [[ "$MAP_NAME" == *"_WP" ]]; then
      MAP_PATH="$MAP_NAME"
    else
      MAP_PATH="${MAP_NAME}_WP"
    fi
    echo "Using map: $MAP_PATH"
    ;;
  esac
}

# Get the build ID from the appmanifest.acf file
get_build_id_from_acf() {
  if [[ -f "$PERSISTENT_ACF_FILE" ]]; then
    local build_id
    build_id=$(grep -E "^\s+\"buildid\"\s+" "$PERSISTENT_ACF_FILE" | grep -o '[[:digit:]]*')
    echo "$build_id"
  else
    echo ""
  fi
}

# Get the current build ID from SteamCMD API
get_current_build_id() {
  local build_id
  build_id=$(curl -sX GET "https://api.steamcmd.net/v1/info/$APPID" | jq -r ".data.\"$APPID\".depots.branches.public.buildid")
  echo "$build_id"
}

install_server() {
  local saved_build_id
  saved_build_id=$(get_build_id_from_acf)
  local current_build_id
  current_build_id=$(get_current_build_id)

  if [ -z "$saved_build_id" ] || [ "$saved_build_id" != "$current_build_id" ]; then
    echo "New server installation or update required..."
    touch /usr/games/updating.flag
    echo "Current build ID is $current_build_id, initiating installation/update..."
    sudo -u games wine "$PROGRAM_FILES/Steam/steamcmd.exe" +login "$USERNAME" +force_install_dir "$ASA_DIR" +app_update "$APPID" +@sSteamCmdForcePlatformType windows +quit
    # Copy the acf file to the persistent volume
    cp "/usr/games/.wine/drive_c/POK/Steam/steamapps/appmanifest_$APPID.acf" "$PERSISTENT_ACF_FILE"
    echo "Installation or update completed successfully."
    rm -f /usr/games/updating.flag
  else
    echo "No update required. Server build ID $saved_build_id is up to date."
  fi
}

update_server() {
  local saved_build_id
  saved_build_id=$(get_build_id_from_acf)
  local current_build_id
  current_build_id=$(get_current_build_id)

  if [ -z "$saved_build_id" ] || [ "$saved_build_id" != "$current_build_id" ]; then
    echo "Server update detected..."
    touch /usr/games/updating.flag
    echo "Updating server to build ID $current_build_id from $saved_build_id..."
    sudo -u games wine "$PROGRAM_FILES/Steam/steamcmd.exe" +login "$USERNAME" +force_install_dir "$ASA_DIR" +app_update "$APPID" +@sSteamCmdForcePlatformType windows +quit
    # Copy the acf file to the persistent volume
    cp "/usr/games/.wine/drive_c/POK/Steam/steamapps/appmanifest_$APPID.acf" "$PERSISTENT_ACF_FILE"
    echo "Server update completed successfully."
    rm -f /usr/games/updating.flag
  else
    echo "Server is already running the latest build ID $saved_build_id. Proceeding to start the server."
  fi
}

# Function to check if save is complete
save_complete_check() {
  local log_file
  log_file="$ASA_DIR/Saved/Logs/ShooterGame.log"
  # Check if the "World Save Complete" message is in the log file
  if tail -n 10 "$log_file" | grep -q "World Save Complete"; then
    echo "Save operation completed."
    return 0
  else
    return 1
  fi
}

# Function to handle graceful shutdown
shutdown_handler() {
  echo "Initiating graceful shutdown..."
  echo "Notifying players about the immediate shutdown and save..."
  rcon-cli --host "localhost" --port "$RCON_PORT" --password "$SERVER_ADMIN_PASSWORD" "ServerChat Immediate server shutdown initiated. Saving the world..."

  echo "Saving the world..."
  rcon-cli --host "localhost" --port "$RCON_PORT" --password "$SERVER_ADMIN_PASSWORD" "saveworld"

  # Initial delay to avoid catching a previous save message
  echo "Waiting a few seconds before checking for save completion..."
  sleep 5  # Initial delay, can be adjusted based on server behavior

  # Wait for save to complete
  echo "Waiting for save to complete..."
  while ! save_complete_check; do
    sleep 5  # Check every 5 seconds
  done

  echo "World saved. Shutting down the server..."

  exit 0
}

# Trap SIGTERM
trap 'shutdown_handler' SIGTERM

# Find the last "Log file open" entry and return the line number
find_new_log_entries() {
  LOG_FILE="$ASA_DIR/Saved/Logs/ShooterGame.log"
  LAST_ENTRY_LINE=$(grep -n "Log file open" "$LOG_FILE" | tail -1 | cut -d: -f1)
  echo $((LAST_ENTRY_LINE + 1)) # Return the line number after the last "Log file open"
}

start_server() {
  # Check if the log file exists and rename it to archive
  local old_log_file;
  old_log_file="$ASA_DIR/Saved/Logs/ShooterGame.log"
  if [ -f "$old_log_file" ]; then
    local timestamp
    timestamp=$(date +%F-%T)
    mv "$old_log_file" "${old_log_file}_$timestamp.log"
  fi

  # Initialize the mods argument to an empty string
  local mods_arg
  mods_arg=""
  local battleye_arg
  battleye_arg=""
  local custom_args
  custom_args=""

  # Check if MOD_IDS is set and not empty
  if [ -n "$MOD_IDS" ]; then
    mods_arg="-mods=${MOD_IDS}"
  fi

  # Set BattlEye flag based on environment variable
  if [ "${BATTLEEYE,,}" = "true" ]; then
    battleye_arg="-UseBattlEye"
  else
    echo "WARNING: BattlEye is disabled."
    battleye_arg="-NoBattlEye"
  fi

  if [ -n "$CUSTOM_SERVER_ARGS" ]; then
    custom_args="$CUSTOM_SERVER_ARGS"
  fi

  # if [ -n "$SERVER_PASSWORD" ]; then
  #   server_password_arg="?ServerPassword=${SERVER_PASSWORD}"
  # fi

  # create a cron job to execute /usr/games/scripts/pull_whitelist.sh every X minutes
  if [ "${ENABLE_WHITELIST,,}" = "true" ]; then
    if [ -z "${WHITELIST_URL// }" ]; then
      echo "ERROR: The WHITELIST_URL must be set when ENABLE_WHITELIST is set to true."
      exit 1
    fi
    if [ -z "${WHITELIST_PULL_INTERVAL// }" ]; then
      echo "ERROR: The WHITELIST_PULL_INTERVAL must be set when ENABLE_WHITELIST is set to true."
      exit 1
    fi
    echo "Creating cron job to pull whitelist every $WHITELIST_PULL_INTERVAL minutes..."
    (crontab -l 2>/dev/null; echo "*/$WHITELIST_PULL_INTERVAL * * * * /usr/games/scripts/pull_whitelist.sh") | crontab -
    bash /usr/games/scripts/pull_whitelist.sh
  else
    # remove the crontab job if it exists
    echo "Removing whitelist cron job..."
    (crontab -l 2>/dev/null | grep -v "/usr/games/scripts/pull_whitelist.sh") | crontab -
  fi

  # create a cron job to execute /usr/games/scripts/pull_no_check_list.sh every X minutes
  if [ "${ENABLE_NO_CHECK_LIST,,}" = "true" ]; then
    if [ -z "${NO_CHECK_LIST_URL// }" ]; then
      echo "ERROR: The NO_CHECK_LIST_URL must be set when ENABLE_NO_CHECK_LIST is set to true."
      exit 1
    fi
    if [ -z "${NO_CHECK_LIST_PULL_INTERVAL// }" ]; then
      echo "ERROR: The NO_CHECK_LIST_PULL_INTERVAL must be set when ENABLE_NO_CHECK_LIST is set to true."
      exit 1
    fi
    echo "Creating cron job to pull no check list every $NO_CHECK_LIST_PULL_INTERVAL minutes..."
    (crontab -l 2>/dev/null; echo "*/$NO_CHECK_LIST_PULL_INTERVAL * * * * /usr/games/scripts/pull_no_check_list.sh") | crontab -
    bash /usr/games/scripts/pull_no_check_list.sh
  else
    # remove the crontab job if it exists
    echo "Removing no check list cron job..."
    (crontab -l 2>/dev/null | grep -v "/usr/games/scripts/pull_no_check_list.sh") | crontab -
  fi

  # Start the server with conditional arguments
  sudo -u games wine "$ASA_DIR/Binaries/Win64/ArkAscendedServer.exe" \
    "$MAP_PATH?listen?Port=${ASA_PORT}" \
    -WinLiveMaxPlayers="${MAX_PLAYERS}" -clusterid="${CLUSTER_ID}" -ClusterDirOverride="$CLUSTER_DIR_OVERRIDE" \
    -servergamelog -servergamelogincludetribelogs -ServerRCONOutputTribeLogs -NotifyAdminCommandsInChat -nosteamclient "$custom_args" \
    "$mods_arg" "$battleye_arg" 2>/dev/null &

  SERVER_PID=$!
  echo "Server process started with PID: $SERVER_PID"

  # Immediate write to PID file
  echo $SERVER_PID > /usr/games/ark_server.pid
  echo "PID $SERVER_PID written to /usr/games/ark_server.pid"

  # Wait for the log file to be created with a timeout
  local LOG_FILE
  LOG_FILE="$ASA_DIR/Saved/Logs/ShooterGame.log"
  local TIMEOUT
  TIMEOUT=120
  while [[ ! -f "$LOG_FILE" && $TIMEOUT -gt 0 ]]; do
    sleep 1
    ((TIMEOUT--))
  done
  if [[ ! -f "$LOG_FILE" ]]; then
    echo "Log file not found after waiting. Please check server status."
    return
  fi

  # Find the line to start tailing from
  local START_LINE
  START_LINE=$(find_new_log_entries)

  # Tail the ShooterGame log file starting from the new session entries
  tail -n +"$START_LINE" -f "$LOG_FILE" &
  local TAIL_PID
  TAIL_PID=$!

  # Wait for the server to fully start
  echo "Waiting for server to start..."
  while true; do
    if grep -q "wp.Runtime.HLOD" "$LOG_FILE"; then
      echo "Server started. PID: $SERVER_PID"
      break
    fi
    sleep 10
  done

  # Wait for the server process to exit
  wait $SERVER_PID

  # Kill the tail process when the server stops
  kill $TAIL_PID
}


# Main function
main() {
  initialize_variables
  install_server
  update_server
  determine_map_path
  cluster_dir
  update_ini_settings
  start_server
}

# Start the main execution
main
