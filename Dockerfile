# Start from the official n8n image (Alpine Linux based)
FROM n8nio/n8n:2.0.2

# Switch to root to install packages
USER root

# 1. Install System Dependencies
# Added 'atomicparsley' -> Required for embedding thumbnails/metadata into MP3s
# Added 'bash' & 'curl' -> Useful utilities for debugging
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        atomicparsley \
        bash \
        curl \
        firefox \
        tigervnc \
        xfce4 \
        xfce4-terminal \
        dbus

# 2. Install yt-dlp from the Master Branch (CRITICAL FIX)
# The standard 'pip install yt-dlp' is too old for the current "n-token" challenges.
# Installing from the master zip ensures you have the absolute latest fixes.
RUN pip install --no-cache-dir --break-system-packages https://github.com/yt-dlp/yt-dlp/archive/master.zip

# 3. VNC Setup (Desktop Environment)
# Creates the startup script for XFCE so you can VNC in if needed
RUN mkdir -p /home/node/.vnc && \
    echo '#!/bin/sh\n/usr/bin/startxfce4' > /home/node/.vnc/xstartup && \
    chmod +x /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

# 4. Firefox Setup
# Ensures the node user has ownership of the Mozilla directory for cookies/profiles
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

# Expose VNC port
EXPOSE 5901

# Switch back to the standard n8n user
USER node
WORKDIR /home/node
