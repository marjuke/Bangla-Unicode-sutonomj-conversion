# Docker Deployment Guide for Unicode Bijoy API

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

The API will be available at http://localhost:8000

---

## Windows Containers Deployment

If you're running on Windows and need to use Windows containers instead of Linux containers:

### Prerequisites

1. **Enable Hyper-V** (run PowerShell as Administrator):
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

2. **Switch Docker Desktop to Windows Containers**:
   - Right-click Docker Desktop icon in system tray
   - Select "Switch to Windows containers..."
   - Or run: `& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon`

### Using Docker Compose for Windows

```powershell
# Build and start the Windows container
docker-compose -f docker-compose.windows.yml up -d

# View logs
docker-compose -f docker-compose.windows.yml logs -f

# Stop the container
docker-compose -f docker-compose.windows.yml down

# Rebuild after changes
docker-compose -f docker-compose.windows.yml up -d --build
```

### Using Docker CLI for Windows

```powershell
# Build the Windows image
docker build -f Dockerfile.windows -t unicode-bijoy-api:windows .

# Run the Windows container
docker run -d --name unicode-bijoy-api -p 8000:8000 unicode-bijoy-api:windows

# View logs
docker logs -f unicode-bijoy-api

# Stop and remove
docker stop unicode-bijoy-api
docker rm unicode-bijoy-api
```

### Windows Container Troubleshooting

1. **"no matching manifest for windows" error**:
   - Make sure Docker Desktop is switched to Windows containers mode
   - Use the Windows-specific compose file: `docker-compose.windows.yml`

2. **Docker Desktop not connecting**:
   - Start Docker Desktop: `Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"`
   - Wait for Docker to fully initialize (whale icon stops animating)

3. **Access container shell (Windows)**:
```powershell
docker exec -it unicode-bijoy-api powershell
```

---

## Using Docker CLI

### Build the image

```bash
docker build -t unicode-bijoy-api .
```

### Run the container

```bash
docker run -d \
  --name unicode-bijoy-api \
  -p 8000:8000 \
  --restart unless-stopped \
  unicode-bijoy-api
```

### View logs

```bash
docker logs -f unicode-bijoy-api
```

### Stop and remove

```bash
docker stop unicode-bijoy-api
docker rm unicode-bijoy-api
```

---

## Production Deployment

### With Nginx Reverse Proxy

1. **Run the API container:**

```bash
docker-compose up -d
```

2. **Configure Nginx:**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### With SSL (Let's Encrypt)

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d your-domain.com
```

---

## Environment Variables

You can customize the deployment by setting environment variables:

```bash
docker run -d \
  --name unicode-bijoy-api \
  -p 8000:8000 \
  -e ENVIRONMENT=production \
  unicode-bijoy-api
```

Or in docker-compose.yml:

```yaml
environment:
  - ENVIRONMENT=production
  - LOG_LEVEL=info
```

---

## Health Check

The container includes a health check that verifies the API is responding:

```bash
# Check container health status
docker ps

# Manual health check
curl http://localhost:8000/health
```

---

## Scaling with Docker Swarm

### Initialize swarm

```bash
docker swarm init
```

### Deploy as a service

```bash
docker service create \
  --name unicode-bijoy-api \
  --replicas 3 \
  --publish 8000:8000 \
  unicode-bijoy-api
```

### Scale the service

```bash
docker service scale unicode-bijoy-api=5
```

---

## Kubernetes Deployment

### Create deployment YAML (k8s-deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: unicode-bijoy-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: unicode-bijoy-api
  template:
    metadata:
      labels:
        app: unicode-bijoy-api
    spec:
      containers:
      - name: api
        image: unicode-bijoy-api:latest
        ports:
        - containerPort: 8000
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: unicode-bijoy-api-service
spec:
  selector:
    app: unicode-bijoy-api
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer
```

### Deploy to Kubernetes

```bash
kubectl apply -f k8s-deployment.yaml
```

---

## API Endpoints

Once deployed, test the API:

### Health check
```bash
curl http://localhost:8000/health
```

### Unicode to Bijoy
```bash
curl -X POST http://localhost:8000/unicode-to-bijoy \
  -H "Content-Type: application/json" \
  -d '{"text": "আপনার টেক্সট"}'
```

### Bijoy to Unicode
```bash
curl -X POST http://localhost:8000/bijoy-to-unicode \
  -H "Content-Type: application/json" \
  -d '{"text": "Avcbvi †U·U"}'
```

### API Documentation
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

---

## Troubleshooting

### View logs
```bash
docker logs unicode-bijoy-api
```

### Access container shell
```bash
docker exec -it unicode-bijoy-api /bin/bash
```

### Check health status
```bash
docker inspect --format='{{.State.Health.Status}}' unicode-bijoy-api
```

### Rebuild after changes
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## Performance Tuning

### Increase workers (in Dockerfile or run command)

```bash
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

### Limit container resources

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

---

## Security Best Practices

1. **Don't run as root** (add to Dockerfile):
```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

2. **Use specific Python version tag** (already done)

3. **Scan for vulnerabilities**:
```bash
docker scan unicode-bijoy-api
```

4. **Use secrets for sensitive data**:
```bash
docker secret create my_secret ./secret.txt
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Build Docker image
      run: docker build -t unicode-bijoy-api .
    
    - name: Push to registry
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker tag unicode-bijoy-api your-registry/unicode-bijoy-api:latest
        docker push your-registry/unicode-bijoy-api:latest
```

---

## Maintenance

### Update the container

```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose up -d --build
```

### Backup (if needed)

```bash
docker commit unicode-bijoy-api unicode-bijoy-api-backup
```

### Clean up old images

```bash
docker image prune -a
```
