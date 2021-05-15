# Configuration

| Parameter                                     | Description                                                                             | Default                                                   |
|--------------------------------------------- |--------------------------------------------------------------------------------------- |--------------------------------------------------------- |
| disableAuth                                   | Disables authentication completely, no registration, login will be shown                | `false`                                                   |
| disableRegistration                           | Disables registration of new users, keep your admin credentials handy                   | `false`                                                   |
| adminUser.email                               | The default (&ldquo;admin&rdquo;) user email                                            | `""`                                                      |
| adminUser.name                                | Admin user&rsquo;s name                                                                 | `""`                                                      |
| adminUser.password                            | The default (&ldquo;admin&rdquo;) user password                                         | `""`                                                      |
| database.enabled                              | Set database URL in env                                                                 | `true`                                                    |
| database.url                                  | The database URL as dictated [here](https://hexdocs.pm/ecto/Ecto.Repo.html#module-urls) | `postgres://postgres:postgres@postgres/plausible?ssl=off` |
| clickhouse.enabled                            | Set clickhouse URL in env                                                               | `true`                                                    |
| clickhouse.url                                | Connection string for Clickhouse in the same format                                     | `http://plausible-events-db:8123/plausible`               |
| smtp.enabled                                  | Set SMTP configuration in env                                                           | `true`                                                    |
| smtp.mailer.emailAddress                      | The email id to use for as from address of all communications from Plausible            | `""`                                                      |
| smtp.mailer.adapter                           | Instead of the default, replace this with Bamboo.PostmarkAdapter                        | `""`                                                      |
| smtp.host                                     | The host address of your smtp server                                                    | `""`                                                      |
| smtp.port                                     | The port of your smtp server                                                            | `""`                                                      |
| smtp.username                                 | The username/email in case SMTP auth is enabled                                         | `""`                                                      |
| smtp.password                                 | The password in case SMTP auth is enabled                                               | `""`                                                      |
| smtp.ssl.enabled                              | If SSL is enabled for SMTP connection                                                   | `false`                                                   |
| smtp.retries                                  | Number of retries to make until mailer gives up                                         | `2`                                                       |
| postmark.apiKey                               | Enter your API key                                                                      | `""`                                                      |
| geoliteCountryDB                              | Path to your IP geolocation database in MaxMind&rsquo;s format                          | `""`                                                      |
| google.clientID                               | The Client ID from the Google API Console for your Plausible Analytics project          | `""`                                                      |
| google.clientSecret                           | The Client Secret from the Google API Console for your Plausible Analytics project      | `""`                                                      |
| twitter.consumer.key                          | The API key from the Twitter Developer Portal                                           | `""`                                                      |
| twitter.consumer.secret                       | The API key secret from the Twitter Developer Portal                                    | `""`                                                      |
| twitter.access.token                          | The access token you generated in the steps above                                       | `""`                                                      |
| twitter.access.secret                         | The access token secret you generated in the steps above                                | `""`                                                      |
| labels                                        | Extra labels to add to all managed resources                                            | `{}`                                                      |
| extraEnv                                      | Declare extra environment variables                                                     | `[]`                                                      |
| image.repository                              | The repo where the image lives                                                          | `plausible/analytics`                                     |
| image.tag                                     | Specifies a tag of from the image to use                                                | `""`                                                      |
| image.pullPolicy                              | Pod container pull policy                                                               | `IfNotPresent`                                            |
| imagePullSecrets                              | References for the registry secrets to pull the container images in the Pod with        | `[]`                                                      |
| nameOverride                                  | Expand the name of the chart                                                            | `""`                                                      |
| fullNameOverride                              | Create a FQDN for the app name                                                          | `""`                                                      |
| serviceAccount.create                         | Whether a serviceAccount should be created for the Pod to use                           | `false`                                                   |
| serviceAccount.name                           | A name to give the servce account                                                       | `nil`                                                     |
| podAnnotations                                | Annotations to assign Pods                                                              | `{}`                                                      |
| podSecurityContext                            | Set a security context for the Pod                                                      | `{}`                                                      |
| securityContext.readOnlyRootFilesystem        | Mount container filesytem as read only                                                  | `true`                                                    |
| securityContext.runAsNonRoot                  | Don&rsquo;t allow the container in the Pod to run as root                               | `true`                                                    |
| securityContext.runAsUser                     | The user ID to run the container in the Pod as                                          | `1000`                                                    |
| securityContext.runAsGroup                    | The group ID to run the container in the Pod as                                         | `1000`                                                    |
| service.type                                  | The service type to create                                                              | `ClusterIP`                                               |
| service.port                                  | The port to bind the app on and for the service to be set to                            | `8000`                                                    |
| ingress.enabled                               | Create an ingress manifests                                                             | `false`                                                   |
| ingress.realIPHeader                          | A header to forward, which contains the real client IP address                          | `""`                                                      |
| ingress.annotations                           | Set annotations for the ingress manifest                                                | `{}`                                                      |
| ingress.hosts                                 | The hosts which the ingress endpoint should be accessed from                            |                                                           |
| ingress.tls                                   | References to TLS secrets                                                               | `[]`                                                      |
| resources                                     | Limits and requests for the Pods                                                        | `{}`                                                      |
| autoscaling.enabled                           | Enable autoscaling for the deployment                                                   | `false`                                                   |
| autoscaling.minReplicas                       | The minimum amount of Pods to run                                                       | `1`                                                       |
| autoscaling.maxReplicas                       | The maximum amount of Pods to run                                                       | `1`                                                       |
| autoscaling.targetCPUUtilizationPercentage    | The individual Pod CPU amount until autoscaling occurs                                  | `80`                                                      |
| autoscaling.targetMemoryUtilizationPercentage | The individual Pod Memory amount until autoscaling occurs                               |                                                           |
| nodeSelector                                  | Declare the node labels for Pod scheduling                                              | `{}`                                                      |
| tolerations                                   | Declare the toleration labels for Pod scheduling                                        | `[]`                                                      |
| affinity                                      | Declare the affinity settings for the Pod scheduling                                    | `{}`                                                      |

# Installation

Install the Helm Chart locally, into the Plausible namespace:
```shell
  helm upgrade --install plausible -n plausible \
    --set adminUser.email=myemail@example.com \
    --set adminUser.name="Test User" \
    --set adminUser.password="password" \
    --set database.url="postgres://plausible:plausible@postgres/plausible?ssl=false" \
    --set clickhouse.url="http://plausible-events-db:8123/plausible" \
    --set disableRegistration=true \
    --set disableAuth=true \
    plausible-analytics
```

# Production installation
## Preparation

Create the namespace for plausible to be installed into
``` bash
kubectl create ns plausible
```

## Helm-Operator
[Helm-Operator](https://docs.fluxcd.io/projects/helm-operator/en/stable/) enables declarive installation of Helm charts.
See the [docs](https://docs.fluxcd.io/projects/helm-operator/en/stable/references/chart/) for installation.

## Postgres-Operator
[Postgres-Operator](https://postgres-operator.readthedocs.io/en/latest/) is an automated cloud-native way to run production-ready Postgres instances.

Declare the installation (postgres-operator.yaml)
```yaml
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: postgres-operator
  namespace: postgres-operator
spec:
  releaseName: postgres-operator
  chart:
    git: https://github.com/zalando/postgres-operator.git
    ref: v1.6.1
    path: charts/postgres-operator
    values:
      configKubernetes:
        enable_pod_antiaffinity: "true"
```

Install Postgres-Operator
```bash
kubectl create ns postgres-operator
kubectl apply -f postgres-operator.yaml
```

## Postgres
Declare the Postgres database (postgresql.yaml)

```yaml
apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: plausible-db
  namespace: plausible
spec:
  enableConnectionPooler: true
  connectionPooler:
    mode: session
    resources:
      requests:
        cpu: 250m
        memory: 100Mi
      limits:
        cpu: "1"
        memory: 100Mi
  teamId: "plausible"
  volume:
    size: 3Gi
  numberOfInstances: 3
  users:
    plausible:  # database owner
    - superuser
    - createdb
  databases:
    plausible: plausible  # dbname: owner
  postgresql:
    version: "12"
```

Create the password for the database (optional)
```bash
kubectl -n plausible create secret generic \
  plausible.plausible-db.credentials.postgresql.acid.zalan.do \
  --from-literal=password=plausible \
  --from-literal=username=plausible \
  --dry-run=client -o yaml \
    | kubectl apply -f -
```

Create the Postgres database
``` bash
kubectl apply -f postgresql.yaml
```
  
## Clickhouse
Install the Clickhouse operator

```bash
kubectl apply -f \
  https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install.yaml
```

Declare the Clickhouse installation

```yaml
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: plausible-clickhouse
  namespace: plausible
spec:
  configuration:
    clusters:
      - name: "replicas"
        layout:
          shardsCount: 1
          replicasCount: 3
  defaults:
    templates:
      serviceTemplate: cluster-service-type
  templates:
    serviceTemplates:
      - name: cluster-service-type
        generateName: "clickhouse-{chi}"
        spec:
          ports:
            - name: http
              port: 8123
            - name: tcp
              port: 9000
          type: ClusterIP
```

## Mail (optional)
An SMTP relay can be installed like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: mail
  name: mail
  namespace: plausible
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mail
  template:
    metadata:
      labels:
        app: mail
    spec:
      containers:
      - image: bytemark/smtp
        imagePullPolicy: IfNotPresent
        name: mail
        ports:
          - name: mail
            containerPort: 25
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mail
  name: mail
spec:
  ports:
  - name: http
    port: 25
    targetPort: 25
  selector:
    app: mail
```

With this, the `smtp` field does not need to be declared in the chart.

## Plausible
Declare the Plausible instance (plausible.yaml)

```yaml
apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: plausible
  namespace: plausible
spec:
  chart:
    git: https://github.com/plausible/hosting
    path: chart/plausible-analytics
    ref: 1efc73f64b76e51cee1935b6a01b6a7529fded41
  releaseName: plausible
  values:
    replicaCount: 3
    adminUser:
      name: "My Name Here"
      email: "my-email@address.here"
      password: "a-secure-password-here"
    database:
      url: "postgres://plausible:plausible@plausible-db-pooler.plausible/plausible?ssl=true"
    clickhouse:
      url: "http://clickhouse_operator:clickhouse_operator_password@clickhouse-plausible-clickhouse:8123/plausible"
    smtp:
      host: "my-smtp.com"
      port: "487"
      username: "my-user-name@my-smtp.com"
      password: "my-secure-password"
      ssl:
        enabled: true
    secretKeyBase: "hello-this-is-plausible-analytics-this-value-must-be-at-least-64-bytes-long"
    ingress:
      enabled: true
      hosts:
      - host: plausible.my-site.here
        paths:
        - /
      realIPHeader: X-Real-Ip
      tls:
      - hosts:
        - plausible.my-site.here
        secretName: letsencrypt-prod
```

Note:
- all values fields are available in the Configuration section

Install the Plausible instance
```bash
kubectl apply -f plausible.yaml
```

## Final things
With all of that, a full-HA instance should be installed!

```bash
$ kubectl -n plausible get pods
NAME                                             READY   STATUS    RESTARTS   AGE
chi-plausible-clickhouse-replicas-0-0-0          1/1     Running   0          4m15s
chi-plausible-clickhouse-replicas-1-0-0          1/1     Running   0          3m24s
chi-plausible-clickhouse-replicas-2-0-0          1/1     Running   0          2m33s
mail-6b5cb7f9b9-86scm                            1/1     Running   0          51s
mail-6b5cb7f9b9-94p62                            1/1     Running   0          68m
mail-6b5cb7f9b9-fw2m5                            1/1     Running   0          51s
plausible-db-0                                   1/1     Running   0          9m23s
plausible-db-1                                   1/1     Running   0          10m
plausible-db-2                                   1/1     Running   0          9m49s
plausible-db-pooler-866788446d-vx99m             1/1     Running   0          14m
plausible-db-pooler-866788446d-xsww4             1/1     Running   0          14m
plausible-plausible-analytics-7fd5c7dc88-glmwx   1/1     Running   0          11m
plausible-plausible-analytics-7fd5c7dc88-pgzjw   1/1     Running   0          11m
plausible-plausible-analytics-7fd5c7dc88-z78vj   1/1     Running   0          11m
```

### Ensure the default user can authenticate
Mark account as verified

```bash
kubectl -n plausible \
  exec -it \
  deployment/plausible-db-pooler -- \
    psql \
    postgresql://plausible:plausible@plausible-db-pooler/plausible?sslmode=require \
      -c "UPDATE users SET email_verified = true;"
```
