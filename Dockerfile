FROM ghcr.io/linuxserver/baseimage-rdesktop-web:arm64v8-focal

LABEL org.opencontainers.image.authors="github@sytone.com"
LABEL org.opencontainers.image.source="https://github.com/sytone/obsidian-remote"
LABEL org.opencontainers.image.title="Container hosted Obsidian MD"
LABEL org.opencontainers.image.description="Hosted Obsidian instance allowing access via web browser"

RUN \
    echo "**** install packages ****" && \
        # Update and install extra packages.
        apt-get update && \
        apt-get install -y --no-install-recommends \
            # Packages needed to download and extract obsidian.
            curl \
            libnss3 \
            # Install Chrome dependencies.
            dbus-x11 \
            uuid-runtime \
            # obsidian.AppImage: error while loading shared libraries: libz.so: cannot open shared object file: No such file or directory
            #  https://github.com/AppImage/AppImageKit/issues/964 for solution
            zlib1g-dev && \
    echo "**** cleanup ****" && \
        apt-get autoclean && \
        rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# set version label
ARG OBSIDIAN_VERSION=0.14.15

RUN \
    echo "**** download obsidian ****" && \
        curl \
        https://github.com/obsidianmd/obsidian-releases/releases/download/v$OBSIDIAN_VERSION/Obsidian-$OBSIDIAN_VERSION-arm64.AppImage \
        -L \
        -o obsidian.AppImage

RUN \
    echo "**** extract obsidian ****" && \
        chmod +x /obsidian.AppImage && \
        /obsidian.AppImage --appimage-extract

ENV \
    CUSTOM_PORT="8080" \
    GUIAUTOSTART="true" \
    HOME="/vaults" \
    TITLE="Obsidian v$OBSIDIAN_VERSION"

# add local files
COPY root/ /

EXPOSE 8080
EXPOSE 27123
EXPOSE 27124
VOLUME ["/config","/vaults"]


