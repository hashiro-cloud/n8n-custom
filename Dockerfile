# Start from the official n8n image
FROM n8nio/n8n:latest

# Switch to root to configure permissions
USER root

# ---------------------------------------------------------------------------
# 🚫 REMOVED: Package Installation
# The latest n8n image is "locked down" and does not allow installing
# external tools like Python or FFmpeg easily.
# Since you removed yt-dlp/vnc, we can skip this and stop the build errors.
# ---------------------------------------------------------------------------

# Optional: Create specific directories if your workflows need them
# RUN mkdir -p /home/node/local-files && chown -R node:node /home/node/local-files

# Switch back to the standard n8n user
USER node
