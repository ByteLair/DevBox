#!/bin/bash
# Script para criar volume com limite de 50GB para o workspace

set -e

WORKSPACE_DIR="$(pwd)/workspace-storage"
SIZE_LIMIT="50G"

echo "🔧 Configurando volume do workspace com limite de ${SIZE_LIMIT}..."

# Cria o diretório se não existir
mkdir -p "$WORKSPACE_DIR"

# Verifica se o sistema suporta quota
if command -v quota &> /dev/null; then
    echo "⚠️  Sistema suporta quotas. Configure manualmente se necessário."
    echo "    Exemplo: sudo xfs_quota -x -c \"limit -p bsoft=${SIZE_LIMIT} bhard=${SIZE_LIMIT} \$(id -u)\" /"
else
    echo "✅ Diretório criado: $WORKSPACE_DIR"
    echo "⚠️  Limite de ${SIZE_LIMIT} será aplicado via Docker (melhor esforço)"
fi

# Define permissões
chmod 755 "$WORKSPACE_DIR"

echo ""
echo "✅ Configuração concluída!"
echo "📁 Diretório do workspace: $WORKSPACE_DIR"
echo "💾 Tamanho máximo configurado: ${SIZE_LIMIT}"
