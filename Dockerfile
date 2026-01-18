# Start from the official n8n image (Always use specific version or latest)
FROM n8nio/n8n:latest

# Switch to root to install system packages
USER root

# 1. Install System Dependencies
# Kept Python & FFmpeg as they are powerful for "Execute Command" nodes
# Removed: firefox, tigervnc, xfce4, dbus (Bloatware since VNC is gone)
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        bash \
        curl

# 2. (Optional) Install Common Python Libs
# If you run python scripts inside n8n, you often need requests or pandas
# RUN pip install --no-cache-dir requests --break-system-packages

# Switch back to the standard n8n user for security
USER node
