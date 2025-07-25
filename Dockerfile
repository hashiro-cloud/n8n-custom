# Start from the official n8n image, which is based on Alpine Linux
FROM n8nio/n8n:latest

# Switch to the root user to install system packages
USER root

# Install all necessary dependencies for n8n, yt-dlp, and the new cookie tool
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        git \
        nodejs \
        npm \
        # Dependencies for firefox-logins-fetcher
        build-base \
        python3-dev \
        libffi-dev

# Use pip to install the latest versions of yt-dlp and the cookie fetcher
# The --break-system-packages flag is required.
RUN pip install --no-cache-dir -U \
    yt-dlp \
    firefox-logins-fetcher \
    --break-system-packages

# Create the directory where Firefox profiles will be stored
# and ensure the 'node' user (which n8n runs as) owns it.
RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

# Switch back to the non-privileged 'node' user for security
USER node

# Set the working directory for the node user
WORKDIR /home/node
