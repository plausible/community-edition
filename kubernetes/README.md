# Plausible Analytics in Kubernetes

This guide is designed to extend the [normal self-hosting guide](https://plausible.io/docs/self-hosting), please refer to it before following this guide.

## 1. Clone the hosting repo

To deploy Plausible Analytics into Kubernetes first download the [plausible/hosting](https://github.com/plausible/hosting) repo.

```bash
git clone https://github.com/plausible/hosting
cd hosting
```

## 2. Add required configuration

Like the original self hosting guide configure your server in the `plausible-conf.env` file.

## 3. Deploy the server

Once you've entered your secret key base, base url and admin credentials, you're ready to deploy the server:

```bash
kubectl create namespace plausible # Create a new namespace for all resources
kubectl -n plausible create secret generic plausible-config --from-env-file=plausible-conf.env # Create a configmap from the plausible-conf.env file
# Please change the Postgres and Clickhouse passwords to something more secure here!
kubectl -n plausible create secret generic plausible-db-user --from-literal='username=postgres' --from-literal='password=postgres' # Create the Postgres user
kubectl -n plausible create secret generic plausible-events-db-user --from-literal='username=clickhouse' --from-literal='password=clickhouse' # Create the Clickhouse user
kubectl -n plausible apply -f ./kubernetes
```

You can now navigate to http://{hostname}:8000 and see the login screen.

When you first log in with your admin credentials, you will be prompted to enter a verification code which has been sent to your email. Please configure your server for SMTP to receive this email. [Here are Plausible's SMTP configuration options](https://plausible.io/docs/self-hosting-configuration#mailersmtp-setup).
Otherwise, run this command to verify all users in the database:

```bash
kubectl -n plausible exec statefulset/plausible-db -- /bin/bash -c 'psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE users SET email_verified = true;"'
```
