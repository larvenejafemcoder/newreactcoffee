# Backup and Restore

## What to back up

| Component | Data | Backup method |
|---|---|---|
| PostgreSQL | Rules, API keys, schema metadata, event log | `pg_dump` |
| Redis | Rate limit counters, idempotency keys | Optional (ephemeral, can be rebuilt) |
| S3 state metadata | Upload state for S3 sink (if used) | Part of Postgres backup |
| Configuration files | `eventflow.yaml`, environment files | File backup |

## Backup procedures

### PostgreSQL

Automated daily backup script:

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/eventflow"
DB_DSN="postgres://eventflow:password@localhost:5432/eventflow"
DATE=$(date +%Y%m%d_%H%M%S)

pg_dump "$DB_DSN" \
  --format=custom \
  --file="$BACKUP_DIR/eventflow_$DATE.dump" \
  --verbose

# Retain 30 days
find "$BACKUP_DIR" -name "*.dump" -mtime +30 -delete
```

Restore:

```bash
pg_restore --dbname=postgres://eventflow:password@localhost:5432/eventflow \
  --format=custom \
  --clean \
  eventflow_20260613_120000.dump
```

### Redis

Redis data is ephemeral – rate limit counters and idempotency keys rebuild automatically. If you want to preserve them:

```bash
redis-cli SAVE
cp /var/lib/redis/dump.rdb /var/backups/eventflow/redis/
```

Restore by copying the RDB file into place and restarting Redis.

### Configuration files

```bash
tar czf /var/backups/eventflow/configs_$DATE.tar.gz /etc/eventflow/
```

## Disaster recovery

### Recovery Time Objective (RTO)

- **Target**: 1 hour
- **Procedure**: Restore Postgres from latest dump, reconfigure from config backup, start EventFlow instances

### Recovery Point Objective (RPO)

- **Target**: 24 hours (daily backup)
- **Improvement**: Enable point-in-time recovery in PostgreSQL (WAL archiving) for RPO of minutes

### Full recovery procedure

1. Provision new infrastructure (VMs or Kubernetes cluster).
2. Restore PostgreSQL from the latest dump.
3. Restore configuration files.
4. Start EventFlow instances pointing to the restored database.
5. Verify health checks pass.
6. Validate that ingestion API keys and rules are present:

```bash
eventflow keys list
eventflow rules list
```

7. Send a test event to confirm the pipeline is operational.

### Validation

After restore, verify:

- `GET /health` returns 200
- `GET /v1/rules` lists expected rules
- A test event is processed successfully
- Metrics endpoint returns data

## Scheduled backup

Add a cron job for automated backups:

```cron
0 2 * * * /usr/local/bin/backup-eventflow.sh
```
