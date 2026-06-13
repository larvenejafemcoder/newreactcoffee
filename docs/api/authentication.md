# Authentication

EventFlow uses API keys to authenticate both ingestion and management API requests. Keys are scoped to specific permissions.

## Generating an API key

Use the CLI to generate a new key:

```bash
eventflow keys create --name "production-ingest" --scope ingest
```

Output:

```
Key ID:     key_abc123def456
API Key:    ef_key_abc123def456ghi789jkl012
Scope:      ingest
Created:    2026-06-13T10:00:00Z
```

> **Warning:** The full API key is shown only once at creation. Store it securely in a password manager or secrets vault.

## Using an API key

Include the key in the `X-API-Key` header:

```bash
curl -X POST http://localhost:8080/v1/events \
  -H "X-API-Key: ef_key_abc123def456ghi789jkl012" \
  -H "Content-Type: application/json" \
  -d '{"id":"evt-001","type":"test","timestamp":"2026-06-13T12:00:00Z","data":{}}'
```

Alternatively, use a Bearer token:

```bash
curl -H "Authorization: Bearer ef_key_abc123def456ghi789jkl012" ...
```

## Key scopes

| Scope | Access |
|---|---|
| `ingest` | Send events to the ingestion API |
| `admin` | Full access to management API (rules, schemas, keys) |
| `metrics` | Read-only access to `/metrics` and health endpoints |

A single key can have multiple scopes:

```bash
eventflow keys create --name "dev-admin" --scope ingest,admin
```

## Listing keys

```bash
eventflow keys list
```

Output:

```
ID                  NAME                SCOPE           CREATED
key_abc123def456    production-ingest   ingest          2026-06-13T10:00:00Z
key_def456ghi789    dev-admin           ingest,admin    2026-06-12T08:00:00Z
```

## Revoking a key

```bash
eventflow keys revoke key_abc123def456
```

Revoked keys are rejected immediately. You cannot un-revoke a key; generate a new one.

## Rotating keys

1. Create a new key with the same scope.
2. Update your applications to use the new key.
3. Verify all traffic is using the new key (monitor `eventflow_ingested_total` metrics).
4. Revoke the old key.

## Storage

API keys are hashed using bcrypt before storage. EventFlow never stores raw keys. If you lose a key, revoke it and create a new one.

## Authentication errors

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "invalid or missing API key",
    "details": {
      "reason": "key not found"
    }
  }
}
```

HTTP status: `401 Unauthorized`.
