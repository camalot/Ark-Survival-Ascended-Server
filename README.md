
# Documentation for Ark Survival Ascended Server Docker Image

> [!NOTE]
> This project was originally based on [Acekorneya/Ark-Survival-Ascended-Server](https://github.com/Acekorneya/Ark-Survival-Ascended-Server).

## DOCKER IMAGE DETAILS

This Docker image is designed to run a dedicated server for the game Ark Survival Ascended. It's based on `scottyhardy/docker-wine` to enable the running of Windows applications. The image uses a bash script to handle startup, server installation, server update ,and setting up environment variables.


---

### ENVIRONMENT VARIABLES

| VARIABLE                      | DEFAULT           | DESCRIPTION                                                                               |
| ------------------------------| ------------------| ------------------------------------------------------------------------------------------|
| `PUID`                        | `1001`            | The UID to run server as                                                                  |
| `PGID`                        | `1001`            | The GID to run server as                                                                  |
| `RESET_GAME_SETTINGS`         | `FALSE`           | Reset the Game.ini and GameUserSettings.ini to the "defaults" before applying             |
| `BATTLEEYE`                   | `TRUE`            | Set to TRUE to use BattleEye, FALSE to not use BattleEye                                  |
| `RCON_ENABLED`                | `TRUE`            | Needed for Graceful Shutdown                                                              |
| `RCON_PORT`                   | `27020`           | RCON Port Use for Most Server Operations                                                  |
| `RCON_SERVER_GAME_LOG_BUFFER` |                   |                                                                                           |
| `DISPLAY_POK_MONITOR_MESSAGE` | `TRUE`            | FALSE to suppress the Server Monitor Shutdown                                             |
| `UPDATE_SERVER`               | `TRUE`            | Enable or disable update checks                                                           |
| `CHECK_FOR_UPDATE_INTERVAL`   | `24`              | Check for Updates interval in hours                                                       |
| `RESTART_NOTICE_MINUTES`      | `30`              | Duration in minutes for notifying players before a server restart due to updates          |
| `ENABLE_MOTD`                 | `FALSE`           | Enable or disable Message of the Day                                                      |
| `MOTD`                        |                   | Message of the Day                                                                        |
| `MOTD_DURATION`               | `30`              | Duration for the Message of the Day                                                       |
| `MAP_NAME`                    | `TheIsland`       | The map name (`TheIsland') Or Custom Map Name Can Be Enter as well                        |
| `SESSION_NAME`                | `Server_name`     | The session name for the server                                                           |
| `SERVER_ADMIN_PASSWORD_FILE`  |                   | A file that contains the admin password for the server                                    |
| `SERVER_ADMIN_PASSWORD`       | `MyPassword`      | The admin password for the server. Will override `SERVER_ADMIN_PASSWORD_FILE`.            |
| `SERVER_PASSWORD_FILE`        |                   | A file that contains the password to connect to the server.                               |
| `SERVER_PASSWORD`             |                   | Set a server password or leave it blank (ONLY NUMBERS AND CHARACTERS ARE ALLOWED BY DEVS) |
| `ASA_PORT`                    | `7777`            | The game port for the server                                                              |
| `MAX_PLAYERS`                 | `127`             | Max allowed players                                                                       |
| `CLUSTER_ID`                  | `cluster`         | The Cluster ID for the server                                                             |
| `MOD_IDS`                     |                   | Add your mod IDs here, separated by commas, e.g., 123456789,987654321                     |
| `CUSTOM_SERVER_ARGS`          |                   | If You need to add more Custom Args -ForceRespawnDinos -ForceAllowCaveFlyers              |
| `QUERY_PORT`                  | `27015`           | The query port for server discovery                                                       |
| `AUTO_SAVE_PERIOD_MINUTES`    |                   | The time, in minutes, in which to auto save.                                              |
| `IMPLANT_SUICIDE_CD`          |                   |                                                                                           |
| `DIFFICULTY_OFFSET`           |                   |                                                                                           |
| `OVERRIDE_OFFICIAL_DIFFICULTY`|                   |                                                                                           |
| `SERVER_AUTO_FORCE_RESPAWN_WILD_DINOS_INTERVAL` | |                                                                                           |
| `ITEM_STACK_SIZE_MULTIPLIER`  |                   |                                                                                           |
| `STRUCTURE_PREVENT_RESOURCE_RADIUS_MULTIPLIER` |  |                                                                                           |
| `TRIBE_NAME_CHANGE_COOLDOWN`  |                   |                                                                                           |
| `ENABLE_PVE`                  |                   |                                                                                           |
| `ALLOW_HITMARKERS`            |                   |                                                                                           |
| `ALLOW_HIDE_DAMAGE_SOURCE_FROM_LOGS` |            |                                                                                           |
| `SHOW_MAP_PLAYER_LOCATION`    |                   |                                                                                           |
| `SERVER_CROSSHAIR`            |                   |                                                                                           |
| `DISABLE_DINO_DECAY_PVE`      |                   |                                                                                           |
| `ALWAYS_ALLOW_STRUCTURE_PICKUP` |                 |                                                                                           |
| `ALLOW_CRATE_SPAWNS_ON_TOP_OF_STRUCTURES` |       |                                                                                           |
| `ALLOW_FLYER_CARRY_PVE`       |                   |                                                                                           |
| `ALLOW_THIRD_PERSON_VIEW`     | `TRUE`            |                                                                                           |
| `PREVENT_DOWNLOAD_SURVIVORS`  |                   |                                                                                           |
| `PREVENT_DOWNLOAD_ITEMS`      |                   |                                                                                           |
| `PREVENT_DOWNLOAD_DINOS`      |                   |                                                                                           |
| `PREVENT_UPLOAD_SURVIVORS`    |                   |                                                                                           |
| `PREVENT_UPLOAD_ITEMS`        |                   |                                                                                           |
| `PREVENT_UPLOAD_DINOS`        |                   |                                                                                           |
| `ENABLE_WHITELIST`            |                   | Only allow whitelisted users to connect to the server.                                    |
| `WHITELIST_URL`               |                   | An `http` URL to content that returns user IDs (EOS format)                               |
| `WHITELIST_PULL_INTERVAL`     | `5`               | The interval, in minutes, on how often the list should be pulled from the URL.            |
| `ENABLE_NO_CHECK_LIST`        |                   | Allow users on list to connect even if the server is full.                                |
| `NO_CHECK_LIST_URL`           |                   | An `http` URL to content that returns user IDs (EOS format)                               |
| `NO_CHECK_LIST_PULL_INTERVAL` | `5`               | The interval, in minutes, on how often the list should be pulled from the URL.            |
| `ALLOW_CHEATERS_URL`          |                   | Admin List: An `http` URL to content that returns user IDs (EOS format)                   |
| `ALLOW_CHEATERS_UPDATE_INTERVAL` |                | The interval, in minutes, on how often the list should be pulled from the URL.            |
| `BAN_LIST_URL`                |                   | Ban List: An `http` URL to content that returns user IDs (EOS format)                     |
| `STRUCTURE_PICKUP_TIME_AFTER_PLACEMENT` |         |                                                                                           |
| `STRUCTURE_PICKUP_HOLD_DURATION` |                |                                                                                           |
| `MAX_STRUCTURES_IN_RANGE`     |                   |                                                                                           |
| `START_TIME_HOUR`             |                   |                                                                                           |
| `KICK_IDLE_PLAYERS_PERIOD`    |                   |                                                                                           |
| `PER_PLATFORM_MAX_STRUCTURES_MULTIPLIER` |        |                                                                                           |
| `PLATFORM_SADDLE_BUILD_AREA_BOUNDS_MULTIPLIER` |  |                                                                                           |
| `DINO_DAMAGE_MULTIPLIER`      |                   |                                                                                           |
| `PVE_DINO_DECAY_PERIOD_MULTIPLIER` |              |                                                                                           |
| `PVE_STRUCTURE_DECAY_PERIOD_MULTIPLIER` |         |                                                                                           |
| `RAID_DINO_CHARACTER_FOOD_DRAIN_MULTIPLIER` |     |                                                                                           |
| `XP_MULTIPLIER`               |                   |                                                                                           |
| `TAMING_SPEED_MULTIPLIER`     |                   |                                                                                           |
| `HARVEST_AMOUNT_MULTIPLIER`   |                   |                                                                                           |
| `STRUCTURE_RESISTANCE_MULTIPLIER` |               |                                                                                           |
| `OXYGEN_SWIM_SPEED_STAT_MULTIPLIER` |             |                                                                                           |
| `BABY_IMPRINTING_STAT_SCALE_MULTIPLIER` |         |                                                                                           |
| `BABY_CUDDLE_INTERVAL_MULTIPLIER` |               |                                                                                           |
| `BABY_CUDDLE_GRACE_PERIOD_MULTIPLIER` |           |                                                                                           |
| `BABY_CUDDLE_LOSE_IMPRINT_QUALITY_SPEED_MULTIPLIER` | |                                                                                       |
| `GLOBAL_SPOILING_TIME_MULTIPLIER` |               |                                                                                           |
| `GLOBAL_ITEM_DECOMPOSITION_TIME_MULTIPLIER` |     |                                                                                           |
| `GLOBAL_CORPSE_DECOMPOSITION_TIME_MULTIPLIER` |   |                                                                                           |
| `PVP_ZONE_STRUCTURE_DAMAGE_MULTIPLIER` |          |                                                                                           |
| `CROP_GROWTH_SPEED_MULTIPLIER` |                  |                                                                                           |
| `LAY_EGG_INTERVAL_MULTIPLIER`  |                  |                                                                                           |
| `POOP_INTERVAL_MULTIPLIER`     |                  |                                                                                           |
| `EGG_HATCH_SPEED_MULTIPLIER`   |                  |                                                                                           |
| `CROP_DECAY_SPEED_MULTIPLIER`  |                  |                                                                                           |
| `MATING_INTERVAL_MULTIPLIER`   |                  |                                                                                           |
| `BABY_MATURE_SPEED_MULTIPLIER` |                  |                                                                                           |
| `BABY_FOOD_CONSUMPTION_SPEED_MULTIPLIER` |        |                                                                                           |
| `DINO_HARVESTING_DAMAGE_MULTIPLIER` |             |                                                                                           |
| `PLAYER_HARVESTING_DAMAGE_MULTIPLIER` |           |                                                                                           |
| `KILL_XP_MULTIPLIER`           |                  |                                                                                           |
| `HARVEST_XP_MULTIPLIER`        |                  |                                                                                           |
| `CRAFT_XP_MULTIPLIER`          |                  |                                                                                           |
| `GENERIC_XP_MULTIPLIER`        |                  |                                                                                           |
| `SPECIAL_XP_MULTIPLIER`        |                  |                                                                                           |
| `MAX_TAMED_DINOS`              |                  |                                                                                           |
---

### Additional Information

- **PUID and PGID**: These are important for setting the permissions of the folders that Docker will use. Make sure to set these values based on your host machine's user and group ID

- **Folder Creation**: Before starting the Docker Compose file, make sure to manually create any folders that you'll be using for volumes, especially if you're overriding the default folders.

---

### Ports

| PORT         | DESCRIPTION                            |
| ------------ | -------------------------------------- |
| `7777/tcp`   | Game port                              |
| `7777/udp`   | Game port                              |
| `27020/tcp`  | RCON port                              |


---

### Volumes
When you run the docker compose up it should create this folders in the same folder as the docker-compose.yaml file unless changed by the user

| VOLUME PATH                                          | DESCRIPTION                                    |
| ---------------------------------------------------- | ---------------------------------------------- |
| `./data/asa`                                         | Game files                                     |
| `./data/asa-server`                                  | Server files                                   |
| `./data/cluster`                                     | Cluster files                                  |
| `./data/asa-data`                                    | Extra data files                               |

---

### Recommended System Requirements

|        | MINIMUM | RECOMMENDED |
| ------ | ------- | ----------- |
| `CPU`  | `2`     | `4`         |
| `RAM`  | `16Gi`  | `24Gi`      |
| `DISK` | `50Gi`  | `75Gi`      |

---

### Usage

#### Docker Compose

If you're planning to change the volume directories, create those directories manually before starting the service.

Then, run the following command to start the server:

``` shell
sudo docker compose up
```

---

### Additional server settings

Advanced Config
For custom settings, edit GameUserSettings.ini in ASA/Saved/Config/WindowsServer. Modify and restart the container.

---
## Temp Fix
If you see this at the end of you logs
``` shell
asa_pve_Server | [2023.11.06-03.55.48:449][  1]Allocator Stats for binned2 are not in this build set BINNED2_ALLOCATOR_STATS 1 in MallocBinned2.cpp
```
you need to run this command first
``` shell
sysctl -w vm.max_map_count=262144
```
if you want to make it permanent
``` shell
sudo -s echo "vm.max_map_count=262144" >> /etc/sysctl.conf && sysctl -p
```
## Hypervisors
If you are using Proxmox as your virtual host make sure to set the CPU Type to "host" in your VM otherwise you'll get errors with the server.

### SERVER_MANAGER
If you want to run rcon_manager.sh download it just place it in the same folder as your docker-compose.yaml make it executable and launch it.

you can also do automatic restart with CronJobs example below

``` shell
0 3 * * * /path/to/start_rcon_manager.sh -restart 10
```
this will schedule a restart every day at 3 AM with a 10-minute countdown

### UPDATING DOCKER IMAGE
Open a terminal or command prompt.

remove old docker image
``` shell
docker rmi acekorneya/asa_server:latest
```
then run this command downloads the latest version of the Ark: Survival Ascended Docker image from Docker Hub.
``` shell
docker pull acekorneya/asa_server:latest
```
Restart the Docker Container

First, bring down your current container with
``` shell
docker-compose down
```
Then, start it again using
``` shell
docker-compose up
```
These commands stop the currently running container and start a new one with the updated image.

## Star History

<a href="https://star-history.com/#Acekorneya/Ark-Survival-Ascended-Server&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=Acekorneya/Ark-Survival-Ascended-Server&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=Acekorneya/Ark-Survival-Ascended-Server&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=Acekorneya/Ark-Survival-Ascended-Server&type=Date" />
  </picture>
</a>