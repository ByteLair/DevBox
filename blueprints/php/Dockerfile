# ByteLair DevBox - PHP Blueprint
FROM ubuntu:22.04

LABEL maintainer="ByteLair <hello@bytelair.dev>"
LABEL description="PHP workspace with Laravel, Composer, MySQL, Nginx"
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
    # PHP and extensions
    php8.1 \
    php8.1-fpm \
    php8.1-cli \
    php8.1-common \
    php8.1-mysql \
    php8.1-zip \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-xml \
    php8.1-bcmath \
    php8.1-redis \
    php8.1-intl \
    # Database
    mysql-server \
    # Web server
    nginx \
    # Build tools
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Laravel installer
RUN composer global require laravel/installer
ENV PATH="/root/.composer/vendor/bin:$PATH"

# Configure MySQL
RUN service mysql start && \
    mysql -e "CREATE USER 'developer'@'localhost' IDENTIFIED BY 'devpass';" && \
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'developer'@'localhost';" && \
    mysql -e "CREATE DATABASE devdb;" && \
    service mysql stop

# Configure Nginx
RUN rm /etc/nginx/sites-enabled/default
COPY nginx-laravel.conf /etc/nginx/sites-available/laravel
RUN ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

# Configure PHP-FPM
RUN sed -i 's/user = www-data/user = developer/' /etc/php/8.1/fpm/pool.d/www.conf && \
    sed -i 's/group = www-data/group = developer/' /etc/php/8.1/fpm/pool.d/www.conf

# Create developer user
RUN useradd -m -s /bin/bash -G sudo,www-data developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Setup developer environment
RUN mkdir -p /home/developer/.ssh /home/developer/public_html && \
    chown -R developer:developer /home/developer

# Install Composer for developer user
USER developer
RUN composer global require laravel/installer
USER root

# Set working directory
WORKDIR /home/developer

# Expose ports
EXPOSE 22 80 3306 8000

# Copy entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check - verify SSH daemon is responsive
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD nc -z localhost 22 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
