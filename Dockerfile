FROM alpine:latest AS fetcher

ARG TARGETPLATFORM
ARG VERSION
WORKDIR /tmp

RUN apk --no-cache add curl unzip

RUN case "$TARGETPLATFORM" in \
  "linux/arm64") ARCH=aarch64-unknown-linux-musl ;; \
  "linux/amd64") ARCH=x86_64-unknown-linux-gnu ;; \
  *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
  esac && \
  URL=https://github.com/rapiz1/rathole/releases/download/v${VERSION}/rathole-${ARCH}.zip && \
  curl -L "$URL" -o rathole.zip && \
  unzip rathole.zip && \
  mv rathole /usr/local/bin/rathole && \
  chmod +x /usr/local/bin/rathole

FROM debian:stable-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /app/start.sh
COPY --from=fetcher /usr/local/bin/rathole /usr/local/bin/rathole

RUN chmod +x /app/start.sh && \
    useradd -u 1000 -m rathole && \
    chown -R rathole:rathole /app

USER rathole

# Default to running the startup script
ENTRYPOINT ["/app/start.sh"]
