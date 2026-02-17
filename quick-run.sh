#!/bin/bash

# DevBox - Pull & Run Automático
# Uso: curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/quick-run.sh | bash
#
# Este script puxa a imagem do Docker Hub e roda tudo automaticamente

set -e

echo "🚀 DevBox Quick Run"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado!"
    echo "Instale com: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

echo "✅ Docker: $(docker --version)"
echo ""

# Configurar chave SSH
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "⚠️  Chave SSH não encontrada"
    read -p "Deseja gerar uma nova? (S/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
        echo "✅ Chave SSH gerada!"
    else
        echo "❌ Necessário ter chave SSH"
        exit 1
    fi
fi

SSH_PUBLIC_KEY=$(cat "$SSH_KEY_PATH")

# Verificar se já existe container
if docker ps -a | grep -q devbox-quick; then
    echo "⚠️  Container 'devbox-quick' já existe"
    read -p "Deseja remover e recriar? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        docker rm -f devbox-quick
    else
        echo "Use: docker start devbox-quick"
        exit 0
    fi
fi

# Puxar imagem do Docker Hub
echo "📥 Baixando imagem do Docker Hub..."
docker pull lyskdot/devbox:latest

# Criar volume para dados
docker volume create devbox-quick-data

# Rodar container
echo "🐳 Iniciando DevBox..."
docker run -d \
    --name devbox-quick \
    -p 2222:22 \
    -e SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
    -v devbox-quick-data:/home/developer \
    --cpus="4" \
    --memory="8g" \
    --restart unless-stopped \
    lyskdot/devbox:latest

# Aguardar
echo "⏳ Aguardando inicialização..."
sleep 5

# Verificar
if docker ps | grep -q devbox-quick; then
    # Descobrir IP
    SERVER_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}' || echo "localhost")
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ DevBox rodando!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🔌 Conectar via SSH:"
    echo "   ssh -p 2222 developer@localhost"
    echo ""
    echo "🖥️  Conectar via VS Code Remote-SSH:"
    echo "   Adicione no ~/.ssh/config:"
    echo ""
    echo "   Host devbox"
    echo "       HostName $SERVER_IP"
    echo "       Port 2222"
    echo "       User developer"
    echo "       IdentityFile ~/.ssh/id_rsa"
    echo ""
    echo "🛑 Parar: docker stop devbox-quick"
    echo "🔄 Reiniciar: docker start devbox-quick"
    echo "🗑️  Remover: docker rm -f devbox-quick"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "❌ Erro ao iniciar"
    docker logs devbox-quick
    exit 1
fi
