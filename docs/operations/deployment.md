# Deployment

## Production considerations

Before deploying EventFlow to production:

- Use a reverse proxy (nginx, Traefik) for TLS termination
- Run at least two EventFlow instances for high availability
- Use a managed PostgreSQL and Redis instance
- Set `--log-level info` or `warn` (not `debug`)
- Configure resource limits

## Docker Compose

```yaml
version: "3.9"
services:
  eventflow:
    image: eventflow/eventflow:1.2.0
    ports:
      - "8080:8080"
    environment:
      EVENTFLOW_SERVER_PORT: "8080"
      EVENTFLOW_INGESTION_RATE_LIMIT: "5000"
      EVENTFLOW_LOGGING_LEVEL: "info"
      EVENTFLOW_DB_POSTGRES_DSN: "postgres://eventflow:${DB_PASSWORD}@postgres:5432/eventflow"
      EVENTFLOW_REDIS_ADDR: "redis:6379"
    configs:
      - source: eventflow_config
        target: /etc/eventflow/eventflow.yaml
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: eventflow
      POSTGRES_USER: eventflow
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U eventflow"]
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
    restart: unless-stopped

volumes:
  pgdata:
  redisdata:
```

## Kubernetes with Helm

A Helm chart is available at `deploy/charts/eventflow`.

### values.yaml

```yaml
replicaCount: 2

image:
  repository: eventflow/eventflow
  tag: 1.2.0

config:
  ingestion:
    rateLimit: 5000
  sinks:
    - name: kafka
      type: kafka
      config:
        brokers:
          - kafka-cluster:9092
        topic: events

env:
  - name: EVENTFLOW_DB_POSTGRES_DSN
    valueFrom:
      secretKeyRef:
        name: eventflow-db
        key: dsn
  - name: EVENTFLOW_REDIS_ADDR
    value: redis-master:6379

resources:
  limits:
    cpu: "2"
    memory: 2Gi
  requests:
    cpu: "1"
    memory: 512Mi

service:
  port: 8080

ingress:
  enabled: true
  host: events.example.com
  tls:
    secretName: eventflow-tls
```

```bash
helm upgrade --install eventflow deploy/charts/eventflow \
  --values values.yaml \
  --namespace eventflow --create-namespace
```

## Systemd (bare metal)

```
[Unit]
Description=EventFlow event processing pipeline
After=network.target postgresql.service redis.service

[Service]
Type=simple
User=eventflow
Group=eventflow
ExecStart=/usr/local/bin/eventflow serve --config /etc/eventflow/eventflow.yaml
Restart=always
RestartSec=10
LimitNOFILE=65536

Environment=EVENTFLOW_DB_POSTGRES_DSN=postgres://eventflow:${DB_PASSWORD}@localhost:5432/eventflow
Environment=EVENTFLOW_REDIS_ADDR=localhost:6379

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable eventflow
sudo systemctl start eventflow
```

## Secrets management

Do not hardcode secrets in configuration files. Use environment variables or a secrets manager:

```bash
export DB_PASSWORD=$(vault read -field=password secret/eventflow/db)
eventflow serve --config /etc/eventflow/eventflow.yaml
```

## Resource recommendations

| Environment | CPU | Memory | Disk |
|---|---|---|---|
| Development | 0.5 core | 256MB | N/A |
| Production (low) | 1 core | 512MB | 10GB |
| Production (high) | 2-4 cores | 2-4GB | 50GB |

Disk is primarily used for logs and the dead letter queue if S3 is unavailable.
