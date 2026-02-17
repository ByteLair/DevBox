FROM ubuntu:22.04

# Evita prompts interativos durante instalação
ENV DEBIAN_FRONTEND=noninteractive

# Configure timezone and locale
ENV TZ=UTC
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Atualiza e instala ferramentas básicas
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    sudo \
    openssh-server \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Configura locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# Instala Node.js (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Instala Python 3 e pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Cria usuário developer sem senha (acesso via VS Code Remote)
RUN useradd -m -s /bin/bash -u 1000 developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

# Configura SSH para VS Code Remote
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Cria diretório .ssh para o developer (chave será configurada em runtime)
RUN mkdir -p /home/developer/.ssh && \
    chmod 700 /home/developer/.ssh && \
    chown -R developer:developer /home/developer/.ssh

# Define o usuário padrão
USER developer
WORKDIR /home/developer

# Configura git defaults
RUN git config --global init.defaultBranch main

# Volta para root para expor porta SSH
USER root
EXPOSE 22

# Script de inicialização
COPY --chown=root:root entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
