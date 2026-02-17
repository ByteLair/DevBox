#!/bin/bash
# DevBox - Add User Script
# Easily add SSH keys for new users

set -e

CONTAINER_NAME="workspace-dev"

echo "🔑 DevBox - Add New User"
echo ""

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 'ssh-rsa AAAAB... user@email.com'"
    echo ""
    echo "Example:"
    echo "  $0 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... john@company.com'"
    echo ""
    echo "The user should run: cat ~/.ssh/id_rsa.pub"
    echo "And send you the output."
    exit 1
fi

SSH_KEY="$1"

# Validate it looks like an SSH key
if [[ ! "$SSH_KEY" =~ ^ssh- ]]; then
    echo "❌ Error: This doesn't look like an SSH public key."
    echo "It should start with 'ssh-rsa', 'ssh-ed25519', etc."
    exit 1
fi

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ Error: Container $CONTAINER_NAME is not running"
    echo "Start it with: docker-compose -f docker-compose-env.yml up -d"
    exit 1
fi

echo "Adding SSH key to DevBox..."

# Add the key
docker exec -i "$CONTAINER_NAME" bash -c "
    echo '$SSH_KEY' >> /home/developer/.ssh/authorized_keys
    chmod 600 /home/developer/.ssh/authorized_keys
    chown developer:developer /home/developer/.ssh/authorized_keys
"

# Extract email from key for display
EMAIL=$(echo "$SSH_KEY" | awk '{print $NF}')

echo ""
echo "✅ User added successfully!"
echo ""
echo "📧 User: $EMAIL"
echo "🔗 They can now connect with:"
echo ""
echo "   ssh -p 2222 developer@$(hostname -I | awk '{print $1}')"
echo ""
echo "Or in VS Code Remote-SSH, add to their ~/.ssh/config:"
echo ""
echo "   Host devbox"
echo "       HostName $(hostname -I | awk '{print $1}')"
echo "       Port 2222"
echo "       User developer"
echo ""
echo "📚 Full guide: NETWORK-ACCESS.md"
