# 🚀 Como Acessar o Workspace

Guia rápido para conectar e usar seu workspace de desenvolvimento.

## 📋 Informações do Workspace

Após iniciar o workspace, você terá:

- **Container:** workspace-dev (configurável)
- **Porta SSH:** 2222 (padrão)
- **Usuário:** developer
- **Diretório de trabalho:** /home/developer
- **Armazenamento:** Definido no docker-compose

## ⚡ Iniciar o Workspace

```bash
# Primeira vez (build + start)
docker-compose -f docker-compose-env.yml up -d --build

# Próximas vezes
docker-compose -f docker-compose-env.yml up -d
```

## 🔌 Conectar via SSH

### Opção 1: Conexão direta

```bash
ssh -p 2222 developer@localhost
```

### Opção 2: Configurar alias no ~/.ssh/config (recomendado)

Adicione ao arquivo `~/.ssh/config`:

```
Host my-workspace
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa
```

Depois conecte com:

```bash
ssh my-workspace
```

## 💻 Conectar via VS Code

### 1. Instalar extensão Remote-SSH

1. Abra o VS Code
2. Pressione `Ctrl+Shift+X` (ou `Cmd+Shift+X` no Mac)
3. Procure por "Remote - SSH"
4. Instale a extensão da Microsoft (ms-vscode-remote.remote-ssh)

### 2. Conectar ao workspace

1. Pressione `Ctrl+Shift+P` (ou `Cmd+Shift+P` no Mac)
2. Digite "Remote-SSH: Connect to Host"
3. Selecione seu workspace (ou digite `developer@localhost:2222`)
4. Aguarde a conexão ser estabelecida
5. Abra a pasta `/home/developer`

**Pronto!** Você está codando dentro do container! 🎉

## 🛠️ Comandos Úteis

### Gerenciamento básico

```bash
# Parar workspace (dados são mantidos)
docker-compose -f docker-compose-env.yml down

# Reiniciar workspace
docker-compose -f docker-compose-env.yml restart

# Ver logs em tempo real
docker-compose -f docker-compose-env.yml logs -f
```

### Monitoramento

```bash
# Ver status do container
docker ps

# Ver uso de recursos (CPU, RAM)
docker stats

# Ver uso de disco dentro do workspace
ssh my-workspace df -h
```

### Debug

```bash
# Ver logs do workspace
docker-compose -f docker-compose-env.yml logs

# Entrar no container como root (para debug)
docker exec -it workspace-dev bash
```

## 📁 Organização de Projetos

Recomendamos organizar seus projetos dentro de `/home/developer`:

```bash
# Conecte ao workspace
ssh my-workspace

# Crie uma estrutura de pastas
mkdir -p ~/projects
cd ~/projects

# Clone seus repositórios
git clone git@github.com:seu-usuario/projeto1.git
git clone git@github.com:seu-usuario/projeto2.git

# Configure git
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

## 🔧 Personalizar Ambiente

### Instalar pacotes

```bash
# Ferramentas do sistema
sudo apt update
sudo apt install postgresql-client redis-tools htop

# Pacotes Python
pip3 install --user flask fastapi requests

# Pacotes Node.js
npm install -g typescript yarn pnpm
```

### Configurar shell

Edite `~/.bashrc` no workspace para personalizar seu ambiente:

```bash
ssh my-workspace
nano ~/.bashrc
# Adicione seus aliases, variáveis de ambiente, etc.
```

## 📊 Recursos pré-instalados

- **Sistema:** Ubuntu 22.04 LTS
- **Node.js:** v20 LTS (com npm)
- **Python:** 3.10 (com pip)
- **Git:** 2.34+
- **Ferramentas:** vim, nano, curl, wget, build-essential
- **Sudo:** Disponível sem senha

## 🆘 Troubleshooting

### ❌ Não consigo conectar via SSH

```bash
# Verifique se o container está rodando
docker ps

# Verifique os logs
docker-compose -f docker-compose-env.yml logs

# Teste a conexão com verbose
ssh -vvv -p 2222 developer@localhost
```

### ❌ Erro "Permission denied (publickey)"

Sua chave SSH pública não está configurada no container.

1. Verifique o arquivo `.env`:
   ```bash
   cat .env
   ```

2. Certifique-se de que contém sua chave pública completa

3. Reconstrua o container:
   ```bash
   docker-compose -f docker-compose-env.yml up -d --build
   ```

### ❌ Container não inicia

```bash
# Veja os logs detalhados
docker-compose -f docker-compose-env.yml logs

# Force a recriação
docker-compose -f docker-compose-env.yml up -d --build --force-recreate
```

### ❌ Esqueci de salvar meu trabalho e recriei o container

Não se preocupe! Seus dados estão seguros em `workspace-storage/` (ou no volume Docker configurado).

Quando você recria o container, os dados em `/home/developer` são mantidos.

## 📝 Notas Importantes

- ✅ Todos os dados em `/home/developer` são persistentes
- ✅ Você tem acesso sudo sem senha dentro do container
- ✅ O workspace reinicia automaticamente se o Docker reiniciar
- ⚠️ Não use `docker-compose down -v` ou você perderá os dados!
- ⚠️ Faça backup regular do diretório `workspace-storage/`

## 🎯 Quick Start (TL;DR)

```bash
# 1. Configure sua chave SSH no .env
cp env.example .env
nano .env  # Adicione sua chave pública

# 2. Inicie o workspace
docker-compose -f docker-compose-env.yml up -d --build

# 3. Conecte
ssh -p 2222 developer@localhost

# Ou use VS Code com Remote-SSH!
```

## 📚 Mais Informações

- [README.md](README.md) - Documentação completa do projeto
- [SETUP-SSH.md](SETUP-SSH.md) - Como configurar chaves SSH

---

**Workspace pronto para desenvolvimento!** 🎉
