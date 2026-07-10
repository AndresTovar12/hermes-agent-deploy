FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies baked into the image at build time.
# These never need to touch the persistent volume.
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    bash \
    && rm -rf /var/lib/apt/lists/*

# HERMES_HOME points at the mounted volume, not the image filesystem.
# Everything Hermes needs to remember (login, config, memory, skills)
# lives here so redeploys and rebuilds never lose it.
ENV HERMES_HOME=/data/.hermes
ENV PATH="${HERMES_HOME}/bin:${PATH}"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /data

ENTRYPOINT ["/entrypoint.sh"]
