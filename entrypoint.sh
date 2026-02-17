#!/bin/bash
set -e

# ByteLair DevBox - Enhanced Entrypoint with Tailscale Support
# This script configures SSH, Tailscale (optional), and starts services

echo "🚀 ByteLair DevBox starting..."

# ============================================
# SSH Key Configuration
# ============================================
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "🔑 Configuring SSH public key..."
    
    # Create .ssh directory if it doesn't exist
    mkdir -p /home/developer/.ssh
    
    # Write SSH public key to authorized_keys
    echo "$SSH_PUBLIC_KEY" > /home/developer/.ssh/authorized_keys
    
    # Set correct permissions
    chmod 700 /home/developer/.ssh
    chmod 600 /home/developer/.ssh/authorized_keys
    chown -R developer:developer /home/developer/.ssh
    
    echo "✅ SSH key configured successfully"
else
    echo "⚠️  Warning: No SSH_PUBLIC_KEY provided"
fi

# ============================================
# Tailscale Configuration (Optional)
# ============================================
if [ -n "$TAILSCALE_AUTH_KEY" ]; then
    # Check if Tailscale is installed
    if ! command -v tailscaled >/dev/null 2>&1; then
        echo "⚠️  Tailscale not installed in this blueprint, skipping..."
        echo "   Use a blueprint with Tailscale support or install it manually"
    else
        echo "🔐 Tailscale authentication key detected"
        echo "🌐 Connecting to Tailscale network..."
        
        # Start tailscaled daemon in background
        tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    
    # Wait for tailscaled to be ready
    sleep 2
    
    # Authenticate and connect
    if [ -n "$TAILSCALE_HOSTNAME" ]; then
        tailscale up --authkey="$TAILSCALE_AUTH_KEY" --hostname="$TAILSCALE_HOSTNAME" --accept-routes
    else
        tailscale up --authkey="$TAILSCALE_AUTH_KEY" --accept-routes
    fi
    
        # Get Tailscale IP
        TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "pending")
        
        if [ "$TAILSCALE_IP" != "pending" ]; then
            echo "✅ Tailscale connected!"
            echo "📡 Tailscale IP: $TAILSCALE_IP"
            echo "🔗 SSH via Tailscale: ssh -p 22 developer@$TAILSCALE_IP"
            
            # Save Tailscale IP for easy access
            echo "$TAILSCALE_IP" > /home/developer/.tailscale-ip
            chown developer:developer /home/developer/.tailscale-ip
        else
            echo "⚠️  Tailscale authentication in progress..."
        fi
    fi
else
    echo "ℹ️  Tailscale not configured (optional)"
    echo "   Set TAILSCALE_AUTH_KEY to enable remote access"
fi

# ============================================
# Additional Services (Blueprint-specific)
# ============================================
# This section can be customized per blueprint

# Start PostgreSQL if installed
if command -v pg_ctlcluster >/dev/null 2>&1; then
    echo "🐘 Starting PostgreSQL..."
    service postgresql start || true
fi

# Start Redis if installed
if command -v redis-server >/dev/null 2>&1; then
    echo "📦 Starting Redis..."
    service redis-server start || true
fi

# Start MySQL if installed
if command -v mysql >/dev/null 2>&1; then
    echo "🐬 Starting MySQL..."
    service mysql start || true
fi

# Start Nginx if installed
if command -v nginx >/dev/null 2>&1; then
    echo "🌐 Starting Nginx..."
    service nginx start || true
fi

# Start PHP-FPM if installed
if command -v php-fpm8.1 >/dev/null 2>&1; then
    echo "🐘 Starting PHP-FPM..."
    service php8.1-fpm start || true
fi

# ============================================
# SSH Service
# ============================================
echo "🔌 Starting SSH service..."
service ssh start

# ============================================
# Workspace Information
# ============================================
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   ✨ ByteLair DevBox Ready!                ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "📡 Access Methods:"
echo "   • Local SSH:     ssh -p 22 developer@<host>"
echo "   • VS Code:       Configure SSH remote with port 22"

if [ -n "$TAILSCALE_AUTH_KEY" ] && [ "$TAILSCALE_IP" != "pending" ]; then
    echo "   • Tailscale SSH: ssh developer@$TAILSCALE_IP"
    echo "   • VS Code:       code --remote ssh-remote+developer@$TAILSCALE_IP /home/developer"
fi

echo ""
echo "📂 Workspace: /home/developer"
echo "🛠️  Type: $(cat /etc/blueprint-type 2>/dev/null || echo 'base')"
echo ""

# ============================================
# Start SSH Daemon as PID 1
# ============================================
# Run sshd in foreground with proper signal handling
exec /usr/sbin/sshd -D -e
