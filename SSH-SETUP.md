# 🔐 SSH Configuration Guide

This project uses SSH public key authentication for secure workspace access. **Your SSH key will NEVER be committed to Git** thanks to `.gitignore`.

## 📋 Step by Step

### 1️⃣ Get your SSH public key

#### If you already have an SSH key:

```bash
cat ~/.ssh/id_rsa.pub
```

You'll see something like:
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... your@email.com
```

#### If you DON'T have an SSH key:

Create a new one:

```bash
ssh-keygen -t rsa -b 4096 -C "your@email.com"
```

Press Enter to accept the default location (`~/.ssh/id_rsa`).

You can add a passphrase or leave it blank (Enter).

Then run:
```bash
cat ~/.ssh/id_rsa.pub
```

### 2️⃣ Configure the .env file

#### Option A: Manual configuration

1. Copy the example file:
   ```bash
   cp env.example .env
   ```

2. Edit the `.env` file:
   ```bash
   nano .env
   # or use: vim .env
   # or use: code .env
   ```

3. Replace `your-ssh-public-key-here` with the output from `cat ~/.ssh/id_rsa.pub`:
   
   ```env
   SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... your@email.com"
   ```

4. Save and close the file.

#### Option B: Automatic configuration

```bash
cp env.example .env
echo "SSH_PUBLIC_KEY=\"$(cat ~/.ssh/id_rsa.pub)\"" > .env
```

### 3️⃣ Verify configuration

```bash
cat .env
```

You should see something like:
```env
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFPfOGncsBlZ... your@email.com"
```

### 4️⃣ Start the workspace

```bash
docker-compose -f docker-compose-env.yml up -d --build
```

### 5️⃣ Connect via SSH

```bash
ssh -p 2222 developer@localhost
```

Or configure the alias in `~/.ssh/config`:

```bash
cat >> ~/.ssh/config << 'EOF'

Host my-workspace
    HostName localhost
    Port 2222
    User developer
    IdentityFile ~/.ssh/id_rsa

EOF
```

And connect with:
```bash
ssh my-workspace
```

## 🔒 Security

### ✅ What's protected:

- ✅ The `.env` file is in `.gitignore` - **won't be committed**
- ✅ The `workspace-storage/` directory is in `.gitignore` - **your data won't go to GitHub**
- ✅ Authentication only via SSH key (no password)
- ✅ Root login disabled via SSH

### ⚠️ NEVER do:

- ❌ NEVER add `.env` to git (`git add .env`)
- ❌ NEVER remove `.env` from `.gitignore`
- ❌ NEVER commit your private SSH key (`id_rsa`) - only the public one (`id_rsa.pub`)
- ❌ NEVER share your private key (`~/.ssh/id_rsa`)

### Check if .env is being ignored:

```bash
git status
```

The `.env` file **should NOT appear** in untracked files.

If it appears:
```bash
git rm --cached .env  # Remove from index (if already added)
```

## 🆘 Troubleshooting

### ❌ Error: "Permission denied (publickey)"

**Cause:** Your SSH key was not configured in `.env`.

**Solution:**
1. Check the `.env` file:
   ```bash
   cat .env
   ```
2. Make sure it contains your complete public key
3. Rebuild the container:
   ```bash
   docker-compose -f docker-compose-env.yml up -d --build
   ```

### ❌ Error: SSH asks for password

**Cause:** The public key is not in the container OR you're using the wrong key.

**Solution:**
1. Check which key SSH is using:
   ```bash
   ssh -vvv -p 2222 developer@localhost
   ```
2. Use the correct key:
   ```bash
   ssh -i ~/.ssh/id_rsa -p 2222 developer@localhost
   ```

### ❌ .env appears in git status

**Solution:**
```bash
# Check if it's in .gitignore
grep ".env" .gitignore

# If not, add it:
echo ".env" >> .gitignore

# Remove from git if already added:
git rm --cached .env
```

## 📚 More Information

- [README.md](README.md) - Complete project documentation
- [ACCESS-WORKSPACE.md](ACCESS-WORKSPACE.md) - Detailed access guide
- [SSH Key Authentication](https://www.ssh.com/academy/ssh/public-key-authentication)

## 🤔 Frequently Asked Questions

### What's the difference between public and private keys?

- **Private Key** (`id_rsa`): Stays on YOUR computer. NEVER share!
- **Public Key** (`id_rsa.pub`): Can be shared. This is what goes in `.env`

### Can I use the same SSH key for multiple workspaces?

Yes! The same public key can be used in multiple places.

### What happens if I lose my private key?

You won't be able to access the workspace via SSH anymore. You'll need to:
1. Generate a new SSH key
2. Update `.env` with the new public key
3. Rebuild the container

### Where is my data stored?

Your data is in `workspace-storage/` which:
- ✅ Is in `.gitignore` (won't go to GitHub)
- ✅ Is persistent (not lost when recreating the container)
- ⚠️ Backup regularly!

---

**🔐 Security first!** Always check if your sensitive files are in `.gitignore` before committing.
