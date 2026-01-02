# --- Stage 1: Build Tools (Alpine) ---
FROM alpine:latest AS builder
RUN apk add --no-cache \
    perl perl-utils tigervnc xvfb xfce4 xfce4-terminal dbus \
    python3 py3-pip firefox ffmpeg wget tar apk-tools-static

# --- Stage 2: Final n8n Image ---
FROM n8nio/n8n:latest
USER root

# Copy tools from builder
COPY --from=builder /usr/bin /usr/bin
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /lib /lib
COPY --from=builder /usr/share /usr/share
COPY --from=builder /sbin/apk.static /sbin/apk

# Install yt-dlp
RUN python3 -m pip install --no-cache-dir -U yt-dlp --break-system-packages

# 1. Setup VNC Config
RUN mkdir -p /home/node/.vnc && \
    echo -e "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4 &" > /home/node/.vnc/xstartup && \
    chmod 755 /home/node/.vnc/xstartup

# 2. Create the wrapper script
RUN echo -e '#!/bin/sh\n\
# Clean up old VNC locks\n\
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1\n\
\n\
# Start VNC Server in background (No password for now)\n\
vncserver :1 -geometry 1280x800 -depth 24 -SecurityTypes None\n\
\n\
# Call the ORIGINAL n8n entrypoint to start n8n properly\n\
exec /docker-entrypoint.sh "$@"' > /entrypoint-vnc.sh && \
chmod +x /entrypoint-vnc.sh

# Final permissions
RUN chown -R node:node /home/node
USER node
ENV DISPLAY=:1
EXPOSE 5678 5901

# 3. Use our new script as the entrypoint
ENTRYPOINT ["/entrypoint-vnc.sh"]
