# ByteLair DevBox - Machine Learning Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="Machine Learning workspace with TensorFlow, PyTorch, Jupyter, MLflow"
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
    # Python and ML dependencies
    python3.11 \
    python3-pip \
    python3-dev \
    # System libraries for ML
    libhdf5-dev \
    libopenblas-dev \
    liblapack-dev \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Upgrade pip
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Install ML frameworks and tools
RUN pip3 install --no-cache-dir \
    # Deep Learning frameworks
    tensorflow \
    torch \
    torchvision \
    torchaudio \
    # JAX (Google's ML framework)
    jax \
    jaxlib \
    # Jupyter
    jupyter \
    jupyterlab \
    notebook \
    # Data science stack
    pandas \
    numpy \
    scipy \
    scikit-learn \
    matplotlib \
    seaborn \
    plotly \
    # ML utilities
    transformers \
    datasets \
    tokenizers \
    # MLOps
    mlflow \
    wandb \
    dvc \
    # Computer Vision
    opencv-python \
    pillow \
    albumentations \
    # NLP
    spacy \
    nltk \
    gensim \
    # Model deployment
    onnx \
    onnxruntime \
    # Utilities
    tqdm \
    python-dotenv \
    ipywidgets

# Download spaCy model
RUN python3 -m spacy download en_core_web_sm

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
EXPOSE 22 8888 5000

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
