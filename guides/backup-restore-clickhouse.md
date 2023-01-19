Guide to backing up and restoring `plausible_events_db`. Based on ["Backup and Restore" from ClickHouse.](https://clickhouse.com/docs/en/operations/backup/)

**Note:** following this guide you'd need to stop some containers and it would make your plausible instance temporarily unavailable.

---

### Plan

1. dump contents of the Plausible tables (events, sessions, imported\_\*) to files in a mounted volume
1. load dumps from the mounted volume into `plausible_events_db`

---

### Backup

1. Add backup config to allow reading backup files in the ClickHouse container

```console
$ touch clickhouse/backups.xml
```

```xml
<clickhouse>
    <storage_configuration>
        <disks>
            <backups>
                <type>local</type>
                <path>/backups/</path>
            </backups>
        </disks>
    </storage_configuration>
    <backups>
        <allowed_disk>backups</allowed_disk>
        <allowed_path>/backups/</allowed_path>
    </backups>
</clickhouse>
```

2. Add backups volume to `plausible_events_db` in your `docker-compose.yml`

```diff
  plausible_events_db:
    image: clickhouse/clickhouse-server:22.6
    volumes:
      - event-data:/var/lib/clickhouse
      - ./clickhouse/:/etc/clickhouse-server/config.d/
+     - ./clickhouse-backups:/backups
```

3. Stop relevant containers to avoid writing to old `plausible_events_db`

```console
> docker compose stop plausible plausible_events_db
[+] Running 2/2
 ⠿ Container hosting-plausible-1            Stopped           6.5s
 ⠿ Container hosting-plausible_events_db-1  Stopped           0.2s
```

4. Restart `plausible_events_db` container to attach volume

```console
> docker compose up plausible_events_db -d
[+] Running 1/1
 ⠿ Container hosting-plausible_events_db-1  Started           0.3s
```

5. Dump old `plausible_events_db` contents to backup files

```console
> docker compose exec plausible_events_db sh -c "clickhouse-client --query 'BACKUP TABLE plausible_events_db.events TO Disk('backups', 'events.zip')'"
> docker compose exec plausible_events_db sh -c "clickhouse-client --query 'BACKUP TABLE plausible_events_db.sessions TO Disk('backups', 'sessions.zip')'"
> docker compose exec plausible_events_db sh -c "clickhouse-client --query 'BACKUP TABLE plausible_events_db.imported_visitors TO Disk('backups', 'imported_visitors.zip')'"

# etc.
```

**TODO:** script

6. (Optional) verify backup went OK

```console
> ls backups
events.zip  sessions.zip  imported_visitors.zip ...
```

7. Move the backups somewhere, like a different host

### Restore

1. Ensure relevant containers are stopped

```console
> docker compose stop plausible plausible_events_db
[+] Running 2/2
 ⠿ Container hosting-plausible-1            Stopped           0.0s
 ⠿ Container hosting-plausible_events_db-1  Stopped           0.2s
```

3. Ensure backup config from step 1 and backups mount from step 2 are still present.

4. Load data into from backups. **TODO:** User + permissions

```console
> docker compose exec plausible_events_db sh -c "clickhouse-client --query 'RESTORE TABLE plausible_events_db.events FROM Disk('backups', 'events.zip')'"
> docker compose exec plausible_events_db sh -c "clickhouse-client --query 'RESTORE TABLE plausible_events_db.sessions FROM Disk('backups', 'sessions.zip')'"
> docker compose exec plausible_events_db sh -c "clickhouse-client --query 'RESTORE TABLE plausible_events_db.imported_visitors FROM Disk('backups', 'imported_visitors.zip')'"

# etc.
```

6. Start all other containers

```console
> docker compose up -d
[+] Running 4/4
 ⠿ Container hosting-plausible_events_db-1  Running           0.0s
 ⠿ Container hosting-mail-1                 Running           0.0s
 ⠿ Container hosting-plausible_db-1         Started           0.5s
 ⠿ Container hosting-plausible-1            Started           0.5s
```

7. (Optional) Remove backups from `docker-compose.yml` and your filesystem

```diff
  plausible_events_db:
    image: clickhouse/clickhouse-server:22.6
    volumes:
      - event-data:/var/lib/clickhouse
      - ./clickhouse/:/etc/clickhouse-server/config.d/
-     - ./clickhouse-backups:/backups
```

```
> rm -rf ./clickhouse-backups
```
