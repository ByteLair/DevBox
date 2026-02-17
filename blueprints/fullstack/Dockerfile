# ByteLair DevBox - Full Stack Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Full Stack workspace with Node.js, Python, PostgreSQL, Redis, Nginx"
LABEL version="1.1.0"

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
    # Database servers
    postgresql-15 \
    postgresql-contrib \
    redis-server \
    # Web servers
    nginx \
    # Docker
    docker.io \
    docker-compose \
    # Python
    python3.11 \
    python3-pip \
    python3-dev \
    # Database clients
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Node.js 20 LTS
ENV NODE_VERSION=20.11.0
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js global packages
RUN npm install -g \
    yarn \
    pnpm \
    typescript \
    ts-node \
    pm2 \
    prisma \
    @prisma/client \
    typeorm \
    sequelize-cli

# Install Python packages
RUN pip3 install --no-cache-dir \
    fastapi \
    uvicorn \
    django \
    flask \
    sqlalchemy \
    psycopg2-binary \
    redis \
    celery \
    poetry \
    black \
    ruff

# Configure PostgreSQL
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE USER developer WITH PASSWORD 'devpass' CREATEDB;" && \
    sudo -u postgres psql -c "CREATE DATABASE devdb OWNER developer;" && \
    service postgresql stop

# Configure Redis
RUN sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf

# Create developer user
RUN useradd -m -s /bin/bash -G sudo,docker developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Setup developer environment
RUN mkdir -p /home/developer/.ssh && \
    chown -R developer:developer /home/developer

# Create startup script for services
RUN echo '#!/bin/bash\n\
service postgresql start\n\
service redis-server start\n\
service nginx start\n\
' > /usr/local/bin/start-services.sh && \
    chmod +x /usr/local/bin/start-services.sh

# Set working directory
WORKDIR /home/developer

# Expose ports
EXPOSE 22 3000 5000 5432 5173 6379 8000 8080 80

# Copy entrypoint
COPY ../entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
