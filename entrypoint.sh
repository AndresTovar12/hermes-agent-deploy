#!/usr/bin/env bash
set -e

# Hermes itself is baked into the image (see Dockerfile). Everything that must
# persist — config.yaml, auth.json (your Codex login), memory, skills — lives on
# the /data volume mounted at $HERMES_HOME.

# If the setup wizard hasn't been run yet, the gateway has nothing to start.
# Keep the container alive so the EasyPanel console stays reachable to run
# `hermes setup`, instead of crash-looping.
if [ ! -f "${HERMES_HOME}/config.yaml" ]; then
    echo "=================================================================="
    echo " No Hermes config found at ${HERMES_HOME}."
    echo " Open this service's console in EasyPanel and run:  hermes setup"
    echo "=================================================================="
    tail -f /dev/null
fi

# Start the messaging gateway in the foreground (this is the long-running
# process that keeps the container up and listens on Telegram).
exec hermes gateway run
