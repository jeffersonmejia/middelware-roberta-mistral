# SCADA LLM Security Middleware

Middleware de seguridad académico para requests y respuestas de modelos de lenguaje en contextos SCADA y redes eléctricas. Intercepta, clasifica, valida y audita cada interacción entre clientes y LLMs.

## Tabla de Contenidos

1. [Resumen](#1-resumen)
2. [Microservicios](#2-microservicios)
3. [Desarrollo Local](#3-desarrollo-local)
4. [Testing](#4-testing)
5. [Docs](#5-docs)

---

## 1. Resumen

El middleware se ubica en una red privada `10.x.x.x` entre el cliente web/API, un clasificador RoBERTa y una API Mistral. Cada request pasa por:

1. Clasificación del prompt (RoBERTa)
2. Validación de reglas de entrada
3. Generación de respuesta (Mistral)
4. Validación de reglas de salida
5. Auditoría completa del evento

---

## 2. Microservicios

### Mistral API

Repositorio: [andylaglaguano9-max/Proyecto_Lagla](https://github.com/andylaglaguano9-max/Proyecto_Lagla.git)

Endpoint de conexión: `MISTRAL_URL` + `MISTRAL_ENDPOINT`. Envía el prompt autorizado y recibe la respuesta generada.

### RoBERTa API

*Pendiente — repositorio por definir.*

Endpoint de conexión: `ROBERTA_URL` + `ROBERTA_ENDPOINT`. Clasifica el prompt como `malicious`, `suspicious` o `safe`.

Para request/response contracts ver [REQUIREMENTS.md](docs/REQUIREMENTS.md).

---

## 3. Desarrollo Local

```powershell
.\scripts\run.ps1
```

Menú:

```text
1. Start
2. Stop
```

Middleware en `http://127.0.0.1:8000`.

---

## 4. Testing

```powershell
pytest
```

---

## 5. Docs

| Archivo | Contenido |
|---|---|
| [API.md](docs/API.md) | Endpoints, request/response, códigos de error |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Componentes del middleware y flujo de datos |
| [MODEL.md](docs/MODEL.md) | Uso esperado y limitaciones del clasificador |
| [REQUIREMENTS.md](docs/REQUIREMENTS.md) | Contratos de integración con Mistral y RoBERTa |
| [SECURITY.md](SECURITY.md) | Reporte de vulnerabilidades y secretos |
