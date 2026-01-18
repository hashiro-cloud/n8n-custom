# Start from the official n8n image
FROM n8nio/n8n:latest

# Switch to root to perform the "jailbreak"
USER root

# 1. THE FIX: Re-install 'apk' (Package Manager)
# n8n v2 removed 'apk' to save space. We must manually download a static version to use it again.
RUN echo "⬇️ Restoring Package Manager..." && \
    # Download the static apk-tools from Alpine's latest stable repository
    wget -q -O apk-tools-static.tar.gz https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/x86_64/apk-tools-static-2.14.8-r0.apk || \
    # Fallback if specific version fails, try finding the latest via directory listing (simplified logic)
    wget -q -O apk-tools-static.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.20/main/x86_64/apk-tools-static-2.14.4-r0.apk && \
    # Extract it
    tar -xzf apk-tools-static.tar.gz && \
    # Install the full apk-tools using the static binary
    ./sbin/apk.static add --no-cache apk-tools && \
    # Clean up the static binary
    rm apk-tools-static.tar.gz ./sbin/apk.static

# 2. Install Your Tools (Python, FFmpeg)
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
