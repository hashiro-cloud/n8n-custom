# Start from the official n8n image
FROM n8nio/n8n:latest

# Switch to the root user to install packages
USER root

# Install only the essentials: python, pip, and ffmpeg.
RUN apk update && apk add --no-cache python3 py3-pip ffmpeg

# Use pip to install the latest version of yt-dlp.
# The --break-system-packages flag is required for modern images.
RUN pip install --no-cache-dir -U yt-dlp --break-system-packages

# Switch back to the non-privileged 'node' user for security
USER node
