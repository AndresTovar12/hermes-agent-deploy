#!/usr/bin/env bash
set -e

# Install (or update) Hermes into the persistent volume, not the image.
# This is what makes `hermes update` and container rebuilds safe: the
# actual install lives at $HERMES_HOME, which is a mounted volume that
# survives redeploys.
if [ ! -x "${HERMES_HOME}/bin/hermes" ]; then
    echo ">>> First boot: installing Hermes into ${HERMES_HOME} ..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
else
    echo ">>> Hermes already installed at ${HERMES_HOME}, skipping install."
fi

# Try to start the messaging gateway. This only succeeds once `hermes setup`
# has been run interactively at least once (it needs your Codex login and
# Telegram bot token, which can't be automated safely).
if hermes gateway 2>/tmp/gateway_error.log; then
    exit 0
fi

echo ""
echo "=================================================================="
echo " Hermes is installed but not configured yet."
echo " Open this service's console in EasyPanel and run:"
echo ""
echo "     hermes setup"
echo ""
echo " After setup finishes once, restart this service and the gateway"
echo " will start automatically from now on."
echo "=================================================================="

# Keep the container alive (instead of crash-looping) so you have time
# to open the console and run `hermes setup`.
tail -f /dev/null
