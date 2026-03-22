# escape=`
FROM lacledeslan/steamcmd AS jb3-builder

# Download Jabroni Brawl: Episode 3 Dedicated Server
RUN mkdir --parents /output &&`
    /app/steamcmd.sh +force_install_dir /output +login anonymous +app_update 869800 validate +quit;

# Copy test scripts
COPY ./dist/linux/ll-tests /output/ll-tests

#=======================================================================
FROM debian:trixie-slim

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

HEALTHCHECK NONE

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        ca-certificates locales locales-all tmux &&`
    apt-get clean &&`
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment &&`
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

LABEL com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="Jabroni Brawl: Episode 3 Dedicated Server" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-jabronibrawl3"

# Set up Environment
RUN useradd --home /app --gid root --system JabroniBrawl3 &&`
    mkdir --parents /app/.steam/sdk64 &&`
    chown JabroniBrawl3:root -R /app;

COPY --chown=JabroniBrawl3:root --from=jb3-builder /output /app

RUN chmod +x /app/ll-tests/*.sh &&`
    echo $'\n\nLinking steamclient.so to prevent srcds_run errors' &&`
    ln -sf /app/linux64/steamclient.so /app/.steam/sdk64/steamclient.so

USER JabroniBrawl3

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
