#!/bin/bash

# Script para adicionar chave SSH de novos usuários no DevBox
# Uso: ./add-user.sh '<chave-ssh-publica>'

set -e

CONTAINER_NAME="workspace-dev"

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função de ajuda
show_help() {
    echo "📘 Uso: ./add-user.sh '<chave-ssh-publica>'"
    echo ""
    echo "Exemplo:"
    echo "  ./add-user.sh 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com'"
    echo ""
    echo "A chave SSH deve começar com um destes tipos:"
    echo "  - ssh-rsa"
    echo "  - ssh-ed25519"
    echo "  - ecdsa-sha2-nistp256"
    echo "  - ecdsa-sha2-nistp384"
    echo "  - ecdsa-sha2-nistp521"
    exit 1
}

# Verifica se tem argumento
if [ "$#" -ne 1 ]; then
    echo -e "${RED}❌ Erro: Número incorreto de argumentos${NC}"
    show_help
fi

SSH_KEY="$1"

# Valida se a chave SSH é válida (começa com tipo conhecido)
if ! echo "$SSH_KEY" | grep -qE '^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp(256|384|521)) '; then
    echo -e "${RED}❌ Erro: Chave SSH inválida${NC}"
    echo "A chave deve começar com: ssh-rsa, ssh-ed25519, ou ecdsa-sha2-nistp*"
    echo ""
    echo "Você enviou:"
    echo "$SSH_KEY" | head -c 100
    echo "..."
    exit 1
fi

# Verifica se o container está rodando
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}❌ Erro: Container ${CONTAINER_NAME} não está rodando${NC}"
    echo ""
    echo "Inicie o workspace primeiro:"
    echo "  docker-compose -f docker-compose-env.yml up -d"
    exit 1
fi

echo -e "${YELLOW}🔍 Verificando se a chave já existe...${NC}"

# Verifica se a chave já existe no authorized_keys
EXISTING=$(docker exec "$CONTAINER_NAME" bash -c "
    if [ -f /home/developer/.ssh/authorized_keys ]; then
        grep -F '$(echo "$SSH_KEY" | awk '{print $2}')' /home/developer/.ssh/authorized_keys || true
    fi
")

if [ -n "$EXISTING" ]; then
    echo -e "${YELLOW}⚠️  Atenção: Esta chave SSH já está cadastrada!${NC}"
    echo ""
    read -p "Deseja continuar mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Operação cancelada."
        exit 0
    fi
fi

echo -e "${YELLOW}🔧 Adicionando chave SSH ao DevBox...${NC}"

# Adiciona a chave ao authorized_keys
docker exec "$CONTAINER_NAME" bash -c "
    mkdir -p /home/developer/.ssh
    echo '$SSH_KEY' >> /home/developer/.ssh/authorized_keys
    chmod 700 /home/developer/.ssh
    chmod 600 /home/developer/.ssh/authorized_keys
    chown -R developer:developer /home/developer/.ssh
"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Chave SSH adicionada com sucesso!${NC}"
    echo ""
    
    # Pega a porta SSH do container
    PORT=$(docker port "$CONTAINER_NAME" 22 2>/dev/null | cut -d: -f2 || echo "2222")
    
    # Pega o IP da máquina (primeiro IP que não seja loopback)
    SERVER_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}' || echo "SEU_IP_AQUI")
    
    echo -e "${GREEN}📝 Instruções para o novo usuário:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "1️⃣  Instale a extensão 'Remote - SSH' no VS Code"
    echo ""
    echo "2️⃣  Adicione no arquivo ~/.ssh/config:"
    echo ""
    echo "    Host devbox"
    echo "        HostName ${SERVER_IP}"
    echo "        Port ${PORT}"
    echo "        User developer"
    echo "        IdentityFile ~/.ssh/id_rsa"
    echo ""
    echo "3️⃣  No VS Code, pressione F1 e digite:"
    echo "    'Remote-SSH: Connect to Host' → Selecione 'devbox'"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${GREEN}🎉 Pronto! O usuário já pode conectar no DevBox!${NC}"
else
    echo -e "${RED}❌ Erro ao adicionar chave SSH${NC}"
    exit 1
fi
