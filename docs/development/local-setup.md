# Local Setup

This guide walks through setting up a local development environment for EventFlow.

## Prerequisites

- Go 1.21 or later
- Docker Engine 24.0+ and Docker Compose v2
- `make`
- `git`

## Clone the repository

```bash
git clone https://github.com/eventflow/eventflow.git
cd eventflow
```

## Install Go dependencies

```bash
go mod download
```

## Run infrastructure dependencies

EventFlow depends on PostgreSQL and Redis. Start them with Docker Compose:

```yaml
# docker-compose.dev.yml
version: "3.9"
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: eventflow
      POSTGRES_USER: eventflow
      POSTGRES_PASSWORD: devpassword
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

```bash
docker compose -f docker-compose.dev.yml up -d
```

## Run EventFlow in dev mode

```bash
go run cmd/eventflow/main.go --config configs/dev.yaml
```

The server starts on `http://localhost:8080`.

## Hot reload with air

Install [air](https://github.com/air-verse/air) for live reloading:

```bash
go install github.com/air-verse/air@latest
air
```

Any source file change automatically rebuilds and restarts the server.

## Configuration for development

A sample `configs/dev.yaml` is included in the repository:

```yaml
server:
  port: 8080

ingestion:
  api_keys:
    - dev-key
  rate_limit: 10000

sinks:
  - name: console
    type: stdout
    config: {}

transforms: []

logging:
  level: debug
  format: text

metrics:
  enabled: true
```

## Pre-commit hooks

Install the pre-commit hooks to automatically run linting and formatting:

```bash
make install-hooks
```

This runs `gofmt`, `go vet`, and `golangci-lint` on staged changes.

## Project structure

```
cmd/
  eventflow/         # Main binary entrypoint
configs/             # Sample configuration files
internal/
  ingestion/         # HTTP ingestion handlers
  transforms/        # Transform pipeline and built-in transforms
  sinks/             # Sink implementations
  api/               # Management API handlers
  metrics/           # Prometheus metrics
  schema/            # JSON Schema validation
  db/                # Database migrations and queries
pkg/
  eventflow/         # Public Go packages
docs/                # Documentation
```

## Verifying the setup

```bash
curl -X POST http://localhost:8080/v1/events \
  -H "Content-Type: application/json" \
  -H "X-API-Key: dev-key" \
  -d '{"id":"test-1","type":"dev_test","timestamp":"2026-06-13T12:00:00Z","data":{}}'
```

You should see the event logged in the console sink output.
