# 🚀 DevBox - Quick Access Guide

Multiple ways to connect to your DevBox without remembering complex commands!

## 🎯 Connection Methods

### Method 1: Shell Aliases (Fastest!) ⭐

Add these aliases to your `~/.bashrc` or `~/.zshrc`:

```bash
# DevBox - Quick Access Aliases
alias devbox='ssh -p 2222 developer@localhost'
alias devbox-start='docker-compose -f docker-compose-env.yml up -d'
alias devbox-stop='docker-compose -f docker-compose-env.yml down'
alias devbox-restart='docker-compose -f docker-compose-env.yml restart'
alias devbox-logs='docker logs -f workspace-dev'
alias devbox-status='docker ps --filter "name=workspace-dev" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

Now you can:
```bash
devbox              # Connect instantly! ⚡
devbox-start        # Start workspace
devbox-stop         # Stop workspace
devbox-restart      # Restart workspace
devbox-logs         # View logs
devbox-status       # Check status
```

### Method 2: SSH Config (Auto-complete enabled)

Add to your `~/.ssh/config`:

```
Host my-workspace
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa
```

Now you can:
```bash
ssh my-workspace    # Auto-completes with Tab! ⭐
```

**Bonus:** This host appears automatically in:
- VS Code Remote SSH host list
- Any SSH client
- Terminal auto-completion

### Method 3: VS Code Remote SSH

1. **Install extension:** "Remote - SSH" (ms-vscode-remote.remote-ssh)
2. **Connect:**
   - Press `F1` or `Ctrl+Shift+P`
   - Type: "Remote-SSH: Connect to Host"
   - **Select "my-workspace"** from the list ✅
   - Done! VS Code opens inside the container

**Your workspace appears in:**
- Remote Explorer panel (left sidebar)
- Recent connections list
- Quick pick menu

### Method 4: VS Code Dev Containers

1. **Install extension:** "Dev Containers" (ms-vscode-remote.remote-containers)
2. **Open this project folder** in VS Code
3. VS Code detects `.devcontainer/devcontainer.json`
4. Click **"Reopen in Container"** notification
5. Done! 🎉

See [.devcontainer/README.md](.devcontainer/README.md) for details.

## 💡 Pro Tips

### Create a desktop shortcut (Linux):

```bash
cat > ~/Desktop/DevBox.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=DevBox
Comment=Connect to DevBox workspace
Exec=gnome-terminal -- ssh -p 2222 developer@localhost
Icon=utilities-terminal
Terminal=false
Categories=Development;
EOF
chmod +x ~/Desktop/DevBox.desktop
```

### Quick status check function:

Add to your `~/.bashrc`:

```bash
devbox-info() {
    echo "🚀 DevBox Status:"
    docker ps --filter "name=workspace-dev" --format "  Status: {{.Status}}" || echo "  ❌ Not running"
    echo ""
    echo "💾 Storage:"
    docker exec workspace-dev df -h /home/developer 2>/dev/null | tail -1 | awk '{print "  Used: "$3" / "$2" ("$5")"}'
    echo ""
    echo "📡 Connection:"
    echo "  ssh -p 2222 developer@localhost"
    echo "  or just type: devbox"
}
```

Then use:
```bash
devbox-info    # Shows complete status
```

## 🔄 Daily Workflow

### Morning (Start working):
```bash
devbox-status      # Check if running
devbox-start       # Start if needed
devbox             # Connect!
```

### Or just open VS Code:
1. Open VS Code
2. `F1` > "Remote-SSH: Connect to Host"
3. Select "my-workspace"
4. Start coding! ✨

### Evening (Stop working):
```bash
# Your data is persistent, so you can just close
# Or explicitly stop:
devbox-stop
```

## ✅ No More Remembering!

You now have **4 ways** to connect:

1. ✅ Type `devbox` (alias)
2. ✅ Type `ssh my-<Tab>` (auto-complete)
3. ✅ Select from VS Code Remote SSH list
4. ✅ "Reopen in Container" in VS Code

**Everything appears in menus and lists!** 🎉

## 🆘 Troubleshooting

### Aliases not working?
```bash
source ~/.bashrc    # Reload shell config
```

### Not appearing in VS Code?
Make sure `~/.ssh/config` has the host configuration and restart VS Code.

### Dev Container not detected?
Make sure `.devcontainer/devcontainer.json` exists and the Docker extension is installed.

---

**No commands to memorize!** Everything is automated. 🚀
