> Original repo can be found [here](https://github.com/BytemarkHosting/docker-smtp)

## Supported tags

* [`stretch`, `latest` (*stretch/Dockerfile*)](https://github.com/BytemarkHosting/docker-smtp/blob/master/stretch/Dockerfile)

## Quick reference

This image allows linked containers to send outgoing email. You can configure
it to send email directly to recipients, or to act as a smart host that relays
mail to an intermediate server (eg, GMail, SendGrid).

* **Code repository:**
  https://github.com/BytemarkHosting/docker-smtp
* **Where to file issues:**
  https://github.com/BytemarkHosting/docker-smtp/issues
* **Maintained by:**
  [Bytemark Hosting](https://www.bytemark.co.uk)
* **Supported architectures:**
  [Any architecture that has the Debian `exim4-daemon-light` package](https://packages.debian.org/stretch/exim4-daemon-light)

## Usage

### Basic SMTP server

In this example, linked containers can connect to hostname `mail` and port `25`
to send outgoing email. The SMTP container sends email out directly.

```
docker run --restart always --name mail -d bytemark/smtp

```

#### Via Docker Compose:

```
version: '3'
services:
  mail:
    image: bytemark/smtp
    restart: always

```

### SMTP smart host

In this example, linked containers can connect to hostname `mail` and port `25`
to send outgoing email. The SMTP container acts as a smart host and relays mail
to an intermediate server server (eg, GMail, SendGrid).

```
docker run --restart always --name mail \
    -e RELAY_HOST=smtp.example.com \
    -e RELAY_PORT=587 \
    -e RELAY_USERNAME=alice@example.com \
    -e RELAY_PASSWORD=secretpassword \
    -d bytemark/smtp

```

#### Via Docker Compose:

```
version: '3'
services:
  mail:
    image: bytemark/smtp
    restart: always
    environment:
      RELAY_HOST: smtp.example.com
      RELAY_PORT: 587
      RELAY_USERNAME: alice@example.com
      RELAY_PASSWORD: secretpassword

```

### Environment variables

All environment variables are optional. But if you specify a `RELAY_HOST`, then
you'll want to also specify the port, username and password otherwise it's
unlikely to work!

* **`MAILNAME`**: Sets Exim's `primary_hostname`, which defaults to the
  hostname of the server.
* **`RELAY_HOST`**: The remote SMTP server address to use.
* **`RELAY_PORT`**: The remote SMTP server port to use.
* **`RELAY_USERNAME`**: The username to authenticate with the remote SMTP
  server.
* **`RELAY_PASSWORD`**: The password to authenticate with the remote SMTP
  server.
* **`RELAY_NETS`**: Declare which networks can use the smart host, separated by
  semi-colons. By default, this is set to
  `10.0.0.0/8;172.16.0.0/12;192.168.0.0/16`, which provides a thin layer of
  protection in case port 25 is accidentally exposed to the public internet
  (which would make your SMTP container an open relay).

