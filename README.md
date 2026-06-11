# SCADA LLM Security Middleware

## Table of Contents

1. [Overview](#1-overview)
2. [Installation](#2-installation)
3. [Docs](#3-docs)

---

## 1. Overview

Middleware de seguridad académico para requests y respuestas de modelos de lenguaje en contextos SCADA y redes eléctricas. Intercepta, clasifica, valida y audita cada interacción entre clientes y LLMs.

---

## 2. Installation

```powershell
git clone <repo-url>
cd backend-llm
pip install -r requirements.txt
cp .env.example .env
.\scripts\run.ps1
```

---

## 3. Docs

| File | Content |
|---|---|
| [API.md](docs/API.md) | Endpoints, request/response, error codes |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Middleware components and data flow |
| [MODEL.md](docs/MODEL.md) | Classifier usage and limitations |
| [REQUIREMENTS.md](docs/REQUIREMENTS.md) | Integration contracts, microservices, env vars |
| [SECURITY.md](SECURITY.md) | Vulnerability reporting and secrets |
