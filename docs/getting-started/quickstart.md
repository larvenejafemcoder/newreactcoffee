# Quickstart

This guide will have you sending and processing events within 5 minutes.

## 1. Start EventFlow

Create a `docker-compose.yml`:

```yaml
version: "3.9"
services:
  eventflow:
    image: eventflow/eventflow:latest
    ports:
      - "8080:8080"
    environment:
      EVENTFLOW_SERVER_PORT: "8080"
      EVENTFLOW_INGESTION_API_KEYS: "dev-key"
    configs:
      - source: eventflow_config
        target: /etc/eventflow/eventflow.yaml

configs:
  eventflow_config:
    content: |
      ingestion:
        rate_limit: 1000
      sinks:
        - name: console
          type: stdout
          config: {}
      transforms: []
```

Start the service:

```bash
docker compose up -d
```

> **Note:** The `dev-key` API key shown above is for local development only. Production deployments should use the `eventflow keys` CLI to generate secure keys.

## 2. Send a test event

```bash
curl -X POST http://localhost:8080/v1/events \
  -H "Content-Type: application/json" \
  -H "X-API-Key: dev-key" \
  -d '{
    "id": "evt-001",
    "type": "page_view",
    "timestamp": "2026-06-13T12:00:00Z",
    "data": {
      "page": "/pricing",
      "user": "alice"
    }
  }'
```

A successful response:

```json
{
  "id": "evt-001",
  "status": "accepted"
}
```

## 3. Check the console sink

In the Docker logs you should see:

```
{"level":"info","event_id":"evt-001","sink":"console","msg":"event delivered to console sink"}
{"level":"info","event_id":"evt-001","type":"page_view","data":{"page":"/pricing","user":"alice"},"msg":"event payload"}
```

## 4. Create a simple transform

Add a transform to uppercase the `user` field. Update your `docker-compose.yml` transforms section:

```yaml
transforms:
  - name: uppercase_user
    type: js_script
    config:
      script: |
        function transform(event) {
          if (event.data && event.data.user) {
            event.data.user = event.data.user.toUpperCase();
          }
          return event;
        }
```

Recreate the container and send the event again. The console sink will now show `"user": "ALICE"`.

## 5. What's next?

- Learn about [configuration](./configuration.md) in depth
- Explore [built-in transforms](../user-guide/transforms.md)
- Set up a [Kafka sink](../user-guide/sinks.md)
