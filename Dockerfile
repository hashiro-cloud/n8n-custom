# Start from the official n8n image, which is based on Alpine Linux
FROM n8nio/n8n:latest

# Switch to the root user to install system packages
USER root

# Install all necessary dependencies in a single, robust command.
# This includes a minimal XFCE desktop environment for VNC to use,
# which solves the "no desktop session" error permanently.
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        firefox \
        tigervnc \
        xfce4 \
        xfce4-terminal \
        dbus

# Use pip to install the latest version of yt-dlp.
# The --break-system-packages flag is required for modern images.
RUN pip install --no-cache-dir -U yt-dlp --break-system-packages

# Create the VNC configuration directory for the 'node' user
RUN mkdir -p /home/node/.vnc && \
    # Create the xstartup file that VNC will run. This starts the XFCE desktop.
    echo '#!/bin/sh\n/usr/bin/startxfce4' > /home/node/.vnc/xstartup && \
    # Make the startup file executable
    chmod +x /home/node/.vnc/xstartup && \
    # Ensure the 'node' user owns all the files
    chown -R node:node /home/node/.vnc

# Create the directory for Firefox profiles and set ownership
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

# Expose the VNC port
EXPOSE 5901

# Switch back to the non-privileged 'node' user for security
USER node

# Set the working directory for the node user
WORKDIR /home/node
