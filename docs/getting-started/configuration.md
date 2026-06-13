# Configuration

EventFlow uses a layered configuration model: **flags > environment variables > config file**.

## Configuration precedence

1. Command-line flags (highest priority)
2. Environment variables prefixed with `EVENTFLOW_`
3. YAML configuration file (default: `eventflow.yaml` in the current directory, or `--config` flag)

## Full configuration example

```yaml
server:
  port: 8080
  read_timeout: 30s
  write_timeout: 30s
  max_header_bytes: 1MB

ingestion:
  api_keys:
    - dev-key
  rate_limit: 1000
  rate_limit_window: 1m
  max_event_size: 256KB
  batch_max_size: 100
  batch_max_wait: 5s

sinks:
  - name: console
    type: stdout
    config: {}
  - name: events-topic
    type: kafka
    config:
      brokers:
        - localhost:9092
      topic: events
      partitioner: hash
      retry_count: 3
      retry_backoff: 1s

transforms:
  - name: enrich_user
    type: js_script
    config:
      script: |
        function transform(event) {
          if (event.data && event.data.user_id) {
            event.data.user_upper = event.data.user_id.toUpperCase();
          }
          return event;
        }

logging:
  level: info
  format: json
  output: stdout

metrics:
  enabled: true
  path: /metrics

telemetry:
  tracing_enabled: true
  otlp_endpoint: http://localhost:4318
```

## Field reference

### server

| Field | Default | Description |
|---|---|---|
| `port` | `8080` | HTTP listen port |
| `read_timeout` | `30s` | Maximum duration for reading the entire request |
| `write_timeout` | `30s` | Maximum duration before timing out writes |
| `max_header_bytes` | `1MB` | Maximum size of request headers |

### ingestion

| Field | Default | Description |
|---|---|---|
| `api_keys` | `[]` | List of valid API keys (or use CLI to manage) |
| `rate_limit` | `1000` | Max requests per API key per window |
| `rate_limit_window` | `1m` | Rate limit window duration |
| `max_event_size` | `256KB` | Maximum single event payload size |
| `batch_max_size` | `100` | Maximum events per batch request |
| `batch_max_wait` | `5s` | Maximum time to buffer before flushing |

### sinks

| Field | Default | Description |
|---|---|---|
| `name` | required | Unique sink identifier |
| `type` | required | One of `stdout`, `file`, `kafka`, `s3`, `webhook` |
| `config` | `{}` | Type-specific configuration |

### transforms

| Field | Default | Description |
|---|---|---|
| `name` | required | Unique transform identifier |
| `type` | required | One of `jsonpath_extract`, `add_field`, `rename_field`, `convert_type`, `filter`, `js_script` |
| `config` | `{}` | Type-specific configuration |

## Environment variable mapping

Nested YAML keys translate to underscore-separated environment variables.

| YAML path | Environment variable |
|---|---|
| `server.port` | `EVENTFLOW_SERVER_PORT` |
| `ingestion.rate_limit` | `EVENTFLOW_INGESTION_RATE_LIMIT` |
| `logging.level` | `EVENTFLOW_LOGGING_LEVEL` |
| `metrics.enabled` | `EVENTFLOW_METRICS_ENABLED` |

## Reloading configuration

Send `SIGHUP` to the EventFlow process to reload configuration without restarting:

```bash
kill -HUP $(pgrep eventflow)
```

The server reloads sinks, transforms, and logging configuration. Server port and metrics path changes require a full restart.

> **Note:** Configuration changes are applied atomically. If the new config is invalid, the process continues with the previous configuration and logs an error.
