# API Overview

The EventFlow management API allows you to configure rules, schemas, and API keys programmatically.

## Base URL

| Environment | Base URL |
|---|---|
| Local | `http://localhost:8080` |
| Production | `https://api.eventflow.io/v1` |

## Authentication

All management API requests require authentication. See [Authentication](./authentication.md) for details.

### Methods

- **API Key** – pass `X-API-Key` header
- **Bearer Token** – pass `Authorization: Bearer <token>` header

## Rate limiting

Management API requests are rate limited per API key. Limits are communicated via response headers:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 98
X-RateLimit-Reset: 1623596400
```

## Versioning

The API is versioned via the URL path prefix (`/v1`). Backward-incompatible changes will result in a new version (e.g. `/v2`). Current version `1.2.0`.

## OpenAPI specification

A machine-readable OpenAPI 3.0 spec is available at:

```
GET /openapi.json
```

```bash
curl http://localhost:8080/openapi.json
```

## Common headers

| Header | Description |
|---|---|
| `Content-Type` | `application/json` (required) |
| `X-API-Key` | API key for authentication |
| `Authorization` | Bearer token alternative |
| `Idempotency-Key` | Idempotency key for write operations |
| `X-Request-Id` | Request ID for tracing (auto-generated if omitted) |

## Pagination

List endpoints support cursor-based pagination:

| Query param | Default | Description |
|---|---|---|
| `cursor` | first page | Opaque cursor from previous response |
| `limit` | `20` | Max items per page (max `100`) |

Paginated responses include:

```json
{
  "data": [...],
  "next_cursor": "eyJpZCI6IjEyMyJ9",
  "total": 150
}
```

## Content type

All requests and responses use `application/json`. Sending an unsupported content type returns `415 Unsupported Media Type`.
