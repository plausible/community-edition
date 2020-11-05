This directory contains pre-made configurations for various reverse proxies. Which flavor you should choose depends on your setup.

## No existing reverse proxy

If you aren't running an existing reverse proxy, then you can use the [`caddy-gen`](https://github.com/wemake-services/caddy-gen) based docker-compose file. Update it to include the domain name you use for your server, then combine it with the existing docker-compose files:

```shell
$ docker-compose -f docker-compose.yml -f reverse-proxy/docker-compose.caddy-gen.yml up
```

## Existing reverse proxy

If you are already running a reverse proxy, then the above will not work as it will clash with the existing port bindings. You should instead use one of the available configuration files:

### NGINX

If you already have NGINX running as a system service, use the configuration file in the `nginx` directory.

Edit the file `reverse-proxy/nginx/plausible` to contain the domain name you use for your server, then copy it into NGINX's configuration folder. Enable it by creating a symlink in NGINX's enabled sites folder. Finally use Certbot to create a TLS certificate for your site:

```shell
$ sudo cp reverse-proxy/nginx/plausible /etc/nginx/sites-available
$ sudo ln -s /etc/nginx/sites-available/plausible /etc/nginx/sites-enabled/plausible
$ sudo certbot --nginx
```

### Traefik 2

If you already have a Traefik container running on Docker, use the docker-compose file in the `traefik` directory. Note that it assumes that your Traefik container is set up to support certificate generation.

Edit the file `reverse-proxy/traefik/docker-compose.traefik.yml` to contain the domain name you use for your server, then combine it with the existing docker-compose files:

```shell
$ docker-compose -f docker-compose.yml -f reverse-proxy/traefik/docker-compose.traefik.yml up
```
