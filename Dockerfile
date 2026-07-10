FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# HERMES_HOME points at the mounted volume — config, login (auth.json),
# memory, and skills live here so redeploys never lose them.
ENV HERMES_HOME=/data/.hermes
ENV PATH="/data/.hermes/bin:/root/.local/bin:${PATH}"

# System dependencies.
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    bash \
    xz-utils \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Hermes at BUILD time so the whole runtime (Python, Node, Playwright,
# Chromium) is baked into the image. This is what makes container restarts and
# redeploys instant instead of re-running the ~7 min installer every boot.
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# The base installer leaves messaging backends (telegram/discord/slack) for
# lazy-install. Bake the Telegram dependency into the image so it survives every
# redeploy instead of vanishing with the ephemeral container layer.
# Hermes uses a uv-managed venv (no pip inside), so install via uv, targeting
# the venv's interpreter directly.
RUN "${HERMES_HOME}/bin/uv" pip install \
    --python /usr/local/lib/hermes-agent/venv/bin/python \
    "python-telegram-bot[webhooks]==22.6"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]
