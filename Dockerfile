# Start from the official n8n image
FROM n8nio/n8n:latest

# Switch to root to perform the "jailbreak"
USER root

# 1. THE FIX: Restore Package Manager (apk)
# We download a known-stable static binary from Alpine v3.19 archives.
# This version works to bootstrap the system, then we update it.
RUN echo "⬇️ Restoring Package Manager..." && \
    wget -q -O apk-tools-static.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.19/main/x86_64/apk-tools-static-2.14.0-r5.apk && \
    tar -xzf apk-tools-static.tar.gz && \
    # Install the full apk-tools using the static binary
    ./sbin/apk.static add --no-cache apk-tools && \
    # Clean up the static binary
    rm apk-tools-static.tar.gz ./sbin/apk.static

# 2. Install Python & FFmpeg
RUN echo "📦 Installing Tools..." && \
    apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        bash \
        curl \
    && rm -rf /var/cache/apk/*

# Switch back to the standard n8n user
USER node
