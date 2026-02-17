# Changelog

All notable changes to ByteLair DevBox will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.2.0] - 2026-02-17

### 🔐 Security Enhancements

**SSH Protection & Monitoring:**
- **Audit Logging**: All SSH access attempts logged to `/var/log/devbox/audit.log`
  - Tracks user, source IP, and commands executed via custom audit wrapper
  - Container lifecycle events logged (startup, shutdown, errors)
  - Essential for security audits, compliance, and debugging
  - Wrapper script: `/usr/local/bin/ssh-audit-wrapper.sh`

- **SSH Rate Limiting**: iptables-based brute force protection
  - Limits connections to 4 per minute per IP address
  - Automatically logs blocked attempts to audit log
  - Requires `--cap-add=NET_ADMIN` (gracefully degrades if not available)
  - Non-breaking: works with or without NET_ADMIN capability
  - Uses dedicated SSH_RATELIMIT chain for clean iptables rules

- **GitHub Actions Security**: Protection against fork PR attacks
  - Secrets only exposed to trusted sources (same repository)
  - Prevents malicious forks from accessing Docker Hub credentials
  - Blocks `pull_request_target` and external forks
  - Applied to build-blueprints.yml workflow

### 🎯 User Experience

**Interactive Onboarding:**
- **`bytelair init`** - New setup wizard for first-time users (390 lines)
  - Auto-detects existing SSH keys (ed25519, RSA, ECDSA)
  - Creates new ed25519 keys if none found
  - Detects project type from current directory (`package.json`, `requirements.txt`, etc.)
  - Recommends appropriate blueprint based on project detection
  - Optional Tailscale configuration
  - Saves preferences to `~/.bytelair/config.json`
  - Rich table display of all 12 available blueprints

**Improved Error Messages:**
- Helpful error messages with suggested next actions
- Clear guidance when workspace not found (shows `list`, `up`, `init`)
- Recommendations for common issues in all commands
- Better "workspace not found" messages with next steps

**Progress Bars:**
- Rich progress indicators for Docker image pulls
- Visual feedback during long operations (download, extract, verify)
- Detailed pull status messages showing layers and progress
- Integrated into `bytelair up` command

### 📸 Workspace Management

**Snapshot System** (`cli/snapshots.py` - 295 lines):
- **`bytelair snapshot-create`** - Create workspace snapshots
  - Uses Docker commit for efficient state preservation
  - Optional snapshot name and description message
  - Metadata tracking in `~/.bytelair/snapshots/metadata.json`
  - Shows snapshot size and image ID

- **`bytelair snapshot-list`** - View all snapshots
  - Rich table display with name, workspace, created date, size, status
  - Filter by workspace with `--workspace` flag
  - Shows total snapshots count and combined size
  - Indicates if snapshot image still exists

- **`bytelair snapshot-restore`** - Restore from snapshot
  - Creates new workspace from snapshot state
  - Custom workspace name support
  - Configurable SSH port
  - Shows connection instructions after restore

- **`bytelair snapshot-delete`** - Remove snapshots
  - Confirmation prompt (bypass with `--force`)
  - Removes both Docker image and metadata
  - Graceful handling of missing images

### ⚙️ Settings Synchronization

**Settings Sync** (`cli/sync.py` - 279 lines):
- **`bytelair sync-settings`** - Sync VS Code settings
  - Bidirectional: push (local→workspace) or pull (workspace→local)
  - Syncs `settings.json` and `keybindings.json`
  - Target: `.vscode-server/data/Machine/` directory
  - Auto-detection of VS Code directory (Linux/macOS)

- **`bytelair sync-dotfiles`** - Sync configuration files
  - Supported: `.bashrc`, `.gitconfig`, `.zshrc`, `.vimrc`, `.tmux.conf`
  - Custom file list with `--files` parameter
  - Progress bars showing sync status per file
  - Automatic backup of local files when pulling (.backup extension)

