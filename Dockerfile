# Change 'latest' to 'latest-alpine' to ensure 'apk' is available
FROM n8nio/n8n:latest-alpine

# You MUST switch to root to use apk
USER root

# Now your original command will work perfectly
RUN apk update && apk add --no-cache \
    perl \
    perl-utils \
    tigervnc \
    xvfb \
    xfce4 \
    xfce4-terminal \
    dbus \
    python3 \
    py3-pip \
    firefox \
    ffmpeg

# Install yt-dlp
RUN python3 -m pip install --no-cache-dir -U yt-dlp --break-system-packages

# ... (rest of your original file remains the same)

# Switch back to the node user at the end for security
USER node

# 3. Create the missing Xsession that TigerVNC is looking for
RUN mkdir -p /etc/X11/xinit/ && \
    echo -e "#!/bin/sh\nexec startxfce4" > /etc/X11/xinit/xinitrc && \
    chmod +x /etc/X11/xinit/xinitrc

# 4. Configure the node user's VNC startup
RUN mkdir -p /home/node/.vnc && \
    echo -e "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4 &" > /home/node/.vnc/xstartup && \
    chmod 755 /home/node/.vnc/xstartup && \
    chown -R node:node /home/node/.vnc

# Set permissions for the downloads folder
RUN mkdir -p /home/node/downloads && chown -R node:node /home/node/downloads

USER node
WORKDIR /home/node
ENV DISPLAY=:1
EXPOSE 5901
