#!/bin/bash

# DevBox Self-Service Portal
# Portal web para usuários adicionarem suas próprias chaves SSH

set -e

CONTAINER_NAME="workspace-dev"
PORTAL_PORT="${PORTAL_PORT:-8080}"

echo "🌐 DevBox Self-Service Portal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Criar diretório temporário para o portal
PORTAL_DIR="/tmp/devbox-portal"
mkdir -p "$PORTAL_DIR"

# Criar servidor web simples em Python
cat > "$PORTAL_DIR/portal.py" << 'EOF'
#!/usr/bin/env python3
import os
import re
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs

CONTAINER_NAME = os.getenv('CONTAINER_NAME', 'workspace-dev')
PORT = int(os.getenv('PORTAL_PORT', '8080'))

HTML_FORM = """
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DevBox - Auto Cadastro</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 100%;
            padding: 40px;
        }
        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 25px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }
        input, textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e1e8ed;
            border-radius: 8px;
            font-size: 14px;
            font-family: 'Monaco', 'Courier New', monospace;
            transition: border-color 0.3s;
        }
        input:focus, textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        textarea {
            min-height: 150px;
            resize: vertical;
        }
        button {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
        }
        button:active {
            transform: translateY(0);
        }
        .instructions {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            font-size: 13px;
            line-height: 1.6;
        }
        .instructions code {
            background: #e1e8ed;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Monaco', 'Courier New', monospace;
        }
        .success {
            background: #d4edda;
            color: #155724;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #c3e6cb;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #f5c6cb;
        }
        .ssh-config {
            background: #2d3748;
            color: #e2e8f0;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
            font-family: 'Monaco', 'Courier New', monospace;
            font-size: 12px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 DevBox - Auto Cadastro</h1>
        <p class="subtitle">Adicione sua chave SSH para acessar o workspace</p>
        
        <div class="instructions">
            <strong>📝 Como obter sua chave SSH pública:</strong><br><br>
            <strong>Linux/Mac:</strong><br>
            <code>cat ~/.ssh/id_rsa.pub</code><br><br>
            <strong>Windows PowerShell:</strong><br>
            <code>type $env:USERPROFILE\\.ssh\\id_rsa.pub</code><br><br>
            <strong>Não tem chave?</strong><br>
            <code>ssh-keygen -t rsa -b 4096 -C "seu@email.com"</code>
        </div>
        
        {MESSAGE}
        
        <form method="POST" action="/">
            <div class="form-group">
                <label for="name">👤 Seu Nome:</label>
                <input type="text" id="name" name="name" placeholder="João Silva" required>
            </div>
            
            <div class="form-group">
                <label for="email">📧 Seu Email:</label>
                <input type="email" id="email" name="email" placeholder="joao@empresa.com" required>
            </div>
            
            <div class="form-group">
                <label for="ssh_key">🔑 Chave SSH Pública:</label>
                <textarea id="ssh_key" name="ssh_key" placeholder="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ..." required></textarea>
            </div>
            
            <button type="submit">✅ Cadastrar Acesso</button>
        </form>
    </div>
</body>
</html>
"""

def validate_ssh_key(key):
    """Valida se é uma chave SSH válida"""
    key = key.strip()
    valid_types = ['ssh-rsa', 'ssh-ed25519', 'ecdsa-sha2-nistp256', 'ecdsa-sha2-nistp384', 'ecdsa-sha2-nistp521']
    return any(key.startswith(t + ' ') for t in valid_types)

