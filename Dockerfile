# Start from the official n8n image
FROM n8nio/n8n:latest

# Switch to root user
USER root

# -------------------------------------------------------
# FIX: Re-install apk-tools (removed in n8n v2+)
# -------------------------------------------------------
RUN wget -q https://dl-cdn.alpinelinux.org/alpine/v3.20/main/x86_64/apk-tools-static-2.14.4-r0.apk && \
    tar -xzf apk-tools-static-*.apk && \
    mv sbin/apk.static /sbin/apk && \
    rm apk-tools-static-*.apk && \
    # Initialize apk
    apk update

# -------------------------------------------------------
# NOW your original install commands will work
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

# Setup VNC (Your original config)
RUN mkdir -p /home/node/.vnc && \
    echo '#!/bin/sh\n/usr/bin/startxfce4' > /home/node/.vnc/xstartup && \
    chmod +x /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

# Setup Mozilla profile folder
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

# Expose VNC port
EXPOSE 5901

# Switch back to node user
USER node
WORKDIR /home/node
