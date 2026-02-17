# 🔐 Guia de Configuração SSH

Este projeto usa autenticação via chave SSH pública para acesso seguro ao workspace. **Sua chave SSH NUNCA será commitada no Git** graças ao `.gitignore`.

## 📋 Passo a Passo

### 1️⃣ Obtenha sua chave SSH pública

#### Se você já tem uma chave SSH:

```bash
cat ~/.ssh/id_rsa.pub
```

Você verá algo como:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... seu@email.com
```

#### Se você NÃO tem uma chave SSH:

Crie uma nova:

```bash
ssh-keygen -t rsa -b 4096 -C "seu@email.com"
```

Pressione Enter para aceitar o local padrão (`~/.ssh/id_rsa`).

Você pode adicionar uma senha ou deixar em branco (Enter).

Depois execute:
```bash
cat ~/.ssh/id_rsa.pub
```

### 2️⃣ Configure o arquivo .env

#### Opção A: Configure manualmente

1. Copie o arquivo de exemplo:
   ```bash
   cp env.example .env
   ```

2. Edite o arquivo `.env`:
   ```bash
   nano .env
   # ou use: vim .env
   # ou use: code .env
   ```

3. Substitua `sua-chave-ssh-publica-aqui` pela saída do comando `cat ~/.ssh/id_rsa.pub`:
   
   ```env
   SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... seu@email.com"
   ```

4. Salve e feche o arquivo.

#### Opção B: Configure automaticamente

```bash
cp env.example .env
echo "SSH_PUBLIC_KEY=\"$(cat ~/.ssh/id_rsa.pub)\"" > .env
```

### 3️⃣ Verifique a configuração

```bash
cat .env
```

Você deve ver algo como:
```env
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFPfOGncsBlZ... seu@email.com"
```

### 4️⃣ Inicie o workspace

```bash
docker-compose -f docker-compose-env.yml up -d --build
```

### 5️⃣ Conecte via SSH

```bash
ssh -p 2222 developer@localhost
```

Ou configure o alias no `~/.ssh/config`:

```bash
cat >> ~/.ssh/config << 'EOF'

Host my-workspace
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa

EOF
```

E conecte com:
```bash
ssh my-workspace
```

## 🔒 Segurança

### ✅ O que está protegido:

- ✅ O arquivo `.env` está no `.gitignore` - **não será commitado**
- ✅ O diretório `workspace-storage/` está no `.gitignore` - **seus dados não vão para o GitHub**
- ✅ Autenticação apenas via chave SSH (sem senha)
- ✅ Root login desabilitado via SSH

### ⚠️ NUNCA faça:

- ❌ NUNCA adicione o `.env` ao git (`git add .env`)
- ❌ NUNCA remova o `.env` do `.gitignore`
- ❌ NUNCA commite sua chave SSH privada (`id_rsa`) - apenas a pública (`id_rsa.pub`)
- ❌ NUNCA compartilhe sua chave privada (`~/.ssh/id_rsa`)

### Verificar se o .env está sendo ignorado:

```bash
git status
```

O arquivo `.env` **NÃO deve aparecer** nos arquivos não rastreados.

Se aparecer:
```bash
git rm --cached .env  # Remove do índice (se já foi adicionado)
```

## 🆘 Troubleshooting

### ❌ Erro: "Permission denied (publickey)"

**Causa:** Sua chave SSH não foi configurada no `.env`.

**Solução:**
1. Verifique o arquivo `.env`:
   ```bash
   cat .env
   ```
2. Certifique-se de que contém sua chave pública completa
3. Reconstrua o container:
   ```bash
   docker-compose -f docker-compose-env.yml up -d --build
   ```

### ❌ Erro: SSH pede senha

**Causa:** A chave pública não está no container OU você está usando a chave errada.

**Solução:**
1. Verifique qual chave o SSH está usando:
   ```bash
   ssh -vvv -p 2222 developer@localhost
   ```
2. Use a chave correta:
   ```bash
   ssh -i ~/.ssh/id_rsa -p 2222 developer@localhost
   ```

### ❌ .env aparece no git status

**Solução:**
```bash
# Verifique se está no .gitignore
grep ".env" .gitignore

# Se não estiver, adicione:
echo ".env" >> .gitignore

# Remova do git se já foi adicionado:
git rm --cached .env
```

## 📚 Mais Informações

- [README.md](README.md) - Documentação completa do projeto
- [ACESSO-WORKSPACE.md](ACESSO-WORKSPACE.md) - Guia detalhado de acesso
- [SSH Key Authentication](https://www.ssh.com/academy/ssh/public-key-authentication)

## 🤔 Dúvidas Frequentes

### Qual é a diferença entre chave pública e privada?

- **Chave Privada** (`id_rsa`): Fica no SEU computador. NUNCA compartilhe!
- **Chave Pública** (`id_rsa.pub`): Pode ser compartilhada. É ela que vai no `.env`

### Posso usar a mesma chave SSH para múltiplos workspaces?

Sim! A mesma chave pública pode ser usada em vários lugares.

### O que acontece se eu perder minha chave privada?

Você não conseguirá mais acessar o workspace via SSH. Você precisará:
1. Gerar uma nova chave SSH
2. Atualizar o `.env` com a nova chave pública
3. Reconstruir o container

### Onde ficam meus dados?

Seus dados ficam em `workspace-storage/` que:
- ✅ Está no `.gitignore` (não vai para o GitHub)
- ✅ É persistente (não é perdido ao recriar o container)
- ⚠️ Faça backup regularmente!

---

**🔐 Segurança em primeiro lugar!** Sempre verifique se seus arquivos sensíveis estão no `.gitignore` antes de fazer commit.
