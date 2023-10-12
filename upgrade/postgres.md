Guide to upgrading PostgreSQL version `>= 12` to version `14` using `pg_dump` and `psql`. Based on [Upgrade a PostgreSQL database with docker.](https://hollo.me/devops/upgrade-postgresql-database-with-docker.html)

**Note:** following this guide you'd need to stop some containers and it would make your plausible instance temporarily unavailable.

---

### Plan

1. dump contents of the old version PostgreSQL to a file
1. copy the dump to the host
1. replace old version PostgreSQL with new version PostgreSQL
1. copy and load the dump into new version PostgreSQL

---

### Steps

1. Stop `plausible` to avoid writing to old `plausible_db`

```console
> docker compose stop plausible
[+] Running 2/2
 ⠿ Container hosting-plausible-1     Stopped           6.5s
```

2. Dump old `plausible_db` contents to a backup file

```console
> docker compose exec plausible_db sh -c "pg_dump -U postgres plausible_db > plausible_db.bak"
```

3. Copy the backup to the host

```console
> docker compose cp plausible_db:plausible_db.bak plausible_db.bak
```

4. (Optional) verify backup went OK

```console
> head plausible_db.bak
--
-- PostgreSQL database dump
--

-- Dumped from database version 12.12 (Debian 12.12-1.pgdg110+1)
-- Dumped by pg_dump version 12.12 (Debian 12.12-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
```

5. Edit `docker-compose.yml` to use new PostgreSQL version, here we update from `v12` to `v14`, alpine flavour.

```diff
  plausible_db:
-   image: postgres:12
+   image: postgres:14-alpine
    restart: always
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=postgres
```

6. Ensure relevant containers are stopped

```console
> docker compose stop plausible plausible_db
[+] Running 2/2
 ⠿ Container hosting-plausible-1     Stopped           0.0s
 ⠿ Container hosting-plausible_db-1  Stopped           0.2s
```

7. Remove old `plausible_db` container to be able to nuke its volume in the next step

```console
> docker compose rm plausible_db
? Going to remove hosting-plausible_db-1 Yes
[+] Running 1/0
 ⠿ Container hosting-plausible_db-1  Removed           0.0s
```

8. Remove old `plausible_db` volume, mine is named `hosting_db-data`

```console
> docker volume ls
DRIVER    VOLUME NAME
<...snip...>
local     hosting_db-data
local     hosting_event-data
<...snip...>

> docker volume rm hosting_db-data
hosting_db-data
```

9. Start new version `plausible_db` container

```console
> docker compose up plausible_db -d
[+] Running 9/9
 ⠿ plausible_db Pulled                                 9.3s
   ⠿ 9b18e9b68314 Already exists                       0.0s
   ⠿ 75aada9edfc5 Pull complete                        1.2s
   ⠿ 820773693750 Pull complete                        1.2s
   ⠿ 8812bb04ef2e Pull complete                        5.2s
   ⠿ 2ccec0f7805c Pull complete                        5.2s
   ⠿ 833f9b98598e Pull complete                        5.3s
   ⠿ 1eb578dc04e6 Pull complete                        5.4s
   ⠿ c873bf6204df Pull complete                        5.4s
[+] Running 2/2
 ⠿ Volume "hosting_db-data"          Created           0.0s
 ⠿ Container hosting-plausible_db-1  Started           0.5s
```

10. Create new DB and load data into it

```console
> docker compose exec plausible_db createdb -U postgres plausible_db
> docker compose cp plausible_db.bak plausible_db:plausible_db.bak

> docker compose exec plausible_db sh -c "psql -U postgres -d plausible_db < plausible_db.bak"
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
CREATE EXTENSION
<...snip...>
```

11. Start all other containers

```console
> docker compose up -d
[+] Running 4/4
 ⠿ Container hosting-plausible_events_db-1  Running           0.0s
 ⠿ Container hosting-mail-1                 Running           0.0s
 ⠿ Container hosting-plausible_db-1         Started           0.5s
 ⠿ Container hosting-plausible-1            Started           0.5s
```

12. (Optional) Remove backups from the container and the host

```console
> rm plausible_db.bak
> docker compose exec plausible_db rm plausible_db.bak
```
