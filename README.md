# 🚀 Docker Development Workspace

[![Version](https://img.shields.io/badge/version-1.2.1-blue.svg)](https://github.com/ByteLair/DevBox/releases/tag/v1.2.1)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-ready-brightgreen.svg)](https://www.docker.com/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Remote%20SSH-007ACC.svg)](https://code.visualstudio.com/docs/remote/ssh)
[![Tailscale](https://img.shields.io/badge/Tailscale-VPN%20Ready-5F4DFF.svg)](https://tailscale.com/)

[Português](README.pt-BR.md) | **English**

A simple Docker-based isolated development workspace system, similar to GitHub Codespaces. Run your own containerized development environment with SSH access and VS Code Remote support.

## 📋 Features

- ✅ Fully isolated environment per developer
- ✅ Persistent data in `/home/developer`
- ✅ Non-root user (with sudo access)
- ✅ VS Code Remote SSH access
- ✅ Node.js 20 LTS and Python 3.10 pre-installed
- ✅ Git configured
- ✅ Resource limits per container (CPU/RAM)
- ✅ SSH key authentication (passwordless)
- ✅ Configurable storage (50GB default)
- 🆕 **v1.2.0** SSH rate limiting & audit logging (protect against brute force)
- 🆕 **v1.2.0** Interactive onboarding wizard (`bytelair init`)
- 🆕 **v1.2.0** Workspace snapshots (backup & restore states)
- 🆕 **v1.2.0** Settings sync (VS Code config, dotfiles, extensions)
- 🆕 **v1.2.0** Health monitoring for all containers
- 🆕 **v1.2.0** Enhanced security & GitHub Actions fork protection
- 🆕 **v1.2.0** Progress bars for long operations
- 🆕 **v1.2.0** Port management commands
- 🔧 **v1.2.1** Critical hotfix: SSH PATH propagation for node/go/java via `/etc/profile.d`
- 🔧 **v1.2.1** Critical hotfix: fullstack PAM hang (`UsePAM no`) + account unlock
- 🔧 **v1.2.1** Critical hotfix: double-sshd port conflict in entrypoint removed
- 🔧 **v1.2.1** 8 production-tested blueprints (111/111 automated tests passing)

## 🛠️ Prerequisites

- Docker and Docker Compose installed
- SSH key pair (public/private)
- VS Code with "Remote - SSH" extension (optional but recommended)

## � Available Blueprints

Choose the perfect environment for your project! All blueprints include SSH access, Tailscale VPN support, and are optimized for VS Code Remote development.

| Blueprint | Description | Key Tools | Best For | Docker Image |
|-----------|-------------|-----------|----------|--------------|
| **Python** | Data Science & APIs | Python 3.11, Jupyter, Pandas, NumPy | Data Science, ML, Web APIs | `lyskdot/devbox-python` |
| **Node.js** | Modern JavaScript/TypeScript | Node 20, npm, yarn, pnpm, Bun, TypeScript | Frontend, Backend, Full-stack JS | `lyskdot/devbox-node` |
| **Full-Stack** | Complete stack with databases | Node.js, Python, PostgreSQL 16, Redis, Nginx | Complex web applications | `lyskdot/devbox-fullstack` |
| **Web** | HTML/CSS/JS static sites | Nginx, Node.js, static file serving | Landing pages, portfolios | `lyskdot/devbox-web` |
| **DevOps** | Infrastructure & automation | Terraform, kubectl, Ansible, Helm, AWS CLI | CI/CD, Infrastructure as Code | `lyskdot/devbox-devops` |
| **Go** | Fast compiled language | Go 1.22, gopls, delve debugger | Microservices, CLI tools, Systems | `lyskdot/devbox-go` |
| **PHP** | Web development classic | PHP 8.2, Composer, Laravel, Nginx | WordPress, Laravel, APIs | `lyskdot/devbox-php` |
| **Java** | Enterprise & Android | Java 21 LTS, Maven 3.9, Gradle 8.5 | Enterprise apps, Android | `lyskdot/devbox-java` |

### 🎯 Quick Start with Blueprints

**Using ByteLair CLI** (Recommended):
```bash
bytelair up --template python    # Auto-detects or specify template
bytelair connect                 # Opens VS Code
```

**Using Docker directly**:
```bash
# Example: Python Data Science environment
docker run -d -p 2222:22 \
  -e SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)" \
  -v python-workspace:/home/developer \
  --name my-python-env \
  lyskdot/devbox-python:latest

# Connect
ssh -p 2222 developer@localhost
```

**With Tailscale** (Access from anywhere):
```bash
docker run -d -p 2222:22 \
  -e SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)" \
  -e TAILSCALE_AUTH_KEY="your-tailscale-auth-key" \
  -v ml-workspace:/home/developer \
  --name my-ml-env \
  --cap-add=NET_ADMIN \
  lyskdot/devbox-ml:latest
```

> 💡 **Tip:** Images are tagged as `:1.2` for stability. Use `:latest` for the newest features.

## �🚀 Installation Methods

### 🎯 Method 1: ByteLair CLI (Recommended - Most Modern)

The friendliest way to use DevBox! CLI with project auto-detection and VS Code integration:

```bash
# One-liner installation
curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/cli/install.sh | bash

# Simple to use
bytelair up              # Auto-detects project and starts workspace
bytelair connect         # Opens VS Code automatically
bytelair list            # Lists workspaces
```

**Benefits:**
- ✨ Auto-detects project type (Python, Node.js, etc.)
- 🚀 One command for everything: `bytelair up`
- 💻 Automatic VS Code Remote SSH integration
- 📊 Beautiful interface with status, logs, and management
- 🎨 Ready-made templates for different stacks

[See full CLI documentation →](cli/README.md)

### ⚡ Method 2: One-Line Auto Install

Everything automated - downloads, configures SSH, and starts (traditional mode):

```bash
curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/install.sh | bash
```

### 🐳 Method 3: Docker Hub Quick Run (No Clone Needed)

Pull pre-built image and run:

```bash
curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/quick-run.sh | bash
```

Or manually:
```bash
docker pull lyskdot/devbox:latest
docker run -d -p 2222:22 \
  -e SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)" \
  -v devbox-data:/home/developer \
  --name devbox \
  lyskdot/devbox:latest
```

### 📦 Method 4: Manual Install (Full Control)

#### 1. Clone the repository

```bash
git clone https://github.com/ByteLair/DevBox.git
cd DevBox
```

#### 2. Configure your SSH key

**IMPORTANT:** Before starting the workspace, you need to configure your SSH public key.

#### 2.1. Get your SSH public key

If you already have an SSH key:

```bash
cat ~/.ssh/id_rsa.pub
```

If you don't have one yet, create it:

```bash
ssh-keygen -t rsa -b 4096 -C "your@email.com"
# Press Enter to accept the default location
# Enter a passphrase (or leave blank)
```

#### 2.2. Create the .env file

Copy the example file and add your key:

```bash
cp env.example .env
```

Edit the `.env` file and replace the example SSH key with yours:

```bash
nano .env
# Or use your preferred editor: vim, code, etc.
```

The `.env` file should look like this:

```env
# Workspace Configuration
# Paste the output from: cat ~/.ssh/id_rsa.pub

SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your@email.com"
```

> ⚠️ **WARNING:** The `.env` file contains your SSH key and is in `.gitignore`. NEVER commit this file!
>
> The project includes an [env.example](env.example) file showing the correct format.

### 3. Start the workspace

```bash
docker-compose -f docker-compose-env.yml up -d --build
```

Wait a few minutes on the first run (downloading images and installing packages).

### 4. Configure SSH access (optional)

You can add an alias to your `~/.ssh/config` to make access easier:

```bash
# Add to ~/.ssh/config file:
Host my-workspace
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa
```

### 5. Connect to the workspace!

Direct SSH:
```bash
ssh -p 2222 developer@localhost
```

Or using the alias (if configured):
```bash
ssh my-workspace
```

## 🆕 v1.2.x New Features

### Interactive Onboarding

First-time setup made easy with a guided wizard:

```bash
bytelair init
```

The wizard will:
- ✅ Detect or generate SSH keys (ed25519 recommended)
- ✅ Auto-detect your project type (Python, Node.js, Go, etc.)
- ✅ Recommend the best blueprint
- ✅ Optional Tailscale setup for remote access
- ✅ Save configuration for future use

### Workspace Snapshots

Backup and restore workspace states:

```bash
# Create a snapshot
bytelair snapshot-create my-workspace --name "before-refactor" --message "Clean state"

# List all snapshots
bytelair snapshot-list

# Filter by workspace
bytelair snapshot-list --workspace my-workspace

# Restore from snapshot
bytelair snapshot-restore before-refactor --workspace my-workspace-restored

# Delete snapshot
bytelair snapshot-delete old-snapshot
```

### Settings Synchronization

Keep your VS Code settings and dotfiles in sync:

```bash
# Sync VS Code settings to workspace
bytelair sync-settings my-workspace --direction push

# Pull settings from workspace to local
bytelair sync-settings my-workspace --direction pull

# Sync dotfiles (.bashrc, .gitconfig, .vimrc, etc)
bytelair sync-dotfiles my-workspace --direction push

# Sync specific files only
bytelair sync-dotfiles my-workspace --files ".bashrc,.gitconfig"

# Export VS Code extensions list
bytelair sync-extensions my-workspace
```

### Port Management

View and manage exposed ports:

```bash
# List all ports for a workspace
bytelair port-list my-workspace

# Get help with dynamic port forwarding
bytelair port-add my-workspace 3000 3000
```

### Security Features

**SSH Rate Limiting** (requires `--cap-add=NET_ADMIN`):
- Automatic protection against brute force attacks
- Limit: 4 connection attempts per minute per IP
- Uses iptables for efficient filtering

**Audit Logging**:
- All SSH logins tracked in `/var/log/devbox/audit.log`
- Records: timestamp, user, IP, commands executed
- Useful for security monitoring and debugging

```bash
# View audit logs
docker exec bytelair-my-workspace cat /var/log/devbox/audit.log
```

### Health Monitoring

All containers now include health checks:
- Monitors SSH daemon responsiveness
- 30-second intervals, 3-second timeout
- View status: `docker ps` shows health state
- Automatic restarts on unhealthy containers (if configured)

```bash
# View health status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

## 💻 Connecting via VS Code

### 1. Install the Remote-SSH extension

1. Open VS Code
2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac)
3. Search for "Remote - SSH"
4. Install the Microsoft extension (`ms-vscode-remote.remote-ssh`)

### 2. Connect to the workspace

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Remote-SSH: Connect to Host"
3. Select "my-workspace" (or type `developer@localhost:2222`)
4. Wait for the connection to establish
5. Open the folder `/home/developer`

**Done!** Now you're coding inside the isolated container! 🎉

## 🌐 Network Access (Server Deployment)

Want to host DevBox on a server and let your team access it remotely? It's super easy!

### For Team Members (Users)

1. Install **VS Code + Remote-SSH** extension
2. Add to `~/.ssh/config`:
   ```
   Host devbox
       HostName <SERVER_IP>
       Port 2222
       User developer
   ```
3. Send your SSH public key to admin: `cat ~/.ssh/id_rsa.pub`
4. Connect: **F1 → Remote-SSH: Connect to Host → devbox**

**That's it!** No Docker needed on user machines. Just VS Code.

### For Server Admin

Add new users in seconds:

```bash
./add-user.sh 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com'
```

**Complete guide:** [NETWORK-ACCESS.md](docs/en/NETWORK-ACCESS.md)

### Why Remote-SSH for Network Access?

- ✅ **Zero setup** for users (just VS Code + extension)
- ✅ **No Docker** needed on client machines
- ✅ **Centralized resources** - one powerful server, many users
- ✅ **Same experience** as local development
- ✅ **Works anywhere** - home, office, or remote

Perfect for teams, schools, or shared development environments! 🚀

## � Multiple Workspaces (Optional)

Need multiple isolated environments? You can run several workspaces simultaneously!

### Quick Setup

Use `docker-compose.yml` instead of `docker-compose-env.yml`:

1. **Edit docker-compose.yml** - duplicate workspace blocks
2. **Change ports** for each workspace (2222, 2223, 2224...)
3. **Declare volumes** for each workspace
4. **Start:** `docker-compose up -d`

### Example Configuration

```yaml
services:
  workspace-dev1:
    ports: ["2222:22"]
    volumes:
      - dev1-home:/home/developer
  
  workspace-dev2:
    ports: ["2223:22"]
    volumes:
      - dev2-home:/home/developer
  
  workspace-frontend:
    ports: ["2224:22"]
    volumes:
      - frontend-home:/home/developer

volumes:
  dev1-home:
  dev2-home:
  frontend-home:
```

### Connect to Each Workspace

```bash
ssh -p 2222 developer@localhost  # Workspace 1
ssh -p 2223 developer@localhost  # Workspace 2
ssh -p 2224 developer@localhost  # Workspace 3
```

**Complete guide:** [MULTIPLE-WORKSPACES.md](MULTIPLE-WORKSPACES.md)

### Use Cases

- ✅ **Per-project isolation** (frontend, backend, mobile)
- ✅ **Per-developer environments** (team A, team B)
- ✅ **Different tech stacks** (Node.js, Python, Go)
- ✅ **Resource limits** per workspace

**Your current setup:** Single workspace (simpler, recommended for one user)

## �📂 Project Structure

```
.
├── Dockerfile                    # Workspace image definition
├── docker-compose.yml           # Configuration for multiple workspaces
├── docker-compose-env.yml       # Simplified configuration (1 workspace)
├── entrypoint.sh                # Container startup script
├── env.example                  # Configuration example
├── .env                         # ⚠️ YOUR SSH KEY (create, don't commit!)
├── .gitignore                   # Files to ignore in git
├── workspace-storage/           # ⚠️ Workspace data (auto-created)
├── add-user.sh                  # Script to add network users easily
├── README.md                    # This file (English)
├── README.pt-BR.md              # Portuguese documentation
├── docs/
│   ├── en/                      # 📚 Documentation in English
│   │   ├── ACCESS-WORKSPACE.md
│   │   ├── NETWORK-ACCESS.md
│   │   ├── MULTIPLE-WORKSPACES.md
│   │   └── SSH-SETUP.md
│   └── pt-BR/                   # 📚 Documentação em Português
│       ├── ACESSO-WORKSPACE.md
│       ├── ACESSO-REDE.md
│       ├── MULTIPLOS-WORKSPACES.md
│       └── SETUP-SSH.md
└── start-workspace.sh           # Quick start script
```

## 🔧 Useful Commands

### Workspace management

```bash
# Start workspace
docker-compose -f docker-compose-env.yml up -d

# Stop workspace (data is preserved)
docker-compose -f docker-compose-env.yml down

# Restart workspace
docker-compose -f docker-compose-env.yml restart

# View logs in real-time
docker-compose -f docker-compose-env.yml logs -f

# Rebuild after Dockerfile changes
docker-compose -f docker-compose-env.yml up -d --build
```

### Monitoring

```bash
# View container status
docker ps

# View resource usage (CPU, RAM)
docker stats workspace-dev

# View disk usage
docker exec workspace-dev df -h
```

### Debug

```bash
# Enter container as root
docker exec -it workspace-dev bash

# View SSH logs
docker logs workspace-dev
```

## 📊 Workspace Resources

The workspace comes pre-configured with:

- **Operating System:** Ubuntu 22.04 LTS
- **Node.js:** v20 LTS (with npm)
- **Python:** 3.10 (with pip)
- **Git:** 2.34+
- **Tools:** vim, nano, curl, wget, build-essential
- **Access:** SSH (port 2222)
- **User:** developer (with passwordless sudo)

## 🎯 Customization

### Add more tools

Edit the [Dockerfile](Dockerfile) and add your favorite tools:

```dockerfile
# Example: add Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    rm go1.21.0.linux-amd64.tar.gz

# Example: add Rust
USER developer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
USER root
```

Then rebuild the container:

```bash
docker-compose -f docker-compose-env.yml up -d --build
```

### Adjust resources (CPU/RAM)

Edit [docker-compose-env.yml](docker-compose-env.yml):

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'    # CPU limit
      memory: 4G     # RAM limit
```

### Create multiple workspaces

Use [docker-compose.yml](docker-compose.yml) to create multiple isolated workspaces (useful for teams):

```bash
# Configure each dev's keys in .env
cp env.example .env
# Add: DEV1_SSH_KEY="...", DEV2_SSH_KEY="...", etc.

# Start all workspaces
docker-compose up -d --build
```

Each workspace will have its own SSH port (2222, 2223, etc.)

## 🎯 Real-World Use Cases

Here are practical examples of how to use each blueprint for real projects:

### 📊 Data Science Project (Python Blueprint)

Perfect for: Jupyter notebooks, data analysis, machine learning models

```bash
# Start environment
bytelair up --template python --name data-analysis

# Connect and install your packages
bytelair connect

# In the container:
pip install pandas matplotlib seaborn scikit-learn
jupyter lab --ip 0.0.0.0 --port 8888
```

**What you get:** Python 3.11, Jupyter Lab ready, NumPy, Pandas, TensorFlow pre-installed

### 🌐 Full-Stack Web App (Full-Stack Blueprint)

Perfect for: MERN/MEAN stack, complete web applications

```bash
# Start environment with database
bytelair up --template fullstack --name webapp

# Databases auto-started:
# - PostgreSQL on port 5432
# - Redis on port 6379
# - Nginx ready for reverse proxy

# Example: Create Next.js + API + PostgreSQL
cd ~/projects
npx create-next-app@latest my-app
cd my-app && npm install pg
# Database already running: postgresql://developer:devpass@localhost/devdb
```

**What you get:** Node.js, Python, PostgreSQL, Redis, Nginx all configured

### 🚀 Go Microservices (Go Blueprint)

Perfect for: REST APIs, microservices, CLI tools

```bash
# Start environment
bytelair up --template go --name api-service

# Example: Build a REST API
mkdir -p ~/projects/api && cd ~/projects/api
go mod init github.com/username/api

# Create main.go
cat > main.go << 'EOF'
package main

import (
    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()
    r.GET("/ping", func(c *gin.Context) {
        c.JSON(200, gin.H{"message": "pong"})
    })
    r.Run(":8080")
}
EOF

go get github.com/gin-gonic/gin
go run main.go
```

**What you get:** Go 1.22, gopls, delve debugger, built for performance

### 🛠️ Infrastructure as Code (DevOps Blueprint)

Perfect for: Terraform, Kubernetes, CI/CD automation

```bash
# Start environment
bytelair up --template devops --name infrastructure

# Example: Deploy Kubernetes cluster
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Or manage AWS infrastructure
aws configure  # Already has AWS CLI
terraform init
terraform plan
terraform apply
```

**What you get:** Docker-in-Docker, kubectl, Terraform, Ansible, AWS CLI, Helm

### 🌍 Remote Team Access (Any Blueprint + Tailscale)

Perfect for: Accessing dev environment from anywhere securely

```bash
# Setup Tailscale on your workspace
bytelair tailscale setup

# Share the Tailscale IP with your team
bytelair tailscale status
# Output: Tailscale IP: 100.64.x.x

# Team members connect via Tailscale network
ssh developer@100.64.x.x
# No port forwarding, no VPN setup, just works!
```

**What you get:** Secure mesh network, accessible globally, end-to-end encrypted

### 🎨 Static Website Hosting (Web Blueprint)

Perfect for: Landing pages, portfolios, documentation sites

```bash
# Start web server
bytelair up --template web --name portfolio

# Build your static site
cd ~/projects
git clone https://github.com/username/my-portfolio
cd my-portfolio
npm install && npm run build

# Nginx already configured to serve from /var/www/html
sudo cp -r dist/* /var/www/html/
# Site live at http://localhost:80
```

**What you get:** Nginx optimized for static files, fast delivery

## 🔒 Security

### ✅ What's protected:

- **SSH key authentication only** (no password login)
- **Root login disabled** via SSH
- **Isolated environment** per container
- **SSH keys configured at runtime** (not baked into image layers)
- **sshd runs as PID 1** for proper signal handling and clean shutdowns

### 🔐 Recommended Security Practices:

**SSH Keys:**
```bash
# Use modern ed25519 keys (recommended over RSA)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Or RSA 4096-bit as alternative
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**Network Security:**
- ⚠️ **DO NOT expose directly to the internet** - Use firewall or Tailscale VPN
- ✅ Use **Tailscale** for secure remote access (built-in support)
- ✅ Configure firewall rules to restrict SSH port access
- ✅ Use non-standard ports for additional obscurity (e.g., 2222 instead of 22)

**Environment Variables:**
- ✅ Keep `.env` file out of version control (already in `.gitignore`)
- ✅ Use environment variables or Docker secrets for sensitive data
- ✅ Never commit Tailscale auth keys to repositories

### ⚠️ Important Considerations:

1. **Passwordless sudo**: User `developer` has `NOPASSWD` sudo access for easier package installation
   - **Risk**: Anyone with SSH access has full system control inside container
   - **Mitigation**: Protect your SSH private key at all costs
   - **Best for**: Development environments, not production servers

2. **Container isolation**: While containers provide isolation, they share the host kernel
   - Use Docker security best practices for production deployments
   - Consider running containers with limited privileges if security is critical

3. **Data persistence**: Volumes in `/home/developer` persist across container recreations
   - Back up important data regularly
   - Consider encrypted volumes for sensitive projects

### To remove passwordless sudo:

Edit the [Dockerfile](Dockerfile) and remove `NOPASSWD`:

```dockerfile
echo "developer ALL=(ALL) ALL" > /etc/sudoers.d/developer && \
```

Then rebuild the image.

## 📦 Backup and Restore

### Backup workspace

```bash
# Complete data backup
tar -czf workspace-backup-$(date +%Y%m%d).tar.gz workspace-storage/

# Or use rsync for incremental backup
rsync -av workspace-storage/ /path/to/backup/
```

### Restore

```bash
# Extract backup
tar -xzf workspace-backup-20260217.tar.gz
```

## 🆘 Troubleshooting

### ❌ Error: "Permission denied (publickey)"

**Cause:** Your SSH key is not configured correctly.

**Solution:**
```bash
# Check if your key is in .env
cat .env

# Check your private key permissions
chmod 600 ~/.ssh/id_rsa

# Rebuild the container
docker-compose -f docker-compose-env.yml up -d --build
```

### ❌ Container doesn't start

**Solution:**
```bash
# View logs
docker-compose -f docker-compose-env.yml logs

# Force recreation
docker-compose -f docker-compose-env.yml up -d --build --force-recreate
```

### ❌ Port 2222 already in use

**Solution:** Change the port in [docker-compose-env.yml](docker-compose-env.yml):

```yaml
ports:
  - "2223:22"  # Use another port
```

### ❌ SSH is slow or hangs

**Common cause:** Slow reverse DNS lookup.

**Solution:** Add to container's `/etc/ssh/sshd_config`:
```bash
docker exec workspace-dev bash -c "echo 'UseDNS no' >> /etc/ssh/sshd_config"
docker-compose -f docker-compose-env.yml restart
```

### ❌ Tools (node, go, mvn) not found after SSH login

**Cause:** Docker `ENV PATH` is not propagated to SSH login shells.

**Solution (v1.2.1+ images already include this fix):** Each blueprint ships `/etc/profile.d/devbox-*.sh` that sets the correct `PATH`. If connecting with `-t` (interactive shell), source `/etc/profile` manually or reconnect with a login shell:
```bash
ssh -t developer@localhost -p PORT 'bash -l'
```

### ❌ fullstack SSH hangs forever (ubuntu:24.04)

**Cause:** PAM modules try to reach `systemd-userdbd` which doesn't exist in containers.

**v1.2.1+ fix:** `UsePAM no` is now set in the fullstack `sshd_config` at build time. If using an older image:
```bash
docker exec <container> bash -c "sed -i 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && kill -HUP \$(pgrep sshd)"
```

## 📚 Additional Documentation

### 🇺🇸 English

- [ACCESS-WORKSPACE.md](docs/en/ACCESS-WORKSPACE.md) - Detailed access and usage guide
- [NETWORK-ACCESS.md](docs/en/NETWORK-ACCESS.md) - Network/server deployment guide
- [MULTIPLE-WORKSPACES.md](docs/en/MULTIPLE-WORKSPACES.md) - Multiple workspaces configuration
- [SSH-SETUP.md](docs/en/SSH-SETUP.md) - Advanced SSH configuration

### 🇧🇷 Português

- [ACESSO-WORKSPACE.md](docs/pt-BR/ACESSO-WORKSPACE.md) - Guia detalhado de acesso e uso
- [ACESSO-REDE.md](docs/pt-BR/ACESSO-REDE.md) - Deploy em rede/servidor
- [MULTIPLOS-WORKSPACES.md](docs/pt-BR/MULTIPLOS-WORKSPACES.md) - Configuração de múltiplos workspaces
- [SETUP-SSH.md](docs/pt-BR/SETUP-SSH.md) - Configuração avançada de SSH

### ⚙️ Configuration Files

- [env.example](env.example) - Configuration file example

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/MyFeature`)
3. Commit your changes (`git commit -m 'Add MyFeature'`)
4. Push to the branch (`git push origin feature/MyFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the MIT License.

## 💡 Use Cases

This workspace is ideal for:

- ✅ Isolated and consistent development
- ✅ Ephemeral environments for testing
- ✅ Onboarding new developers
- ✅ Projects with specific dependencies
- ✅ Separation of work environments
- ✅ Remote development via VS Code

## 🎓 Learn More

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [SSH Key Authentication](https://www.ssh.com/academy/ssh/public-key-authentication)

---

**Created with ❤️ to facilitate isolated and secure development.**

If this project was useful, consider giving it a ⭐ on GitHub!
