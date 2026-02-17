#!/bin/sh
set -e

# Configurar chave SSH se fornecida
if [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "🔑 Configurando chave SSH..."
    mkdir -p /home/developer/.ssh
    echo "$SSH_PUBLIC_KEY" > /home/developer/.ssh/authorized_keys
    chmod 700 /home/developer/.ssh
    chmod 600 /home/developer/.ssh/authorized_keys
    chown -R developer:developer /home/developer/.ssh
    echo "✅ Chave SSH configurada!"
fi

# Configurar Tailscale se auth key fornecida
if [ -n "$TAILSCALE_AUTH_KEY" ]; then
    echo "🔗 Configurando Tailscale..."
    sudo mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale
    
    # Inicia tailscaled em background
    sudo tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    sleep 2
    
    # Autenticar na rede Tailscale
    sudo tailscale up --authkey="$TAILSCALE_AUTH_KEY" --hostname="devbox-minimal-$(hostname)"
    
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "pending")
    echo "✅ Tailscale configurado! IP: $TAILSCALE_IP"
fi

# Inicia o serviço SSH (Alpine usa /usr/sbin/sshd diretamente)
echo "🚀 Iniciando SSH server..."
sudo /usr/sbin/sshd

echo "✅ DevBox pronto! Conecte via: ssh -p 22 developer@<host>"

# Mantém o container rodando
tail -f /dev/null
