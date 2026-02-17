# 🚀 Workspaces Isolados On-Premise

[![Versão](https://img.shields.io/badge/versão-1.0.0-blue.svg)](https://github.com/ByteLair/DevBox/releases/tag/v1.0.0)
[![Licença](https://img.shields.io/badge/licença-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-pronto-brightgreen.svg)](https://www.docker.com/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Remote%20SSH-007ACC.svg)](https://code.visualstudio.com/docs/remote/ssh)

**Português** | [English](README.md)

Sistema simples de workspaces isolados para desenvolvimento, similar ao GitHub Codespaces. Rode seu próprio ambiente de desenvolvimento containerizado com acesso via SSH e VS Code Remote.

## 📋 Características

- ✅ Ambiente totalmente isolado por desenvolvedor
- ✅ Persistência de dados em `/home/developer`
- ✅ Usuário sem privilégios root (mas com sudo)
- ✅ Acesso via VS Code Remote SSH
- ✅ Node.js 20 LTS e Python 3.10 pré-instalados
- ✅ Git configurado
- ✅ Recursos limitados por container (CPU/RAM)
- ✅ Autenticação via chave SSH (passwordless)
- ✅ Armazenamento configurável (50GB padrão)

## 🛠️ Pré-requisitos

- Docker e Docker Compose instalados
- Par de chaves SSH (pública/privada)
- VS Code com extensão "Remote - SSH" (opcional, mas recomendado)

## 🚀 Métodos de Instalação

### ⚡ Método 1: Instalação Automática com Um Comando (Mais Fácil)

Tudo automatizado - baixa, configura SSH e inicia:

```bash
curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/install.sh | bash
```

### 🐳 Método 2: Execução Rápida via Docker Hub (Sem Clone)

Baixa imagem pronta e executa:

```bash
curl -fsSL https://raw.githubusercontent.com/ByteLair/DevBox/main/quick-run.sh | bash
```

Ou manualmente:
```bash
docker pull bytelair/devbox:latest
docker run -d -p 2222:22 \
  -e SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)" \
  -v devbox-data:/home/developer \
  --name devbox \
  bytelair/devbox:latest
```

### 📦 Método 3: Instalação Manual (Controle Total)

#### 1. Clone o repositório

```bash
git clone https://github.com/ByteLair/DevBox.git
cd DevBox
```

#### 2. Configure sua chave SSH

**IMPORTANTE:** Antes de iniciar o workspace, você precisa configurar sua chave SSH pública.

#### 2.1. Obtenha sua chave SSH pública

Se você já tem uma chave SSH:

```bash
cat ~/.ssh/id_rsa.pub
```

Se você ainda não tem, crie uma:

```bash
ssh-keygen -t rsa -b 4096 -C "seu@email.com"
# Pressione Enter para aceitar o local padrão
# Digite uma senha (ou deixe em branco)
```

#### 2.2. Crie o arquivo .env

Copie o arquivo de exemplo e adicione sua chave:

```bash
cp env.example .env
```

Edite o arquivo `.env` e substitua a chave SSH de exemplo pela sua:

```bash
nano .env
# Ou use seu editor preferido: vim, code, etc.
```

O arquivo `.env` deve ficar assim:

```env
# Configuração do Workspace
# Cole aqui a saída do comando: cat ~/.ssh/id_rsa.pub

SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... seu@email.com"
```

> ⚠️ **ATENÇÃO:** O arquivo `.env` contém sua chave SSH e está no `.gitignore`. NUNCA faça commit deste arquivo!
>
> O projeto já vem com um arquivo [env.example](env.example) que mostra o formato correto.

### 3. Inicie o workspace

```bash
docker-compose -f docker-compose-env.yml up -d --build
```

Aguarde alguns minutos na primeira vez (download de imagens e instalação de pacotes).

### 4. Configure o acesso SSH (opcional)

Você pode adicionar um alias ao seu `~/.ssh/config` para facilitar o acesso:

```bash
# Adicione ao arquivo ~/.ssh/config:
Host my-workspace
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa
```

### 5. Conecte ao workspace!

Via SSH direto:
```bash
ssh -p 2222 developer@localhost
```

Ou usando o alias (se configurou):
```bash
ssh my-workspace
```

## 💻 Conectando via VS Code

### 1. Instale a extensão Remote-SSH

1. Abra o VS Code
2. Pressione `Ctrl+Shift+X` (ou `Cmd+Shift+X` no Mac)
3. Procure por "Remote - SSH"
4. Instale a extensão da Microsoft (`ms-vscode-remote.remote-ssh`)

### 2. Conecte ao workspace

1. Pressione `Ctrl+Shift+P` (ou `Cmd+Shift+P` no Mac)
2. Digite "Remote-SSH: Connect to Host"
3. Selecione "workspace-felipe" (ou digite `localhost:2222`)
4. Aguarde a conexão ser estabelecida
5. Abra a pasta `/home/developer`

**Pronto!** Agora você está codando dentro do container isolado! 🎉

## 🌐 Acesso em Rede (Deploy em Servidor)

Quer hospedar o DevBox em um servidor e permitir que seu time acesse remotamente? É super fácil!

### Para Membros da Equipe (Usuários)

1. Instalar **VS Code + extensão Remote-SSH**
2. Adicionar ao `~/.ssh/config`:
   ```
   Host devbox
       HostName <IP_DO_SERVIDOR>
       Port 2222
       User developer
   ```
3. Enviar chave SSH pública para o admin: `cat ~/.ssh/id_rsa.pub`
4. Conectar: **F1 → Remote-SSH: Connect to Host → devbox**

**Só isso!** Sem precisar de Docker na máquina do usuário. Apenas VS Code.

### Para o Admin do Servidor

Adicione novos usuários em segundos:

```bash
./add-user.sh 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com'
```

**Guia completo:** [ACESSO-REDE.md](ACESSO-REDE.md)

### Por que Remote-SSH para Acesso em Rede?

- ✅ **Zero configuração** para usuários (só VS Code + extensão)
- ✅ **Sem Docker** necessário nas máquinas clientes
- ✅ **Recursos centralizados** - um servidor potente, muitos usuários
- ✅ **Mesma experiência** do desenvolvimento local
- ✅ **Funciona de qualquer lugar** - casa, escritório ou remoto

Perfeito para times, escolas ou ambientes de desenvolvimento compartilhados! 🚀

## � Múltiplos Workspaces (Opcional)

Precisa de múltiplos ambientes isolados? Você pode rodar vários workspaces simultaneamente!

### Configuração Rápida

Use `docker-compose.yml` ao invés de `docker-compose-env.yml`:

1. **Edite docker-compose.yml** - duplique blocos de workspace
2. **Mude as portas** para cada workspace (2222, 2223, 2224...)
3. **Declare volumes** para cada workspace
4. **Inicie:** `docker-compose up -d`

### Exemplo de Configuração

```yaml
services:
  workspace-dev1:
    ports: ["2222:22"]
    volumes:
      - dev1-home:/home/developer
  
  workspace-dev2:
    ports: ["2223:22"]
    volumes:
      - dev2-home:/home/developer
  
  workspace-frontend:
    ports: ["2224:22"]
    volumes:
      - frontend-home:/home/developer

volumes:
  dev1-home:
  dev2-home:
  frontend-home:
```

### Conectar a Cada Workspace

```bash
ssh -p 2222 developer@localhost  # Workspace 1
ssh -p 2223 developer@localhost  # Workspace 2
ssh -p 2224 developer@localhost  # Workspace 3
```

**Guia completo:** [MULTIPLOS-WORKSPACES.md](MULTIPLOS-WORKSPACES.md)

### Casos de Uso

- ✅ **Isolamento por projeto** (frontend, backend, mobile)
- ✅ **Ambientes por desenvolvedor** (time A, time B)
- ✅ **Diferentes tecnologias** (Node.js, Python, Go)
- ✅ **Limites de recursos** por workspace

**Sua configuração atual:** Workspace único (mais simples, recomendado para um usuário)

## �📂 Estrutura do Projeto

```
.
├── Dockerfile                    # Definição da imagem do workspace
├── docker-compose.yml           # Configuração para múltiplos workspaces
├── docker-compose-env.yml       # Configuração simplificada (1 workspace)
├── entrypoint.sh                # Script de inicialização do container
├── env.example                  # Exemplo de configuração
├── .env                         # ⚠️ SUA CHAVE SSH (criar, não commitar!)
├── .gitignore                   # Arquivos a ignorar no git
├── workspace-storage/           # ⚠️ Dados do workspace (criado automaticamente)
├── add-user.sh                  # Script para adicionar usuários de rede facilmente
├── README.md                    # Documentação em inglês
├── README.pt-BR.md              # Este arquivo (Português)
├── docs/
│   ├── pt-BR/                   # 📚 Documentação em Português
│   │   ├── ACESSO-WORKSPACE.md
│   │   ├── ACESSO-REDE.md
│   │   ├── MULTIPLOS-WORKSPACES.md
│   │   └── SETUP-SSH.md
│   └── en/                      # 📚 Documentation in English
│       ├── ACCESS-WORKSPACE.md
│       ├── NETWORK-ACCESS.md
│       ├── MULTIPLE-WORKSPACES.md
│       └── SSH-SETUP.md
└── start-workspace.sh           # Script de início rápido
```

## 🔧 Comandos Úteis

### Gerenciamento do workspace

```bash
# Iniciar workspace
docker-compose -f docker-compose-env.yml up -d

# Parar workspace (dados são mantidos)
docker-compose -f docker-compose-env.yml down

# Reiniciar workspace
docker-compose -f docker-compose-env.yml restart

# Ver logs em tempo real
docker-compose -f docker-compose-env.yml logs -f

# Reconstruir após mudanças no Dockerfile
docker-compose -f docker-compose-env.yml up -d --build
```

### Monitoramento

```bash
# Ver status do container
docker ps

# Ver uso de recursos (CPU, RAM)
docker stats workspace-dev

# Ver uso de disco
docker exec workspace-dev df -h
```

### Debug

```bash
# Entrar no container como root
docker exec -it workspace-dev bash

# Ver logs do SSH
docker logs workspace-dev
```

## 📊 Recursos do Workspace

O workspace vem pré-configurado com:

- **Sistema Operacional:** Ubuntu 22.04 LTS
- **Node.js:** v20 LTS (com npm)
- **Python:** 3.10 (com pip)
- **Git:** 2.34+
- **Ferramentas:** vim, nano, curl, wget, build-essential
- **Acesso:** SSH (porta 2222)
- **Usuário:** developer (com sudo sem senha)

## 🎯 Personalização

### Adicionar mais ferramentas

Edite o [Dockerfile](Dockerfile) e adicione suas ferramentas favoritas:

```dockerfile
# Exemplo: adicionar Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    rm go1.21.0.linux-amd64.tar.gz

# Exemplo: adicionar Rust
USER developer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
USER root
```

Depois rebuilde o container:

```bash
docker-compose -f docker-compose-env.yml up -d --build
```

### Ajustar recursos (CPU/RAM)

Edite o [docker-compose-env.yml](docker-compose-env.yml):

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'    # Limite de CPU
      memory: 4G     # Limite de RAM
```

### Criar múltiplos workspaces

Use o [docker-compose.yml](docker-compose.yml) para criar vários workspaces isolados (útil para equipes):

```bash
# Configure as chaves de cada dev no .env
cp env.example .env
# Adicione: DEV1_SSH_KEY="...", DEV2_SSH_KEY="...", etc.

# Inicie todos os workspaces
docker-compose up -d --build
```

Cada workspace terá sua própria porta SSH (2222, 2223, etc.)

## 🔒 Segurança

### ✅ O que está protegido:

- Autenticação apenas via chave SSH (sem senha)
- Root login desabilitado via SSH
- Ambiente isolado por container
- Arquivo `.env` no `.gitignore` (chave não vai para o GitHub)

### ⚠️ Considerações:

- Usuário `developer` tem `sudo` sem senha (facilita instalação de pacotes)
- Porta SSH exposta (2222) - certifique-se de ter firewall configurado
- Dados em `workspace-storage/` são locais - considere backups

### Para remover sudo sem senha:

Edite o [Dockerfile](Dockerfile) e remova o `NOPASSWD`:

```dockerfile
echo "developer ALL=(ALL) ALL" > /etc/sudoers.d/developer && \
```

## 📦 Backup e Restore

### Backup do workspace

```bash
# Backup completo dos dados
tar -czf workspace-backup-$(date +%Y%m%d).tar.gz workspace-storage/

# Ou use rsync para backup incremental
rsync -av workspace-storage/ /caminho/do/backup/
```

### Restore

```bash
# Extrair backup
tar -xzf workspace-backup-20260217.tar.gz
```

## 🆘 Troubleshooting

### ❌ Erro: "Permission denied (publickey)"

**Causa:** Sua chave SSH não está configurada corretamente.

**Solução:**
```bash
# Verifique se sua chave está no .env
cat .env

# Verifique as permissões da sua chave privada
chmod 600 ~/.ssh/id_rsa

# Reconstrua o container
docker-compose -f docker-compose-env.yml up -d --build
```

### ❌ Container não inicia

**Solução:**
```bash
# Veja os logs
docker-compose -f docker-compose-env.yml logs

# Force recriação
docker-compose -f docker-compose-env.yml up -d --build --force-recreate
```

### ❌ Porta 2222 já em uso

**Solução:** Mude a porta no [docker-compose-env.yml](docker-compose-env.yml):

```yaml
ports:
  - "2223:22"  # Use outra porta
```

### ❌ SSH demora muito ou trava

**Causa comum:** DNS reverso lento.

**Solução:** Adicione no `/etc/ssh/sshd_config` do container:
```bash
docker exec workspace-felipe bash -c "echo 'UseDNS no' >> /etc/ssh/sshd_config"
docker-compose -f docker-compose-env.yml restart
```

## 📚 Documentação Adicional

### 🇧🇷 Português

- [ACESSO-WORKSPACE.md](docs/pt-BR/ACESSO-WORKSPACE.md) - Guia detalhado de acesso e uso
- [ACESSO-REDE.md](docs/pt-BR/ACESSO-REDE.md) - Deploy em rede/servidor
- [MULTIPLOS-WORKSPACES.md](docs/pt-BR/MULTIPLOS-WORKSPACES.md) - Configuração de múltiplos workspaces
- [SETUP-SSH.md](docs/pt-BR/SETUP-SSH.md) - Configuração avançada de SSH

### 🇺🇸 English

- [ACCESS-WORKSPACE.md](docs/en/ACCESS-WORKSPACE.md) - Detailed access guide
- [NETWORK-ACCESS.md](docs/en/NETWORK-ACCESS.md) - Network/server deployment guide
- [MULTIPLE-WORKSPACES.md](docs/en/MULTIPLE-WORKSPACES.md) - Multiple workspaces configuration
- [SSH-SETUP.md](docs/en/SSH-SETUP.md) - Advanced SSH configuration

### ⚙️ Arquivos de Configuração

- [env.example](env.example) - Exemplo de arquivo de configuração

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

## 📄 Licença

Este projeto é open source e está disponível sob a licença MIT.

## 💡 Casos de Uso

Este workspace é ideal para:

- ✅ Desenvolvimento isolado e consistente
- ✅ Ambientes efêmeros para testes
- ✅ Onboarding de novos desenvolvedores
- ✅ Projetos com dependências específicas
- ✅ Separação de ambientes de trabalho
- ✅ Desenvolvimento remoto via VS Code

## 🎓 Aprendendo Mais

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [SSH Key Authentication](https://www.ssh.com/academy/ssh/public-key-authentication)

---

**Criado com ❤️ para facilitar o desenvolvimento isolado e seguro.**

Se este projeto foi útil, considere dar uma ⭐ no GitHub!
- ❌ Produção (use K8s ou similar)
- ❌ Workloads pesados (ML, big data)
- ❌ Times muito grandes (>20 devs)
