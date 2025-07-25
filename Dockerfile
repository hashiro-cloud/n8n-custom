# Start from the official n8n image, which is based on Alpine Linux
FROM n8nio/n8n:latest

# Switch to the root user to install system packages
USER root

# Combine update and install into a single RUN instruction for efficiency.
# This uses the correct package names for Alpine Linux.
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        firefox \
        tigervnc \
        font-noto-cjk \
        dbus

# Use pip to install the latest version of yt-dlp
RUN pip install --no-cache-dir -U yt-dlp

# Create the directory where Firefox will store its profile data
# and ensure the 'node' user (which n8n runs as) owns it.
# This directory will be part of the main n8n persistent volume.
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

# Expose the VNC port for the one-time login
EXPOSE 5901

# Switch back to the non-privileged 'node' user for security
USER node

# Set the working directory for the node user
WORKDIR /home/node
