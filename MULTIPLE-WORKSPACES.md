# 🔢 DevBox - Multiple Workspaces Guide

Guide for creating and managing multiple isolated development workspaces.

## 🎯 When to Use Multiple Workspaces

**Use multiple workspaces when you want:**
- ✅ Isolated environments per developer (different teams)
- ✅ Separate environments per project (frontend/backend/mobile)
- ✅ Different tech stacks (Node.js vs Python vs Go)
- ✅ Resource isolation and limits per workspace
- ✅ Independent SSH ports and access control

**Use single workspace when:**
- ✅ Only one person using it (like your current setup)
- ✅ Server deployment with network access (everyone shares one workspace)
- ✅ Simpler management and monitoring

## 🚀 Quick Start - Adding More Workspaces

### Current Setup

You're using **docker-compose-env.yml** with a single workspace:
- Container: `workspace-dev`
- Port: `2222`
- Storage: `workspace-storage/` (bind mount)

### Switch to Multiple Workspaces

Use **docker-compose.yml** instead, which supports multiple workspaces with Docker volumes.

## 📝 Step-by-Step: Add New Workspace

### 1. Stop current workspace (if running)

```bash
docker-compose -f docker-compose-env.yml down
```

### 2. Edit docker-compose.yml

Open `docker-compose.yml` and duplicate a workspace block:

```yaml
version: '3.8'

services:
  # First workspace
  workspace-dev1:
    build: .
    container_name: workspace-dev1
    hostname: DevBox-1
    restart: unless-stopped
    ports:
      - "2222:22"  # SSH port for workspace 1
    volumes:
      - dev1-home:/home/developer  # Persistent storage
      - dev1-ssh:/home/developer/.ssh  # SSH keys
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G

  # Second workspace (NEW!)
  workspace-dev2:
    build: .
    container_name: workspace-dev2
    hostname: DevBox-2
    restart: unless-stopped
    ports:
      - "2223:22"  # Different port! ⚠️
    volumes:
      - dev2-home:/home/developer
      - dev2-ssh:/home/developer/.ssh
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G

  # Third workspace (if needed)
  workspace-frontend:
    build: .
    container_name: workspace-frontend
    hostname: DevBox-Frontend
    restart: unless-stopped
    ports:
      - "2224:22"  # Another different port
    volumes:
      - frontend-home:/home/developer
      - frontend-ssh:/home/developer/.ssh
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          cpus: '2.0'  # Less resources for lighter workload
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G

# Don't forget to declare volumes!
volumes:
  dev1-home:
    driver: local
  dev1-ssh:
    driver: local
  dev2-home:
    driver: local
  dev2-ssh:
    driver: local
  frontend-home:
    driver: local
  frontend-ssh:
    driver: local
```

### 3. Build and start all workspaces

```bash
# Build the image (if not already built)
docker-compose build

# Start all workspaces
docker-compose up -d

# Or start specific workspace:
docker-compose up -d workspace-dev1
```

### 4. Add SSH keys to each workspace

Each workspace needs its authorized SSH keys:

```bash
# For workspace 1
docker exec -i workspace-dev1 bash -c "
    mkdir -p /home/developer/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com' >> /home/developer/.ssh/authorized_keys
    chmod 600 /home/developer/.ssh/authorized_keys
    chown developer:developer /home/developer/.ssh/authorized_keys
"

# For workspace 2
docker exec -i workspace-dev2 bash -c "
    mkdir -p /home/developer/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com' >> /home/developer/.ssh/authorized_keys
    chmod 600 /home/developer/.ssh/authorized_keys
    chown developer:developer /home/developer/.ssh/authorized_keys
"
```

### 5. Configure SSH access for each workspace

In your `~/.ssh/config`:

```
Host devbox-1
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa

Host devbox-2
    HostName localhost
    Port 2223
    User developer
    IdentityFile ~/.ssh/id_rsa

Host devbox-frontend
    HostName localhost
    Port 2224
    User developer
    IdentityFile ~/.ssh/id_rsa
```

### 6. Connect!

```bash
# Connect to workspace 1
ssh devbox-1

# Connect to workspace 2
ssh devbox-2

# Or directly:
ssh -p 2222 developer@localhost  # workspace 1
ssh -p 2223 developer@localhost  # workspace 2
ssh -p 2224 developer@localhost  # workspace frontend
```

## 🔧 Management Commands

### View all workspaces

```bash
docker-compose ps
```

### Start/stop specific workspace

```bash
# Start
docker-compose up -d workspace-dev1

# Stop
docker-compose stop workspace-dev1

# Restart
docker-compose restart workspace-dev2
```

### Start/stop all workspaces

```bash
# Start all
docker-compose up -d

# Stop all
docker-compose down

# Restart all
docker-compose restart
```

### View logs

```bash
# All workspaces
docker-compose logs -f

# Specific workspace
docker-compose logs -f workspace-dev1
```

