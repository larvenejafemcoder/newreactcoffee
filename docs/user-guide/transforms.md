# Transforms

Transforms let you enrich, filter, and restructure events as they flow through the pipeline.

## Pipeline model

Transforms are executed **sequentially** in the order they are defined in the configuration. Each transform receives the output of the previous transform. If any transform returns an error, the event is routed to the dead letter queue.

```yaml
transforms:
  - name: add_timestamp
    type: add_field
    config:
      key: processed_at
      value: "{{ now }}"
  - name: sanitize_email
    type: js_script
    config:
      script: |
        function transform(event) {
          if (event.data.email) {
            event.data.email = event.data.email.toLowerCase().trim();
          }
          return event;
        }
```

## Built-in transforms

### jsonpath_extract

Extracts a value from the event using a JSONPath expression and stores it in a new field.

```yaml
type: jsonpath_extract
config:
  source_path: "$.data.user_id"
  target_key: "user_id"
```

### add_field

Adds a static or dynamic field to the event.

```yaml
type: add_field
config:
  key: "source"
  value: "webhook"
```

### rename_field

Renames an existing field.

```yaml
type: rename_field
config:
  from: "data.user_name"
  to: "data.username"
```

### convert_type

Converts a field's type (string to number, string to boolean, etc.).

```yaml
type: convert_type
config:
  field: "data.price"
  to_type: float
```

### filter

Drops events that do not match a condition.

```yaml
type: filter
config:
  condition: "data.status != 'test'"
```

> **Warning:** Filtered events are silently dropped and not sent to sinks or the DLQ.

### js_script

Runs an arbitrary JavaScript function using the embedded QuickJS engine.

```yaml
type: js_script
config:
  script: |
    function transform(event) {
      event.data.env = process.env.STAGE || "production";
      return event;
    }
```

## Writing a custom JS transform

Example – calculate a geohash from latitude/longitude:

```yaml
type: js_script
config:
  script: |
    function geohashEncode(lat, lon, precision) {
      precision = precision || 7;
      var chars = "0123456789bcdefghjkmnpqrstuvwxyz";
      var latInterval = [-90, 90];
      var lonInterval = [-180, 180];
      var hash = "";
      var isEven = true;
      var bit = 0;
      var ch = 0;
      while (hash.length < precision) {
        var mid;
        if (isEven) {
          mid = (lonInterval[0] + lonInterval[1]) / 2;
          if (lon > mid) { ch |= (1 << (4 - bit)); lonInterval[0] = mid; }
          else { lonInterval[1] = mid; }
        } else {
          mid = (latInterval[0] + latInterval[1]) / 2;
          if (lat > mid) { ch |= (1 << (4 - bit)); latInterval[0] = mid; }
          else { latInterval[1] = mid; }
        }
        isEven = !isEven;
        if (bit < 4) { bit++; }
        else { hash += chars[ch]; bit = 0; ch = 0; }
      }
      return hash;
    }

    function transform(event) {
      var lat = event.data.latitude;
      var lon = event.data.longitude;
      if (lat != null && lon != null) {
        event.data.geohash = geohashEncode(lat, lon);
      }
      return event;
    }
```

## Debugging transforms

Use the CLI to test a transform against a sample event without running the server:

```bash
eventflow transform test --transform configs/my-transform.yaml --event sample.json
```

Output shows the transformed event or the error message.

## Performance considerations

- JS transforms are sandboxed and have a 1-second execution timeout.
- For high-throughput pipelines, prefer built-in transforms over JS for simple operations.
- Transform errors are counted in the `eventflow_transform_errors_total` metric.
