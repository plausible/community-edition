# Configuration options

> The easiest way to get started with Plausible is with [our official managed service in the Cloud](https://plausible.io/#pricing). It takes 2 minutes to start counting your stats with a worldwide CDN, high availability, backups, security and maintenance all done for you by us. Our managed hosting can save a substantial amount of developer time and resources. For most sites this ends up being the best value option and the revenue goes to funding the maintenance and further development of Plausible. So you’ll be supporting open source software and getting a great service! The section below is for self-hosting our analytics on your server and managing your infrastructure.

When running a Plausible release, the following configuration parameters can be supplied as environment variables.

### Server

Following are the variables that can be used to configure the availability of the server.

| Parameter                 | Default | Description                                                                                                                                                                                                                       |
| ------------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BASE_URL                  | --      | The hosting URL of the server, used for URL generation. In production systems, this should be your ingress host.                                                                                                                  |
| PORT                      | 8000    | The port on which the server is available.                                                                                                                                                                                        |
| LISTEN_IP                 | 0.0.0.0 | The IP address on which the server is listening. `0.0.0.0` means all interfaces, `127.0.0.1` means localhost. Also see the related section **Erlang platform ports** below.                                                       |
| SECRET_KEY_BASE           | --      | An internal secret key used by [Phoenix Framework](https://www.phoenixframework.org/). Follow the [instructions](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Secret.html#content) or use `openssl rand -hex 64` to generate one. |
| DISABLE_REGISTRATION      | true    | Restricts registration of new users. Possible values are `true` (full restriction), `false` (no restriction), and `invite_only` (only the invited users can register).                                                            |
| LOG_FAILED_LOGIN_ATTEMPTS | false   | Controls whether to log warnings about failed login attempts.                                                                                                                                                                     |

#### Erlang platform ports

When changing the `LISTEN_IP` of the Plausible HTTP server, you may also wish to change the listen IPs of the Erlang VM and Port Mapper Daemon (`epmd`) normally started by Plausible. They allow remote code execution and are listening on all interfaces by default. You can change that by setting the environment variables:

- [`RELEASE_VM_ARGS`](https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-environment-variables), to e.g. `-kernel inet_dist_use_interface "{127,0,0,1}"`
- [`ERL_EPMD_ADDRESS`](https://erlang.org/doc/man/epmd.html#environment-variables) to e.g. `127.0.0.1`

Alternatively, if you are running on a single machine and don't need any of Erlang's multi-node distribution features, you turn them off entirely by setting environment variable:

- [`RELEASE_DISTRIBUTION`](https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-environment-variables) to `none`

### Database

Plausible uses [PostgreSQL](https://www.tutorialspoint.com/postgresql/postgresql_environment.htm) for storing user data and [ClickhouseDB](https://clickhouse.tech/docs/en/getting-started/tutorial/) for analytics data. Use the following variables to configure it.

| Parameter                    | Default                                                     | Description                                                                                                                                                                                                                  |
| ---------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DATABASE_URL                 | postgres://postgres:postgres@plausible_db:5432/plausible_db | The database URL as dictated [here](https://hexdocs.pm/ecto/Ecto.Repo.html#module-urls), i.e. for external db server postgres://user:password@ip.or.domain.to.server/database_name                                           |
| DATABASE_SOCKET_DIR          | --                                                          | Directory where a UNIX socket of postgresql is available. Mutually exclusive with `DATABASE_URL`, can only be used with `DATABASE_NAME`                                                                                      |
| DATABASE_NAME                | --                                                          | Name of the database in PostgreSQL to use. Only applicable in conjunction with `DATABASE_SOCKET_DIR`                                                                                                                         |
| ECTO_IPV6                    | --                                                          | When defined, enables ipv6 for the PostgreSQL connection. [Applicable](https://github.com/plausible/analytics/pull/1661) for hosting on fly.io.                                                                              |
| CLICKHOUSE_DATABASE_URL      | http://plausible_events_db:8123/plausible_events_db         | Connection string for Clickhouse in the same format, i.e. for docker-compose setup http://ip.or.domain.to.server:8123/plausible_events_db                                                                                    |
| CLICKHOUSE_FLUSH_INTERVAL_MS | 5000                                                        | Interval (in milliseconds) between flushing events and sessions data to Clickhouse. Consult [Clickhouse docs](https://clickhouse.tech/docs/en/introduction/performance/#performance-when-inserting-data) before changing it. |
| CLICKHOUSE_MAX_BUFFER_SIZE   | 10000                                                       | Maximum size of the buffer of events or sessions. Consult [Clickhouse docs](https://clickhouse.tech/docs/en/introduction/performance/#performance-when-inserting-data) before changing it.                                   |

### Mailer/SMTP Setup

Plausible uses a SMTP server to send transactional emails e.g. account activation, password reset. In addition, it sends non-transactional emails like weekly or monthly reports.

| Parameter             | Default               | Description                                                                     |
| --------------------- | --------------------- | ------------------------------------------------------------------------------- |
| MAILER_EMAIL          | hello@plausible.local | The email id to use for as _from_ address of all communications from Plausible. |
| MAILER_NAME           | --                    | The display name for the sender (_from_).                                       |
| SMTP_HOST_ADDR        | localhost             | The host address of your smtp server.                                           |
| SMTP_HOST_PORT        | 25                    | The port of your smtp server.                                                   |
| SMTP_USER_NAME        | --                    | The username/email in case SMTP auth is enabled.                                |
| SMTP_USER_PWD         | --                    | The password in case SMTP auth is enabled.                                      |
| SMTP_HOST_SSL_ENABLED | false                 | If SSL is enabled for SMTP connection                                           |
| SMTP_RETRIES          | 2                     | Number of retries to make until mailer gives up.                                |

Alternatively, you can use Postmark to send transactional emails. In this case, use the following parameters:

| Parameter        | Default            | Description                                                        |
| ---------------- | ------------------ | ------------------------------------------------------------------ |
| MAILER_ADAPTER   | Bamboo.SMTPAdapter | Instead of the default, replace this with `Bamboo.PostmarkAdapter` |
| POSTMARK_API_KEY | --                 | Enter your API key.                                                |

In case you are using postmark, you have to set the MAILER_EMAIL variable which needs to be configured in PostmarkApps sender signatures.

### IP Geolocation

Plausible uses the country database created by [dbip](https://db-ip.com/) for enriching analytics data with visitor countries. The
database is shipped with Plausible and country data collection happens automatically.

Optionally, you can provide a different database. For example, you can use [MaxMind](https://www.maxmind.com) services.
You need to create an account and use their **GeoLite2 Country** database.

| Parameter            | Default       | Description                                                                                                                                                                               |
| -------------------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MAXMIND_LICENSE_KEY  | --            | MaxMind license key to automatically download and update the datase                                                                                                                       |
| MAXMIND_EDITION      | GeoLite2-City | MaxMind database edition to use (only if MAXMIND_LICENSE_KEY is set)                                                                                                                      |
| GEOLITE2_COUNTRY_DB  | --            | Path to your custom IP geolocation database in MaxMind's format                                                                                                                           |
| GEONAMES_SOURCE_FILE | --            | Path to your custom CSV file containing geoname_id -> place name mapping. [geonames.lite.csv](https://github.com/plausible/location/blob/main/priv/geonames.lite.csv) is used by default. |

### Google API Integration

To enable [the Google Search Console integration](google-search-console-integration.md) and [Google Analytics imports,](google-analytics-import.md) you first need to authorize your self-hosted installation with a Google Account. Complete the following two tasks to do so.

#### Task One: Configure the OAuth Consent Screen

1. Login to [Google API Console](https://console.developers.google.com/) with your Google Account. Once on the API Console, create a new project for the Plausible integration.

![google1](https://user-images.githubusercontent.com/85956139/132954658-2d5bc2c3-22c2-4300-b9c6-cbe4f8f8987e.png)

2. Make sure your new Project is open, select "OAuth consent screen" from the left side menu to configure the consent screen. If you can't see the "OAuth consent screen" menu item, open the navigation ("hamburger") menu in the top left corner and select "APIs & Services". "OAuth consent screen" is a menu item below that.

3. Enter an "App name" and a "User support email". Again, to help with naming, remember that the "app" is your self-hosted Plausible site which will be requesting access to the Search Console API using your Google Account, so you are probably the only user.

4. Apart from the mandatory "Developer contact information" fields, the only other necessary setting is the "Authorized domains" which must include the domain used for the earlier "Authorized Redirect URIs" setting. That is, add the domain (eg. `example.com`) of your Plausible installation's public URL. All subdomains will be authorized automatically.

5. Click "SAVE AND CONTINUE". No "Scopes" are required, so click "SAVE AND CONTINUE" again.

6. The "app" will be created with status set to "Testing". To avoid having to verify it with Google, you must enter the email address of your Google Account as a "Test user". Add the email address and then click "SAVE AND CONTINUE" and the OAuth Consent Screen configuration is complete.

#### Task Two: Create an OAuth Client

1. We will need to obtain OAuth 2.0 credentials such as a Client ID and Client Secret key that are known to both Google and your installation. Make sure your new Project is open, then go to the "Credentials" screen and get your Client ID and Client Secret key. If you can't see the "Credentials" menu item, open the navigation ("hamburger") menu in the top left corner and select "APIs & Services". "Credentials" is a menu item below that.

![google2](https://user-images.githubusercontent.com/85956139/132954742-bb9c3477-b84a-40a5-a2eb-f9fa683804cf.png)

2. Use the "+ CREATE CREDENTIALS" button near the top of the screen to create a new "OAuth client ID". Set the "Application type" to "Web application" and give it a name. To help with naming, note that your self-hosted Plausible site will be the "client" that is accessing an API exposed by your Google account.

3. Use the "+ ADD URI" button to set an "Authorized redirect URI" to your Plausible installation's public URL followed by `/auth/google/callback`. Eg. `https://plausible.example.com/auth/google/callback`. Then click "CREATE".

![google3](https://user-images.githubusercontent.com/85956139/132954858-ef951349-20b0-4675-bf9c-ead8d4bc292b.jpg)

4. Copy the Client ID and Client Secret key from your project in Google API Console into these config values (that is, add them to `plausible-conf.env`):

| Parameter            | Default | Description                                                                        |
| -------------------- | ------- | ---------------------------------------------------------------------------------- |
| GOOGLE_CLIENT_ID     | --      | The Client ID from the Google API Console for your Plausible Analytics project     |
| GOOGLE_CLIENT_SECRET | --      | The Client Secret from the Google API Console for your Plausible Analytics project |

5. Force the new config values to take effect by restarting your Plausible site (eg. with the command `docker-compose down --remove-orphans && docker-compose up -d`).

### Google Search Integration

Although you can now grant your Plausible installation access to your Google account, you still won't be able to choose a property from the Search Console as described in [Google Search Console Integration](google-search-console-integration.md), until you enable the "[Google Search Console API](https://console.developers.google.com/apis/api/searchconsole.googleapis.com)" on your Google API project.

#### Enable Google Search Console API

1. Click on "Enable APIs and Services."

![google_enable_1](https://user-images.githubusercontent.com/85956139/132954489-34071ab3-dd96-44ab-83be-02431a888df9.jpg)

2. Search for "Google Search Console API" in the search bar of the API Library.

![google_enable2](https://user-images.githubusercontent.com/85956139/132954499-bc96eb44-d94b-4413-8e0e-c2008fc60242.png)

3. Click on "Google Search Console API" and the button to enable.

![google_enable3](https://user-images.githubusercontent.com/85956139/132954503-df8caff9-8654-4ec0-87eb-4d76363ebc75.png)

![google_enable4](https://user-images.githubusercontent.com/85956139/132954508-290bda57-47cf-4cda-bb6d-77a1c8baa485.png)

4. Finally, return to APIs & Services, and select "Domain verification". If you can't see the "Domain verification" menu item, open the navigation ("hamburger") menu in the top left corner and select "APIs & Services". "Domain verification" is a menu item below that.

5. Add the same domain you used in Step 2 above. You will be prompted to go to Google Search Console to finish configuration, which coincidentally is exactly where you need to be to start the [Google Search Console Integration](https://plausible.io/docs/google-search-console-integration) instructions.

### Google Analytics Integration

To be able to [import data from Google Analytics,](https://plausible.io/docs/google-analytics-import) you need to enable [Analytics Reporting API](https://console.developers.google.com/apis/api/analyticsreporting.googleapis.com) and [Google Analytics API.](https://console.developers.google.com/apis/api/analytics.googleapis.com)

Once those services are enabled, follow the instructions outlined in [Import stats from Google Analytics.](https://plausible.io/docs/google-analytics-import) Note that when going through Google Auth, you need to make sure the "See and download your Google Analytics data." checkbox is selected.

> Our only source of funding is our premium, managed service for running Plausible in the cloud. If you're looking for an alternative way to support the project, we've put together some sponsorship packages. Maintaining open source software is a thankless, time-consuming job. We released our code on GitHub and made it easy to self-host on principle, not because it's good business. If you're self-hosting Plausible, [sponsoring us](https://github.com/sponsors/plausible) is a great way to give back to the community and to contribute to the long-term sustainability of the project. Thank you for supporting independent creators of Free Open Source Software!
