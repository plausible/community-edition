# How to deploy

This deployment uses docker-stack-deploy to make secret and configuration management easier. See https://github.com/neuroforgede/docker-stack-deploy.

This assumes you have a Docker swarm running. Once set up, you will need a
traefik instance configured to work with constraint `traefik-public` and a network `traefik-public`.

This also expects encryption to be handled outside of docker swarm by a LB that has access to the Swarm.

Also, Geo-IP is not supported yet (but being worked on).

## 1. Adapt passwords in plausible

Admin users are users that are allowed to create new passwords.
To manage these users, simply adapt the file `secrets/admin_users.sh`

## 2. Adapt values in swarm/secrets/plausible_analytics/plausible-conf.env

Replace all variables with `<placeholders>` according to your needs.

## 3. Adapt values in swarm/plausible.yml

Replace all variables with `<placeholders>` according to your needs.

## 4. Run deploy

```
bash deploy.sh
```

## 5. Use it

You can now find your plausible application under the domain you configured in `swarm/secrets/plausible_analytics/plausible-conf.env`.

Creating new passwords will require the login from login from `swarm/secrets/plausible_analytics/plausible-conf.env`.