- **`bytelair sync-extensions`** - Export extension list
  - Saves installed VS Code extensions to file
  - Location: `~/.bytelair/{workspace}-extensions.txt`
  - Shows installation command for workspace
  - Requires VS Code CLI (`code` command)

### 🔌 Port Management

**Port Commands:**
- **`bytelair port-list`** - Display all exposed ports
  - Rich table with container port, protocol, host port, host IP
  - Auto-detection of common services (SSH, HTTP)
  - Shows connection strings for recognized ports (ssh -p, http://localhost)
  - Clear formatting distinguishing SSH (22), web (3000, 8080), etc.

- **`bytelair port-add`** - Guide for dynamic port forwarding
  - Explains Docker limitations (can't add ports to running containers)
  - Shows SSH port forwarding alternative
  - Lists current port mappings for context
  - Educational command with practical examples

### 🏥 Health Monitoring

**Container Health Checks:**
- Added `HEALTHCHECK` directive to **all 13 Dockerfiles** (main + 12 blueprints)
  - Monitors SSH daemon responsiveness on port 22
  - Interval: 30s, timeout: 3s, start-period: 5s, retries: 3
  - Uses netcat (`nc -z localhost 22`) for lightweight check
  - Visible in `docker ps` output
  - Enables automatic restart policies based on health

### 🌍 Environment Configuration

**Timezone & Locale:**
- Added to **all Dockerfiles** (main + 12 blueprints)
  - `ENV TZ=UTC` - Consistent timezone across all containers
  - `ENV LANG=en_US.UTF-8` - Default locale
  - `ENV LC_ALL=en_US.UTF-8` - Fallback locale
  - Prevents locale-related issues in applications
  - Ensures consistent timestamp behavior

### 📖 Documentation

**README Enhancements:**
- Updated version badge to 1.2.0
- Added v1.2.0 features section with examples
- Interactive onboarding documentation
- Snapshot system usage examples
- Settings sync commands and workflows
- Port management guide
- Security features documentation (rate limiting, audit logging)
- Health monitoring explanation

**CHANGELOG Improvements:**
- Comprehensive v1.2.0 section (this file)
- Detailed feature descriptions with file references
- Breaking changes (none - all features backward compatible)
- Technical details for each new feature

### 🛠️ Technical Improvements

**Code Quality:**
- All Python code passes `py_compile` syntax checks
- Rich library integration for beautiful CLI output
- Progress tracking with spinners and bars
- Consistent error handling across all commands
- Type hints in new modules (`Optional`, `List`, `Dict`)

**Architecture:**
- Modular design: `snapshots.py`, `sync.py` as separate concerns
- Reusable components (`SettingsSync`, `SnapshotManager` classes)
- Docker Python SDK for container operations
- In-memory tar operations for efficient file transfer

### 📦 Commits

- `b8bc0a6` - feat: add health checks to all 12 blueprints (v1.2.0)
- `793c594` - feat: add v1.2.0 UX improvements and snapshot system
- `ed0ca64` - feat: add settings sync and port management (v1.2.0)
- `c9938f3` - security: add SSH rate limiting, audit logging, onboarding wizard
- `a791c50` - docs: add v1.2.0 section to CHANGELOG

### ⚠️ Breaking Changes

**None** - All features are additive and backward compatible:
- Existing workspaces continue to work without changes
- New security features gracefully degrade if capabilities not available
- New CLI commands don't interfere with existing workflows
- Environment variables (TZ, LANG, LC_ALL) are non-breaking defaults

### 🔄 Migration Notes

**For existing users:**
1. Pull latest images: `docker pull lyskdot/devbox-*:latest`
2. Recreate containers to get health checks and security features
3. Optional: Enable rate limiting with `--cap-add=NET_ADMIN`
4. Optional: Try new snapshot feature: `bytelair snapshot-create <workspace>`

**For new users:**
1. Install/update CLI: `curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/cli/install.sh | bash`
2. Run interactive setup: `bytelair init`
3. Create workspace: `bytelair up`
4. Connect: `bytelair connect`

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
