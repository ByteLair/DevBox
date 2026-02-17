#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ByteLair CLI Installer
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════╗
║                                            ║
║   ____        _       _       _____ ____   ║
║  |  _ \      | |     | |     / ____|  _ \  ║
║  | |_) |_   _| |_ ___| |    | (___ | |_) | ║
║  |  _ <| | | |  _/ _ \ |     \___ \|  _ <  ║
║  | |_) | |_| | ||  __/ |____ ____) | |_) | ║
║  |____/ \__, |\__\___|______|_____/|____/  ║
║          __/ |                             ║
║         |___/     DevBox CLI v1.1.0        ║
║                                            ║
╔════════════════════════════════════════════╗
EOF
echo -e "${NC}"

echo -e "${BLUE}🚀 Instalando ByteLair CLI...${NC}\n"

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Não execute este script como root/sudo${NC}"
    exit 1
fi

# Check Docker
echo -e "${CYAN}🐳 Verificando Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não encontrado. Instale o Docker primeiro:${NC}"
    echo -e "${YELLOW}https://docs.docker.com/engine/install/${NC}"
    exit 1
fi

if ! docker ps &> /dev/null; then
    echo -e "${RED}❌ Docker não está rodando ou você não tem permissão${NC}"
    echo -e "${YELLOW}Adicione seu usuário ao grupo docker:${NC}"
    echo -e "${YELLOW}sudo usermod -aG docker \$USER${NC}"
    echo -e "${YELLOW}Depois faça logout/login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker OK${NC}"

# Check Python
echo -e "${CYAN}🐍 Verificando Python 3...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 não encontrado${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo -e "${GREEN}✅ Python ${PYTHON_VERSION} OK${NC}"

# Check pip
if ! command -v pip3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  pip3 não encontrado. Instalando...${NC}"
    python3 -m ensurepip --user
fi

# Create installation directory
INSTALL_DIR="$HOME/.bytelair/cli"
echo -e "${CYAN}📁 Criando diretório de instalação...${NC}"
mkdir -p "$INSTALL_DIR"

# Download CLI files
echo -e "${CYAN}📥 Baixando arquivos da CLI...${NC}"

# Determine download method
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/bytelair.py" ]; then
    # Running from repo/local directory
    echo -e "${YELLOW}Detectado instalação local. Copiando arquivos...${NC}"
    cp "$SCRIPT_DIR/bytelair.py" "$INSTALL_DIR/"
    cp "$SCRIPT_DIR/project_detector.py" "$INSTALL_DIR/"
    cp "$SCRIPT_DIR/config.py" "$INSTALL_DIR/"
    cp "$SCRIPT_DIR/requirements.txt" "$INSTALL_DIR/"
else
    # Download from GitHub
    echo -e "${YELLOW}Baixando do GitHub...${NC}"
    GITHUB_RAW="https://raw.githubusercontent.com/ByteLair/DevBox/main/cli"
    
    wget -q "$GITHUB_RAW/bytelair.py" -O "$INSTALL_DIR/bytelair.py" || \
        curl -fsSL "$GITHUB_RAW/bytelair.py" -o "$INSTALL_DIR/bytelair.py"
    
    wget -q "$GITHUB_RAW/project_detector.py" -O "$INSTALL_DIR/project_detector.py" || \
        curl -fsSL "$GITHUB_RAW/project_detector.py" -o "$INSTALL_DIR/project_detector.py"
    
    wget -q "$GITHUB_RAW/config.py" -O "$INSTALL_DIR/config.py" || \
        curl -fsSL "$GITHUB_RAW/config.py" -o "$INSTALL_DIR/config.py"
    
    wget -q "$GITHUB_RAW/requirements.txt" -O "$INSTALL_DIR/requirements.txt" || \
        curl -fsSL "$GITHUB_RAW/requirements.txt" -o "$INSTALL_DIR/requirements.txt"
fi

# Install Python dependencies
echo -e "${CYAN}📦 Instalando dependências Python...${NC}"
pip3 install --user -q -r "$INSTALL_DIR/requirements.txt"

# Make CLI executable
chmod +x "$INSTALL_DIR/bytelair.py"

# Create symlink
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# Remove old symlink if exists
[ -L "$BIN_DIR/bytelair" ] && rm "$BIN_DIR/bytelair"

ln -s "$INSTALL_DIR/bytelair.py" "$BIN_DIR/bytelair"

echo -e "${GREEN}✅ ByteLair CLI instalada com sucesso!${NC}\n"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}⚠️  Adicione ~/.local/bin ao seu PATH:${NC}\n"
    
    SHELL_RC=""
    if [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    fi
    
    if [ -n "$SHELL_RC" ]; then
        echo -e "${CYAN}Execute:${NC}"
        echo -e "${YELLOW}echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> $SHELL_RC${NC}"
        echo -e "${YELLOW}source $SHELL_RC${NC}\n"
    fi
else
    echo -e "${GREEN}✅ PATH configurado corretamente${NC}\n"
fi

# Show next steps
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           🎉 INSTALAÇÃO COMPLETA!         ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}\n"

echo -e "${GREEN}📖 Comandos disponíveis:${NC}\n"
echo -e "  ${YELLOW}bytelair up${NC}              # Cria e inicia um workspace"
echo -e "  ${YELLOW}bytelair down${NC}            # Para um workspace"
echo -e "  ${YELLOW}bytelair connect${NC}         # Conecta via VS Code"
echo -e "  ${YELLOW}bytelair list${NC}            # Lista workspaces"
echo -e "  ${YELLOW}bytelair status${NC}          # Status do workspace"
echo -e "  ${YELLOW}bytelair logs${NC}            # Mostra logs"
echo -e "  ${YELLOW}bytelair template list${NC}   # Lista templates"
echo -e ""

echo -e "${CYAN}🚀 Comece agora:${NC}"
echo -e "  ${GREEN}bytelair up${NC}\n"

# Test installation
if command -v bytelair &> /dev/null; then
    echo -e "${GREEN}✅ ByteLair CLI pronta para uso!${NC}"
else
    echo -e "${YELLOW}⚠️  Recarregue seu terminal ou execute:${NC}"
    echo -e "${YELLOW}source ~/.bashrc${NC} (ou ~/.zshrc)"
fi
