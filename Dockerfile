# Start from the official n8n image
FROM n8nio/n8n:latest

# Switch to the root user to install system packages
USER root

# The n8n image is based on Alpine Linux. We update and install all dependencies.
# This includes Python, yt-dlp, ffmpeg, Firefox, and a VNC server for remote access.
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    firefox \
    tigervnc-standalone-server \
    ttf-freefont \
    dbus

# Use pip to install the latest version of yt-dlp
RUN pip install --no-cache-dir -U yt-dlp

# Create the directory where Firefox will store its profile data
# and ensure the 'node' user (which n8n runs as) owns it.
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

# Expose the VNC port
EXPOSE 5901

# Switch back to the non-privileged 'node' user for security
USER node

# Set the working directory for the node user
WORKDIR /home/node

# Set up the VNC server password (run once when you first open the shell)
# And define the command to start both VNC and n8n
# We will run this manually from the Coolify shell for the one-time login.
# The default entrypoint will still start n8n.
