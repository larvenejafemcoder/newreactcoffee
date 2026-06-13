# Testing

EventFlow has a comprehensive test suite covering unit, integration, and end-to-end tests.

## Running tests

### Unit tests

```bash
make test
```

Runs all unit tests with a race detector. Coverage goal is above 80%.

To view coverage:

```bash
make test-coverage
go tool cover -html=coverage.out -o coverage.html
```

### Integration tests

Integration tests require Docker (for Postgres and Redis):

```bash
make integration
```

This starts the required containers, runs tests that depend on external services, and tears everything down.

### End-to-end tests

E2E tests validate the full pipeline end to end:

```bash
make e2e
```

### Benchmarks

```bash
make bench
```

## Writing tests

### Unit test example (transform)

Tests for transforms live in `internal/transforms/`:

```go
package transforms

import (
    "testing"
    "encoding/json"
)

func TestAddFieldTransform(t *testing.T) {
    cfg := map[string]interface{}{
        "key":   "data.env",
        "value": "test",
    }
    tr, err := New("add_field", cfg)
    if err != nil {
        t.Fatal(err)
    }

    event := json.RawMessage(`{
        "id": "evt-001",
        "type": "test",
        "timestamp": "2026-06-13T12:00:00Z",
        "data": {}
    }`)

    result, err := tr.Transform(event)
    if err != nil {
        t.Fatal(err)
    }

    var resultMap map[string]interface{}
    json.Unmarshal(result, &resultMap)
    data := resultMap["data"].(map[string]interface{})
    if data["env"] != "test" {
        t.Errorf("expected env=test, got %v", data["env"])
    }
}
```

### Integration test example

Integration tests use the `testcontainers-go` library to spin up dependencies:

```go
func TestKafkaSinkIntegration(t *testing.T) {
    ctx := context.Background()
    kafkaC, _ := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: testcontainers.ContainerRequest{
            Image: "confluentinc/cp-kafka:7.5.0",
            ExposedPorts: []string{"9093/tcp"},
            Env: map[string]string{
                "KAFKA_ADVERTISED_LISTENERS": "PLAINTEXT://localhost:9093",
            },
        },
        Started: true,
    })
    defer kafkaC.Terminate(ctx)
    // ... test sink against this container
}
```

## Test conventions

- Test files are named `*_test.go` and placed alongside the code they test.
- Use `t.Parallel()` for independent tests.
- Integration test files use the `_integration_test.go` suffix.
- Fixtures live in `testdata/` directories.
- Mock external services where possible for unit tests.

## Continuous Integration

Tests run automatically on every PR via GitHub Actions:

```yaml
# .github/workflows/ci.yml (partial)
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: "1.21"
      - run: make test
      - run: make integration
```
