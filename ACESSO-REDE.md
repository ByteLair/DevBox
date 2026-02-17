# 🌐 DevBox - Guia de Acesso em Rede

Guia para acessar o DevBox de outros computadores na sua rede.

## 🎯 Visão Geral

O DevBox está rodando em um servidor e pode ser acessado por qualquer pessoa na rede usando VS Code Remote-SSH.

**O que os usuários precisam:**
- VS Code instalado
- Extensão Remote-SSH
- Acesso de rede ao servidor
- Sua chave SSH pública (vamos adicionar no DevBox)

## 📋 Informações do Servidor

**IP do Servidor:** `<IP_DO_SERVIDOR>` (substitua pelo IP local do seu servidor)  
**Porta SSH:** `2222`  
**Usuário:** `developer`  
**Autenticação:** Chave pública SSH

## 👥 Para Usuários - Configuração Rápida (5 minutos)

### Passo 1: Instalar Extensão do VS Code

1. Abra o VS Code
2. Pressione `Ctrl+Shift+X` (Extensões)
3. Busque por "Remote - SSH"
4. Instale **Remote - SSH** da Microsoft

### Passo 2: Configurar Conexão SSH

O arquivo de configuração SSH varia por sistema operacional:

#### 🪟 Windows

**Local do arquivo:** `C:\Users\SeuNome\.ssh\config`

```
Host devbox
    HostName <IP_DO_SERVIDOR>
    Port 2222
    User developer
    IdentityFile C:\Users\SeuNome\.ssh\id_rsa
```

