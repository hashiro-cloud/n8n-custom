# Start from the official n8n image (Alpine Linux based)
FROM n8nio/n8n:2.0.2

# Switch to root to install packages
USER root

# 1. Install System Dependencies
# REMOVED: atomicparsley (caused build failure)
# Note: ffmpeg is sufficient for most metadata operations with yt-dlp
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        bash \
        curl \
        firefox \
        tigervnc \
        xfce4 \
        xfce4-terminal \
        dbus

# 2. Install yt-dlp from the Master Branch
# We use the master branch to get the latest fixes for YouTube's anti-bot changes
RUN pip install --no-cache-dir --break-system-packages https://github.com/yt-dlp/yt-dlp/archive/master.zip

# 3. VNC Setup (Desktop Environment)
RUN mkdir -p /home/node/.vnc && \
    echo '#!/bin/sh\n/usr/bin/startxfce4' > /home/node/.vnc/xstartup && \
    chmod +x /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

# 4. Firefox Setup
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

# Expose VNC port
EXPOSE 5901

# Switch back to the standard n8n user
USER node
WORKDIR /home/node
