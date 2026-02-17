# 🚀 Docker Development Workspace

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

## 🛠️ Prerequisites

- Docker and Docker Compose installed
- SSH key pair (public/private)
- VS Code with "Remote - SSH" extension (optional but recommended)

## 🚀 Quick Installation

### 1. Clone the repository

```bash
git clone https://github.com/ByteLair/DevBox.git
cd DevBox
```

### 2. Configure your SSH key

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

## 📂 Project Structure

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
├── README.md                    # This file (English)
├── README.pt-BR.md              # Portuguese documentation
├── ACCESS-WORKSPACE.md          # Workspace access guide
├── SSH-SETUP.md                 # SSH configuration guide
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

## 🔒 Security

### ✅ What's protected:

- SSH key authentication only (no password)
- Root login disabled via SSH
- Isolated environment per container
- `.env` file in `.gitignore` (key won't go to GitHub)

### ⚠️ Considerations:

- User `developer` has passwordless `sudo` (makes package installation easier)
- SSH port exposed (2222) - ensure you have a firewall configured
- Data in `workspace-storage/` is local - consider backups

### To remove passwordless sudo:

Edit the [Dockerfile](Dockerfile) and remove `NOPASSWD`:

```dockerfile
echo "developer ALL=(ALL) ALL" > /etc/sudoers.d/developer && \
```

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

## 📚 Additional Documentation

- [ACCESS-WORKSPACE.md](ACCESS-WORKSPACE.md) - Detailed access and usage guide
- [SSH-SETUP.md](SSH-SETUP.md) - Advanced SSH configuration
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
