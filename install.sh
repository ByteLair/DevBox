#!/bin/bash
set -e

# DevBox - Instalador Automático
# Uso: curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/install.sh | bash

VERSION="${DEVBOX_VERSION:-v1.0.0}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/devbox}"

echo "🚀 DevBox Installer - $VERSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar dependências
echo "📋 Verificando dependências..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado!"
    echo ""
    echo "Instale com:"
    echo "  curl -fsSL https://get.docker.com | sh"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose não encontrado!"
    echo ""
    echo "Instale com:"
    echo "  sudo apt install docker-compose-plugin"
    exit 1
fi

echo "✅ Docker: $(docker --version)"
echo "✅ Compose: $(docker compose version 2>&1 || docker-compose --version)"
echo ""

# Baixar DevBox
echo "📥 Baixando DevBox $VERSION..."

if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Diretório $INSTALL_DIR já existe!"
    read -p "Deseja sobrescrever? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

# Clone ou download
if command -v git &> /dev/null; then
    git clone --depth 1 --branch "$VERSION" https://github.com/ByteLair/DevBox.git "$INSTALL_DIR"
else
    echo "Baixando via curl..."
    mkdir -p "$INSTALL_DIR"
    curl -fsSL "https://github.com/ByteLair/DevBox/archive/refs/tags/$VERSION.tar.gz" | \
        tar -xz -C "$INSTALL_DIR" --strip-components=1
fi

cd "$INSTALL_DIR"

# Configurar chave SSH
echo ""
echo "🔑 Configuração da chave SSH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "⚠️  Chave SSH não encontrada em $SSH_KEY_PATH"
    echo ""
    read -p "Deseja gerar uma nova chave SSH? (S/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
        echo "✅ Chave SSH gerada!"
    else
        echo "❌ Não é possível continuar sem chave SSH"
        exit 1
    fi
fi

# Criar arquivo .env
echo ""
echo "📝 Criando configuração..."
cp env.example .env

SSH_PUBLIC_KEY=$(cat "$SSH_KEY_PATH")
sed -i "s|SSH_PUBLIC_KEY=.*|SSH_PUBLIC_KEY=\"$SSH_PUBLIC_KEY\"|" .env

echo "✅ Arquivo .env configurado"

# Iniciar workspace
echo ""
echo "🐳 Iniciando workspace..."
docker compose -f docker-compose-env.yml up -d

# Aguardar container iniciar
echo "⏳ Aguardando container iniciar..."
sleep 5

# Verificar se está rodando
if docker ps | grep -q workspace-dev; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ DevBox instalado com sucesso!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📍 Instalado em: $INSTALL_DIR"
    echo ""
    echo "🔌 Conectar via SSH:"
    echo "   ssh -p 2222 developer@localhost"
    echo ""
    echo "🖥️  Conectar via VS Code:"
    echo "   1. Instale a extensão 'Remote - SSH'"
    echo "   2. Adicione no ~/.ssh/config:"
    echo ""
    echo "      Host devbox"
    echo "          HostName localhost"
    echo "          Port 2222"
    echo "          User developer"
    echo "          IdentityFile ~/.ssh/id_rsa"
    echo ""
    echo "   3. F1 > Remote-SSH: Connect to Host > devbox"
    echo ""
    echo "📚 Documentação: $INSTALL_DIR/README.md"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo "❌ Erro ao iniciar container"
    echo "Veja os logs com: docker logs workspace-dev"
    exit 1
fi
