# Sending events

Events are sent to EventFlow via the HTTP ingestion API. Each event must conform to the expected schema and be accompanied by a valid API key.

## Endpoint

```
POST /v1/events
```

### Required headers

| Header | Value | Description |
|---|---|---|
| `Content-Type` | `application/json` | Must be set |
| `X-API-Key` | `<your-api-key>` | Authentication |

### Event schema

```json
{
  "id": "uuid",
  "type": "string",
  "timestamp": "RFC3339",
  "data": {}
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Unique event identifier (UUID v4 recommended) |
| `type` | string | yes | Event type used for routing and filtering |
| `timestamp` | string | yes | RFC 3339 timestamp (e.g. `2026-06-13T12:00:00Z`) |
| `data` | object | yes | Arbitrary JSON payload |

### Example request

```bash
curl -X POST http://localhost:8080/v1/events \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ef_key_abc123" \
  -d '{
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "type": "order.created",
    "timestamp": "2026-06-13T12:34:56Z",
    "data": {
      "order_id": "ORD-9876",
      "customer": "alice@example.com",
      "total": 49.99
    }
  }'
```

### Success response

```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "accepted"
}
```

## Batch ingestion

Send multiple events in a single request:

```
POST /v1/events/batch
```

```bash
curl -X POST http://localhost:8080/v1/events/batch \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ef_key_abc123" \
  -d '{
    "events": [
      {
        "id": "evt-001",
        "type": "page_view",
        "timestamp": "2026-06-13T12:00:00Z",
        "data": {"page": "/home"}
      },
      {
        "id": "evt-002",
        "type": "click",
        "timestamp": "2026-06-13T12:00:01Z",
        "data": {"element": "signup-btn"}
      }
    ]
  }'
```

### Batch response

```json
{
  "accepted": 2,
  "failed": 0,
  "errors": []
}
```

## Idempotency

The `Idempotency-Key` header ensures that resending the same event does not create duplicates. EventFlow deduplicates based on the key value within a 24-hour window.

```bash
curl -X POST http://localhost:8080/v1/events \
  -H "Content-Type: application/json" \
  -H "X-API-Key: ef_key_abc123" \
  -H "Idempotency-Key: unique-req-001" \
  -d '{"id":"evt-003","type":"payment","timestamp":"2026-06-13T12:00:00Z","data":{"amount":19.99}}'
```

## Rate limiting

Each API key is rate limited. The default is 1,000 requests per minute. Rate limit information is returned in response headers:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1623596400
```

When exceeded, the API returns `429 Too Many Requests`:

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "rate limit of 1000 requests per minute exceeded",
    "details": {
      "retry_after": 42
    }
  }
}
```

## Error responses

| Status | Code | Meaning |
|---|---|---|
| 400 | `INVALID_EVENT_SCHEMA` | Event payload failed validation |
| 401 | `UNAUTHORIZED` | Missing or invalid API key |
| 413 | `PAYLOAD_TOO_LARGE` | Event exceeds `max_event_size` |
| 429 | `RATE_LIMIT_EXCEEDED` | Rate limit hit |
| 503 | `SERVICE_UNAVAILABLE` | Server is overloaded or down |
