# ByteLair DevBox - Web Frontend Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Web Frontend workspace with React, Vue, Angular, Tailwind CSS"
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
    # Browsers for testing
    chromium-browser \
    firefox \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Node.js 20 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install frontend tooling
RUN npm install -g \
    # Framework CLIs
    create-react-app \
    @vue/cli \
    @angular/cli \
    create-next-app \
    create-vite \
    # Build tools
    vite \
    webpack \
    webpack-cli \
    parcel \
    # CSS tools
    tailwindcss \
    postcss \
    autoprefixer \
    sass \
    # Package managers
    yarn \
    pnpm \
    # TypeScript
    typescript \
    # Linters/Formatters
    eslint \
    prettier \
    stylelint \
    # Testing
    jest \
    vitest \
    @playwright/test \
    cypress \
    # Dev servers
    serve \
    http-server \
    browser-sync

# Create developer user
RUN useradd -m -s /bin/bash -G sudo developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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
EXPOSE 22 3000 4200 5173 8080

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
