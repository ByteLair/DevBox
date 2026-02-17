#!/bin/bash

# Script para configurar acesso SSH ao workspace
# Uso: ./setup-workspace.sh <nome-workspace> <caminho-chave-publica>

set -e

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <nome-workspace> <caminho-chave-publica>"
    echo "Exemplo: $0 workspace-dev1 ~/.ssh/id_rsa.pub"
    exit 1
fi

WORKSPACE_NAME=$1
SSH_PUBLIC_KEY=$2

if [ ! -f "$SSH_PUBLIC_KEY" ]; then
    echo "❌ Erro: Chave pública não encontrada em $SSH_PUBLIC_KEY"
    exit 1
fi

echo "🔧 Configurando acesso SSH para $WORKSPACE_NAME..."

# Verifica se o container está rodando
if ! docker ps | grep -q "$WORKSPACE_NAME"; then
    echo "❌ Erro: Container $WORKSPACE_NAME não está rodando"
    echo "Execute: docker-compose up -d $WORKSPACE_NAME"
    exit 1
fi

# Copia a chave pública para o container
docker exec "$WORKSPACE_NAME" bash -c "
    mkdir -p /home/developer/.ssh
    chmod 700 /home/developer/.ssh
    cat > /home/developer/.ssh/authorized_keys
    chmod 600 /home/developer/.ssh/authorized_keys
    chown -R developer:developer /home/developer/.ssh
" < "$SSH_PUBLIC_KEY"

# Pega a porta SSH do container
PORT=$(docker port "$WORKSPACE_NAME" 22 | cut -d: -f2)

# Descobre o IP de rede local (exclui loopback)
SERVER_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}' || hostname -I | awk '{print $1}' || echo "SEU_IP_AQUI")

echo "✅ Configuração concluída!"
echo ""
echo "🌐 IP do Servidor: $SERVER_IP"
echo "🔌 Porta SSH: $PORT"
echo ""
echo "📝 Para conectar no VS Code:"
echo "1. Instale a extensão 'Remote - SSH' no VS Code"
echo "2. Adicione no seu ~/.ssh/config:"
echo ""
echo "# Acesso local (mesma máquina)"
echo "Host $WORKSPACE_NAME"
echo "    HostName localhost"
echo "    Port $PORT"
echo "    User developer"
echo "    IdentityFile ~/.ssh/id_rsa"
echo ""
echo "# Acesso remoto (de outra máquina na rede)"
echo "Host $WORKSPACE_NAME-remote"
echo "    HostName $SERVER_IP"
echo "    Port $PORT"
echo "    User developer"
echo "    IdentityFile ~/.ssh/id_rsa"
echo ""
echo "3. No VS Code: Ctrl+Shift+P > 'Remote-SSH: Connect to Host' > $WORKSPACE_NAME"
echo ""
echo "💡 Compartilhe o IP ($SERVER_IP) e a porta ($PORT) com outros usuários da rede!"
