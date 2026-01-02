# Stage 1: Get tools from a real Alpine image
FROM alpine:latest AS builder
RUN apk add --no-cache \
    perl perl-utils tigervnc xvfb xfce4 xfce4-terminal dbus \
    python3 py3-pip firefox ffmpeg wget tar

# Stage 2: The actual n8n image
FROM n8nio/n8n:latest
USER root

# Copy the tools from the builder stage to n8n
COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /lib /lib
COPY --from=builder /usr/share /usr/share

# Install yt-dlp using the python we just moved
RUN python3 -m pip install --no-cache-dir -U yt-dlp --break-system-packages

# Fix XFCE/VNC Startup (The Xsession error fix)
RUN mkdir -p /home/node/.vnc && \
    echo -e "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4 &" > /home/node/.vnc/xstartup && \
    chmod 755 /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

# Set permissions for downloads
RUN mkdir -p /home/node/downloads && chown -R node:node /home/node/downloads

USER node
WORKDIR /home/node
ENV DISPLAY=:1
EXPOSE 5901
