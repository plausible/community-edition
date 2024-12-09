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

### Apache2
Install the necessary Apache modules and restart Apache. Edit the file `reverse-proxy/apache2/plausible.conf` to contain the domain name you use for your server, then copy it into Apache's configuration folder. Enable it by creating a symlink in Apache's enabled sites folder with `a2ensite` command. Finally use Certbot to create a TLS certificate for your site:

```shell
$ sudo a2enmod proxy proxy_http proxy_ajp remoteip headers proxy_wstunnel
$ sudo systemctl restart apache2
$ sudo cp reverse-proxy/apache2/plausible.conf /etc/apache2/sites-available/
$ sudo a2ensite plausible.conf
$ sudo systemctl restart apache2
$ sudo certbot --apache
```
#### Apache2 Modsecurity
Modsecurity block with CRS the "plain/text" used by Plausible and ".com" in headers so if you use Modsecurity as a Waff to your Apache2 configuration you will need to add some custom rules in order to not block Plausible. Here are some rules, feel free to adapt to your specific case:

```shell
# Autoriser text/plain pour la route /api/event
SecRule REQUEST_URI "@streq /api/event" \
    "id:1000005,phase:1,t:none,pass,nolog,ctl:requestBodyAccess=On"

# Désactiver les règles spécifiques uniquement pour /api/event
SecRule REQUEST_URI "@streq /api/event" \
    "id:1000006,phase:1,t:none,pass,nolog,ctl:ruleRemoveById=920420,ctl:ruleRemoveById=949110"

# Autoriser toutes les requêtes .com pour l'agent utilisateur Plausible
SecRule REQUEST_HEADERS:User-Agent "@contains Plausible" \
    "id:1000008,phase:1,t:none,pass,nolog,ctl:ruleRemoveById=920440,ctl:ruleRemoveById=949110"

# Autoriser l'accès aux requêtes .com pour l'agent utilisateur Plausible
SecRule REQUEST_URI "@contains .com" \
    "id:1000010,phase:1,t:none,pass,nolog,ctl:ruleRemoveById=920440,ctl:ruleRemoveById=949110"
```

Save this as 
```shell
/etc/modsecurity/customrules/customrules.conf
```

And add those custom rules to
```shell
/etc/modsecurity/modsecurity.conf
```
Like that
```shell
Include /etc/modsecurity/crs/crs-setup.conf
Include /etc/modsecurity/customrules/customrules.conf

#SecRuleEngine DetectionOnly
SecRuleEngine On
```
And test and adapt!
