# Changelog

All notable changes to ByteLair DevBox will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.1.1] - 2026-02-17

### 🔐 Security Improvements

**Critical security enhancements based on best practices review:**

- **SSH Key Protection**: Removed `ARG SSH_PUBLIC_KEY` and build-time key configuration
  - SSH keys are now configured **only at runtime** via environment variable
  - Prevents keys from being embedded in Docker image layers
  - Eliminates risk of key exposure when publishing images to Docker Hub

- **Process Management**: sshd now runs as PID 1 with proper signal handling
  - Changed from `tail -f /dev/null` to `exec /usr/sbin/sshd -D -e`
  - Ensures clean container shutdowns and proper log output
  - Follows Docker best practices for service containers

- **Resource Limits**: Added compose standalone compatibility
  - Added `mem_limit` and `cpus` directives alongside `deploy.resources`
  - Works correctly with both `docker-compose up` and Swarm mode
  - Eliminates need for `--compatibility` flag

- **Tailscale Safety Guards**: Added checks before using Tailscale commands
  - Verifies `tailscaled` command exists before attempting to start
  - Prevents container initialization failures if Tailscale not installed
  - Shows helpful warning if auth key provided but Tailscale missing
  - Applied to both Ubuntu (`entrypoint.sh`) and Alpine (`entrypoint-alpine.sh`)

- **Documentation Enhancements**:
  - Added recommendation for modern **ed25519** SSH keys over RSA
  - Clear warnings about `NOPASSWD` sudo and its security implications
  - Strong recommendation to use Tailscale VPN or firewall for network security
  - Added security best practices section with actionable guidance

### 🐛 Bug Fixes

- **devops blueprint**: Fixed `yq` installation (not available in apt)
  - Now installs from GitHub releases as binary
- Fixed SSH connection message to show correct port syntax
- Corrected entrypoint service startup messages
## [1.0.1] - 2026-02-17

### 🔒 Security

#### Critical Security Improvements
- **Removed SSH keys from build process** - SSH public keys are now configured only at runtime via `SSH_PUBLIC_KEY` environment variable, preventing keys from being embedded in Docker image history layers
- **sshd as PID 1** - Changed from `tail -f /dev/null` to `exec /usr/sbin/sshd -D -e` for proper signal handling, cleaner logs, and correct container shutdown behavior
- **Enhanced security documentation** - Added comprehensive security best practices section in README

#### Recommended Practices Added
- **ed25519 SSH keys**: Documentation now recommends modern ed25519 keys over RSA
- **Network security warnings**: Clear warnings about not exposing containers directly to internet
- **Tailscale VPN recommendation**: Emphasized secure remote access via Tailscale
- **Sudo access clarification**: Documented passwordless sudo implications and how to disable if needed

### 🐛 Bug Fixes
- Fixed SSH connection message showing placeholder `<port>` instead of actual port number
- Fixed `yq` installation in DevOps blueprint (now installed from GitHub releases instead of apt)
- Added `--ignore-installed` flag to pip in fullstack blueprint to avoid conflicts with system packages

### 🚀 Improvements
- **Docker Compose compatibility** - Added `mem_limit` and `cpus` alongside `deploy.resources` for standalone mode compatibility
- **Python 3.12 support** - Added `--break-system-packages` flag for pip in Ubuntu 24.04 blueprints
- **PostgreSQL 16** - Upgraded fullstack and ruby blueprints to use PostgreSQL 16 on Ubuntu 24.04

### 📖 Documentation
- Improved security section with detailed threat model
- Added recommendations for firewall configuration
- Documented container isolation considerations
- Added backup and data persistence security notes

## [1.1.0] - 2026-02-17

### 🎉 Major Features

#### 12 Specialized Blueprints
Complete rewrite with 12 production-ready development environments:
- **minimal** - Ultra-lightweight Alpine Linux base (~50MB)
- **python** - Data Science with Jupyter, Pandas, NumPy, TensorFlow, Scikit-learn
- **node** - Modern JavaScript/TypeScript with Node 20/18, npm, yarn, pnpm, Bun
- **go** - Go 1.21 with gopls and delve debugger
- **rust** - Rust stable with cargo, rustfmt, clippy
- **php** - PHP 8.2 with Composer, Laravel support, Nginx
- **ruby** - Ruby 3.2 with Rails 7 and Bundler
- **java** - Java 17 LTS with Maven, Gradle, Spring Boot
- **web** - Static site hosting with Nginx
- **fullstack** - MEAN/MERN stack with Node.js, Python, PostgreSQL, Redis
- **ml** - Deep Learning with CUDA support, PyTorch, TensorFlow
- **devops** - Infrastructure tools: Docker, Kubernetes, Terraform, Ansible, AWS CLI

