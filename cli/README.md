# ByteLair CLI

> 🚀 Uma CLI amigável para gerenciar workspaces de desenvolvimento ByteLair DevBox

## ✨ Características

- **Auto-detecção de projetos**: Detecta automaticamente o tipo do projeto (Python, Node.js, Full Stack, etc.)
- **Comandos simples**: `bytelair up` e pronto!
- **Integração VS Code**: Abre VS Code Remote SSH com um comando
- **Templates prontos**: Escolha entre vários templates pré-configurados
- **Gerenciamento inteligente**: Pausa workspaces para economizar recursos
- **Interface bonita**: Output colorido e tabelas organizadas com Rich

## 🚀 Instalação Rápida

### One-liner (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/cli/install.sh | bash
```

### Manual

```bash
# Clone o repositório
git clone https://github.com/ByteLair/DevBox.git
cd DevBox/cli

# Execute o instalador
bash install.sh
```

## 📖 Comandos

### `bytelair up`
Cria e inicia um workspace de desenvolvimento

```bash
# Auto-detecta o projeto no diretório atual
bytelair up

# Especifica nome e template
bytelair up --name meu-projeto --template python

# Customiza recursos
bytelair up --cpu 8 --memory 16g --port 3000
```

**Opções:**
- `--name, -n`: Nome do workspace
- `--port, -p`: Porta SSH (padrão: 2222)
- `--cpu`: Limite de CPUs (padrão: 4)
- `--memory, -m`: Limite de memória (padrão: 8g)
- `--template, -t`: Template do workspace

### `bytelair down`
Para um workspace

```bash
# Pausa workspace (economiza recursos)
bytelair down meu-projeto

# Remove completamente
bytelair down meu-projeto --remove
```

### `bytelair connect`
Conecta ao workspace via VS Code Remote SSH

```bash
# Conecta via VS Code
bytelair connect meu-projeto

# Conecta apenas via SSH
bytelair connect meu-projeto --ssh
```

### `bytelair list`
Lista todos os workspaces

```bash
bytelair list
```

**Output:**
```
📦 Workspaces Disponíveis

Nome         Status       Porta SSH  Template   Uptime
─────────────────────────────────────────────────────
meu-app      🟢 running   2222       python     running
api-backend  🟡 paused    2223       node       paused
```

### `bytelair status`
Mostra status detalhado de um workspace

```bash
bytelair status meu-projeto
```

**Output:**
```
📊 Status do Workspace: meu-projeto

Status        🟢 running
Container ID  f521dd10d864
CPU           12.5%
Memória       2.34GB / 8.00GB (29.2%)
Uptime        running
```

### `bytelair logs`
Mostra logs de um workspace

```bash
# Últimas 100 linhas
bytelair logs meu-projeto

# Segue logs em tempo real
bytelair logs meu-projeto --follow

# Últimas 500 linhas
bytelair logs meu-projeto --tail 500
```

### `bytelair template`
Gerencia templates

```bash
# Lista templates disponíveis
bytelair template list
```

### `bytelair version`
Mostra versão da CLI

```bash
bytelair version
```

## 🎨 Templates Disponíveis

| Template | Descrição | Ferramentas |
|----------|-----------|-------------|
| `base` | Ambiente genérico | Ubuntu 22.04 + Node.js 20 + Python 3.10 + Git |
| `python` | Data Science | Python + Jupyter + Pandas + NumPy + Scikit-learn |
| `node` | Node.js | Node.js 20 LTS + npm + yarn + pnpm |
| `fullstack` | Full Stack | Node.js + Python + PostgreSQL + Redis |

## 🔍 Auto-detecção de Projetos

A CLI detecta automaticamente o tipo do projeto baseado nos arquivos:

| Arquivo | Tipo Detectado |
|---------|---------------|
| `requirements.txt` / `pyproject.toml` | Python |
| `package.json` | Node.js |
| `Gemfile` | Ruby |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml` / `build.gradle` | Java |
| `composer.json` | PHP |

## 📋 Pré-requisitos

- **Docker**: Instalado e rodando
- **Python 3.8+**: Para executar a CLI
- **VS Code** (opcional): Para integração Remote SSH

## 🛠️ Desenvolvimento

### Estrutura de Arquivos

```
cli/
├── bytelair.py          # CLI principal (Typer)
├── project_detector.py  # Auto-detecção de projetos
├── config.py            # Gerenciamento de configuração
├── requirements.txt     # Dependências Python
├── install.sh          # Instalador
└── README.md           # Documentação
```

### Instalação para Desenvolvimento

```bash
cd cli/
pip install -r requirements.txt
chmod +x bytelair.py
./bytelair.py --help
```

### Fazer Symlink Local

```bash
mkdir -p ~/.local/bin
ln -s $(pwd)/bytelair.py ~/.local/bin/bytelair
```

## 🎯 Roadmap

- [x] Comandos básicos (up, down, connect, list, status)
- [x] Auto-detecção de projetos
- [x] Templates
- [ ] Auto-hibernação de workspaces
- [ ] Dashboard web
- [ ] Blueprints customizados
- [ ] Integração com Tailscale/VPN
- [ ] Suporte a clusters

## 🤝 Contribuindo

Contribuições são bem-vindas! Veja [CONTRIBUTING.md](../CONTRIBUTING.md) para detalhes.

## 📄 Licença

MIT - Veja [LICENSE](../LICENSE) para detalhes.

## 🔗 Links

- [GitHub](https://github.com/ByteLair/DevBox)
- [Docker Hub](https://hub.docker.com/r/lyskdot/devbox)
- [Documentação Completa](../docs/pt-BR/)

---

Feito com ❤️ pela equipe ByteLair
