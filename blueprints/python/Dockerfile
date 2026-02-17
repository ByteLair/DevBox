# ByteLair DevBox - Python Data Science Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Python Data Science workspace with Jupyter, Pandas, NumPy, Scikit-learn"
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
    # Python dependencies
    python3.11 \
    python3.10 \
    python3-pip \
    python3-dev \
    python3-venv \
    # Database clients
    postgresql-client \
    sqlite3 \
    # Additional tools
    graphviz \
    pkg-config \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv for multi-version Python
RUN curl https://pyenv.run | bash

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Python package managers and tools
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
    # Data Science stack
    jupyter \
    jupyterlab \
    notebook \
    pandas \
    numpy \
    scipy \
    scikit-learn \
    matplotlib \
    seaborn \
    plotly \
    # ML libraries
    tensorflow \
    keras \
    # Package managers
    poetry \
    pdm \
    pipenv \
    # Code quality
    black \
    ruff \
    mypy \
    pylint \
    flake8 \
    # Utilities
    ipython \
    requests \
    python-dotenv \
    pydantic

# Create developer user
RUN useradd -m -s /bin/bash -G sudo developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Setup SSH for developer
RUN mkdir -p /home/developer/.ssh && \
    chown -R developer:developer /home/developer

# Set working directory
WORKDIR /home/developer

# Expose ports
EXPOSE 22 8888

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
