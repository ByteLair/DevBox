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
    # Tailscale
    ca-certificates \
    iptables \
    ip6tables

# Install Tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/alpine/tailscale_1.58.2_amd64.apk -o /tmp/tailscale.apk && \
    apk add --allow-untrusted /tmp/tailscale.apk && \
    rm /tmp/tailscale.apk

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
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to developer user for runtime
USER developer

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
