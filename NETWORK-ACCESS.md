# 🌐 DevBox - Network Access Guide

Guide for accessing DevBox from other computers on your network.

## 🎯 Overview

DevBox is running on a server and can be accessed by anyone on the network using VS Code Remote-SSH.

**What users need:**
- VS Code installed
- Remote-SSH extension
- Network access to the server
- Their SSH public key (we'll add it to DevBox)

## 📋 Server Information

**Server IP:** `<SERVER_IP>` (replace with your server's local IP)  
**SSH Port:** `2222`  
**Username:** `developer`  
**Authentication:** SSH public key

## 👥 For Users - Quick Setup (5 minutes)

### Step 1: Install VS Code Extension

1. Open VS Code
2. Press `Ctrl+Shift+X` (Extensions)
3. Search for "Remote - SSH"
4. Install **Remote - SSH** by Microsoft

### Step 2: Configure SSH Connection

Add this to your `~/.ssh/config` file:

**Windows:** `C:\Users\YourName\.ssh\config`  
**Mac/Linux:** `~/.ssh/config`

```
Host devbox
    HostName <SERVER_IP>
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa
```

**Replace `<SERVER_IP>`** with the actual server IP (e.g., `192.168.1.100`)

### Step 3: Connect!

1. Press `F1` or `Ctrl+Shift+P` in VS Code
2. Type: "Remote-SSH: Connect to Host"
3. Select **"devbox"** from the list
4. Done! 🎉

**First connection:** Takes a bit longer (VS Code installs server components)  
**Next times:** Instant connection!

## 🔐 For Server Admin - Add New User

When someone wants access, they need to send you their **SSH public key**.

### User generates their key (first time only):

**On their computer:**
```bash
# Windows (PowerShell), Mac, or Linux
ssh-keygen -t rsa -b 4096 -C "their@email.com"

# Then get the public key:
# Windows:
type %USERPROFILE%\.ssh\id_rsa.pub

# Mac/Linux:
cat ~/.ssh/id_rsa.pub
```

They copy the output (starts with `ssh-rsa AAAA...`) and send to you.

### You add their key to DevBox:

**Option A: Add manually (for 1-2 users)**

```bash
# Connect to DevBox as admin
ssh -p 2222 developer@localhost

# Add their key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com" >> ~/.ssh/authorized_keys

# Fix permissions
chmod 600 ~/.ssh/authorized_keys
```

**Option B: Script for multiple users (recommended)**

Save this script on your server:

```bash
#!/bin/bash
# add-devbox-user.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: ./add-devbox-user.sh 'ssh-rsa AAAAB... user@email.com'"
    exit 1
fi

docker exec -i workspace-dev bash -c "
    echo '$1' >> /home/developer/.ssh/authorized_keys
    chmod 600 /home/developer/.ssh/authorized_keys
    chown developer:developer /home/developer/.ssh/authorized_keys
"

echo "✅ User added successfully!"
echo "They can now connect with: ssh -p 2222 developer@<SERVER_IP>"
```

Usage:
```bash
chmod +x add-devbox-user.sh
./add-devbox-user.sh 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com'
```

## 🌐 Network Configuration

### Find your server IP:

**Linux:**
```bash
hostname -I | awk '{print $1}'
```

**Or check with:**
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### Open firewall port (if needed):

**Ubuntu/Debian:**
```bash
sudo ufw allow 2222/tcp
sudo ufw status
```

**CentOS/RHEL:**
```bash
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

## 📱 User Quick Reference Card

Create this card for your team:

```
╔══════════════════════════════════════════╗
║     DevBox - Quick Access                ║
╠══════════════════════════════════════════╣
║                                          ║
║  1. Install VS Code + Remote-SSH        ║
║  2. Add to ~/.ssh/config:               ║
║                                          ║
║     Host devbox                          ║
║         HostName <SERVER_IP>             ║
║         Port 2222                        ║
║         User developer                   ║
║         IdentityFile ~/.ssh/id_rsa      ║
║                                          ║
║  3. In VS Code: F1 > Remote-SSH:        ║
║     Connect to Host > devbox            ║
║                                          ║
║  Need access? Send your SSH public key: ║
║  cat ~/.ssh/id_rsa.pub                  ║
║                                          ║
╚══════════════════════════════════════════╝
```

## 🎯 VS Code Remote Development Features

Once connected, users get:

- ✅ Full IDE inside the container
- ✅ All extensions work (install once, persist)
- ✅ Integrated terminal
- ✅ Git integration
- ✅ Debugging support
- ✅ Port forwarding (access local servers)
- ✅ File sync (automatic)

## 🔧 Advanced Configuration

### Custom ports for each user (optional)

If you want isolation, create multiple workspaces:

```yaml
# docker-compose.yml
services:
  devbox-user1:
    build: .
    ports:
      - "2222:22"
    volumes:
      - user1-data:/home/developer
      
  devbox-user2:
    build: .
    ports:
      - "2223:22"
    volumes:
      - user2-data:/home/developer

volumes:
  user1-data:
  user2-data:
```

### Resource limits per user:

Already configured in docker-compose-env.yml!
- CPU: 4 cores max
- RAM: 8GB max

Adjust as needed for your server capacity.

## 📊 Monitoring

### See who's connected:

```bash
# Show active SSH connections
docker exec workspace-dev who

# See resource usage
docker stats workspace-dev
```

### View connection logs:

```bash
docker logs workspace-dev | grep "Accepted publickey"
```

## 🆘 Troubleshooting

### User can't connect:

1. **Check their SSH key is added:**
   ```bash
   docker exec workspace-dev cat /home/developer/.ssh/authorized_keys
   ```

2. **Test from server:**
   ```bash
   ssh -p 2222 developer@localhost
   ```

3. **Check firewall:**
   ```bash
   sudo ufw status | grep 2222
   ```

4. **Verify container is running:**
   ```bash
   docker ps | grep workspace-dev
   ```

### Connection is slow:

Add to container's SSH config:
```bash
docker exec workspace-dev bash -c "echo 'UseDNS no' >> /etc/ssh/sshd_config"
docker-compose -f docker-compose-env.yml restart
```

## 🎓 Training Your Team

Send them this 3-step guide:

1. **Install Remote-SSH extension** in VS Code
2. **Copy this config** to `~/.ssh/config` (replace SERVER_IP):
   ```
   Host devbox
       HostName SERVER_IP
       Port 2222
       User developer
   ```
3. **Send your public key** to admin: `cat ~/.ssh/id_rsa.pub`

After admin adds them: **F1 > Remote-SSH: Connect > devbox** ✅

---

**Easy for users, simple for admins!** 🚀