⚠️ **Importante no Windows:**
- Use **barras invertidas** (`\`) no `IdentityFile`
- Se não existir, crie a pasta `.ssh` e o arquivo `config` (sem extensão)

#### 🍎 Mac / 🐧 Linux

**Local do arquivo:** `~/.ssh/config`

```
Host devbox
    HostName <IP_DO_SERVIDOR>
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa
```

**Substitua `<IP_DO_SERVIDOR>`** pelo IP real do servidor (ex: `192.168.1.100`)

### Passo 3: Conectar!

1. Pressione `F1` ou `Ctrl+Shift+P` no VS Code
2. Digite: "Remote-SSH: Connect to Host"
3. Selecione **"devbox"** da lista
4. Pronto! 🎉

**Primeira conexão:** Demora um pouco (VS Code instala componentes no servidor)  
**Próximas vezes:** Conexão instantânea!

## 🔐 Para o Admin do Servidor - Adicionar Novo Usuário

Quando alguém quiser acesso, precisa te enviar a **chave pública SSH**.

### Usuário gera sua chave (apenas primeira vez):

#### 🪟 Windows (PowerShell)

```powershell
# Gerar chave SSH
ssh-keygen -t rsa -b 4096 -C "email@dele.com"

# Ver a chave pública
type $env:USERPROFILE\.ssh\id_rsa.pub
```

#### 🍎 Mac / 🐧 Linux

```bash
# Gerar chave SSH
ssh-keygen -t rsa -b 4096 -C "email@dele.com"

# Ver a chave pública
cat ~/.ssh/id_rsa.pub
```

Copie a saída completa (começa com `ssh-rsa AAAA...`) e envie para o administrador.

### Você adiciona a chave no DevBox:

**Opção A: Adicionar manualmente (para 1-2 usuários)**

```bash
# Conectar no DevBox como admin
ssh -p 2222 developer@localhost

# Adicionar a chave
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com" >> ~/.ssh/authorized_keys

# Corrigir permissões
chmod 600 ~/.ssh/authorized_keys
```

**Opção B: Script para múltiplos usuários (recomendado)** ⭐

Já criamos o script `add-user.sh` para você!

```bash
./add-user.sh 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... user@email.com'
```

Simples assim! O script:
- ✅ Valida se é uma chave SSH válida
- ✅ Adiciona no container automaticamente
- ✅ Configura permissões corretas
- ✅ Mostra instruções para o usuário

## 🌐 Configuração de Rede

### Descobrir o IP do seu servidor:

**Linux:**
```bash
hostname -I | awk '{print $1}'
```

**Ou checar com:**
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

### Abrir porta no firewall (se necessário):

**Ubuntu/Debian:**
```bash
sudo ufw allow 2222/tcp
sudo ufw status
```

**CentOS/RHEL:**
```bash
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

## 📱 Cartão de Referência Rápida para Usuários

Crie este cartão para sua equipe:

```
╔══════════════════════════════════════════╗
║     DevBox - Acesso Rápido               ║
╠══════════════════════════════════════════╣
║                                          ║
║  1. Instalar VS Code + Remote-SSH       ║
║  2. Adicionar ao ~/.ssh/config:         ║
║                                          ║
║     Host devbox                          ║
║         HostName <IP_DO_SERVIDOR>        ║
║         Port 2222                        ║
║         User developer                   ║
║         IdentityFile ~/.ssh/id_rsa      ║
║                                          ║
║  3. No VS Code: F1 > Remote-SSH:        ║
║     Connect to Host > devbox            ║
║                                          ║
║  Precisa de acesso? Envie sua chave     ║
║  SSH pública: cat ~/.ssh/id_rsa.pub     ║
║                                          ║
╚══════════════════════════════════════════╝
```

## 🎯 Recursos do VS Code Remote Development

Ao conectar, os usuários têm:

- ✅ IDE completa dentro do container
- ✅ Todas as extensões funcionam (instala uma vez, persiste)
- ✅ Terminal integrado
- ✅ Integração com Git
- ✅ Suporte a debugging
- ✅ Port forwarding (acessar servidores locais)
- ✅ Sincronização de arquivos (automática)

## 🔧 Configuração Avançada

### Portas customizadas por usuário (opcional)

Se quiser isolamento, crie múltiplos workspaces:

```yaml
# docker-compose.yml
services:
  devbox-user1:
    build: .
    ports:
      - "2222:22"
    volumes:
      - user1-data:/home/developer
      
  devbox-user2:
    build: .
    ports:
      - "2223:22"
    volumes:
      - user2-data:/home/developer

volumes:
  user1-data:
  user2-data:
```

### Limites de recursos por usuário:

Já configurado no docker-compose-env.yml!
- CPU: 4 cores máximo
- RAM: 8GB máximo

Ajuste conforme a capacidade do seu servidor.

## 📊 Monitoramento

### Ver quem está conectado:

```bash
# Mostrar conexões SSH ativas
docker exec workspace-dev who

# Ver uso de recursos
docker stats workspace-dev
```

### Ver logs de conexão:

```bash
docker logs workspace-dev | grep "Accepted publickey"
```

## 🆘 Resolução de Problemas

### Usuário não consegue conectar:

1. **Verificar se a chave SSH foi adicionada:**
   ```bash
   docker exec workspace-dev cat /home/developer/.ssh/authorized_keys
   ```

2. **Testar do servidor:**
   ```bash
   ssh -p 2222 developer@localhost
   ```

3. **Verificar firewall:**
   ```bash
   sudo ufw status | grep 2222
   ```

4. **Verificar se container está rodando:**
   ```bash
   docker ps | grep workspace-dev
   ```

### Conexão está lenta:

Adicionar ao SSH config do container:
```bash
docker exec workspace-dev bash -c "echo 'UseDNS no' >> /etc/ssh/sshd_config"
docker-compose -f docker-compose-env.yml restart
```

## 🎓 Treinando sua Equipe

Envie este guia de 3 passos:

1. **Instalar extensão Remote-SSH** no VS Code
2. **Copiar esta config** para `~/.ssh/config` (substituir IP_DO_SERVIDOR):
   ```
   Host devbox
       HostName IP_DO_SERVIDOR
       Port 2222
       User developer
   ```
3. **Enviar chave pública** para o admin: `cat ~/.ssh/id_rsa.pub`

Após o admin adicionar: **F1 > Remote-SSH: Connect > devbox** ✅

---

**Fácil para os usuários, simples para admins!** 🚀
