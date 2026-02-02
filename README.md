# Unicode-Bijoy Converter API

A FastAPI-based REST API for converting Bengali text between **Unicode** and **Bijoy** encoding formats.

## Overview

This project provides a simple HTTP API to convert:
- **Unicode → Bijoy**: Convert standard Unicode Bengali text to Bijoy encoding
- **Bijoy → Unicode**: Convert Bijoy-encoded Bengali text to standard Unicode

[Bijoy](https://en.wikipedia.org/wiki/Bijoy_keyboard) is a popular keyboard layout and encoding system used for typing Bengali text, especially in Bangladesh.

## Features

- 🚀 Fast and lightweight API built with FastAPI
- 🔄 Bidirectional conversion (Unicode ↔ Bijoy)
- 🐳 Docker support (Linux & Windows containers)
- 🏥 Built-in health check endpoint
- 📦 Easy deployment options (Docker, IIS)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check endpoint |
| `POST` | `/unicode-to-bijoy` | Convert Unicode text to Bijoy |
| `POST` | `/bijoy-to-unicode` | Convert Bijoy text to Unicode |

### Request/Response Format

**Request Body:**
```json
{
  "text": "Your text here"
}
```

**Response Body:**
```json
{
  "text": "Converted text"
}
```

## Quick Start

### Prerequisites

- Python 3.12+
- pip

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/unicode-bijoy-converter.git
   cd unicode-bijoy-converter
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the server:**
   ```bash
   uvicorn api:app --host 0.0.0.0 --port 8000 --reload
   ```

4. **Access the API:**
   - API: http://localhost:8000
   - Interactive docs (Swagger UI): http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

### Using PowerShell Script (Windows)

```powershell
.\run.ps1
```

## Docker Deployment

### Linux Containers

```bash
# Build and run
docker-compose up -d

# Or build manually
docker build -t unicode-bijoy-api .
docker run -d -p 8000:8000 unicode-bijoy-api
```

### Windows Containers

```powershell
# Build and run with Windows containers
docker-compose -f docker-compose.windows.yml up -d
```

## IIS Deployment

For deploying on Windows IIS, see the detailed guide in [deploy/IIS-DEPLOYMENT.md](deploy/IIS-DEPLOYMENT.md).

```powershell
# Quick setup
.\deploy\setup-iis.ps1
```

## Usage Examples

### Convert Unicode to Bijoy

```bash
curl -X POST "http://localhost:8000/unicode-to-bijoy" \
  -H "Content-Type: application/json" \
  -d '{"text": "বাংলা"}'
```

### Convert Bijoy to Unicode

```bash
curl -X POST "http://localhost:8000/bijoy-to-unicode" \
  -H "Content-Type: application/json" \
  -d '{"text": "evsjv"}'
```

### Python Example

```python
import requests

# Unicode to Bijoy
response = requests.post(
    "http://localhost:8000/unicode-to-bijoy",
    json={"text": "বাংলা"}
)
print(response.json()["text"])

# Bijoy to Unicode
response = requests.post(
    "http://localhost:8000/bijoy-to-unicode",
    json={"text": "evsjv"}
)
print(response.json()["text"])
```

## Project Structure

```
├── api.py                  # FastAPI application and endpoints
├── converter.py            # Unicode to Bijoy conversion logic
├── bijoy_to_unicode.py     # Bijoy to Unicode conversion logic
├── util.py                 # Utility functions
├── requirements.txt        # Python dependencies
├── Dockerfile              # Linux container image
├── Dockerfile.windows      # Windows container image
├── docker-compose.yml      # Linux Docker Compose config
├── docker-compose.windows.yml  # Windows Docker Compose config
├── run.ps1                 # PowerShell run script
├── web.config              # IIS configuration
└── deploy/                 # Deployment documentation
    ├── DOCKER-DEPLOYMENT.md
    ├── IIS-DEPLOYMENT.md
    └── setup-iis.ps1
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- Built with [FastAPI](https://fastapi.tiangolo.com/)
- Inspired by the need for easy Bengali text encoding conversion
