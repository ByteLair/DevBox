#!/bin/bash
# Quick Start - Development Workspace

echo "🚀 Iniciando Workspace..."
echo ""

cd "$(dirname "$0")"

# Para containers antigos se houver
docker-compose down 2>/dev/null || true

# Inicia o workspace
docker-compose -f docker-compose-env.yml up -d

echo ""
echo "⏳ Aguardando workspace iniciar..."
sleep 5

# Verifica status
if docker ps | grep -q workspace-dev; then
    echo "✅ Workspace está rodando!"
    echo ""
    echo "📡 Conectar via SSH:"
    echo "   ssh -p 2222 developer@localhost"
    echo ""
    echo "💻 Conectar via VS Code:"
    echo "   1. Abra o VS Code"
    echo "   2. Ctrl+Shift+P > 'Remote-SSH: Connect to Host'"
    echo "   3. Digite: developer@localhost:2222"
    echo ""
    echo "📊 Status:"
    docker stats workspace-dev --no-stream --format "   CPU: {{.CPUPerc}} | RAM: {{.MemUsage}}"
    echo ""
    echo "📚 Documentação: ACESSO-WORKSPACE.md"
else
    echo "❌ Erro ao iniciar workspace. Verifique os logs:"
    echo "   docker-compose -f docker-compose-env.yml logs"
fi
