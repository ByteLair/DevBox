# 🔢 DevBox - Guia de Múltiplos Workspaces

Guia para criar e gerenciar múltiplos workspaces de desenvolvimento isolados.

## 🎯 Quando Usar Múltiplos Workspaces

**Use múltiplos workspaces quando quiser:**
- ✅ Ambientes isolados por desenvolvedor (diferentes times)
- ✅ Ambientes separados por projeto (frontend/backend/mobile)
- ✅ Diferentes tecnologias (Node.js vs Python vs Go)
- ✅ Isolamento de recursos e limites por workspace
- ✅ Portas SSH independentes e controle de acesso

**Use workspace único quando:**
- ✅ Apenas uma pessoa usando (como sua configuração atual)
- ✅ Deploy em servidor com acesso em rede (todos compartilham um workspace)
- ✅ Gerenciamento e monitoramento mais simples

## 🚀 Início Rápido - Adicionando Mais Workspaces

### Configuração Atual

Você está usando **docker-compose-env.yml** com um único workspace:
- Container: `workspace-dev`
- Porta: `2222`
- Armazenamento: `workspace-storage/` (bind mount)

### Mudar para Múltiplos Workspaces

Use **docker-compose.yml** ao invés, que suporta múltiplos workspaces com volumes Docker.

## 📝 Passo a Passo: Adicionar Novo Workspace

### 1. Parar workspace atual (se estiver rodando)

```bash
docker-compose -f docker-compose-env.yml down
```

### 2. Editar docker-compose.yml

Abra `docker-compose.yml` e duplique um bloco de workspace:

```yaml
version: '3.8'

services:
  # Primeiro workspace
  workspace-dev1:
    build: .
    container_name: workspace-dev1
    hostname: DevBox-1
    restart: unless-stopped
    ports:
      - "2222:22"  # Porta SSH para workspace 1
    volumes:
      - dev1-home:/home/developer  # Armazenamento persistente
      - dev1-ssh:/home/developer/.ssh  # Chaves SSH
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G

  # Segundo workspace (NOVO!)
  workspace-dev2:
    build: .
    container_name: workspace-dev2
    hostname: DevBox-2
    restart: unless-stopped
    ports:
      - "2223:22"  # Porta diferente! ⚠️
    volumes:
      - dev2-home:/home/developer
      - dev2-ssh:/home/developer/.ssh
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G

  # Terceiro workspace (se necessário)
  workspace-frontend:
    build: .
    container_name: workspace-frontend
    hostname: DevBox-Frontend
    restart: unless-stopped
    ports:
      - "2224:22"  # Outra porta diferente
    volumes:
      - frontend-home:/home/developer
      - frontend-ssh:/home/developer/.ssh
    environment:
      - TZ=America/Sao_Paulo
    deploy:
      resources:
        limits:
          cpus: '2.0'  # Menos recursos para carga mais leve
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G

# Não esqueça de declarar os volumes!
volumes:
  dev1-home:
    driver: local
  dev1-ssh:
    driver: local
  dev2-home:
    driver: local
  dev2-ssh:
    driver: local
  frontend-home:
    driver: local
  frontend-ssh:
    driver: local
```

### 3. Buildar e iniciar todos os workspaces

```bash
# Build da imagem (se ainda não foi feito)
docker-compose build

# Iniciar todos os workspaces
docker-compose up -d

# Ou iniciar workspace específico:
docker-compose up -d workspace-dev1
```

### 4. Adicionar chaves SSH em cada workspace

Cada workspace precisa de suas chaves SSH autorizadas:

```bash
# Para workspace 1
docker exec -i workspace-dev1 bash -c "
    mkdir -p /home/developer/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com' >> /home/developer/.ssh/authorized_keys
    chmod 600 /home/developer/.ssh/authorized_keys
    chown developer:developer /home/developer/.ssh/authorized_keys
"

# Para workspace 2
docker exec -i workspace-dev2 bash -c "
    mkdir -p /home/developer/.ssh
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com' >> /home/developer/.ssh/authorized_keys
    chmod 600 /home/developer/.ssh/authorized_keys
    chown developer:developer /home/developer/.ssh/authorized_keys
"
```

### 5. Configurar acesso SSH para cada workspace

No seu `~/.ssh/config`:

```
Host devbox-1
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa

Host devbox-2
    HostName localhost
    Port 2223
    User developer
    IdentityFile ~/.ssh/id_rsa

Host devbox-frontend
    HostName localhost
    Port 2224
    User developer
    IdentityFile ~/.ssh/id_rsa
```

### 6. Conectar!

```bash
# Conectar ao workspace 1
ssh devbox-1

# Conectar ao workspace 2
ssh devbox-2

# Ou diretamente:
ssh -p 2222 developer@localhost  # workspace 1
ssh -p 2223 developer@localhost  # workspace 2
ssh -p 2224 developer@localhost  # workspace frontend
```

## 🔧 Comandos de Gerenciamento

### Ver todos os workspaces

```bash
docker-compose ps
```

### Iniciar/parar workspace específico

```bash
# Iniciar
docker-compose up -d workspace-dev1

# Parar
docker-compose stop workspace-dev1

# Reiniciar
docker-compose restart workspace-dev2
```

### Iniciar/parar todos os workspaces

```bash
# Iniciar todos
docker-compose up -d

# Parar todos
docker-compose down

# Reiniciar todos
docker-compose restart
```

### Ver logs

