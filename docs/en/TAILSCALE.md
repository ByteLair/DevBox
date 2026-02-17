# 🌐 Tailscale Integration

ByteLair DevBox tem integração nativa com Tailscale para acesso remoto seguro aos seus workspaces de qualquer lugar do mundo!

## 🚀 Quick Start

### 1. Obtenha uma Tailscale Auth Key

1. Acesse: https://login.tailscale.com/admin/settings/keys
2. Click em **Generate auth key**
3. Configure:
   - ✅ **Reusable** (para criar múltiplos workspaces)
   - ✅ **Ephemeral** (opcional - remove o device quando desconectar)
   - Expiração: 90 dias (recomendado)
4. Copie a chave (começa com `tskey-`)

### 2. Configure no ByteLair CLI

```bash
bytelair tailscale setup tskey-auth-XXXXXXXXXXXXX
```

### 3. Crie Workspaces com Tailscale

```bash
# Workspace acessível remotamente
bytelair up --tailscale

# Com template específico
bytelair up --template python --tailscale

# Workspace nomeado
bytelair up --name meu-projeto --tailscale
```

### 4. Conecte de Qualquer Lugar

```bash
# Via SSH
ssh developer@100.x.y.z

# Via VS Code Remote
code --remote ssh-remote+developer@100.x.y.z /home/developer

# Ou use o comando connect (detecta Tailscale automaticamente)
bytelair connect meu-projeto
```

## 📊 Comandos Tailscale

### `bytelair tailscale setup <auth_key>`
Configura Tailscale auth key globalmente

```bash
bytelair tailscale setup tskey-auth-XXXXXXXXXXXXX
```

### `bytelair tailscale status [workspace]`
Mostra status e IP Tailscale de um workspace

```bash
bytelair tailscale status meu-projeto
```

**Output:**
```
🌐 Tailscale Status: meu-projeto

Status        ✅ Conectado
Tailscale IP  100.101.102.103
Hostname      bytelair-meu-projeto
SSH           ssh developer@100.101.102.103
```

### `bytelair tailscale remove`
Remove configuração Tailscale

```bash
bytelair tailscale remove
```

## 🎯 Casos de Uso

### 1. Desenvolvimento Remoto Pessoal

Trabalhe de casa, café, viagens - sempre conectado ao seu workspace:

```bash
# No servidor (uma vez)
bytelair tailscale setup tskey-xxx
bytelair up --name dev --tailscale

# Do seu laptop/tablet (qualquer lugar)
ssh developer@bytelair-dev
```

### 2. Time Distribuído

Cada dev com seu workspace, acessível apenas pela rede privada Tailscale:

```bash
# Dev 1
bytelair up --name alice-dev --tailscale

# Dev 2
bytelair up --name bob-dev --tailscale

# Todos na mesma rede privada Tailscale!
```

### 3. Demonstrações e Pair Programming

Compartilhe acesso temporário ao workspace:

```bash
# Crie workspace com Ephemeral key
bytelair up --name demo --tailscale

# Compartilhe IP Tailscale com colega
bytelair tailscale status demo
```

### 4. CI/CD Runners

Runners acessíveis de qualquer lugar, sem expor portas:

```bash
bytelair up --name runner-1 --template devops --tailscale
```

## 🔒 Segurança

### Vantagens do Tailscale

- ✅ **Zero Trust Network**: Criptografia ponto-a-ponto
- ✅ **Sem Portas Abertas**: Não precisa expor SSH publicamente
- ✅ **ACLs Granulares**: Controle quem acessa o quê
- ✅ **MagicDNS**: Use hostnames ao invés de IPs
- ✅ **Audit Log**: Veja quem acessou quando

### Boas Práticas

1. **Use Ephemeral Keys** para workspaces temporários
2. **Configure ACLs** no Tailscale Admin para restringir acesso
3. **Monitore Connections** via `bytelair tailscale status`
4. **Revogue Keys** antigas periodicamente
5. **Use Tags** para organizar devices

## 🆚 Com vs Sem Tailscale

| Recurso | Sem Tailscale | Com Tailscale |
|---------|---------------|---------------|
| **Acesso local** | ✅ ssh -p 2222 localhost | ✅ ssh developer@100.x.y.z |
| **Acesso remoto** | ❌ Precisa port forwarding | ✅ De qualquer lugar |
| **Segurança** | ⚠️  Porta exposta | ✅ Criptografia E2E |
| **Setup** | 1 comando | 2 comandos |
| **IP Fixo** | ❌ Muda por rede | ✅ IP estável |
| **Firewall** | ⚠️  Precisa configurar | ✅ Funciona sempre |

## ❓ FAQ

### O Tailscale é obrigatório?

Não! É completamente opcional. Workspaces funcionam normalmente sem Tailscale via SSH local.

### Preciso pagar pelo Tailscale?

O plano Free suporta:
- ✅ 1 usuário
- ✅ 100 devices
- ✅ Todos os recursos principais

Perfeito para uso pessoal!

### Posso usar outra VPN?

Tecnicamente sim, mas Tailscale está integrado nativamente. Para outras VPNs, você precisará configurar manualmente dentro do container.

### E se eu mudar de rede?

Tailscale funciona em qualquer rede (WiFi, 4G, VPN corporativa). Seu workspace mantém o mesmo IP Tailscale.

### Como remover Tailscale de um workspace?

Workspaces sem `--tailscale` não iniciam o Tailscale. Para remover de um existente:

```bash
bytelair down meu-projeto --remove
bytelair up --name meu-projeto  # sem --tailscale
```

## 🔗 Links Úteis

- [Tailscale Docs](https://tailscale.com/kb/)
- [Auth Keys](https://login.tailscale.com/admin/settings/keys)
- [ACLs](https://tailscale.com/kb/1018/acls/)
- [MagicDNS](https://tailscale.com/kb/1081/magicdns/)

---

**💡 Dica:** Combine Tailscale com `bytelair template` para criar workspaces especializados acessíveis remotamente com um comando!

```bash
bytelair up --template ml --tailscale --name ia-experiments
```

Agora você tem um ambiente Machine Learning acessível de qualquer lugar! 🚀
