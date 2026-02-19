# ByteLair DevBox - Node.js Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Node.js workspace with npm, yarn, pnpm, bun and TypeScript"
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
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Node.js 20 LTS and 18 LTS via nvm
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=20.11.0
ENV NODE_18_VERSION=18.19.0

RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm install $NODE_18_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# Add Node.js to PATH
ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install package managers
RUN npm install -g \
    yarn \
    pnpm \
    npm-check-updates \
    # Build tools
    vite \
    webpack \
    webpack-cli \
    # TypeScript
    typescript \
    ts-node \
    tsx \
    @types/node \
    # Linters/Formatters
    eslint \
    prettier \
    # Process managers
    pm2 \
    nodemon \
    # Testing
    jest \
    vitest \
    # Utilities
    dotenv-cli \
    cross-env

# Install Bun (non-fatal - optional tool)
RUN curl -fsSL https://bun.sh/install | bash || echo "Bun install optional - skipped"
ENV PATH="/root/.bun/bin:$PATH"

# Create developer user
RUN useradd -m -s /bin/bash -G sudo developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Setup for developer user
RUN mkdir -p /home/developer/.ssh && \
    chown -R developer:developer /home/developer && \
    # Install nvm for developer user
    sudo -u developer bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'

# Persist PATH for all SSH login shells (must come after all tool installs)
RUN printf 'export NVM_DIR=%s\nexport PATH=%s/versions/node/v%s/bin:$PATH\n' \
    "${NVM_DIR}" "${NVM_DIR}" "${NODE_VERSION}" \
    > /etc/profile.d/devbox-node.sh && \
    [ -f /root/.bun/bin/bun ] && echo 'export PATH=/root/.bun/bin:$PATH' >> /etc/profile.d/devbox-node.sh || true && \
    chmod +x /etc/profile.d/devbox-node.sh

# Set working directory
WORKDIR /home/developer

# Expose ports
EXPOSE 22 3000 5173 8080

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
