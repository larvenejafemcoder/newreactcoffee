# Sinks

Sinks are the destinations where processed events are forwarded. Each sink is configured with a `type`, `name`, and type-specific `config`.

## Configuring sinks

```yaml
sinks:
  - name: console
    type: stdout
    config: {}
  - name: events-topic
    type: kafka
    config:
      brokers:
        - kafka-1:9092
        - kafka-2:9092
      topic: events
      partitioner: hash
      retry_count: 3
      retry_backoff: 1s
  - name: archive-bucket
    type: s3
    config:
      bucket: my-event-archive
      region: us-east-1
      path_prefix: events/year=2026/
      batch_size: 500
```

## Supported sink types

### stdout / file

| Config | Default | Description |
|---|---|---|
| `path` | (stdout) | File path for file sink. Omit for stdout. |
| `format` | `json` | Output format: `json` or `jsonl` |

```yaml
- name: debug
  type: file
  config:
    path: /var/log/eventflow/events.log
    format: jsonl
```

### kafka

| Config | Default | Description |
|---|---|---|
| `brokers` | required | List of Kafka broker addresses |
| `topic` | required | Kafka topic name |
| `partitioner` | `hash` | `hash`, `round_robin`, or `random` |
| `retry_count` | `3` | Number of publish retries |
| `retry_backoff` | `1s` | Delay between retries |
| `batch_size` | `100` | Max messages per batch |

### s3

| Config | Default | Description |
|---|---|---|
| `bucket` | required | S3 bucket name |
| `region` | required | AWS region |
| `path_prefix` | `""` | Prefix for object keys |
| `batch_size` | `500` | Events per uploaded object |
| `batch_max_wait` | `60s` | Max wait before flushing batch |
| `compression` | `gzip` | `none` or `gzip` |

### webhook

| Config | Default | Description |
|---|---|---|
| `url` | required | Target URL |
| `headers` | `{}` | Custom HTTP headers |
| `retry_count` | `3` | Delivery retries |
| `retry_backoff` | `1s` | Initial backoff (exponential) |
| `timeout` | `10s` | HTTP request timeout |

```yaml
- name: alert-webhook
  type: webhook
  config:
    url: https://hooks.example.com/events
    headers:
      Authorization: "Bearer whsec_abc123"
    retry_count: 5
    retry_backoff: 2s
```

## Dead letter queue

Events that fail after all retries are written to the dead letter queue. Configure a DLQ sink:

```yaml
dead_letter_queue:
  sink: dlq-storage
  max_retries: 3

sinks:
  - name: dlq-storage
    type: s3
    config:
      bucket: eventflow-dlq
      region: us-east-1
      path_prefix: dlq/
```

Failed events include a `_error` field with the error message and the original event payload.

## Routing events by type

Use the `routes` configuration to send events with different `type` values to different sinks:

```yaml
routes:
  - event_type: "order.*"
    sink: orders-topic
  - event_type: "page_view"
    sink: analytics-bucket
  - event_type: "*"
    sink: fallback-console
```

Routes are evaluated in order. The first matching route wins. Use `*` as a catch-all.
