# Requisitos de integración — API Mistral

## Tabla de contenidos

- [1. Microservicios](#1-microservicios)
- [2. Configuración](#2-configuración)
- [3. Endpoints](#3-endpoints)
  - [3.1 Health check](#31-health-check)
  - [3.2 Generación de chat](#32-generación-de-chat)
- [4. Formato de respuestas](#4-formato-de-respuestas)
- [5. Códigos de error](#5-códigos-de-error)
- [6. Flujo de llamada](#6-flujo-de-llamada)
- [7. Variables de entorno](#7-variables-de-entorno)

---

## 1. Microservicios

Servicios externos a los que el middleware se conecta vía API. Cada uno es un proyecto independiente con su propia documentación.

### Mistral API

Repositorio: [andylaglaguano9-max/Proyecto_Lagla](https://github.com/andylaglaguano9-max/Proyecto_Lagla.git)

### RoBERTa API

*Pendiente — repositorio por definir.*

---

## 2. Configuración

| Variable | Valor por defecto | Descripción |
|---|---|---|
| `MISTRAL_URL` | `http://127.0.0.1:8002` | URL base del servicio Mistral |
| `MISTRAL_ENDPOINT` | `/chat` | Ruta del endpoint de generación |
| `REQUEST_TIMEOUT_SECONDS` | `30.0` | Timeout general para requests |

---

## 3. Endpoints

### 3.1 Health check

```
GET {MISTRAL_URL}/health
```

**Propósito:** Verificar que el servicio está vivo.

| Aspecto | Detalle |
|---|---|
| Método | `GET` |
| URL | `{MISTRAL_URL}/health` |
| Body request | No aplica |
| Código esperado | `200` |
| Validación | Solo importa el código HTTP, no el body |

**Ejemplo:**
```bash
curl -s -o /dev/null -w "%{http_code}" http://10.141.2.135:8000/health
# → 200
```

---

### 3.2 Generación de chat

```
POST {MISTRAL_URL}{MISTRAL_ENDPOINT}
```

**Propósito:** Procesar un prompt y devolver una respuesta generada por el LLM.

| Aspecto | Detalle |
|---|---|
| Método | `POST` |
| URL | `{MISTRAL_URL}/{MISTRAL_ENDPOINT}` (ej. `http://10.141.2.135:8000/chat`) |
| Content-Type | `application/json` |
| Código esperado | `200` |
| Timeout | Configurable vía `REQUEST_TIMEOUT_SECONDS` |

#### Request body

```json
{
  "prompt": "texto de entrada del usuario"
}
```

| Campo | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `prompt` | `string` | Sí | Prompt a procesar (1–12000 caracteres) |

#### Response body (200)

```json
{
  "response": "texto generado por el modelo"
}
```

O alternativamente:

```json
{
  "message": "texto generado por el modelo"
}
```

O:

```json
{
  "text": "texto generado por el modelo"
}
```

El campo exacto no importa: el cliente busca en orden `response` → `message` → `text` y usa el primero que encuentre.

---

## 4. Formato de respuestas

### 4.1 Éxito (200)

| Campo | Tipo | Prioridad | Descripción |
|---|---|---|---|
| `response` | `string` | 1ª opción | Respuesta generada |
| `message` | `string` | 2ª opción | Respuesta generada (fallback) |
| `text` | `string` | 3ª opción | Respuesta generada (fallback) |

### 4.2 Error (500+)

Si el servidor responde con código `>= 500`, el cliente lanza `ServiceUnavailableError` y la request se marca como fallida.

---

## 5. Códigos de error

| Rango | Comportamiento |
|---|---|
| `200` | Éxito — se procesa la respuesta |
| `400–499` | `HTTPError` genérico, se reporta como error |
| `500+` | `ServiceUnavailableError` — servicio no disponible |
| Sin conexión / timeout | `ServiceUnavailableError` — servicio no responde |

---

## 6. Flujo de llamada

```
Cliente (FastAPI)                    Servidor Mistral
       │                                    │
       ├── GET /health ─────────────────►   │
       │   ◄── 200 OK ──────────────────┤   │
       │                                    │
       ├── POST /chat {"prompt":"..."} ──►  │
       │   ◄── 200 {"response":"..."} ───┤  │
       │                                    │
```

1. Periódicamente se llama a `GET /health` para verificar disponibilidad.
2. Cuando el usuario envía un mensaje, el middleware primero lo clasifica (RoBERTa) y valida reglas.
3. Si el input no está bloqueado, se llama a `POST /chat` con el prompt original.
4. La respuesta del LLM se valida contra reglas de salida antes de devolverse al usuario.

---

## 7. Variables de entorno

Archivo `.env`:

```env
MISTRAL_URL=http://10.141.2.135:8000
MISTRAL_ENDPOINT=/chat
REQUEST_TIMEOUT_SECONDS=2500
```

| Variable | Descripción |
|---|---|
| `MISTRAL_URL` | URL base del servicio Mistral (sin trailing slash) |
| `MISTRAL_ENDPOINT` | Ruta del endpoint de generación |
| `REQUEST_TIMEOUT_SECONDS` | Timeout en segundos para requests HTTP |