### Resource monitoring

```bash
# See resource usage
docker stats

# Specific workspace
docker stats workspace-dev1
```

## 📊 Resource Planning

**Example server with 32GB RAM and 16 cores:**

You could create:
- 4 workspaces with 8GB RAM each (4GB reserved)
- Each with 4 CPU cores limit (2 cores reserved)

Adjust `deploy.resources` in docker-compose.yml:

```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'    # Maximum CPUs
      memory: 8G     # Maximum RAM
    reservations:
      cpus: '2.0'    # Guaranteed CPUs
      memory: 4G     # Guaranteed RAM
```

## 🌐 Network Access with Multiple Workspaces

Same server, multiple workspaces, different ports:

**User configuration (`~/.ssh/config`):**

```
Host devbox-backend
    HostName server.company.com
    Port 2222
    User developer

Host devbox-frontend
    HostName server.company.com
    Port 2223
    User developer

Host devbox-mobile
    HostName server.company.com
    Port 2224
    User developer
```

**Firewall setup:**

```bash
# Open all workspace ports
sudo ufw allow 2222:2230/tcp
```

## 🔐 Different Users per Workspace

You can configure different SSH keys per workspace:

**Workspace 1 - Team A:**
```bash
docker exec -i workspace-dev1 bash -c "
    echo 'ssh-rsa AAA... alice@company.com' >> /home/developer/.ssh/authorized_keys
    echo 'ssh-rsa BBB... bob@company.com' >> /home/developer/.ssh/authorized_keys
"
```

**Workspace 2 - Team B:**
```bash
docker exec -i workspace-dev2 bash -c "
    echo 'ssh-rsa CCC... charlie@company.com' >> /home/developer/.ssh/authorized_keys
    echo 'ssh-rsa DDD... diana@company.com' >> /home/developer/.ssh/authorized_keys
"
```

## 💡 Use Cases

### Use Case 1: Per-Project Workspaces

```yaml
services:
  workspace-api:
    # ... Node.js 20 for API development
    ports: ["2222:22"]
    
  workspace-web:
    # ... Frontend development
    ports: ["2223:22"]
    
  workspace-mobile:
    # ... React Native / Flutter
    ports: ["2224:22"]
```

### Use Case 2: Per-Developer Workspaces

```yaml
services:
  workspace-alice:
    ports: ["2222:22"]
    volumes:
      - alice-data:/home/developer
    
  workspace-bob:
    ports: ["2223:22"]
    volumes:
      - bob-data:/home/developer
```

### Use Case 3: Per-Environment Workspaces

```yaml
services:
  workspace-dev:
    # Development environment
    ports: ["2222:22"]
    
  workspace-staging:
    # Staging testing
    ports: ["2223:22"]
    
  workspace-qa:
    # QA testing
    ports: ["2224:22"]
```

## 🔄 Migrating from Single to Multiple Workspaces

### Your current setup (docker-compose-env.yml):
- 1 workspace
- Bind mount: `./workspace-storage`
- Port: 2222

### To migrate to multiple workspaces:

**Option 1: Keep single workspace, add new ones**

1. Rename current workspace in docker-compose.yml to match your container:
   ```yaml
   workspace-dev:  # Match your current container name
     ports: ["2222:22"]
     volumes:
       - ./workspace-storage:/home/developer  # Keep bind mount
   ```

2. Add new workspaces with Docker volumes:
   ```yaml
   workspace-dev2:
     ports: ["2223:22"]
     volumes:
       - dev2-home:/home/developer
   ```

**Option 2: Fresh start with all Docker volumes**

1. Backup current data:
   ```bash
   cp -r workspace-storage workspace-storage-backup
   ```

2. Stop and remove old setup:
   ```bash
   docker-compose -f docker-compose-env.yml down
   ```

3. Start with docker-compose.yml:
   ```bash
   docker-compose up -d
   ```

4. Copy data to new volume if needed:
   ```bash
   docker cp workspace-storage-backup/. workspace-dev1:/home/developer/
   ```

## 📚 Full Example Configuration

See the included `docker-compose.yml` file for a complete working example with 2 workspaces pre-configured.

## 🆘 Troubleshooting

### Port already in use

**Error:** `bind: address already in use`

**Solution:** Change the port in docker-compose.yml:
```yaml
ports:
  - "2225:22"  # Use a different host port
```

### Can't find workspace

**Error:** `No such service: workspace-dev3`

**Solution:** Make sure you added it to docker-compose.yml and declared its volumes.

### Out of resources

**Error:** Container using too much RAM

**Solution:** Adjust resource limits:
```yaml
deploy:
  resources:
    limits:
      memory: 4G  # Reduce limit
```

---

**Need help?** Check the main [README.md](README.md) or [NETWORK-ACCESS.md](NETWORK-ACCESS.md) guides! 🚀
