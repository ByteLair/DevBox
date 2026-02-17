# ByteLair DevBox - DevOps Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="DevOps workspace with Terraform, Ansible, Kubernetes, Docker, Cloud CLIs"
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
    # Docker
    docker.io \
    docker-compose \
    # Python (for Ansible)
    python3 \
    python3-pip \
    # Utilities
    jq \
    unzip \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install yq (YAML processor)
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Install Ansible
RUN pip3 install --no-cache-dir ansible ansible-lint

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install k9s (Kubernetes TUI)
RUN curl -sS https://webinstall.dev/k9s | bash

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && apt-get install -y google-cloud-sdk && \
    rm -rf /var/lib/apt/lists/*

# Install Pulumi
RUN curl -fsSL https://get.pulumi.com | sh
ENV PATH="/root/.pulumi/bin:$PATH"

# Install HashiCorp Vault
RUN apt-get update && apt-get install -y vault && rm -rf /var/lib/apt/lists/*

# Install Prometheus tools
RUN wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz && \
    tar xvfz prometheus-*.tar.gz && \
    mv prometheus-*/promtool /usr/local/bin/ && \
    rm -rf prometheus-*

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

# Set working directory
WORKDIR /home/developer

# Expose SSH port
EXPOSE 22

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
