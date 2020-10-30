This directory contains pre-made configurations for various reverse proxies. Which flavor you should choose depends on your setup.

## No existing reverse proxy

If you aren't running an existing reverse proxy, then you can use the [`caddy-gen`](https://github.com/wemake-services/caddy-gen) based docker-compose file. Update it to include the domain name you use for your server, then combine it with the existing docker-compose files:

```shell
$ docker-compose -f docker-compose.yml -f reverse-proxy/docker-compose.caddy-gen.yml up
```
