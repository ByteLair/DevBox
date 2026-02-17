# 🚀 Guia de Publicação Docker Hub & GitHub Release

## 📖 O que é GitHub Release?

**GitHub Release** é uma forma oficial de distribuir versões do seu projeto:
- 📦 Arquivos para download
- 📝 Changelog detalhado
- 🏷️ Versionamento semântico
- 📄 Release notes profissionais

**Exemplo:** Quando você baixa um programa tipo VS Code, clica em "Releases" → baixa o instalador

---

## 🐳 Configurar Publicação no Docker Hub

### Passo 1: Criar conta no Docker Hub

1. Acesse: https://hub.docker.com/signup
2. Crie sua conta (pode usar GitHub para login)
3. Confirme o email

### Passo 2: Criar Access Token

1. Login no Docker Hub
2. Vá em: **Account Settings** → **Security** → **New Access Token**
3. Nome: `github-actions-devbox`
4. Permissões: **Read, Write, Delete**
5. **COPIE O TOKEN** (só aparece uma vez!)

### Passo 3: Configurar Secrets no GitHub

1. Vá em: https://github.com/ByteLair/DevBox/settings/secrets/actions
2. Clique em **"New repository secret"** duas vezes:

   **Secret 1:**
   ```
   Name: DOCKERHUB_USERNAME
   Value: bytelair  (seu username do Docker Hub)
   ```

   **Secret 2:**
   ```
   Name: DOCKERHUB_TOKEN
   Value: [cole o token que você copiou]
   ```

### Passo 4: Verificar nome da imagem

O workflow já está configurado para:
```
DOCKER_IMAGE: bytelair/devbox
```

Se seu username for diferente, edite `.github/workflows/docker-build.yml`

### Passo 5: Fazer commit e push

```bash
git add .github/workflows/docker-build.yml README.md README.pt-BR.md
git commit -m "ci: add Docker Hub auto-publish and badges"
git push origin main
```

### Passo 6: Acompanhar o build

1. Vá em: https://github.com/ByteLair/DevBox/actions
2. Veja o workflow "Docker Build & Publish" rodando
3. Após finalizar, confira em: https://hub.docker.com/r/bytelair/devbox

---

## 📦 Criar GitHub Release v1.0.0

### Método 1: Interface Web (Mais Fácil) ⭐

1. **Acesse:** https://github.com/ByteLair/DevBox/releases/new

2. **Preencha:**
   - **Choose a tag:** Selecione `v1.0.0` (já existe)
   - **Release title:** `DevBox v1.0.0 - First Stable Release`
   - **Describe this release:**

```markdown
## 🎉 DevBox v1.0.0 - First Stable Release

Self-hosted Docker development workspace, similar to GitHub Codespaces.

### ✨ Features

- ✅ Complete workspace isolation with Docker
- ✅ SSH access with VS Code Remote-SSH support  
- ✅ Network deployment support for teams
- ✅ Easy user management with `add-user.sh` script
- ✅ Auto IP display on setup
- ✅ Cross-platform SSH instructions (Windows/Mac/Linux)
- ✅ Organized bilingual documentation (English/Portuguese)
- ✅ Node.js 20 LTS and Python 3.10 pre-installed
- ✅ Resource limits (CPU/RAM) per container
- ✅ 50GB default storage per workspace

### 🚀 Quick Start

Clone and configure:
\`\`\`bash
git clone https://github.com/ByteLair/DevBox.git
cd DevBox
cp env.example .env
# Edit .env and add your SSH public key
\`\`\`

Start workspace:
\`\`\`bash
docker-compose -f docker-compose-env.yml up -d
ssh -p 2222 developer@localhost
\`\`\`

### 🐳 Docker Image

Pull directly from Docker Hub:
\`\`\`bash
docker pull bytelair/devbox:1.0.0
docker pull bytelair/devbox:latest
\`\`\`

### 📚 Documentation

- 🇺🇸 [English Documentation](https://github.com/ByteLair/DevBox/tree/main/docs/en)
- 🇧🇷 [Documentação em Português](https://github.com/ByteLair/DevBox/tree/main/docs/pt-BR)

### 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### 📄 License

MIT License - see [LICENSE](LICENSE) for details.
```

3. **Clique em "Publish release"** 🎉

### Método 2: GitHub CLI

```bash
# Instalar (se necessário)
sudo apt install gh

# Login
gh auth login

# Criar release
gh release create v1.0.0 \
  --title "DevBox v1.0.0 - First Stable Release" \
  --notes "🎉 First stable release with complete workspace isolation, SSH access, and team deployment support."
```

---

## 🎨 Adicionar Mais Badges (Após Publicar)

Após publicar no Docker Hub, adicione estes badges aos READMEs:

```markdown
[![Docker Pulls](https://img.shields.io/docker/pulls/bytelair/devbox.svg)](https://hub.docker.com/r/bytelair/devbox)
[![Docker Image Size](https://img.shields.io/docker/image-size/bytelair/devbox/latest.svg)](https://hub.docker.com/r/bytelair/devbox)
[![Build Status](https://github.com/ByteLair/DevBox/workflows/Docker%20Build%20%26%20Publish/badge.svg)](https://github.com/ByteLair/DevBox/actions)
```

---

## ✅ Checklist de Publicação

### Docker Hub
- [ ] Conta criada no Docker Hub
- [ ] Access Token gerado
- [ ] Secrets configurados no GitHub (DOCKERHUB_USERNAME e DOCKERHUB_TOKEN)
- [ ] Workflow commitado
- [ ] Push feito para `main`
- [ ] Actions executou com sucesso
- [ ] Imagem apareceu no Docker Hub

### GitHub Release
- [ ] Tag v1.0.0 criada e pushed
- [ ] Release criado com changelog
- [ ] Release notes bem formatado
- [ ] Links de documentação funcionando

### Finalização
- [ ] Badges adicionados aos READMEs
- [ ] Documentação revisada
- [ ] Tudo commitado e pushed

---

## 🆘 Troubleshooting

### ❌ "unauthorized: incorrect username or password"
**Solução:** Verifique os secrets no GitHub. Use o **Access Token**, não a senha.

### ❌ Workflow não executou
**Solução:** 
1. Settings → Actions → General
2. "Actions permissions" → "Allow all actions"

### ❌ Build falhou
**Solução:** Veja os logs em Actions tab e verifique o Dockerfile

### ❌ Tag já existe no Docker Hub
**Solução:** Para republicar a mesma versão:
```bash
# Deletar a tag localmente e remotamente
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# Recriar
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

---

## 🎯 Próximos Passos

Após publicar v1.0.0:

1. **Compartilhar:**
   - Reddit: r/docker, r/selfhosted
   - Dev.to: Criar artigo de lançamento
   - Twitter/LinkedIn

2. **Melhorias futuras:**
   - Multi-arch build (ARM64 para Raspberry Pi)
   - Docker Compose profiles
   - Health checks
   - Monitoring dashboard

**Seu projeto agora está pronto para o mundo! 🚀**
