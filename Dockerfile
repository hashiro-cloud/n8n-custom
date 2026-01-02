# Stage 1: Use a standard Alpine image to collect binaries
FROM alpine:latest AS builder

# Install everything you need here (standard Alpine has apk)
RUN apk update && \
    apk add --no-cache \
        python3 \
        py3-pip \
        ffmpeg \
        firefox \
        tigervnc \
        xfce4 \
        xfce4-terminal \
        dbus \
        tar

# Stage 2: Final n8n image
FROM n8nio/n8n:latest

USER root

# Copy the installed binaries and libraries from the builder stage
COPY --from=builder /usr/bin /usr/bin
# Note: We also need the shared libraries for these apps to run
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /lib /lib
COPY --from=builder /etc/alpine-release /etc/alpine-release

# Install yt-dlp using the python we just moved over
RUN python3 -m pip install --no-cache-dir -U yt-dlp --break-system-packages

# Setup VNC (Your original configuration)
RUN mkdir -p /home/node/.vnc && \
    echo '#!/bin/sh\n/usr/bin/startxfce4' > /home/node/.vnc/xstartup && \
    chmod +x /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

RUN mkdir -p /home/node/.mozilla && chown -R node:node /home/node/.mozilla

EXPOSE 5901

# Switch to node user
USER node
WORKDIR /home/node
