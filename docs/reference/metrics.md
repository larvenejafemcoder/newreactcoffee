# Metrics

EventFlow exposes Prometheus metrics at the `/metrics` endpoint. All metrics are prefixed with `eventflow_`.

## Metric reference

### `eventflow_ingested_total`

| Type | Labels |
|---|---|
| Counter | `api_key`, `status` |

Events received by the ingestion endpoint. `status` is `success` or `validation_error`.

```
eventflow_ingested_total{api_key="ef_key_abc123",status="success"} 15420
eventflow_ingested_total{api_key="ef_key_abc123",status="validation_error"} 3
```

### `eventflow_ingest_latency_seconds`

| Type | Labels |
|---|---|
| Histogram | `api_key` |

Time from receiving the HTTP request to accepting the event. Buckets: 0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5.

### `eventflow_transform_seconds`

| Type | Labels |
|---|---|
| Histogram | `name` |

Duration of each transform execution. Buckets: 0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1.

### `eventflow_transform_errors_total`

| Type | Labels |
|---|---|
| Counter | `name` |

Number of transform execution failures.

### `eventflow_sink_latency_seconds`

| Type | Labels |
|---|---|
| Histogram | `name` |

Time to deliver an event to a sink. Buckets: 0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5, 10.

### `eventflow_sink_errors_total`

| Type | Labels |
|---|---|
| Counter | `name`, `error_type` |

Sink delivery failures. `error_type` values: `timeout`, `connection_refused`, `rate_limited`, `invalid_response`.

### `eventflow_sink_batch_size`

| Type | Labels |
|---|---|
| Gauge | `name` |

Current number of events buffered in the sink batch.

### `eventflow_active_connections`

| Type | Labels |
|---|---|
| Gauge | (none) |

Number of active HTTP connections.

### `eventflow_rate_limit_remaining`

| Type | Labels |
|---|---|
| Gauge | `api_key` |

Remaining requests for the current rate limit window.

### `eventflow_rules_total`

| Type | Labels |
|---|---|
| Gauge | `type` |

Number of loaded rules. `type` is `transform` or `sink`.

### `eventflow_dlq_size`

| Type | Labels |
|---|---|
| Gauge | `sink` |

Number of events currently in the dead letter queue for a sink.

### Go runtime metrics

EventFlow also exposes standard Go runtime metrics:

- `go_memstats_alloc_bytes`
- `go_memstats_heap_inuse_bytes`
- `go_goroutines`
- `process_cpu_seconds_total`
- `process_resident_memory_bytes`

## Adding custom metrics (for contributors)

To add a new metric, use the `prometheus` package in `internal/metrics/`:

```go
package metrics

import "github.com/prometheus/client_golang/prometheus"

var (
    MyCustomCounter = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "eventflow_my_custom_total",
            Help: "Description of my custom metric",
        },
        []string{"label1"},
    )
)

func init() {
    prometheus.MustRegister(MyCustomCounter)
}
```

Then increment it in your code:

```go
metrics.MyCustomCounter.WithLabelValues("value1").Inc()
```

## Grafana dashboard (full)

A more complete Grafana dashboard JSON is available at `deploy/grafana/eventflow-dashboard.json` in the repository. Import it directly via the Grafana web UI.
