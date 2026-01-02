# --- Stage 1: The Builder (Full Alpine) ---
FROM alpine:latest AS builder

# 1. Install every system package you need here
RUN apk add --no-cache \
    perl \
    perl-utils \
    tigervnc \
    xvfb \
    xfce4 \
    xfce4-terminal \
    dbus \
    python3 \
    py3-pip \
    ffmpeg \
    firefox \
    wget \
    tar \
    apk-tools-static

# --- Stage 2: The Final n8n Container ---
FROM n8nio/n8n:latest

USER root

# 2. "Teleport" all tools and libraries from the builder into n8n
COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /lib /lib
COPY --from=builder /usr/share /usr/share
COPY --from=builder /etc/alpine-release /etc/alpine-release
# This specifically restores the 'apk' command to the container
COPY --from=builder /sbin/apk.static /sbin/apk

# 3. Install yt-dlp using the python we just moved
RUN python3 -m pip install --no-cache-dir -U yt-dlp --break-system-packages

# 4. Setup VNC Config
RUN mkdir -p /home/node/.vnc && \
    echo '#!/bin/sh\n/usr/bin/startxfce4' > /home/node/.vnc/xstartup && \
    chmod +x /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

# Set display for VNC
ENV DISPLAY=:1
EXPOSE 5901

# 5. Finalize permissions
RUN mkdir -p /home/node/downloads && chown -R node:node /home/node/downloads

USER node
WORKDIR /home/node
