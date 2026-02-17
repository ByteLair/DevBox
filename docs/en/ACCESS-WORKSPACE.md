# 🚀 How to Access the Workspace

Quick guide to connect and use your development workspace.

## 📋 Workspace Information

After starting the workspace, you will have:

- **Container:** workspace-dev (configurable)
- **SSH Port:** 2222 (default)
- **User:** developer
- **Working Directory:** /home/developer
- **Storage:** Defined in docker-compose

## ⚡ Start the Workspace

```bash
# First time (build + start)
docker-compose -f docker-compose-env.yml up -d --build

# Next times
docker-compose -f docker-compose-env.yml up -d
```

## 🔌 Connect via SSH

### Option 1: Direct connection

```bash
ssh -p 2222 developer@localhost
```

### Option 2: Configure alias in ~/.ssh/config (recommended)

Add to the `~/.ssh/config` file:

```
Host my-workspace
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa
```

Then connect with:

```bash
ssh my-workspace
```

## 💻 Connect via VS Code

### 1. Install Remote-SSH extension

1. Open VS Code
2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac)
3. Search for "Remote - SSH"
4. Install the Microsoft extension (ms-vscode-remote.remote-ssh)

### 2. Connect to the workspace

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Remote-SSH: Connect to Host"
3. Select your workspace (or type `developer@localhost:2222`)
4. Wait for the connection to establish
5. Open the folder `/home/developer`

**Done!** You're coding inside the container! 🎉

## 🛠️ Useful Commands

### Basic management

```bash
# Stop workspace (data is preserved)
docker-compose -f docker-compose-env.yml down

# Restart workspace
docker-compose -f docker-compose-env.yml restart

# View logs in real-time
docker-compose -f docker-compose-env.yml logs -f
```

### Monitoring

```bash
# View container status
docker ps

# View resource usage (CPU, RAM)
docker stats

# View disk usage inside the workspace
ssh my-workspace df -h
```

### Debug

```bash
# View workspace logs
docker-compose -f docker-compose-env.yml logs

# Enter container as root (for debugging)
docker exec -it workspace-dev bash
```

## 📁 Project Organization

We recommend organizing your projects inside `/home/developer`:

```bash
# Connect to the workspace
ssh my-workspace

# Create a folder structure
mkdir -p ~/projects
cd ~/projects

# Clone your repositories
git clone git@github.com:your-user/project1.git
git clone git@github.com:your-user/project2.git

# Configure git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## 🔧 Customize Environment

### Install packages

```bash
# System tools
sudo apt update
sudo apt install postgresql-client redis-tools htop

# Python packages
pip3 install --user flask fastapi requests

# Node.js packages
npm install -g typescript yarn pnpm
```

### Configure shell

Edit `~/.bashrc` in the workspace to customize your environment:

```bash
ssh my-workspace
nano ~/.bashrc
# Add your aliases, environment variables, etc.
```

## 📊 Pre-installed Resources

- **System:** Ubuntu 22.04 LTS
- **Node.js:** v20 LTS (with npm)
- **Python:** 3.10 (with pip)
- **Git:** 2.34+
- **Tools:** vim, nano, curl, wget, build-essential
- **Sudo:** Available without password

## 🆘 Troubleshooting

### ❌ Can't connect via SSH

```bash
# Check if the container is running
docker ps

# Check logs
docker-compose -f docker-compose-env.yml logs

# Test connection with verbose output
ssh -vvv -p 2222 developer@localhost
```

### ❌ Error "Permission denied (publickey)"

Your SSH public key is not configured in the container.

1. Check the `.env` file:
   ```bash
   cat .env
   ```

2. Make sure it contains your complete public key

3. Rebuild the container:
   ```bash
   docker-compose -f docker-compose-env.yml up -d --build
   ```

### ❌ Container doesn't start

```bash
# View detailed logs
docker-compose -f docker-compose-env.yml logs

# Force recreation
docker-compose -f docker-compose-env.yml up -d --build --force-recreate
```

### ❌ I forgot to save my work and recreated the container

Don't worry! Your data is safe in `workspace-storage/` (or the configured Docker volume).

When you recreate the container, data in `/home/developer` is preserved.

## 📝 Important Notes

- ✅ All data in `/home/developer` is persistent
- ✅ You have passwordless sudo access inside the container
- ✅ The workspace restarts automatically if Docker restarts
- ⚠️ Don't use `docker-compose down -v` or you'll lose data!
- ⚠️ Regularly backup the `workspace-storage/` directory

## 🎯 Quick Start (TL;DR)

```bash
# 1. Configure your SSH key in .env
cp env.example .env
nano .env  # Add your public key

# 2. Start the workspace
docker-compose -f docker-compose-env.yml up -d --build

# 3. Connect
ssh -p 2222 developer@localhost

# Or use VS Code with Remote-SSH!
```

## 📚 More Information

- [README.md](README.md) - Complete project documentation
- [SSH-SETUP.md](SSH-SETUP.md) - How to configure SSH keys

---

**Workspace ready for development!** 🎉
