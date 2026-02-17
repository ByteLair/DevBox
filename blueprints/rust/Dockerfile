# ByteLair DevBox - Rust Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Rust workspace with stable and nightly toolchains"
LABEL version="1.1.0"

# Configure timezone and locale
ENV TZ=UTC
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    git \
    curl \
    wget \
    vim \
    nano \
    build-essential \
    # Rust dependencies
    pkg-config \
    libssl-dev \
    # Debugger
    gdb \
    lldb \
    # Additional tools
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Rust (stable and nightly)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Set Rust environment
ENV PATH="/root/.cargo/bin:$PATH"

# Install Rust components and tools
RUN rustup component add rustfmt clippy rust-analyzer && \
    rustup toolchain install nightly && \
    cargo install cargo-watch cargo-edit cargo-audit cargo-outdated cargo-tree

# Create developer user
RUN useradd -m -s /bin/bash -G sudo developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Rust for developer user
USER developer
WORKDIR /home/developer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt clippy rust-analyzer && \
    rustup toolchain install nightly

USER root

# Configure SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Setup developer environment
RUN mkdir -p /home/developer/.ssh && \
    chown -R developer:developer /home/developer

# Set working directory
WORKDIR /home/developer

# Expose ports
EXPOSE 22 8080

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
