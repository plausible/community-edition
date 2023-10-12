Guide to backing up and restoring `plausible_events_db`. Based on ["Backup and Restore" from ClickHouse.](https://clickhouse.com/docs/en/operations/backup/)

**Note:** following this guide you'd need to stop some containers and it would make your plausible instance temporarily unavailable.

---

### Plan

1. dump contents of the Plausible tables to a file
1. optionally copy that file to a new host
1. restore the tables from that file into `plausible_events_db`

---

### Backup

1. Add backup config to allow reading and writing backup files in the ClickHouse container

```console
$ touch clickhouse/backups.xml
```

```xml
<clickhouse>
  <backups>
    <allowed_path>/backups/</allowed_path>
  </backups>
</clickhouse>
```

2. Mount new configuration to volume to `plausible_events_db` in your `docker-compose.yml`

```diff
  plausible_events_db:
    image: clickhouse/clickhouse-server:23-alpine
    volumes:
      - event-data:/var/lib/clickhouse
      - ./clickhouse/:/etc/clickhouse-server/config.d/
```

3. Dump old `plausible_events_db` contents to a backup file

```console
> docker compose exec plausible_events_db sh -c "clickhouse-client -q 'BACKUP DATABASE plausible_events_db TO File(\'/backups/plausible_events_db.zip\')'"
```

4. Copy the dump to the host

```console
> docker compose cp plausible_events_db:/backups/plausible_events_db.zip plausible_events_db.zip
```

5. (Optional) verify backup went OK

```console
> unzip -l plausible_events_db.zip
```

6. Move the dump somewhere, like a different host

### Restore

1. Copy the dump into the container

```console
> docker compose cp plausible_events_db.zip plausible_events_dh:/backups/plausible_events_db.zip
```

2. Restore

```console
> docker compose exec plausible_events_db sh -c "clickhouse-client -q 'RESTORE DATABSE plausible_events_db FROM File(\'/backups/plausible_events_db.zip\')'"
```

3. (Optional) Remove backups from the container and the host

```console
> docker compose exec plausible_events_db rm -rf /backups/plausible_events_db.zip
> rm plausible_events_db.zip
```