```bash
# Todos os workspaces
docker-compose logs -f

# Workspace específico
docker-compose logs -f workspace-dev1
```

### Monitoramento de recursos

```bash
# Ver uso de recursos
docker stats

# Workspace específico
docker stats workspace-dev1
```

## 📊 Planejamento de Recursos

**Exemplo de servidor com 32GB RAM e 16 cores:**

Você poderia criar:
- 4 workspaces com 8GB RAM cada (4GB reservado)
- Cada um com limite de 4 cores CPU (2 cores reservados)

Ajuste `deploy.resources` no docker-compose.yml:

```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'    # CPUs máximas
      memory: 8G     # RAM máxima
    reservations:
      cpus: '2.0'    # CPUs garantidas
      memory: 4G     # RAM garantida
```

## 🌐 Acesso em Rede com Múltiplos Workspaces

Mesmo servidor, múltiplos workspaces, portas diferentes:

**Configuração do usuário (`~/.ssh/config`):**

```
Host devbox-backend
    HostName server.empresa.com
    Port 2222
    User developer

Host devbox-frontend
    HostName server.empresa.com
    Port 2223
    User developer

Host devbox-mobile
    HostName server.empresa.com
    Port 2224
    User developer
```

**Configuração de firewall:**

```bash
# Abrir todas as portas dos workspaces
sudo ufw allow 2222:2230/tcp
```

## 🔐 Diferentes Usuários por Workspace

Você pode configurar chaves SSH diferentes por workspace:

**Workspace 1 - Time A:**
```bash
docker exec -i workspace-dev1 bash -c "
    echo 'ssh-rsa AAA... alice@empresa.com' >> /home/developer/.ssh/authorized_keys
    echo 'ssh-rsa BBB... bob@empresa.com' >> /home/developer/.ssh/authorized_keys
"
```

**Workspace 2 - Time B:**
```bash
docker exec -i workspace-dev2 bash -c "
    echo 'ssh-rsa CCC... charlie@empresa.com' >> /home/developer/.ssh/authorized_keys
    echo 'ssh-rsa DDD... diana@empresa.com' >> /home/developer/.ssh/authorized_keys
"
```

## 💡 Casos de Uso

### Caso de Uso 1: Workspaces por Projeto

```yaml
services:
  workspace-api:
    # ... Node.js 20 para desenvolvimento de API
    ports: ["2222:22"]
    
  workspace-web:
    # ... Desenvolvimento frontend
    ports: ["2223:22"]
    
  workspace-mobile:
    # ... React Native / Flutter
    ports: ["2224:22"]
```

### Caso de Uso 2: Workspaces por Desenvolvedor

```yaml
services:
  workspace-alice:
    ports: ["2222:22"]
    volumes:
      - alice-data:/home/developer
    
  workspace-bob:
    ports: ["2223:22"]
    volumes:
      - bob-data:/home/developer
```

### Caso de Uso 3: Workspaces por Ambiente

```yaml
services:
  workspace-dev:
    # Ambiente de desenvolvimento
    ports: ["2222:22"]
    
  workspace-staging:
    # Testes de staging
    ports: ["2223:22"]
    
  workspace-qa:
    # Testes de QA
    ports: ["2224:22"]
```

## 🔄 Migrando de Único para Múltiplos Workspaces

### Sua configuração atual (docker-compose-env.yml):
- 1 workspace
- Bind mount: `./workspace-storage`
- Porta: 2222

### Para migrar para múltiplos workspaces:

**Opção 1: Manter workspace único, adicionar novos**

1. Renomear workspace atual no docker-compose.yml para coincidir com seu container:
   ```yaml
   workspace-dev:  # Coincidir com nome do container atual
     ports: ["2222:22"]
     volumes:
       - ./workspace-storage:/home/developer  # Manter bind mount
   ```

2. Adicionar novos workspaces com volumes Docker:
   ```yaml
   workspace-dev2:
     ports: ["2223:22"]
     volumes:
       - dev2-home:/home/developer
   ```

**Opção 2: Começar do zero com todos os volumes Docker**

1. Fazer backup dos dados atuais:
   ```bash
   cp -r workspace-storage workspace-storage-backup
   ```

2. Parar e remover setup antigo:
   ```bash
   docker-compose -f docker-compose-env.yml down
   ```

3. Iniciar com docker-compose.yml:
   ```bash
   docker-compose up -d
   ```

4. Copiar dados para novo volume se necessário:
   ```bash
   docker cp workspace-storage-backup/. workspace-dev1:/home/developer/
   ```

## 📚 Exemplo Completo de Configuração

Veja o arquivo `docker-compose.yml` incluído para um exemplo completo funcionando com 2 workspaces pré-configurados.

## 🆘 Resolução de Problemas

### Porta já em uso

**Erro:** `bind: address already in use`

**Solução:** Mudar a porta no docker-compose.yml:
```yaml
ports:
  - "2225:22"  # Usar uma porta diferente do host
```

### Não encontra workspace

**Erro:** `No such service: workspace-dev3`

**Solução:** Certifique-se de que adicionou no docker-compose.yml e declarou seus volumes.

### Sem recursos

**Erro:** Container usando muita RAM

**Solução:** Ajustar limites de recursos:
```yaml
deploy:
  resources:
    limits:
      memory: 4G  # Reduzir limite
```

---

**Precisa de ajuda?** Veja os guias principais [README.pt-BR.md](README.pt-BR.md) ou [ACESSO-REDE.md](ACESSO-REDE.md)! 🚀
