# Troubleshooting

## Common errors

### "too many open files"

EventFlow opens connections to sinks and external services. If you see this in the logs:

```
error: accept tcp [::]:8080: accept4: too many open files
```

**Solution:** Increase the file descriptor limit.

```bash
# Check current limit
ulimit -n

# Set higher limit (systemd: see LimitNOFILE in unit file)
ulimit -n 65536
```

### "sink timeout"

```
error: sink 'kafka-prod' delivery timed out after 10s
```

**Solutions:**

1. Check Kafka broker connectivity: `nc -zv kafka-1 9092`
2. Increase sink timeout: `config.timeout: 30s`
3. Check if the Kafka cluster is under load.
4. Verify topic exists: `kafka-topics --describe --topic events`

### "invalid API key"

```
{"error":{"code":"UNAUTHORIZED","message":"invalid or missing API key"}}
```

**Solutions:**

1. Verify the key exists: `eventflow keys list`
2. Check the key hasn't been revoked.
3. Confirm the request includes the `X-API-Key` header.
4. Check for trailing whitespace or quoting issues in the header value.

## Enabling debug logging

```bash
eventflow serve --log-level debug
```

Or set the environment variable:

```bash
EVENTFLOW_LOGGING_LEVEL=debug eventflow serve
```

## Inspecting rules

Use the CLI to inspect the currently loaded rule set:

```bash
eventflow inspect
```

Output:

```
Rules (3):
  transform: uppercase_user (enabled)
  sink: console (type: stdout, status: connected)
  sink: kafka-prod (type: kafka, status: error: connection refused)
```

## Metrics to alert on

| Metric | Alert threshold | Meaning |
|---|---|---|
| `eventflow_sink_errors_total` | > 0 in 5m | Sink is failing |
| `eventflow_transform_errors_total` | > 1% of total events | Transform script error |
| `eventflow_active_connections` | > 80% of max | Nearing connection limit |
| Go `process_resident_memory_bytes` | > 80% of limit | Memory pressure |

## Capturing a bug report

When reporting an issue, include:

1. **EventFlow version**: `eventflow version`
2. **Configuration** (redact secrets): `eventflow validate --show`
3. **Logs** from around the time of the error (with `--log-level debug`)
4. **Metrics snapshot**: `curl http://localhost:8080/metrics`
5. **Steps to reproduce** including sample event payload

## Health check failures

If `/ready` returns non-200, check dependencies.

## Still stuck?

- Search [GitHub Issues](https://github.com/eventflow/eventflow/issues) for similar problems.
- Ask in the [Discord](https://discord.gg/eventflow) `#support` channel.
- Include the information from the bug report section above.