def add_ssh_key(name, email, ssh_key):
    """Adiciona chave SSH ao container"""
    try:
        # Adicionar comentário com nome e email
        key_with_comment = f"{ssh_key.strip()} {name} <{email}>"
        
        # Adicionar ao authorized_keys
        cmd = f"""
            mkdir -p /home/developer/.ssh
            echo '{key_with_comment}' >> /home/developer/.ssh/authorized_keys
            chmod 700 /home/developer/.ssh
            chmod 600 /home/developer/.ssh/authorized_keys
            chown -R developer:developer /home/developer/.ssh
        """
        
        subprocess.run(
            ['docker', 'exec', CONTAINER_NAME, 'bash', '-c', cmd],
            check=True,
            capture_output=True
        )
        return True
    except Exception as e:
        print(f"Erro ao adicionar chave: {e}")
        return False

class PortalHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(HTML_FORM.replace('{MESSAGE}', '').encode())
    
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        params = parse_qs(post_data)
        
        name = params.get('name', [''])[0].strip()
        email = params.get('email', [''])[0].strip()
        ssh_key = params.get('ssh_key', [''])[0].strip()
        
        # Validar
        if not name or not email or not ssh_key:
            message = '<div class="error">❌ Todos os campos são obrigatórios!</div>'
        elif not validate_ssh_key(ssh_key):
            message = '<div class="error">❌ Chave SSH inválida! Deve começar com ssh-rsa, ssh-ed25519, etc.</div>'
        elif add_ssh_key(name, email, ssh_key):
            # Descobrir IP do servidor
            try:
                server_ip = subprocess.check_output(
                    "ip route get 1 2>/dev/null | awk '{print $7; exit}'",
                    shell=True
                ).decode().strip() or 'localhost'
            except:
                server_ip = 'SEU_IP_AQUI'
            
            message = f"""
            <div class="success">
                <strong>✅ Acesso cadastrado com sucesso!</strong><br><br>
                👤 Nome: {name}<br>
                📧 Email: {email}<br><br>
                
                <strong>🖥️ Conectar via VS Code Remote-SSH:</strong>
                <div class="ssh-config">Host devbox
    HostName {server_ip}
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa</div>
                
                <strong style="display: block; margin-top: 15px;">💡 Próximos passos:</strong><br>
                1. Copie a configuração acima<br>
                2. Cole no arquivo <code>~/.ssh/config</code><br>
                3. No VS Code: F1 → Remote-SSH: Connect to Host → devbox<br><br>
                
                🎉 Pronto! Você já pode conectar!
            </div>
            """
        else:
            message = '<div class="error">❌ Erro ao cadastrar. Tente novamente ou contate o administrador.</div>'
        
        self.send_response(200)
        self.send_header('Content-type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(HTML_FORM.replace('{MESSAGE}', message).encode())
    
    def log_message(self, format, *args):
        print(f"[{self.date_time_string()}] {format % args}")

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', PORT), PortalHandler)
    print(f"🌐 Portal Self-Service rodando em http://0.0.0.0:{PORT}")
    print(f"📝 Compartilhe este link com sua equipe!")
    print(f"🛑 Pressione Ctrl+C para parar")
    print("")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n\n👋 Portal encerrado!")
EOF

chmod +x "$PORTAL_DIR/portal.py"

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado!"
    echo "Instale com: sudo apt install python3"
    exit 1
fi

# Verificar se container está rodando
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ Container $CONTAINER_NAME não está rodando!"
    exit 1
fi

# Descobrir IP do servidor
SERVER_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}' || hostname -I | awk '{print $1}' || echo "localhost")

echo "✅ Iniciando portal self-service..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Portal disponível em:"
echo ""
echo "   Local:  http://localhost:$PORTAL_PORT"
echo "   Rede:   http://$SERVER_IP:$PORTAL_PORT"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📧 Compartilhe este link com sua equipe:"
echo "   http://$SERVER_IP:$PORTAL_PORT"
echo ""
echo "🔥 Firewall (se necessário):"
echo "   sudo ufw allow $PORTAL_PORT/tcp"
echo ""
echo "🛑 Para parar: Ctrl+C"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Rodar portal
export CONTAINER_NAME
export PORTAL_PORT
python3 "$PORTAL_DIR/portal.py"
