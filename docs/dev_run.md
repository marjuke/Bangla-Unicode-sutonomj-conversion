# Development Run Guide

This guide shows how to run the project locally for development.

## Prerequisites

- Python 3.14.4
- `pip`
- Git (optional, for cloning)

## 1) Open the project

```bash
cd Bangla-Unicode-sutonomj-conversion
```

## 2) Create and activate virtual environment

### Windows (PowerShell)
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

If activation is blocked:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

### Linux/macOS (bash)
```bash
python3 -m venv .venv
source .venv/bin/activate
```

## 3) Install dependencies

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## 4) Run the API server

```bash
python -m uvicorn app.api:app --host 127.0.0.1 --port 8000 --reload
```

## 5) Verify it is running

### Health check
```bash
curl http://127.0.0.1:8000/health
```

Expected response:
```json
{"text":"ok"}
```

### API docs
- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`

## 6) Test conversion endpoints

### Unicode -> Bijoy
```bash
curl -X POST "http://127.0.0.1:8000/unicode-to-bijoy" \
  -H "Content-Type: application/json" \
  -d '{"text":"বাংলা"}'
```

### Bijoy -> Unicode
```bash
curl -X POST "http://127.0.0.1:8000/bijoy-to-unicode" \
  -H "Content-Type: application/json" \
  -d '{"text":"evsjv"}'
```

## 7) Stop the server

Press `Ctrl + C` in the terminal running Uvicorn.

## Troubleshooting

- `ModuleNotFoundError`: activate `.venv` and reinstall requirements.
- Port `8000` already in use: run with a different port, e.g. `--port 8001`.
- `uvicorn` not found: use `python -m uvicorn ...` instead of plain `uvicorn`.
- Wrong app import path: use `app.api:app` (not `api:app`).

