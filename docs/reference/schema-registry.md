# Schema Registry

The schema registry manages JSON Schemas used to validate incoming events. Each event type can have an associated schema.

## Managing schemas via API

### List schemas

```
GET /v1/schemas
```

```bash
curl -H "X-API-Key: ef_key_admin" http://localhost:8080/v1/schemas
```

```json
{
  "data": [
    {
      "id": "page_view.v1",
      "version": 1,
      "event_type": "page_view",
      "created_at": "2026-06-01T10:00:00Z",
      "compatible": true
    }
  ]
}
```

### Get a schema

```
GET /v1/schemas/{id}
```

```bash
curl -H "X-API-Key: ef_key_admin" http://localhost:8080/v1/schemas/page_view.v1
```

### Create a schema

```
POST /v1/schemas
```

```bash
curl -X POST http://localhost:8080/v1/schemas \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ef_key_admin" \
  -d '{
    "id": "order.created.v1",
    "event_type": "order.created",
    "schema": {
      "type": "object",
      "required": ["id", "type", "timestamp", "data"],
      "properties": {
        "id": {"type": "string", "format": "uuid"},
        "type": {"type": "string"},
        "timestamp": {"type": "string", "format": "date-time"},
        "data": {
          "type": "object",
          "required": ["order_id", "total"],
          "properties": {
            "order_id": {"type": "string"},
            "total": {"type": "number", "minimum": 0}
          }
        }
      }
    }
  }'
```

```json
{
  "id": "order.created.v1",
  "version": 1,
  "event_type": "order.created",
  "created_at": "2026-06-13T12:00:00Z",
  "compatible": true
}
```

### Delete a schema

```
DELETE /v1/schemas/{id}
```

```bash
curl -X DELETE http://localhost:8080/v1/schemas/obsolete.v1 \
  -H "X-API-Key: ef_key_admin"
```

## Schema versioning

Schemas are versioned. When you update a schema, the version increments automatically:

```
POST /v1/schemas/order.created.v1
```

The response includes the new version number and a compatibility check result.

### Backward compatibility

EventFlow checks backward compatibility when a new schema version is registered. Rules:

- **New fields** must be optional (not in `required`).
- **Existing fields** cannot change type.
- **Removing fields** is not allowed.

If the new schema is incompatible, the API returns:

```json
{
  "error": {
    "code": "INCOMPATIBLE_SCHEMA",
    "message": "new schema version is not backward compatible",
    "details": {
      "version": 2,
      "errors": [
        "field 'data.total' changed type from number to string",
        "field 'data.order_id' was removed"
      ]
    }
  }
}
```

## CLI: pushing a schema

```bash
eventflow schema push --file order-schema.json --id order.created.v1
```

The command reads a JSON Schema file, registers it, and prints the result.

```bash
eventflow schema push --id order.created.v1 --file order-schema.json
Schema 'order.created.v1' registered (version 2, compatible: true)
```

## Schema enforcement

When an event is ingested, EventFlow looks up the schema by event `type`. If a schema is found, the event must conform to it. If no schema is registered for that type, the event is accepted without schema validation (unless `require_schema` is enabled in config).

```yaml
ingestion:
  require_schema: true   # reject events with no registered schema
  schema_cache_ttl: 5m   # how long to cache schemas in memory
```

## Schema discovery

EventFlow exposes an OpenAPI extension at `/v1/schemas/openapi.json` that combines all registered schemas into a single OpenAPI document for use with code generators and API clients.
