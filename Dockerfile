# Start from the official n8n image
FROM n8nio/n8n:latest

# Switch to root to install packages
USER root

# 1. Install System Dependencies
# Changed package manager from 'apk' to 'apt-get' because n8n:latest is Debian-based.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        ffmpeg \
        bash \
        curl && \
    # Clean up to reduce image size
    rm -rf /var/lib/apt/lists/*

# Switch back to the standard n8n user
USER node
