# ByteLair DevBox - Minimal Blueprint
# Ultra-lightweight base image without pre-installed dependencies
FROM alpine:3.19

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Minimal DevBox - Alpine Linux with SSH only"
LABEL version="1.1.0"

# Install only essential packages
RUN apk add --no-cache \
    openssh-server \
    bash \
    git \
    curl \
    wget \
    sudo \
    shadow \
    # Tailscale dependencies
    ca-certificates \
    iptables \
    ip6tables

# Install Tailscale (Alpine Edge repository)
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing tailscale

# Create developer user
RUN addgroup -g 1000 developer && \
    adduser -D -u 1000 -G developer -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN ssh-keygen -A && \
    mkdir -p /home/developer/.ssh && \
    chown -R developer:developer /home/developer

# Set working directory
WORKDIR /home/developer

# Expose SSH port
EXPOSE 22

# Copy entrypoint
COPY entrypoint-alpine.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to developer user for runtime
USER developer

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
