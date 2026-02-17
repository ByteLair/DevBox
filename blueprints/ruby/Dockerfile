# ByteLair DevBox - Ruby Blueprint
FROM ubuntu:24.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Ruby workspace with Rails, rbenv, PostgreSQL, Redis"
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
    # Ruby dependencies
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libyaml-dev \
    libsqlite3-dev \
    sqlite3 \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    # Database
    postgresql-16 \
    postgresql-contrib \
    libpq-dev \
    redis-server \
    # JavaScript runtime for Rails
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install rbenv and ruby-build
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv && \
    git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build && \
    /usr/local/rbenv/plugins/ruby-build/install.sh

ENV PATH="/usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH"

# Install Ruby 3.3.0
RUN rbenv install 3.3.0 && \
    rbenv global 3.3.0 && \
    eval "$(rbenv init -)" && \
    gem install bundler rails

# Configure PostgreSQL
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE USER developer WITH PASSWORD 'devpass' CREATEDB;" && \
    sudo -u postgres psql -c "CREATE DATABASE devdb OWNER developer;" && \
    service postgresql stop

# Create developer user
RUN useradd -m -s /bin/bash -G sudo developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup rbenv for developer user
USER developer
WORKDIR /home/developer
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    ~/.rbenv/bin/rbenv install 3.3.0 && \
    ~/.rbenv/bin/rbenv global 3.3.0

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
EXPOSE 22 3000 5432 6379

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
