# Use an image that has Wine installed to run Windows applications
# hadolint ignore=DL3007
FROM scottyhardy/docker-wine:latest

# Add ARG for PUID and PGID with a default value
# Setting this here, at build time, does not allow a user to change it at runtime
ARG PUID="1000"
ARG PGID="1000"
ARG INI_FILE_VERSION="1.4.6"
ARG RCON_CLI_VERSION="1.6.4"

ENV DEBIAN_FRONTEND="noninteractive"
# Arguments and environment variables
ENV PUID="${PUID}"
ENV PGID="${PGID}"
ENV WINEPREFIX="/usr/games/.wine"
ENV WINEDEBUG="err-all"
ENV PROGRAM_FILES="$WINEPREFIX/drive_c/POK"
ENV ASA_DIR="$PROGRAM_FILES/Steam/steamapps/common/ARK Survival Ascended Dedicated Server/"

# Set the working directory
WORKDIR /usr/games

# hadolint ignore=DL3002
USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Set the entry point to Supervisord
ENTRYPOINT ["/usr/games/scripts/init.sh"]
HEALTHCHECK --interval=60s --timeout=30s --start-period=60s --retries=3 CMD [ "/usr/games/scripts/healthcheck.sh" ]

# Copy scripts folder into the container
COPY scripts/ /usr/games/scripts/
# Copy defaults folder into the container
COPY defaults/ /usr/games/defaults/

# Install jq, curl, and dependencies for rcon-cli
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install --no-install-recommends --yes jq curl unzip nano bc cron \
  && rm -rf /var/lib/apt/lists/* \
  && curl -sL "https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VERSION}/rcon-cli_${RCON_CLI_VERSION}_linux_amd64.tar.gz" | tar xvz \
  && mv rcon-cli /usr/local/bin/ \
  && chmod +x /usr/local/bin/rcon-cli \
  && curl -sL "https://github.com/bitnami/ini-file/releases/download/v${INI_FILE_VERSION}/ini-file-linux-amd64.tar.gz" | tar xvz \
  && mv ini-file-linux-amd64 /usr/local/bin/ini-file \
  && chmod +x /usr/local/bin/ini-file \
  && mkdir -p "${WINEPREFIX}" "$PROGRAM_FILES" \
  && usermod --shell /bin/bash games \
  && chown -R games:games /usr/games \
  && groupmod -o -g "$PGID" games \
  && usermod -o -u "$PUID" -g games games \
  && sed -i 's/\r//' /usr/games/scripts/*.sh \
  && chmod +x /usr/games/scripts/*.sh \
  && curl -sL https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -o steamcmd.zip \
  && unzip steamcmd.zip -d "${PROGRAM_FILES}/Steam" \
  && rm steamcmd.zip \
  && ln -s "${PROGRAM_FILES}/Steam" "/usr/games/Steam" \
  && mkdir -p "/usr/games/Steam/steamapps/common" \
  && chown -R games:games "${PROGRAM_FILES}" \
  && chown -R games:games "${WINEPREFIX}" \
  # remove comment to include /etc/sudoers.d/
  # && sed -i 's?^#includedir /etc/sudoers.d?includedir /etc/sudoers.d?g' /etc/sudoers \
  # allow games to sudo without a password
  # && echo "games ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/games
  && echo "games ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  # allow games to crontab
  && echo "games" > /etc/cron.d/cron.allow \
  # add games to crontab group
  && usermod -a -G crontab games



# NEED TO FIND A WAY TO NOT HAVE TO RUN THIS AS ROOT
# setting this user does not work. it causes permission issues

USER games
