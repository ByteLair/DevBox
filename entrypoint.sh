#!/bin/bash
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

# Inicia o serviço SSH
echo "🚀 Iniciando SSH server..."
service ssh start

echo "✅ DevBox pronto! Conecte via: ssh -p 22 developer@<host>"

# Mantém o container rodando
tail -f /dev/null
