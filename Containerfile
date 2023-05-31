ARG   RIDER_PACKAGE_NAME='rider'
ARG   RIDER_PACKAGE_DESC='A cross-platform .NET IDE by JetBrains.'
ARG   RIDER_PACKAGE_VERSION='2023.1.2'
ARG   RIDER_PACKAGE_DIR="JetBrains Rider-${RIDER_PACKAGE_VERSION}"
ARG   RIDER_SOURCE_FILE="JetBrains.Rider-${RIDER_PACKAGE_VERSION}.tar.gz"
ARG   RIDER_INSTALL_DIR='/usr/share'

FROM  alpine:latest AS downloader
ARG   RIDER_PACKAGE_NAME
ARG   RIDER_PACKAGE_DESC
ARG   RIDER_PACKAGE_VERSION
ARG   RIDER_PACKAGE_DIR
ARG   RIDER_SOURCE_FILE
ARG   RIDER_INSTALL_DIR
WORKDIR /build

RUN   apk --no-cache add curl sed tar

COPY  desktop/rider.desktop "${RIDER_PACKAGE_NAME}.desktop"
COPY  scripts/distrobox-export-all ./

RUN   sed -i "s#Version=#Version=${RIDER_PACKAGE_VERSION}#g" "${RIDER_PACKAGE_NAME}.desktop" && \
      sed -i "s#Exec=#Exec=\"${RIDER_INSTALL_DIR}/${RIDER_PACKAGE_NAME}/bin/rider.sh\" %f#g" "${RIDER_PACKAGE_NAME}.desktop" && \
      sed -i "s/Comment=/Comment=${RIDER_PACKAGE_DESC}/g" "${RIDER_PACKAGE_NAME}.desktop" && \
      
      sed -i "s#RIDER_PACKAGE_NAME#${RIDER_PACKAGE_NAME}#g" distrobox-export-all && \

      curl -O "https://download-cf.jetbrains.com/rider/${RIDER_SOURCE_FILE}" && \
      curl -O "https://download-cf.jetbrains.com/rider/${RIDER_SOURCE_FILE}.sha256" && \
      sha256sum -c "${RIDER_SOURCE_FILE}.sha256" && \

      tar xf "${RIDER_SOURCE_FILE}" && \

      rm -rf "${RIDER_SOURCE_FILE}"


FROM alpine:latest AS distrobox
WORKDIR /build

RUN   apk --no-cache add git wget
RUN   git clone --depth=1 https://github.com/89luca89/distrobox.git --single-branch && \
      cp distrobox/distrobox-host-exec distrobox-host-exec && \
      wget https://github.com/1player/host-spawn/releases/download/$(cat distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O distrobox/host-spawn && \
      cp distrobox/host-spawn host-spawn && \

      rm -rf distrobox


FROM  fedora:38
ARG   RIDER_PACKAGE_NAME
ARG   RIDER_PACKAGE_DIR
ARG   RIDER_INSTALL_DIR

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="All-in-one dotnet development image." \
      maintainer="equals.zero.three@gmail.com"

COPY  --from=distrobox --chmod=755 /build/distrobox-host-exec /build/host-spawn /usr/bin
COPY  --from=downloader --chmod=755 /build/distrobox-export-all /usr/bin

RUN   ln -s /usr/bin/distrobox-host-exec /usr/bin/podman && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/docker && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/docker-compose && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/google-chrome && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/chromium && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/firefox && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/firefox-developer-edition && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/opera && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/microsoft-edge && \
      ln -s /usr/bin/distrobox-host-exec /usr/bin/xdg-open
      

RUN   dnf update -y --allowerasing && \
      dnf install -y --allowerasing \
            # distrobox requires
            bc \
            curl \
            diffutils \
            dnf-plugins-core \
            findutils \
            gnupg2 \
            less \
            lsof \
            ncurses \
            passwd \
            pinentry \
            procps-ng \
            shadow-utils \
            sudo \
            time \
            util-linux \
            wget \
            vte-profile \
            # everything needs git...
            git \
            # xorg
            libXtst \
            # dotnet
            dotnet-sdk-7.0 \
            dotnet-sdk-6.0 \
            aspnetcore-runtime-7.0 \
            aspnetcore-runtime-6.0 \
            mono-complete && \
            
      dnf clean all -y

COPY  --from=downloader --chmod=644 "/build/${RIDER_PACKAGE_NAME}.desktop" "/usr/share/applications/${RIDER_PACKAGE_NAME}.desktop"
COPY  --from=downloader --chown=root:root "/build/${RIDER_PACKAGE_DIR}" "${RIDER_INSTALL_DIR}/${RIDER_PACKAGE_NAME}"
RUN   ln -s "${RIDER_INSTALL_DIR}/${RIDER_PACKAGE_NAME}/bin/rider.sh" "/usr/bin/${RIDER_PACKAGE_NAME}"
