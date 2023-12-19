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
    SESSION_NAME="${SESSION_NAME:-ASA Server}"

    QUERY_PORT="${QUERY_PORT:-27015}"
    ASA_PORT="${ASA_PORT:-7777}"

    RCON_ENABLED="${RCON_ENABLED:-"TRUE"}"
    # set RCON_ENABLED to false if not set
    if [ "${RCON_ENABLED,,}" = "true" ]; then
        RCON_ENABLED="True"
    else
        RCON_ENABLED="False"
    fi
    RCON_PORT="${RCON_PORT:-27020}"


    DIFFICULTY_OFFSET="${DIFFICULTY_OFFSET:-"1.286000"}"
    # validate that difficulty offset is a number between 0.01 and 1.0
    if [ -n "$DIFFICULTY_OFFSET" ]; then
        if ! [[ "$DIFFICULTY_OFFSET" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The difficulty offset must be a number between 0.01 and 1.0."
            exit 1
        fi
        if (( $(echo "$DIFFICULTY_OFFSET > 1.0" | bc -l) )) || (( $(echo "$DIFFICULTY_OFFSET < 0.01" | bc -l) )); then
            echo "ERROR: The difficulty offset must be a number between 0.01 and 1.0."
            exit 1
        fi
    fi

    # set PVE to false if not set
    ENABLE_PVP="${ENABLE_PVP:-"TRUE"}"
    if [ "${ENABLE_PVP,,}" = "true" ]; then
        ENABLE_PVE="False"
    else
        ENABLE_PVE="True"
    fi


    DINO_DAMAGE_MULTIPLIER="${DINO_DAMAGE_MULTIPLIER:-""}"
    # validate that the value is a number
    if [ -n "$DINO_DAMAGE_MULTIPLIER" ]; then
        if ! [[ "$DINO_DAMAGE_MULTIPLIER" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            echo "ERROR: The dino damage multiplier must be a number."
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


update_game_user_settings() {
  local ini_file="$ASA_DIR/Saved/Config/WindowsServer/GameUserSettings.ini"

  # [ServerSettings]
  update_game_user_setting "$ini_file" "ServerSettings" "ServerAdminPassword" "$SERVER_ADMIN_PASSWORD"
  update_game_user_setting "$ini_file" "ServerSettings" "ServerPassword" "$SERVER_PASSWORD"
  update_game_user_setting "$ini_file" "ServerSettings" "DifficultyOffset" "$DIFFICULTY_OFFSET"
  update_game_user_setting "$ini_file" "ServerSettings" "serverPVE" "$ENABLE_PVE"
  update_game_user_setting "$ini_file" "ServerSettings" "DinoDamageMultiplier" "$DINO_DAMAGE_MULTIPLIER"
  update_game_user_setting "$ini_file" "ServerSettings" "XPMultiplier" "$XP_MULTIPLIER"
  update_game_user_setting "$ini_file" "ServerSettings" "TamingSpeedMultiplier" "$TAMING_SPEED_MULTIPLIER"
  update_game_user_setting "$ini_file" "ServerSettings" "HarvestAmountMultiplier" "$HARVEST_AMOUNT_MULTIPLIER"
  update_game_user_setting "$ini_file" "ServerSettings" "StructureResistanceMultiplier" "$STRUCTURE_RESISTANCE_MULTIPLIER"
  update_game_user_setting "$ini_file" "ServerSettings" "MaxTamedDinos" "$MAX_TAMED_DINOS"
  update_game_user_setting "$ini_file" "ServerSettings" "RCONPort" "$RCON_PORT"
  update_game_user_setting "$ini_file" "ServerSettings" "RCONEnabled" "$RCON_ENABLED"
  update_game_user_setting "$ini_file" "ServerSettings" "AllowedCheatersURL" "'$ALLOW_CHEATERS_URL'"
  update_game_user_setting "$ini_file" "ServerSettings" "AllowedCheatersUpdateInterval" "$ALLOW_CHEATERS_UPDATE_INTERVAL"
  update_game_user_setting "$ini_file" "ServerSettings" "BanListURL" "'$BAN_LIST_URL'"
  update_game_user_setting "$ini_file" "ServerSettings" "AllowThirdPersonPlayer" "$ALLOW_THIRD_PERSON_VIEW"
  update_game_user_setting "$ini_file" "ServerSettings" "UseExclusiveList" "$USE_EXCLUSIVE_LIST"

  # [SessionSettings]
  update_game_user_setting "$ini_file" "SessionSettings" "SessionName" "$SESSION_NAME"
  update_game_user_setting "$ini_file" "SessionSettings" "QueryPort" "$QUERY_PORT"

  # [/Script/Engine.GameSession]
  update_game_user_setting "$ini_file" "/Script/Engine.GameSession" "MaxPlayers" "$MAX_PLAYERS"

  # Check if the file exists
  if [ -f "$ini_file" ]; then
    # Remove existing [MessageOfTheDay] section
    sed -i '/^\[MessageOfTheDay\]/,/^$/d' "$ini_file"
    # Prepare MOTD by escaping newline characters
    local escaped_motd=$(echo "$MOTD" | sed 's/\\n/\\\\n/g')
    # Handle MOTD based on ENABLE_MOTD value
    if [ "${ENABLE_MOTD,,}" = "true" ]; then
      update_game_user_setting "$ini_file" "MessageOfTheDay" "Message" "$escaped_motd"
      update_game_user_setting "$ini_file" "MessageOfTheDay" "Duration" "$MOTD_DURATION"
    else
      update_game_user_setting "$ini_file" "MessageOfTheDay" "Message" ""
      update_game_user_setting "$ini_file" "MessageOfTheDay" "Duration" ""
    fi

  else
    echo "$ini_file not found."
  fi
}


update_game_user_setting() {
    local ini_file="$1"
    local section="$2"
    local setting="$3"
    local value="$4"

    # Check if the file exists
    if [ -f "$ini_file" ]; then
      if [ -n "$value" ]; then
        echo "Updating [$section] $setting=$value in $ini_file"
        ini-file set --section "$section" --key "$setting" --value "$value" "$ini_file"
      else
        echo "Removing [$section] $setting from $ini_file"
        # Remove the setting line if value is not set
        ini-file del --section "$section" --key "$setting" "$ini_file"
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
    local rcon_args=""
    local custom_args=""
    local server_password_arg=""
    local session_name_arg="SessionName=\"${SESSION_NAME}\""

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

    # Set RCON arguments based on RCON_ENABLED environment variable
    # if [ "$RCON_ENABLED" = "TRUE" ]; then
    #     rcon_args="?RCONEnabled=True?RCONPort=${RCON_PORT}"
    # elif [ "$RCON_ENABLED" = "FALSE" ]; then
    #     rcon_args="?RCONEnabled=False"
    # fi

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
        $MAP_PATH?listen?$session_name_arg?Port=${ASA_PORT}${rcon_args}${server_password_arg}?ServerAdminPassword=${SERVER_ADMIN_PASSWORD} \
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
    update_game_user_settings
    start_server
}

# Start the main execution
main
