# Error Codes

All API errors follow a standard envelope format.

## Error envelope

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "human-readable description",
    "details": {}
  }
}
```

## HTTP status codes

| Status | Meaning |
|---|---|
| `400 Bad Request` | Malformed request body or missing required fields |
| `401 Unauthorized` | Missing or invalid authentication |
| `403 Forbidden` | Authenticated but insufficient scope |
| `404 Not Found` | Requested resource does not exist |
| `409 Conflict` | Resource conflict (e.g. duplicate rule name) |
| `422 Unprocessable Entity` | Validation failure |
| `429 Too Many Requests` | Rate limit exceeded |
| `500 Internal Server Error` | Unexpected server error |
| `503 Service Unavailable` | Server temporarily unable to handle request |

## Error code reference

### `INVALID_EVENT_SCHEMA`

Returned when an event payload fails JSON Schema validation.

```json
{
  "error": {
    "code": "INVALID_EVENT_SCHEMA",
    "message": "event failed schema validation",
    "details": {
      "schema_id": "event.v1",
      "errors": [
        {"field": "id", "reason": "required field missing"},
        {"field": "data", "reason": "must be an object"}
      ]
    }
  }
}
```

**Action:** Fix the event payload to conform to the schema.

### `RATE_LIMIT_EXCEEDED`

Returned when an API key has exceeded its rate limit.

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "rate limit of 1000 requests per minute exceeded",
    "details": {
      "retry_after": 42,
      "limit": 1000,
      "remaining": 0,
      "reset_at": "2026-06-13T12:01:00Z"
    }
  }
}
```

**Action:** Retry after the specified `retry_after` seconds, or reduce request volume.

### `SINK_UNAVAILABLE`

Returned during event ingestion when the configured sink is unreachable.

```json
{
  "error": {
    "code": "SINK_UNAVAILABLE",
    "message": "sink 'kafka-prod' is unreachable",
    "details": {
      "sink_name": "kafka-prod",
      "sink_type": "kafka",
      "underlying_error": "dial tcp kafka-1:9092: connection refused"
    }
  }
}
```

**Action:** Check the sink's health and connectivity. The event is queued for retry.

### `TRANSFORM_ERROR`

Returned when a transform script fails to execute.

```json
{
  "error": {
    "code": "TRANSFORM_ERROR",
    "message": "transform 'enrich_user' execution failed",
    "details": {
      "transform_name": "enrich_user",
      "transform_type": "js_script",
      "error": "ReferenceError: foo is not defined"
    }
  }
}
```

**Action:** Review the transform script for bugs. Test with `eventflow transform test`.

### `UNAUTHORIZED`

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "invalid or missing API key"
  }
}
```

**Action:** Provide a valid API key via `X-API-Key` or `Authorization` header.

### `FORBIDDEN`

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "insufficient scope",
    "details": {
      "required_scope": "admin",
      "key_scope": "ingest"
    }
  }
}
```

**Action:** Use an API key with the required scope.

### `NOT_FOUND`

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "rule 'r_999' not found"
  }
}
```

**Action:** Check the resource ID.

### `CONFLICT`

```json
{
  "error": {
    "code": "CONFLICT",
    "message": "a rule with name 'uppercase_user' already exists"
  }
}
```

**Action:** Use a different name, or update the existing rule.

## Retry strategy

- **4xx errors** (except `429`): do not retry – fix the request.
- **429**: retry after the `retry_after` duration.
- **5xx errors**: retry with exponential backoff (1s, 2s, 4s, 8s, max 30s).
