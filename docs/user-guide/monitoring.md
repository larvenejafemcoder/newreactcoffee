# Monitoring

EventFlow exposes Prometheus metrics, health check endpoints, and structured logging for observability.

## Prometheus metrics

The metrics endpoint is available at `/metrics` (default port 8080). Add it as a scrape target in your `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: eventflow
    static_configs:
      - targets:
          - localhost:8080
```

### Key metrics

| Metric | Type | Description |
|---|---|---|
| `eventflow_ingested_total` | Counter | Events accepted, by status |
| `eventflow_transform_seconds` | Histogram | Transform duration |
| `eventflow_transform_errors_total` | Counter | Transform failures |
| `eventflow_sink_latency_seconds` | Histogram | Sink delivery latency |
| `eventflow_sink_errors_total` | Counter | Sink delivery failures |
| `eventflow_active_connections` | Gauge | Current HTTP connections |
| `eventflow_rate_limit_remaining` | Gauge | Remaining rate limit for key |

Example metric output:

```
eventflow_ingested_total{api_key="ef_key_abc123",status="success"} 15420
eventflow_ingested_total{api_key="ef_key_abc123",status="validation_error"} 3
eventflow_sink_latency_seconds_bucket{name="kafka",le="0.01"} 12000
eventflow_sink_latency_seconds_bucket{name="kafka",le="0.05"} 15200
eventflow_sink_latency_seconds_bucket{name="kafka",le="+Inf"} 15400
eventflow_sink_latency_seconds_count{name="kafka"} 15400
```

## Grafana dashboard

Below is a minimal dashboard JSON to get started. Import it into Grafana via the web UI.

```json
{
  "title": "EventFlow Overview",
  "panels": [
    {
      "title": "Ingestion rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(eventflow_ingested_total[1m])",
          "legendFormat": "events/s"
        }
      ]
    },
    {
      "title": "Sink latency (p99)",
      "type": "heatmap",
      "targets": [
        {
          "expr": "histogram_quantile(0.99, rate(eventflow_sink_latency_seconds_bucket[5m]))",
          "legendFormat": "{{name}}"
        }
      ]
    },
    {
      "title": "Error rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(eventflow_transform_errors_total[5m]) + rate(eventflow_sink_errors_total[5m])",
          "legendFormat": "errors/s"
        }
      ]
    }
  ]
}
```

## Health checks

| Endpoint | Purpose |
|---|---|
| `GET /health` | Liveness – returns 200 if the process is alive |
| `GET /ready` | Readiness – returns 200 if EventFlow can accept traffic |

```bash
curl http://localhost:8080/health
{"status":"ok","uptime":"12h34m56s"}

curl http://localhost:8080/ready
{"status":"ready"}
```

## Structured logging

Logs are output in JSON format by default:

```json
{"level":"info","timestamp":"2026-06-13T12:00:00Z","msg":"event ingested","event_id":"evt-001","api_key":"ef_key_abc123","status":"accepted"}
{"level":"error","timestamp":"2026-06-13T12:00:01Z","msg":"sink delivery failed","event_id":"evt-001","sink":"kafka","error":"connection refused","retry":2}
```

### Log levels

| Level | Usage |
|---|---|
| `debug` | Detailed diagnostic information |
| `info` | Normal operational messages |
| `warn` | Something unexpected but non-critical |
| `error` | A failure that may require attention |

Set the log level via the `--log-level` flag or `EVENTFLOW_LOGGING_LEVEL` environment variable.