#### Tailscale Integration
- Native Tailscale VPN support in all blueprints
- Access your development environment from anywhere securely
- Zero-config remote access through Tailscale network
- CLI commands: `bytelair tailscale setup/status/remove`
- Auto-detection of Tailscale IP addresses

#### ByteLair CLI v1.1.0
Complete command-line interface for workspace management:
- Project auto-detection (Python, Node.js, Go, Rust, PHP, Ruby, Java)
- One-command workspace creation: `bytelair up`
- Automatic VS Code Remote SSH integration: `bytelair connect`
- Beautiful CLI interface with Rich library
- Template system for all 12 blueprints
- Workspace management: list, stop, restart, destroy
- SSH configuration automation
- Tailscale integration commands

### 🚀 Improvements

#### CI/CD & Automation
- GitHub Actions workflow for automated Docker builds (`build-blueprints.yml`)
- Multi-architecture support (amd64, planned: arm64)
- Automated deployment workflow (`deploy.yml`)
- Self-hosted runner support with configurable parallelism
- Docker Hub automated publishing with multi-tag strategy (latest, X.Y.Z, X.Y, X)

#### Documentation
- Comprehensive Tailscale integration guide
- Blueprint catalog with descriptions and use cases
- Quick start guides for each blueprint
- Network access documentation for remote teams
- CI/CD setup instructions

#### Developer Experience
- Alpine-specific entrypoint for minimal blueprint
- Improved error messages and logging
- Build scripts with progress indicators
- Docker layer caching for faster builds
- Environment variable configuration for SSH keys and Tailscale

### 🔧 Technical Improvements

- **Build System**: Parallel builds support (configurable 3-12 concurrent)
- **Storage**: Persistent volumes for each blueprint
- **Security**: Non-root user by default, sudo access, SSH key-only authentication
- **Networking**: Tailscale mesh networking, port exposure per blueprint
- **Resource Management**: CPU/RAM limits configurable per container

### 📦 Docker Images

All images published to Docker Hub under `lyskdot/devbox-*`:
- Available tags: `latest`, `1.1.0`, `1.1`, `1`
- Size range: 50MB (minimal) to 8GB (ml with CUDA)
- Base images: Alpine 3.19, Ubuntu 22.04
- Multi-layer caching optimization

### 🐛 Bug Fixes

- Fixed Alpine Linux service command compatibility
- Corrected Tailscale installation for Alpine (edge repository)
- Fixed entrypoint.sh path in Dockerfile COPY commands
- Resolved JSON array generation in GitHub Actions workflow
- Fixed Docker Hub authentication in CI/CD pipeline
- Added unzip dependency for Bun installation in node blueprint

### 🔐 Security

- SSH key-only authentication (no passwords)
- Tailscale end-to-end encryption
- Non-root container execution
- Isolated network namespaces
- Secrets management in GitHub Actions

### 📝 Documentation

- Added CHANGELOG.md (this file)
- Blueprint comparison table in README
- Tailscale setup guide (docs/en/TAILSCALE.md)
- CLI documentation (cli/README.md)
- Quick access guides for local and remote setups

## [1.0.0] - 2026-02-16

### Initial Release

- Basic Docker workspace with SSH access
- Node.js 20 LTS and Python 3.10 pre-installed
- VS Code Remote SSH support
- Docker Compose configuration
- Basic documentation
- Single monolithic container approach

---

## Upgrade Guide

### From 1.0.0 to 1.1.0

**Breaking Changes:**
- Moved from monolithic image to specialized blueprints
- CLI installation method changed to use `bytelair` command
- Environment variable structure updated for Tailscale support

**Migration Steps:**

1. **Backup your data:**
   ```bash
   docker cp workspace:/home/developer ~/devbox-backup
   ```

2. **Choose your blueprint:**
   ```bash
   # Install new CLI
   curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/cli/install.sh | bash
   
   # Create workspace with appropriate blueprint
   bytelair up --template python  # or node, go, etc.
   ```

3. **Restore your data:**
   ```bash
   docker cp ~/devbox-backup/. workspace:/home/developer
   ```

4. **Update VS Code SSH config** (if using direct SSH):
   ```
   Host devbox
       HostName localhost
       Port 2222
       User developer
   ```

**New Features Available:**
- Tailscale VPN access: `bytelair tailscale setup`
- Multiple workspaces: `bytelair up --name project-a`
- Auto VS Code connection: `bytelair connect`

---

[1.1.0]: https://github.com/ByteLair/DevBox/releases/tag/v1.1.0
[1.0.0]: https://github.com/ByteLair/DevBox/releases/tag/v1.0.0
