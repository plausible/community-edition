# Getting started

> The easiest way to get started with Plausible is with [our official managed service in the Cloud](https://plausible.io/#pricing). It takes 2 minutes to start counting your stats with a worldwide CDN, high availability, backups, security and maintenance all done for you by us. Our managed hosting can save a substantial amount of developer time and resources. For most sites this ends up being the best value option and the revenue goes to funding the maintenance and further development of Plausible. So you’ll be supporting open source software and getting a great service! The section below is for self-hosting our analytics on your server and managing your infrastructure.

Plausible Analytics is designed to be self-hosted through Docker. You don't have to be a Docker expert
to launch your own instance of Plausible Analytics. You should have a basic understanding of the command-line
and networking to successfully set up your own instance of Plausible Analytics.

> NB: If you hit a snag with the setup, you can reach out to us on the [forum](https://github.com/plausible/analytics/discussions). If you think something could be better explained in the docs, please open a PR on GitHub so the next person has a nicer experience. Happy hosting!

## Version management

Plausible follows [semantic versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

You can find available Plausible versions on [DockerHub](https://hub.docker.com/r/plausible/analytics). The default
`latest` tag refers to the latest stable release tag. You can also pin your version:

- `plausible/analytics:v2` pins the major version to `2` but allows minor and patch version upgrades
- `plausible/analytics:v2.0` pins the minor version to `2.0` but allows only patch upgrades

None of the functionality is backported to older versions. If you wish to get the latest bug fixes and security
updates you need to upgrade to a newer version.

Version changes are documented in our [Changelog](https://github.com/plausible/analytics/blob/master/CHANGELOG.md).
Please note that database schema changes require running migrations when you're upgrading. However, we consider the schema
as an internal API and therefore schema changes aren't considered a breaking change.

## Requirements

The only thing you need to install Plausible Analytics is a server with Docker installed. The server must have a CPU with x86_64 architecture
and support for SSE 4.2 instructions. We recommend using a minimum of 4GB of RAM but the requirements will depend on your site traffic.

We've tested this on [Digital Ocean](https://m.do.co/c/91569eca0213) (affiliate link)
but any hosting provider works. If your server doesn't come with Docker pre-installed, you can follow [their docs](https://docs.docker.com/get-docker/) to install it.

To make your Plausible instance accessible on a (sub)domain, you also need to be able to edit your DNS. Plausible isn't currently designed for subfolder installations.

## Up and running

### 1. Clone the hosting repo

To get started quickly, close this repo as a starting point. It has everything you need
to boot up your own Plausible server.

```bash
$ git clone https://github.com/plausible/hosting
$ cd hosting
```

Alternatively, you can download and extract the repo as a tarball

```bash
$ curl -L https://github.com/plausible/hosting/archive/master.tar.gz | tar -xz
$ cd hosting-master
```

In the downloaded directory you'll find two important files:

- `docker-compose.yml` - installs and orchestrates networking between your Plausible server, Postgres database, Clickhouse database (for stats), and an SMTP server. It comes with sensible defaults that are ready to go, although you're free to tweak the settings if you wish.
- `plausible-conf.env` - configures the Plausible server itself. Full configuration options are documented [here](./configuration.md).

### 2. Add required configuration

The configuration file, `plausible-conf.env`, has placeholders for the required parameters. To set the parameters you'll first need a random 64-character secret key which will be used to secure the app. Here's a simple way to generate one:

```bash
$ openssl rand -base64 64 | tr -d '\n' ; echo
```

Now edit `plausible-conf.env` and set `SECRET_KEY_BASE` to your secret key.

Next, enter the `BASE_URL` for your app. It should be the base url where this instance is accessible, including the scheme (eg. `http://` or `https://`), the domain name, and optionally a port. If no port is specified the default `8000` will be used. Plausible isn't currently designed for subfolder installations, so please don't add a path component to the base URL.

### 3. Start the server

Once you've entered your secret key base and base URL, you're ready to start up the server:

```bash
$ docker-compose up -d
```

When you run this command for the first time, it does the following:

- Creates a Postgres database for user data.
- Creates a Clickhouse database for stats.
- Runs migrations on both databases to prepare the schema.
- Starts the server on port 8000.

You can now navigate to `http://{hostname}:8000` and see the registration screen for the admin user.

### 4. (Optional) Email verification

If you've enabled email verification with `ENABLE_EMAIL_VERIFICATION=true`, you'd be prompted to enter a verification code which has been sent to your email. Please configure your server for SMTP to receive this email. [Here are Plausible's SMTP configuration options](./configuration.md#mailersmtp-setup).

Otherwise, run this command to verify all users in the database:

```bash
$ docker-compose exec plausible_db psql -U postgres -d plausible_db -c "UPDATE users SET email_verified = true;"
```

> Something not working? Please reach out on our [forum](https://github.com/plausible/analytics/discussions/categories/self-hosted-support) for troubleshooting.

The Plausible server itself does not perform SSL termination. It only runs on unencrypted HTTP. If you want to run on HTTPS you also need to set up a reverse proxy in front of the server. We have instructions and examples of how to do that below.

## Updating Plausible

Plausible is updated regularly, but it's up to you to apply these updates on your server.
You may refer to the discussions on [the releases page](https://github.com/plausible/analytics/releases) for specific instructions.
The typical steps for handling minor version updates are as follows:

```bash
$ docker-compose down --remove-orphans
$ docker-compose pull plausible
$ docker-compose up -d
```

The self-hosted version is somewhat of a LTS, only getting the changes after they have been battle tested on the hosted version.
If you want features as soon as they are available, consider becoming a hosted customer.

## Optional extras

At this stage, you should have a basic installation of Plausible going. With some extra configuration, you can add functionality to
your instance:

### 1. MaxMind geolocation database

Plausible uses the country database created by [dbip](https://db-ip.com/) for enriching analytics data with visitor countries. The database is shipped with Plausible and country data collection happens automatically.

Optionally, you can provide a different database. For example, you can use [MaxMind](https://www.maxmind.com) services. Their end-user license does not make it very easy to just package the database along with an open-source product.

This is why, to use MaxMind, you need to create an account [here](https://www.maxmind.com/en/geolite2/signup). Once you have your account details, open the `geoip/geoip.conf` file and enter your `GEOIPUPDATE_ACCOUNT_ID` and `GEOIPUPDATE_LICENSE_KEY`. Then, combine both the base docker-compose file with the one in the geoip folder:

```bash
$ docker-compose -f docker-compose.yml -f geoip/docker-compose.geoip.yml up -d
```

The `geoip/docker-compose.geoip.yml` file downloads and updates the country database automatically, making it available to the `plausible`
container.

### 2. Reverse proxy

By default, Plausible runs on unencrypted HTTP on port 8000. We recommend running it on HTTPS behind a reverse proxy of some sort.

> After setting up a reverse proxy be sure to change this line `- 8000:8000` to `- 127.0.0.1:8000:8000` in `docker-compose.yml` file and restart the container for it to apply changes. This prevents Plausible from being accessed remotely using HTTP on port 8000 which is a security concern.

You may or may not already be running a reverse proxy on your host, let's look at both options:

#### No existing reverse proxy

If your DNS is managed by a service that offers a proxy option with automatic SSL management, feel free to use that. We've successfully
used Cloudflare as a reverse proxy in front of Plausible Self Hosted, and it works well.

Alternatively, you can run your own Caddy server as a reverse proxy. This way your SSL certificate will be stored on the
host machine and managed by Let's Encrypt. The Caddy server will expose port 443, terminate SSL traffic and proxy the requests to your
Plausible server. [Full instructions](https://github.com/plausible/hosting/tree/master/reverse-proxy#no-existing-reverse-proxy).

#### Existing reverse proxy

If you're already running a reverse proxy, the most important things to note are:

1. Configure the virtual host to match the `BASE_URL` in your plausible configuration.
1. Proxy the traffic to `127.0.0.1:8000` or `{ip-address}:8000` if running on a remote machine.
1. Ensure the `X-Forwarded-For` is set correctly.

The most important thing to note with an existing reverse proxy is that the `X-Forwarded-For` header is set correctly. If the remote client IP isn't forwarded to the Plausible server, it can't detect visitor countries and unique user tracking will be inaccurate.

In our hosting repo, you'll find useful example configurations in case you're already running [Nginx](../reverse-proxy/README.md#nginx), [Apache](../reverse-proxy/README.md#apache2), or [Traefik 2](../reverse-proxy/README.md#traefik-2).

### 3. External Databases

There are some caveats to consider when running your own databases:

##### Postgres

The user needs the role superuser for setting up certain modules on the database
If the database already exists prior to running docker-compose up, please remove `&& /entrypoint.sh db createdb` in the command of the plausible service section inside docker-compose.yml. However, this will also prevent the Clickhouse database from being created, see below.

##### Clickhouse

If you receive an error upon startup that for some reason the database does not exist, you can create it 'manually' through this docker run:
make sure that --link, --net, --host, and the name of the db receive the right parameter values according to the running setup

```bash
docker compose exec plausible_events_db clickhouse-client --host plausible_events_db --query "CREATE DATABASE IF NOT EXISTS plausible_events_db"
```

> Our only source of funding is our premium, managed service for running Plausible in the cloud. If you're looking for an alternative way to support the project, we've put together some sponsorship packages. Maintaining open source software is a thankless, time-consuming job. We released our code on GitHub and made it easy to self-host on principle, not because it's good business. If you're self-hosting Plausible, [sponsoring us](https://github.com/sponsors/plausible) is a great way to give back to the community and to contribute to the long-term sustainability of the project. Thank you for supporting independent creators of Free Open Source Software!
