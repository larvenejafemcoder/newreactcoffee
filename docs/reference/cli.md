# CLI Reference

The `eventflow` CLI provides commands for operating and managing EventFlow.

## Global flags

| Flag | Env | Default | Description |
|---|---|---|---|
| `--config` | `EVENTFLOW_CONFIG` | `eventflow.yaml` | Path to configuration file |
| `--log-level` | `EVENTFLOW_LOGGING_LEVEL` | `info` | Log level: `debug`, `info`, `warn`, `error` |
| `--log-format` | `EVENTFLOW_LOGGING_FORMAT` | `json` | Log format: `json` or `text` |

## Commands

### `eventflow serve`

Start the EventFlow server.

```bash
eventflow serve [flags]
```

| Flag | Default | Description |
|---|---|---|
| `--port` | `8080` | HTTP listen port |
| `--config` | `eventflow.yaml` | Config file path |

Example:

```bash
eventflow serve --config configs/prod.yaml --port 8080 --log-level warn
```

### `eventflow keys`

Manage API keys.

```bash
eventflow keys create --name <name> --scope <scope>
eventflow keys list
eventflow keys revoke <key_id>
```

| Flag | Description |
|---|---|
| `--name` | Human-readable key name |
| `--scope` | Comma-separated scopes: `ingest`, `admin`, `metrics` |

Examples:

```bash
eventflow keys create --name "ci-cd-pipeline" --scope ingest
eventflow keys list
eventflow keys revoke key_abc123def456
```

### `eventflow validate`

Validate a configuration file without starting the server.

```bash
eventflow validate [--config path] [--show]
```

| Flag | Description |
|---|---|
| `--show` | Print the parsed configuration (secrets redacted) |

Example:

```bash
eventflow validate --config configs/prod.yaml --show
```

Exit code `0` means valid, non-zero means validation errors.

### `eventflow transform test`

Test a transform against a sample event.

```bash
eventflow transform test --transform <file> --event <file>
```

| Flag | Description |
|---|---|
| `--transform` | Path to a YAML file with a single transform definition |
| `--event` | Path to a JSON file with a sample event |

Example:

```bash
cat > my-transform.yaml <<EOF
type: js_script
config:
  script: |
    function transform(event) {
      event.data.upper = event.data.name.toUpperCase();
      return event;
    }
EOF

cat > sample-event.json <<EOF
{"id":"t1","type":"test","timestamp":"2026-06-13T12:00:00Z","data":{"name":"alice"}}
EOF

eventflow transform test --transform my-transform.yaml --event sample-event.json
```

Output:

```json
{
  "id": "t1",
  "type": "test",
  "timestamp": "2026-06-13T12:00:00Z",
  "data": {
    "name": "alice",
    "upper": "ALICE"
  }
}
```

### `eventflow version`

Print the version and build information.

```bash
eventflow version
```

Output:

```
EventFlow v1.2.0 (commit a1b2c3d4, built 2026-06-01T10:00:00Z with go1.21.10)
```

### `eventflow inspect`

Display the current runtime state of rules and sink connections.

```bash
eventflow inspect
```

### `eventflow schema push`

Push a JSON Schema to the registry. See [Schema Registry](./schema-registry.md).

```bash
eventflow schema push --file schema.json --id event.v2
```

### `eventflow help`

Display help for any command:

```bash
eventflow help serve
eventflow keys --help
```
