# API Endpoints

## Rules

### List rules

```
GET /v1/rules
```

```bash
curl -H "X-API-Key: ef_key_admin" http://localhost:8080/v1/rules
```

```json
{
  "data": [
    {
      "id": "r_001",
      "type": "transform",
      "name": "uppercase_user",
      "config": {
        "script": "function transform(e) { e.data.user = e.data.user.toUpperCase(); return e; }"
      },
      "created_at": "2026-06-01T10:00:00Z",
      "updated_at": "2026-06-01T10:00:00Z"
    }
  ],
  "next_cursor": null,
  "total": 1
}
```

### Create a rule

```
POST /v1/rules
```

```bash
curl -X POST http://localhost:8080/v1/rules \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ef_key_admin" \
  -d '{
    "type": "transform",
    "name": "add_source_tag",
    "config": {
      "key": "data.source",
      "value": "eventflow"
    }
  }'
```

```json
{
  "id": "r_002",
  "type": "transform",
  "name": "add_source_tag",
  "config": {
    "key": "data.source",
    "value": "eventflow"
  },
  "created_at": "2026-06-13T12:00:00Z",
  "updated_at": "2026-06-13T12:00:00Z"
}
```

### Delete a rule

```
DELETE /v1/rules/{id}
```

```bash
curl -X DELETE http://localhost:8080/v1/rules/r_001 \
  -H "X-API-Key: ef_key_admin"
```

```json
{
  "status": "deleted",
  "id": "r_001"
}
```

## Events

### Tail recent events

```
GET /v1/events
```

Query parameters:

| Param | Default | Description |
|---|---|---|
| `type` | all | Filter by event type |
| `status` | all | `accepted`, `failed` |
| `since` | 5m ago | RFC 3339 timestamp |
| `limit` | `20` | Max results |

```bash
curl "http://localhost:8080/v1/events?type=order.*&since=2026-06-13T11:00:00Z&limit=5" \
  -H "X-API-Key: ef_key_admin"
```

```json
{
  "data": [
    {
      "id": "evt-001",
      "type": "order.created",
      "timestamp": "2026-06-13T11:30:00Z",
      "status": "accepted",
      "sink": "kafka"
    }
  ]
}
```

## Validate

### Validate an event without ingestion

```
POST /v1/validate
```

```bash
curl -X POST http://localhost:8080/v1/validate \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ef_key_admin" \
  -d '{
    "id": "evt-test-001",
    "type": "page_view",
    "timestamp": "2026-06-13T12:00:00Z",
    "data": {"page": "/home"}
  }'
```

```json
{
  "valid": true,
  "warnings": []
}
```

If validation fails:

```json
{
  "valid": false,
  "errors": [
    {
      "code": "INVALID_EVENT_SCHEMA",
      "message": "field 'id' is required"
    }
  ]
}
```

## Schemas

See the [Schema Registry](../reference/schema-registry.md) reference for schema management endpoints.
