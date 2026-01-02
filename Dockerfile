# Start from n8n v2
FROM n8nio/n8n:latest

USER root

# -------------------------------------------------------
# FIX: Re-install apk in n8n v2 (Distroless fix)
# -------------------------------------------------------
RUN ARCH=$(uname -m) && \
    wget -qO- "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/" | \
    grep -o 'href="apk-tools-static-[0-9][^"]*\.apk"' | sed 's/href="//' | head -1 > /tmp/apk_name.txt && \
    APK_PACKAGE=$(cat /tmp/apk_name.txt) && \
    wget -q "https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/${ARCH}/${APK_PACKAGE}" && \
    tar -xzf ${APK_PACKAGE} && \
    mv sbin/apk.static /sbin/apk && \
    rm ${APK_PACKAGE} /tmp/apk_name.txt && \
    # Now we can finally use apk
    apk update

# -------------------------------------------------------
# Install your dependencies
# -------------------------------------------------------
RUN apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        firefox \
        tigervnc \
        xfce4 \
        xfce4-terminal \
        dbus

# Install yt-dlp
RUN pip install --no-cache-dir -U yt-dlp --break-system-packages

# Setup VNC Configuration
RUN mkdir -p /home/node/.vnc && \
    echo '#!/bin/sh\n/usr/bin/startxfce4' > /home/node/.vnc/xstartup && \
    chmod +x /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

# Mozilla profiles
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

EXPOSE 5901

USER node
WORKDIR /home/node
