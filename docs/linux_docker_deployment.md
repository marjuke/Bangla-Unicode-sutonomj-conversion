# Linux Docker Deployment (Ubuntu)

This guide is for deploying the API on Ubuntu using Docker and Docker Compose.

## 1) Install Docker on Ubuntu

### Step 1: Update system
```bash
sudo apt update
sudo apt upgrade -y
```

### Step 2: Install required packages
```bash
sudo apt install -y ca-certificates curl gnupg
```

### Step 3: Add Docker GPG key
```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

### Step 4: Add Docker repository
```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 5: Install Docker Engine + Compose plugin
```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 6: Start and enable Docker
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Step 7: Verify installation
```bash
docker --version
docker compose version
```


## 2) Get the project on the server

### Step 1: Generate an SSH key (on server)
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Press Enter to keep the default file path (`~/.ssh/id_ed25519`).

### Step 2: Start ssh-agent and add the key
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Step 3: Copy public key and add it to GitHub
```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the output, then go to GitHub:
- `Settings` -> `SSH and GPG keys` -> `New SSH key`
- Paste the key and save.

### Step 4: Test GitHub SSH access
```bash
ssh -T git@github.com
```

If prompted with host authenticity, type `yes`.

### Step 5: Clone with SSH

```bash
git clone git@github.com:marjuke/Bangla-Unicode-sutonomj-conversion.git
cd Bangla-Unicode-sutonomj-conversion
```

If the code is already copied to the server, just `cd` into the project root where `docker-compose.yml` and `Dockerfile` exist.

## 3) Build and run with Docker Compose

From the project root:
```bash
docker compose up -d --build
```

This uses:
- `docker-compose.yml` service: `a2u-converter`
- `Dockerfile` command: `uvicorn app.api:app --host 0.0.0.0 --port 8000`

## 4) Verify the API is running

```bash
docker compose ps
curl http://127.0.0.1:8000/health
```

Expected response:
```json
{"text":"ok"}
```

## 5) Useful operations

### View logs
```bash
docker compose logs -f
```

### Restart service
```bash
docker compose restart
```

### Stop service
```bash
docker compose down
```

## 6) Update and redeploy

```bash
cd Bangla-Unicode-sutonomj-conversion
git pull
sudo docker compose up -d --build
```

## 7) Troubleshooting

### Port 8000 already in use
```bash
sudo ss -ltnp | grep :8000
```

Then stop the conflicting process, or change host port mapping in `docker-compose.yml`.

### Container exits immediately
```bash
docker compose logs --tail=100
```

### Health check fails
- Ensure container is running: `docker compose ps`
- Check logs: `docker compose logs -f`
- Test inside server: `curl http://127.0.0.1:8000/health`

## 8) Production note

For internet exposure, place Nginx/Caddy in front of this service for TLS (HTTPS), rate limiting, and domain routing.

