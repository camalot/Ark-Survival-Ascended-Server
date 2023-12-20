#!/bin/bash

# Initialize environment variables
initialize_variables() {
    export DISPLAY=:0.0
    USERNAME=anonymous
    APPID=2430930
    ASA_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/ShooterGame"
    CLUSTER_DIR="$ASA_DIR/Cluster"
    CLUSTER_DIR_OVERRIDE="$CLUSTER_DIR"
    SOURCE_DIR="/usr/games/.wine/drive_c/POK/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/"
    DEST_DIR="$ASA_DIR/Binaries/Win64/"
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
        SERVER_ADMIN_PASSWORD=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 20 | head -n 1)
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

    QUERY_PORT="${QUERY_PORT:-27015}"
    ASA_PORT="${ASA_PORT:-7777}"

    RCON_ENABLED="${RCON_ENABLED:-""}"
    # set RCON_ENABLED to false if not set
    if [ "${RCON_ENABLED,,}" = "true" ]; then
        RCON_ENABLED="True"
    elif [ "${RCON_ENABLED,,}" = "false" ]; then
        RCON_ENABLED="False"
    fi
    RCON_PORT="${RCON_PORT:-27020}"
    RCON_SERVER_GAME_LOG_BUFFER="${RCON_SERVER_GAME_LOG_BUFFER:-""}"
    # validate that the value is a number
    if [ -n "$RCON_SERVER_GAME_LOG_BUFFER" ]; then
        if ! [[ "$RCON_SERVER_GAME_LOG_BUFFER" =~ ^[0-9]+$ ]]; then
            echo "ERROR: The RCON server game log buffer must be a number."
            exit 1
        fi
    fi

    AUTO_SAVE_PERIOD_MINUTES="${AUTO_SAVE_PERIOD_MINUTES:-""}"

    IMPLANT_SUICIDE_CD="${IMPLANT_SUICIDE_CD,-""}"
    # validate that the value is a number
    if [ -n "$IMPLANT_SUICIDE_CD" ]; then
        if ! [[ "$IMPLANT_SUICIDE_CD" =~ ^[0-9]+$ ]]; then
            echo "ERROR: The implant suicide cd must be a number."
            exit 1
        fi
    fi

    DIFFICULTY_OFFSET="${DIFFICULTY_OFFSET:-""}"
    # validate that difficulty offset is a number between 0.01 and 1.0
    if [ -n "$DIFFICULTY_OFFSET" ]; then
        if ! [[ "$DIFFICULTY_OFFSET" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The difficulty offset must be a number between 0.01 and 1.0."
            exit 1
        fi
        if (( $(echo "$DIFFICULTY_OFFSET > 1.0" | bc -l) )) || (( $(echo "$DIFFICULTY_OFFSET < 0.01" | bc -l) )); then
            echo "WARNING: The difficulty offset must be a number between 0.01 and 1.0."
        fi
    fi

    OVERRIDE_OFFICIAL_DIFFICULTY="${OVERRIDE_OFFICIAL_DIFFICULTY:-""}"
    # validate that override official difficulty is a number
    if [ -n "$OVERRIDE_OFFICIAL_DIFFICULTY" ]; then
        if ! [[ "$OVERRIDE_OFFICIAL_DIFFICULTY" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The override official difficulty must be a number."
            exit 1
        fi
    fi

    SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL="${SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL:-""}"
    # validate that the value is a number
    if [ -n "$SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL" ]; then
        if ! [[ "$SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The server auto force respawn wild dinos interval must be a number in seconds."
            exit 1
        fi
    fi

    ITEM_STACK_SIZE_MULTIPLIER="${ITEM_STACK_SIZE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$ITEM_STACK_SIZE_MULTIPLIER" ]; then
        if ! [[ "$ITEM_STACK_SIZE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The item stack size multiplier must be a number."
            exit 1
        fi
    fi

    STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER="${STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER" ]; then
        if ! [[ "$STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The structure prevent resource radius multiplier must be a number."
            exit 1
        fi
    fi

    TRIBE_NAME_CHANGE_COOLDOWN="${TRIBE_NAME_CHANGE_COOLDOWN:-""}"
    # validate that the value is a number
    if [ -n "$TRIBE_NAME_CHANGE_COOLDOWN" ]; then
        if ! [[ "$TRIBE_NAME_CHANGE_COOLDOWN" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The tribe name change cooldown must be a number."
            exit 1
        fi
    fi

    # set PVE to false if not set
    ENABLE_PVP="${ENABLE_PVP:-""}"
    if [ "${ENABLE_PVP,,}" = "true" ]; then
        ENABLE_PVE="False"
    elif [ "${ENABLE_PVP,,}" = "false" ]; then
        ENABLE_PVE="True"
    fi

    ALLOW_HITMARKERS="${ALLOW_HITMARKERS:-""}"
    if [ "${ALLOW_HITMARKERS,,}" = "true" ]; then
        ALLOW_HITMARKERS="True"
    elif [ "${ALLOW_HITMARKERS,,}" = "false" ]; then
        ALLOW_HITMARKERS="False"
    fi

    ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS="${ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS:-""}"
    if [ "${ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS,,}" = "true" ]; then
        ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS="True"
    elif [ "${ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS,,}" = "false" ]; then
        ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS="False"
    fi

    SHOW_MAP_PLAYER_LOCATION="${SHOW_MAP_PLAYER_LOCATION:-""}"
    if [ "${SHOW_MAP_PLAYER_LOCATION,,}" = "true" ]; then
        SHOW_MAP_PLAYER_LOCATION="True"
    elif [ "${SHOW_MAP_PLAYER_LOCATION,,}" = "false" ]; then
        SHOW_MAP_PLAYER_LOCATION="False"
    fi

    SERVER_CROSSHAIR="${SERVER_CROSSHAIR:-""}"
    if [ "${SERVER_CROSSHAIR,,}" = "true" ]; then
        SERVER_CROSSHAIR="True"
    elif [ "${SERVER_CROSSHAIR,,}" = "false" ]; then
        SERVER_CROSSHAIR="False"
    fi

    DISABLE_DINO_DECAY_PVE="${DISABLE_DINO_DECAY_PVE:-""}"
    if [ "${DISABLE_DINO_DECAY_PVE,,}" = "true" ]; then
        DISABLE_DINO_DECAY_PVE="True"
    elif [ "${DISABLE_DINO_DECAY_PVE,,}" = "false" ]; then
        DISABLE_DINO_DECAY_PVE="False"
    fi

    ALWAYS_ALLOW_STRUCTURE_PICKUP="${ALWAYS_ALLOW_STRUCTURE_PICKUP:-""}"
    if [ "${ALWAYS_ALLOW_STRUCTURE_PICKUP,,}" = "true" ]; then
        ALWAYS_ALLOW_STRUCTURE_PICKUP="True"
    elif [ "${ALWAYS_ALLOW_STRUCTURE_PICKUP,,}" = "false" ]; then
        ALWAYS_ALLOW_STRUCTURE_PICKUP="False"
    fi

    ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES="${ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES:-""}"
    if [ "${ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES,,}" = "true" ]; then
        ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES="True"
    elif [ "${ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES,,}" = "false" ]; then
        ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES="False"
    fi

    ALLOW_FLYER_CARRY_PVE="${ALLOW_FLYER_CARRY_PVE:-""}"
    if [ "${ALLOW_FLYER_CARRY_PVE,,}" = "true" ]; then
        ALLOW_FLYER_CARRY_PVE="True"
    elif [ "${ALLOW_FLYER_CARRY_PVE,,}" = "false" ]; then
        ALLOW_FLYER_CARRY_PVE="False"
    fi

    PREVENT_DOWNLOAD_SURVIVORS="${PREVENT_DOWNLOAD_SURVIVORS:-""}"
    if [ "${PREVENT_DOWNLOAD_SURVIVORS,,}" = "true" ]; then
        PREVENT_DOWNLOAD_SURVIVORS="True"
    elif [ "${PREVENT_DOWNLOAD_SURVIVORS,,}" = "false" ]; then
        PREVENT_DOWNLOAD_SURVIVORS="False"
    fi

    PREVENT_DOWNLOAD_ITEMS="${PREVENT_DOWNLOAD_ITEMS:-""}"
    if [ "${PREVENT_DOWNLOAD_ITEMS,,}" = "true" ]; then
        PREVENT_DOWNLOAD_ITEMS="True"
    elif [ "${PREVENT_DOWNLOAD_ITEMS,,}" = "false" ]; then
        PREVENT_DOWNLOAD_ITEMS="False"
    fi

    PREVENT_DOWNLOAD_DINOS="${PREVENT_DOWNLOAD_DINOS:-""}"
    if [ "${PREVENT_DOWNLOAD_DINOS,,}" = "true" ]; then
        PREVENT_DOWNLOAD_DINOS="True"
    elif [ "${PREVENT_DOWNLOAD_DINOS,,}" = "false" ]; then
        PREVENT_DOWNLOAD_DINOS="False"
    fi

    PREVENT_UPLOAD_SURVIVORS="${PREVENT_UPLOAD_SURVIVORS:-""}"
    if [ "${PREVENT_UPLOAD_SURVIVORS,,}" = "true" ]; then
        PREVENT_UPLOAD_SURVIVORS="True"
    elif [ "${PREVENT_UPLOAD_SURVIVORS,,}" = "false" ]; then
        PREVENT_UPLOAD_SURVIVORS="False"
    fi

    PREVENT_UPLOAD_ITEMS="${PREVENT_UPLOAD_ITEMS:-""}"
    if [ "${PREVENT_UPLOAD_ITEMS,,}" = "true" ]; then
        PREVENT_UPLOAD_ITEMS="True"
    elif [ "${PREVENT_UPLOAD_ITEMS,,}" = "false" ]; then
        PREVENT_UPLOAD_ITEMS="False"
    fi

    PREVENT_UPLOAD_DINOS="${PREVENT_UPLOAD_DINOS:-""}"
    if [ "${PREVENT_UPLOAD_DINOS,,}" = "true" ]; then
        PREVENT_UPLOAD_DINOS="True"
    elif [ "${PREVENT_UPLOAD_DINOS,,}" = "false" ]; then
        PREVENT_UPLOAD_DINOS="False"
    fi

    STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT="${STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT:-""}"
    # validate that the value is a number
    if [ -n "$STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT" ]; then
        if ! [[ "$STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT" =~ ^[0-9]+$ ]]; then
            echo "ERROR: The structure pickup time after placement must be a number."
            exit 1
        fi
    fi

    STRUCTURE_PICKUP_HOLD_DURATION="${STRUCTURE_PICKUP_HOLD_DURATION:-""}"
    # validate that the value is a number
    if [ -n "$STRUCTURE_PICKUP_HOLD_DURATION" ]; then
        if ! [[ "$STRUCTURE_PICKUP_HOLD_DURATION" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The structure pickup hold duration must be a number."
            exit 1
        fi
    fi

    MAX_STRUCTURES_IN_RANGE="${MAX_STRUCTURES_IN_RANGE:-""}"
    # validate that the value is a number
    if [ -n "$MAX_STRUCTURES_IN_RANGE" ]; then
        if ! [[ "$MAX_STRUCTURES_IN_RANGE" =~ ^[0-9]+$ ]]; then
            echo "ERROR: The max structures in range must be a number."
            exit 1
        fi
    fi

    START_TIME_HOUR="${START_TIME_HOUR:-"-1"}"
    # validate that the value is a number
    if [ -n "$START_TIME_HOUR" ]; then
        if ! [[ "$START_TIME_HOUR" =~ ^[0-9]+$ ]]; then
            echo "ERROR: The start time hour must be a number."
            exit 1
        fi
    fi

    KICK_IDLE_PLAYERS_PERIOD="${KICK_IDLE_PLAYERS_PERIOD:-""}"
    # validate that the value is a number
    if [ -n "$KICK_IDLE_PLAYERS_PERIOD" ]; then
        if ! [[ "$KICK_IDLE_PLAYERS_PERIOD" =~ ^[0-9]+$ ]]; then
            echo "ERROR: The kick idle players period must be a number."
            exit 1
        fi
    fi

    PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER="${PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER" ]; then
        if ! [[ "$PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The per platform max structures multiplier must be a number."
            exit 1
        fi
    fi

    PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER="${PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER" ]; then
        if ! [[ "$PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The platform saddle build area bounds multiplier must be a number."
            exit 1
        fi
    fi

    DINO_DAMAGE_MULTIPLIER="${DINO_DAMAGE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$DINO_DAMAGE_MULTIPLIER" ]; then
        if ! [[ "$DINO_DAMAGE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The dino damage multiplier must be a number."
            exit 1
        fi
    fi

    PVE_DINO_DECAY_PERIOD_MULTIPLIER="${PVE_DINO_DECAY_PERIOD_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$PVE_DINO_DECAY_PERIOD_MULTIPLIER" ]; then
        if ! [[ "$PVE_DINO_DECAY_PERIOD_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The PVE dino decay period multiplier must be a number."
            exit 1
        fi
    fi

    PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER="${PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER" ]; then
        if ! [[ "$PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The PVE structure decay period multiplier must be a number."
            exit 1
        fi
    fi

    RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER="${RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER" ]; then
        if ! [[ "$RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The raid dino character food drain multiplier must be a number."
            exit 1
        fi
    fi

    XP_MULTIPLIER="${XP_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$XP_MULTIPLIER" ]; then
        if ! [[ "$XP_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The XP multiplier must be a number."
            exit 1
        fi
    fi

    TAMING_SPEED_MULTIPLIER="${TAMING_SPEED_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$TAMING_SPEED_MULTIPLIER" ]; then
        if ! [[ "$TAMING_SPEED_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The taming speed multiplier must be a number."
            exit 1
        fi
    fi

    HARVEST_AMOUNT_MULTIPLIER="${HARVEST_AMOUNT_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$HARVEST_AMOUNT_MULTIPLIER" ]; then
        if ! [[ "$HARVEST_AMOUNT_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The harvest amount multiplier must be a number."
            exit 1
        fi
    fi

    STRUCTURE_RESISTANCE_MULTIPLIER="${STRUCTURE_RESISTANCE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$STRUCTURE_RESISTANCE_MULTIPLIER" ]; then
        if ! [[ "$STRUCTURE_RESISTANCE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The structure resistance multiplier must be a number."
            exit 1
        fi
    fi

    OXYGEN_SWIM_SPEED_STAT_MULTIPLIER="${OXYGEN_SWIM_SPEED_STAT_MULTIPLIER:-"1"}"
    # validate that the value is a number
    if [ -n "$OXYGEN_SWIM_SPEED_STAT_MULTIPLIER" ]; then
        if ! [[ "$OXYGEN_SWIM_SPEED_STAT_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The oxygen swim speed stat multiplier must be a number."
            exit 1
        fi
    fi

    BABY_IMPRINTING_STAT_SCALE_MULTIPLIER="${BABY_IMPRINTING_STAT_SCALE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$BABY_IMPRINTING_STAT_SCALE_MULTIPLIER" ]; then
        if ! [[ "$BABY_IMPRINTING_STAT_SCALE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The baby imprinting stat scale multiplier must be a number."
            exit 1
        fi
    fi

    BABY_CUDDLE_INTERVAL_MULTIPLIER="${BABY_CUDDLE_INTERVAL_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$BABY_CUDDLE_INTERVAL_MULTIPLIER" ]; then
        if ! [[ "$BABY_CUDDLE_INTERVAL_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The baby cuddle interval multiplier must be a number."
            exit 1
        fi
    fi

    BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER="${BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER" ]; then
        if ! [[ "$BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The baby cuddle grace period multiplier must be a number."
            exit 1
        fi
    fi

    BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER="${BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER" ]; then
        if ! [[ "$BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The baby cuddle lose imprint quality speed multiplier must be a number."
            exit 1
        fi
    fi

    GLOBAL_SPOILING_TIME_MULTIPLIER="${GLOBAL_SPOILING_TIME_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$GLOBAL_SPOILING_TIME_MULTIPLIER" ]; then
        if ! [[ "$GLOBAL_SPOILING_TIME_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The global spoiling time multiplier must be a number."
            exit 1
        fi
    fi

    GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER="${GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER" ]; then
        if ! [[ "$GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The global item decomposition time multiplier must be a number."
            exit 1
        fi
    fi

    GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER="${GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER" ]; then
        if ! [[ "$GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The global corpse decomposition time multiplier must be a number."
            exit 1
        fi
    fi

    PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER="${PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER" ]; then
        if ! [[ "$PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The PVP zone structure damage multiplier must be a number."
            exit 1
        fi
    fi

    CROP_GROWTH_SPEED_MULTIPLIER="${CROP_GROWTH_SPEED_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$CROP_GROWTH_SPEED_MULTIPLIER" ]; then
        if ! [[ "$CROP_GROWTH_SPEED_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The crop growth speed multiplier must be a number."
            exit 1
        fi
    fi

    LAY_EGG_INTERVAL_MULTIPLIER="${LAY_EGG_INTERVAL_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$LAY_EGG_INTERVAL_MULTIPLIER" ]; then
        if ! [[ "$LAY_EGG_INTERVAL_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The lay egg interval multiplier must be a number."
            exit 1
        fi
    fi

    POOP_INTERVAL_MULTIPLIER="${POOP_INTERVAL_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$POOP_INTERVAL_MULTIPLIER" ]; then
        if ! [[ "$POOP_INTERVAL_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The poop interval multiplier must be a number."
            exit 1
        fi
    fi

    EGG_HATCH_SPEED_MULTIPLIER="${EGG_HATCH_SPEED_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$EGG_HATCH_SPEED_MULTIPLIER" ]; then
        if ! [[ "$EGG_HATCH_SPEED_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The egg hatch speed multiplier must be a number."
            exit 1
        fi
    fi

    CROP_DECAY_SPEED_MULTIPLIER="${CROP_DECAY_SPEED_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$CROP_DECAY_SPEED_MULTIPLIER" ]; then
        if ! [[ "$CROP_DECAY_SPEED_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The crop decay speed multiplier must be a number."
            exit 1
        fi
    fi

    MATING_INTERVAL_MULTIPLIER="${MATING_INTERVAL_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$MATING_INTERVAL_MULTIPLIER" ]; then
        if ! [[ "$MATING_INTERVAL_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The mating interval multiplier must be a number."
            exit 1
        fi
    fi

    BABY_MATURE_SPEED_MULTIPLIER="${BABY_MATURE_SPEED_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$BABY_MATURE_SPEED_MULTIPLIER" ]; then
        if ! [[ "$BABY_MATURE_SPEED_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The baby mature speed multiplier must be a number."
            exit 1
        fi
    fi

    BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER="${BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER" ]; then
        if ! [[ "$BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The baby food consumption speed multiplier must be a number."
            exit 1
        fi
    fi

    DINO_HARVESTING_DAMAGE_MULTIPLIER="${DINO_HARVESTING_DAMAGE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$DINO_HARVESTING_DAMAGE_MULTIPLIER" ]; then
        if ! [[ "$DINO_HARVESTING_DAMAGE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The dino harvesting damage multiplier must be a number."
            exit 1
        fi
    fi

    PLAYER_HARVESTING_DAMAGE_MULTIPLIER="${PLAYER_HARVESTING_DAMAGE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$PLAYER_HARVESTING_DAMAGE_MULTIPLIER" ]; then
        if ! [[ "$PLAYER_HARVESTING_DAMAGE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The player harvesting damage multiplier must be a number."
            exit 1
        fi
    fi

    KILL_XP_MULTIPLIER="${KILL_XP_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$KILL_XP_MULTIPLIER" ]; then
        if ! [[ "$KILL_XP_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The kill XP multiplier must be a number."
            exit 1
        fi
    fi

    HARVEST_XP_MULTIPLIER="${HARVEST_XP_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$HARVEST_XP_MULTIPLIER" ]; then
        if ! [[ "$HARVEST_XP_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The harvest XP multiplier must be a number."
            exit 1
        fi
    fi

    CRAFT_XP_MULTIPLIER="${CRAFT_XP_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$CRAFT_XP_MULTIPLIER" ]; then
        if ! [[ "$CRAFT_XP_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The craft XP multiplier must be a number."
            exit 1
        fi
    fi

    GENERIC_XP_MULTIPLIER="${GENERIC_XP_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$GENERIC_XP_MULTIPLIER" ]; then
        if ! [[ "$GENERIC_XP_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The generic XP multiplier must be a number."
            exit 1
        fi
    fi

    SPECIAL_XP_MULTIPLIER="${SPECIAL_XP_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$SPECIAL_XP_MULTIPLIER" ]; then
        if ! [[ "$SPECIAL_XP_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The special XP multiplier must be a number."
            exit 1
        fi
    fi

    MAX_TAMED_DINOS="${MAX_TAMED_DINOS:-5000}"
    # validate that the value is a number
    if [ -n "$MAX_TAMED_DINOS" ]; then
        if ! [[ "$MAX_TAMED_DINOS" =~ ^-?[0-9]+$ ]]; then
            echo "ERROR: The max tamed dinos must be a number."
            exit 1
        fi
    fi

    ALLOW_CHEATERS_URL="${ALLOW_CHEATERS_URL:-""}"
    if [ -n "$ALLOW_CHEATERS_URL" ]; then
        if ! [[ "$ALLOW_CHEATERS_URL" =~ ^http:// ]]; then
            echo "ERROR: The allow cheaters url must be a valid URL. It must start with http://; https:// is not supported."
            exit 1
        fi
    fi
    ALLOW_CHEATERS_UPDATE_INTERVAL="${ALLOW_CHEATERS_UPDATE_INTERVAL:-"600"}"
    # validate that the value is a number
    if [ -n "$ALLOW_CHEATERS_UPDATE_INTERVAL" ]; then
        if ! [[ "$ALLOW_CHEATERS_UPDATE_INTERVAL" =~ ^[0-9]+$ ]]; then
            echo "ERROR: The allow cheaters update interval must be a number in seconds."
            exit 1
        fi
    fi

    BAN_LIST_URL="${BAN_LIST_URL:-""}"
    if [ -n "$BAN_LIST_URL" ]; then
        if ! [[ "$BAN_LIST_URL" =~ ^http:// ]]; then
            echo "ERROR: The ban list url must be a valid URL. It must start with http://; https:// is not supported."
            exit 1
        fi
    fi

    ALLOW_THIRD_PERSON_VIEW="${ALLOW_THIRD_PERSON_VIEW:-"TRUE"}"
    if [ "${ALLOW_THIRD_PERSON_VIEW,,}" = "true" ]; then
        ALLOW_THIRD_PERSON_VIEW="True"
    else
        ALLOW_THIRD_PERSON_VIEW="False"
    fi

    USE_EXCLUSIVE_LIST="${USE_EXCLUSIVE_LIST:-"FALSE"}"
    if [ "${USE_EXCLUSIVE_LIST,,}" = "true" ]; then
        USE_EXCLUSIVE_LIST="True"
    else
        USE_EXCLUSIVE_LIST="False"
    fi
}


update_ini_settings() {
  local gus_ini="$ASA_DIR/Saved/Config/WindowsServer/GameUserSettings.ini"
  local game_ini="$ASA_DIR/Saved/Config/WindowsServer/Game.ini"

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
    # Prepare MOTD by escaping newline characters
    local escaped_motd=$(echo "$MOTD" | sed 's/\\n/\\\\n/g')
    # Handle MOTD based on ENABLE_MOTD value
    if [ "${ENABLE_MOTD,,}" = "true" ]; then
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
    local ini_file="$1"
    local section="$2"
    local setting="$3"
    local value="$4"

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
}


update_ini_setting() {
    local ini_file="$1"
    local section="$2"
    local setting="$3"
    local value="$4"

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
        local build_id=$(grep -E "^\s+\"buildid\"\s+" "$PERSISTENT_ACF_FILE" | grep -o '[[:digit:]]*')
        echo "$build_id"
    else
        echo ""
    fi
}

# Get the current build ID from SteamCMD API
get_current_build_id() {
    local build_id=$(curl -sX GET "https://api.steamcmd.net/v1/info/$APPID" | jq -r ".data.\"$APPID\".depots.branches.public.buildid")
    echo "$build_id"
}

install_server() {
    local saved_build_id=$(get_build_id_from_acf)
    local current_build_id=$(get_current_build_id)

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
    local saved_build_id=$(get_build_id_from_acf)
    local current_build_id=$(get_current_build_id)

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
    local log_file="$ASA_DIR/Saved/Logs/ShooterGame.log"
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
    rcon-cli --host localhost --port $RCON_PORT --password $SERVER_ADMIN_PASSWORD "ServerChat Immediate server shutdown initiated. Saving the world..."

    echo "Saving the world..."
    rcon-cli --host localhost --port $RCON_PORT --password $SERVER_ADMIN_PASSWORD "saveworld"

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
    local old_log_file="$ASA_DIR/Saved/Logs/ShooterGame.log"
    if [ -f "$old_log_file" ]; then
        local timestamp=$(date +%F-%T)
        mv "$old_log_file" "${old_log_file}_$timestamp.log"
    fi

    # Initialize the mods argument to an empty string
    local mods_arg=""
    local battleye_arg=""
    local custom_args=""

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
    #     server_password_arg="?ServerPassword=${SERVER_PASSWORD}"
    # fi

    # setup cron job to pull the "whitelist" every X minutes
    # if [ "$WHITELIST_ENABLED" = "TRUE" ]; then
    #   # if the UseExclusiveList is set to true, then we need to set the ExclusiveJoin to true
    #     echo "Pulling whitelist every $WHITELIST_PULL_INTERVAL minutes..."
    #     (crontab -l 2>/dev/null; echo "*/$WHITELIST_PULL_INTERVAL * * * * /usr/games/arkmanager cron pull_whitelist") | crontab -
    # fi
    # setup cron job to pull the "no check" list every X minutes
    # if [ "$NO_CHECK_ENABLED" = "TRUE" ]; then
    #     echo "Pulling no check list every $NO_CHECK_PULL_INTERVAL minutes..."
    #     (crontab -l 2>/dev/null; echo "*/$NO_CHECK_PULL_INTERVAL * * * * /usr/games/arkmanager cron pull_no_check") | crontab -
    # fi


    # Start the server with conditional arguments
    sudo -u games wine "$ASA_DIR/Binaries/Win64/ArkAscendedServer.exe" \
        $MAP_PATH?listen?$session_name_arg?Port=${ASA_PORT} \
        -WinLiveMaxPlayers=${MAX_PLAYERS} -clusterid=${CLUSTER_ID} -ClusterDirOverride=$CLUSTER_DIR_OVERRIDE \
        -servergamelog -servergamelogincludetribelogs -ServerRCONOutputTribeLogs -NotifyAdminCommandsInChat -nosteamclient $custom_args \
        $mods_arg $battleye_arg 2>/dev/null &

    SERVER_PID=$!
    echo "Server process started with PID: $SERVER_PID"

    # Immediate write to PID file
    echo $SERVER_PID > /usr/games/ark_server.pid
    echo "PID $SERVER_PID written to /usr/games/ark_server.pid"

    # Wait for the log file to be created with a timeout
    local LOG_FILE="$ASA_DIR/Saved/Logs/ShooterGame.log"
    local TIMEOUT=120
    while [[ ! -f "$LOG_FILE" && $TIMEOUT -gt 0 ]]; do
        sleep 1
        ((TIMEOUT--))
    done
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Log file not found after waiting. Please check server status."
        return
    fi

    # Find the line to start tailing from
    local START_LINE=$(find_new_log_entries)

    # Tail the ShooterGame log file starting from the new session entries
    tail -n +"$START_LINE" -f "$LOG_FILE" &
    local TAIL_PID=$!

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
