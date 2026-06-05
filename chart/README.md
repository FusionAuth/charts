# FusionAuth Helm Chart

![Build Status](https://github.com/FusionAuth/charts/actions/workflows/release.yml/badge.svg)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting, and much more.

## Important Changes

### 1.68.0

⚠️ This release contains several breaking changes, as well as recommended changes.
Review your values file carefully against these notes!

#### Breaking Changes

- **The minimum supported Kubernetes version is now 1.23.0.** This removes support
  for long-deprecated beta APIs for `HorizontalPodAutoscaler`, `Ingress`, and
  `PodDisruptionBudget`.

- **`service.spec` has been removed from the chart** to eliminate the risk of
  overwriting valid service configurations. If you used `service.spec` in a way
  that is not supported by the standard chart values, please open an issue
  describing your use case.

- **`service.type` no longer supports `ExternalName`.** `ExternalName` support
  should not be required in this chart. If you used `ExternalName`, please open
  an issue describing your use case.

- **`environment` can no longer override variables managed by chart values.**
  If you have set any of the following variables in the `environment` section,
  you must remove them and use the corresponding chart values instead.
  | Env Var | Chart Value |
  | --- | --- |
  | `DATABASE_USERNAME` | `database.dbUser.username` |
  | `DATABASE_PASSWORD` | `database.dbUser.password` |
  | `DATABASE_ROOT_USERNAME` | `database.rootUser.username` |
  | `DATABASE_ROOT_PASSWORD` | `database.rootUser.password` |
  | `DATABASE_URL` | `database.url` |
  | `FUSIONAUTH_APP_MEMORY` | `fusionauth.app.memory` |
  | `FUSIONAUTH_APP_RUNTIME_MODE` | `fusionauth.app.runtimeMode` |
  | `FUSIONAUTH_APP_SILENT_MODE` | `fusionauth.app.silentMode` |
  | `FUSIONAUTH_APP_KICKSTART_FILE` | `kickstart.file` |
  | `SEARCH_TYPE` | `search.engine` |
  | `SEARCH_SERVERS` | `search.host`<br/>`search.protocol`<br/>`search.port` |
  | `SEARCH_USERNAME` | `search.basicAuth.username` |
  | `SEARCH_PASSWORD` | `search.basicAuth.password` |

- **Chart-managed database secrets have changed.**
  - If you are using `existingSecret` to store passwords, this does not affect you.
  - If you are not using `existingSecret`, we recommend that you do, as storing passwords
    in clear text in the values file is not secure. If you continue to store passwords in
    the values file, you will be impacted by these changes.
    - The previous secret `<release-name>-credentials` is no longer created or used by
      the chart. Instead, the chart creates two new secrets:
      - `<release-name>-db-credentials` contains the password from `database.dbUser.password`.
      - `<release-name>-db-root-credentials` contains the password from `database.rootUser.password`.

#### Recommended Migrations

There are additional changes to the values, but these changes include compatibility
shims to give you time to migrate. It's recommended to migrate to the new values
as soon as possible, as the compatibility shims will be removed in a future chart release.

- **Values for `database` credentials have been updated.**

  If you are using `existingSecret` to store the database passwords (recommended):

  ```yaml
  # Old values
  database:
    user: fusionauth # name of the database user
    existingSecret: fusionauth-db-creds # name of the k8s Secret
    root:
      user: postgres # name of the root user

  # New values
  database:
    dbUser:
      username: fusionauth # name of the database user
      existingSecret:
        enabled: true
        name: fusionauth-db-creds # name of the k8s Secret
        passwordKey: password # name of the key that stores the password
    rootUser:
      username: postgres # name of the root user
      existingSecret:
        enabled: true
        name: fusionauth-root-creds # name of the k8s Secret
        passwordKey: password # name of the key that stores the root password
  ```

  If you are storing the database passwords in clear text (NOT recommended):

  ```yaml
  # Old values
  database:
    user: fusionauth
    password: password
    root:
      user: postgres
      password: password

  # New values
  database:
    dbUser:
      username: fusionauth
      password: password
    rootUser:
      username: postgres
      password: password
  ```

  📝 Whether you use the new shape or not, if you are not using `existingSecret`,
  the chart will now create separate Secrets for the database user and the root
  user, instead of putting both passwords into a single secret.

- `initContainers.waitForEs` renamed to `initContainers.waitForSearch`

- Values for `search` credentials have changed.
  - A `basicAuth` key was added to prepare for support of other credential types in the future.
  - `search.basicAuth` now supports `existingSecret`.

  ```yaml
  # Old values
  search:
    user: username # name of the search user
    password: password # password for the search user

  # New values
  search:
    basicAuth:
      enabled: true
      username: username
      password: password

  # New values with existingSecret
  search:
    basicAuth:
      existingSecret:
        enabled: true
        name: fusionauth-search-creds
        userKey: username
        passwordKey: password
  ```

### 1.57.1

- **The chart version now matches the FusionAuth app version.**

  ⚠️ You can (and probably should) override the `image.tag` field in `values.yaml` to pin the desired version of the FusionAuth application. This ensures that upgrading the helm chart doesn't unexpectedly upgrade the FusionAuth version.

### 1.0.0

- **The FusionAuth app version will now default to the latest available at the time of the chart's release.** Release notes will indicate the FusionAuth version included in the chart.

  ⚠️ You can (and probably should) override the `image.tag` field in `values.yaml` to pin the desired version of the FusionAuth application. This ensures that upgrading the helm chart doesn't unexpectedly upgrade the FusionAuth version.

### 0.8.0

- **The `environment` value is now an array instead of an object.** Make sure to reformat your values when you update.

### 0.4.0

- **The external postgresql and elasticsearch charts were dropped.** You will need to maintain those dependencies on your own.

## Installing the Chart

You can read the official instructions, including install steps for AWS, GCP, and Azure, in the [FusionAuth Kubernetes installation guide](https://fusionauth.io/docs/get-started/download-and-install/kubernetes/fusionauth-deployment).

### Prerequisites

- PostgreSQL or MySQL database
- ElasticSearch or OpenSearch instance (optional)

⚠️ Though an ElasticSearch or OpenSearch instance is optional, it is strongly recommended for most use cases.

### Installation

To install the chart with the release name `fusionauth`:

```shell
helm repo add fusionauth https://fusionauth.github.io/charts
helm install fusionauth fusionauth/fusionauth \
  --set database.host=[database host] \
  --set database.dbUser.username=[database username] \
  --set database.dbUser.password=[database password] \
  --set search.host=[elasticsearch host]
```

## Setting Up a Test Deployment

This will install FusionAuth and its prerequisites in a single kubernetes namespace, with a configuration suitable for evaluation and testing. **This configuration is not suitable for production.**

Create and switch to the test namespace.

```shell
kubectl create namespace fusionauth-test
kubectl config set-context --current --namespace=fusionauth-test
```

### Install PostgreSQL

```shell
helm install postgres oci://registry-1.docker.io/bitnamicharts/postgresql
```

### Install Opensearch

Opensearch is optional, but highly recommended. See the note below.

```shell
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm install opensearch opensearch/opensearch \
--set singleNode=true \
--set-json 'extraEnvs=[{"name":"DISABLE_SECURITY_PLUGIN","value":"true"}]'
```

### Install FusionAuth

Wait for the Postgres and Opensearch pods to be ready, then install FusionAuth.

```shell
export FA_PSQL_PASS=$(kubectl get secret postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
helm repo add fusionauth https://fusionauth.github.io/charts
helm install fusionauth fusionauth/fusionauth \
--set database.host=postgres-postgresql \
--set database.dbUser.username=fusionauth \
--set database.dbUser.password=$FA_PSQL_PASS \
--set search.host=opensearch-cluster-master
```

📝 For test deployments, you can remove `--set search.host` and add `--set search.engine=database` to configure FusionAuth to use the database for search instead of a dedicated search host. This is **not recommended** for real-world use, as search performance will be greatly reduced.

### Connect to FusionAuth

Create a port forward to connect to the FusionAuth app.

```shell
kubectl port-forward svc/fusionauth 9011:9011
```

You should now be able to connect to the FusionAuth application at http://localhost:9011 to start the initial setup.

📝 You may wish to set up an ingress instead of using a port forward. See the table below for how to configure the FusionAuth chart values to add an ingress.

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Define affinity for kubernetes to use when scheduling fusionauth pods. |
| annotations | object | `{}` | Define annotations for fusionauth deployment. |
| app | object | `{"memory":"256M","runtimeMode":"development","silentMode":false}` | Configures general settings for the fusionauth application |
| app.memory | string | `"256M"` | Configures the amount of memory Java can use |
| app.runtimeMode | string | `"development"` | Configures runtime mode for fusionauth. Should be 'development' or 'production' learn more about the difference here: https://fusionauth.io/docs/v1/tech/reference/configuration |
| app.silentMode | bool | `false` | Configures silent mode for fusionauth. Should be 'true' or 'false' learn more about silent mode here: https://fusionauth.io/docs/get-started/download-and-install/silent-mode silent-mode minimizes downtime during upgrades: https://fusionauth.io/docs/operate/deploy/upgrade#downtime-and-database-migrations |
| autoscaling | object | `{"enabled":false,"maxReplicas":5,"minReplicas":2,"targetCPU":50}` | Configures Horizontal Pod Autoscaling. If you enable autoscaling, you will need to also set resource requests for the corresponding targets. |
| autoscaling.enabled | bool | `false` | Enable Horizontal Pod Autoscaling. |
| autoscaling.maxReplicas | int | `5` | Maximum number of running instances when HPA is enabled. |
| autoscaling.minReplicas | int | `2` | Minimum number of running instances when HPA is enabled. |
| autoscaling.targetCPU | int | `50` | CPU use % threshold to trigger a HPA scale up. |
| database | object | `{"dbUser":{"existingSecret":{"enabled":false,"name":"","passwordKey":"password"},"password":"","username":""},"host":"","name":"fusionauth","port":5432,"protocol":"postgresql","rootUser":{"existingSecret":{"enabled":false,"name":"","passwordKey":"password"},"password":"","username":""},"tls":false,"tlsMode":"require","url":""}` | Configures the database connection for fusionauth |
| database.dbUser | object | `{"existingSecret":{"enabled":false,"name":"","passwordKey":"password"},"password":"","username":""}` | Database credentials for fusionauth to use in normal operation |
| database.dbUser.existingSecret | object | `{"enabled":false,"name":"","passwordKey":"password"}` | Configures an existing secret that contains the normal database user password. |
| database.dbUser.existingSecret.enabled | bool | `false` | Use an existing secret for the normal database user password. |
| database.dbUser.existingSecret.name | string | `""` | The name of an existing secret that contains the normal database user password. |
| database.dbUser.existingSecret.passwordKey | string | `"password"` | The key in the existing secret that contains the database password. |
| database.dbUser.password | string | `""` | Database password for fusionauth to use in normal operation. It is not recommended to set the password in clear text here. Use an existing secret instead. |
| database.dbUser.username | string | `""` | Database username for fusionauth to use in normal operation. |
| database.host | string | `""` | Hostname or ip of the database instance. Required by the wait-for-db init container even when database.url is set. |
| database.name | string | `"fusionauth"` | Name of the fusionauth database |
| database.port | int | `5432` | Port of the database instance. Required by the wait-for-db init container even when database.url is set. |
| database.protocol | string | `"postgresql"` | Protocol for jdbc connection to database [`postgresql|mysql`]. |
| database.rootUser | object | `{"existingSecret":{"enabled":false,"name":"","passwordKey":"password"},"password":"","username":""}` | Database credentials for fusionauth to use during initial bootstrap |
| database.rootUser.existingSecret | object | `{"enabled":false,"name":"","passwordKey":"password"}` | Configures an existing secret that contains the root database user password. |
| database.rootUser.existingSecret.enabled | bool | `false` | Use an existing secret for the root database user password. |
| database.rootUser.existingSecret.name | string | `""` | The name of an existing secret that contains the root database user password. |
| database.rootUser.existingSecret.passwordKey | string | `"password"` | The key in the existing secret that contains the root database password. |
| database.rootUser.password | string | `""` | Database password for fusionauth to use during initial bootstrap It is not recommended to set the password in clear text here. Use an existing secret instead. |
| database.rootUser.username | string | `""` | Database username for fusionauth to use during initial bootstrap |
| database.tls | bool | `false` | Configures whether or not to use tls when connecting to the database |
| database.tlsMode | string | `"require"` | If tls is enabled, this configures the mode |
| database.url | string | `""` | Optional full JDBC URL. When set, this value is used for DATABASE_URL instead of building it from protocol, host, port, name, tls, and tlsMode. |
| dnsConfig | object | `{}` | Define dnsConfig for fusionauth pods. |
| dnsPolicy | string | `"ClusterFirst"` | Define dnsPolicy for fusionauth pods. |
| environment | list | `[]` | Configure additional environment variables. Should only be used for things that are not explicitly set elsewhere in the chart. |
| extraContainers | list | `[]` | Add specs for additional containers if needed. |
| extraInitContainers | list | `[]` | Add specs for additional init containers if needed. |
| extraObjects | list | `[]` | Additional Kubernetes objects to deploy with the chart. Values are rendered with Helm templating support. |
| extraVolumeMounts | list | `[]` | Associate mountPath for each extraVolumes |
| extraVolumes | list | `[]` | Define extra Volumes. Allow to add existing claimName |
| fullnameOverride | string | `""` | Overrides full resource names |
| gateway | object | `{"annotations":{},"enabled":false,"hostnames":[],"labels":{},"parentRefs":[],"rules":[]}` | Configures a Gateway API HTTPRoute for FusionAuth. GatewayClass and Gateway resources are not created by this chart. |
| gateway.annotations | object | `{}` | Configure annotations to add to the HTTPRoute object. |
| gateway.enabled | bool | `false` | Enables creation of an HTTPRoute. |
| gateway.hostnames | list | `[]` | Hostnames to match for the HTTPRoute. When empty, hostnames are not restricted by the route. |
| gateway.labels | object | `{}` | Configure labels to add to the HTTPRoute object. |
| gateway.parentRefs | list | `[]` | Parent Gateway references for the HTTPRoute. Required when gateway.enabled is true. |
| gateway.rules | list | `[]` | HTTPRoute rules. Each rule routes to the FusionAuth service HTTP port. When empty, a default PathPrefix / rule is used. |
| global | object | `{"imageRegistry":""}` | Global values shared across chart images. |
| global.imageRegistry | string | `""` | Optional registry override applied to chart-managed images when image-specific registry values are not set. |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"","repository":"docker.io/fusionauth/fusionauth-app","tag":"0.0.0-app-dev"}` | Configures the docker image to use for fusionauth-app |
| image.pullPolicy | string | `"IfNotPresent"` | Kubernetes image pullPolicy to use for fusionauth-app |
| image.registry | string | `""` | Optional registry override for fusionauth-app. When set, this replaces any registry included in image.repository. |
| image.repository | string | `"docker.io/fusionauth/fusionauth-app"` | The name of the docker repository for fusionauth-app |
| image.tag | string | `"0.0.0-app-dev"` | The docker tag to pull for fusionauth-app |
| imagePullSecrets | list | `[]` | Configures kubernetes secrets to use for pulling private images |
| ingress | object | `{"annotations":{},"enabled":false,"extraPaths":[],"hosts":[],"ingressClassName":null,"paths":[],"tls":[]}` | Configures ingress for FusionAuth. |
| ingress.annotations | object | `{}` | Configure annotations to add to the ingress object |
| ingress.enabled | bool | `false` | Enables ingress creation for fusionauth. |
| ingress.extraPaths | list | `[]` | Define complete path objects, will be inserted before regular paths. Can be useful for things like ALB Ingress Controller actions |
| ingress.hosts | list | `[]` | List of hostnames to configure the ingress with |
| ingress.ingressClassName | string/null | null | Specify the ingressClass to be used by the Ingress. The kubernetes.io/ingress.class annotation is deprecated as of networking.k8s.io/v1 or Kubernetes 1.22+. |
| ingress.paths | list | `[]` | Paths to be used by the Ingress. |
| ingress.tls | list | `[]` | List of secrets used to configure TLS for the ingress. |
| initContainers | object | `{"image":{"registry":"","repository":"docker.io/library/busybox","tag":"1.36.1"},"resources":{},"waitForDb":true,"waitForSearch":true}` | Configures init containers for fusionauth pods. Init containers are used to wait for the database and search engine to be ready before starting fusionauth. |
| initContainers.image | object | `{"registry":"","repository":"docker.io/library/busybox","tag":"1.36.1"}` | Configures the docker image to use for init containers. |
| initContainers.image.registry | string | `""` | Optional registry override for init containers. When set, this replaces any registry included in initContainers.image.repository. |
| initContainers.image.repository | string | `"docker.io/library/busybox"` | Docker image to use for initContainers. This image must contain `nc`, `wget` and a shell of some kind to do a simple loop. |
| initContainers.image.tag | string | `"1.36.1"` | Tag to use for initContainers docker image |
| initContainers.resources | object | `{}` | It is recommended to set these values when you understand FusionAuth's resource usage in your specific environment. |
| initContainers.waitForDb | bool | `true` | waits for the database to be ready. Setting this to `false` is not recommended. |
| initContainers.waitForSearch | bool | `true` | waits for the search engine to be ready. Setting this to `false` is not recommended. |
| kickstart | object | `{"data":{},"enabled":false,"file":"/kickstart/kickstart.json"}` | Configures kickstart for initial application setup |
| kickstart.data | object | `{}` | FusionAuth kickstart settings. |
| kickstart.enabled | bool | `false` | Enable kickstart for initial application setup. |
| kickstart.file | string | `"/kickstart/kickstart.json"` | File path FusionAuth should use for kickstart configuration. |
| lifecycle | object | `{}` | Define custom lifecycle settings for the deployment. |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":30,"timeoutSeconds":5}` | Configures a livenessProbe to ensure fusionauth is running |
| livenessProbe.failureThreshold | int | `3` | Failure threshold for the liveness probe. |
| livenessProbe.httpGet | object | `{"path":"/","port":"http"}` | Configures the liveness probe HTTP endpoint. |
| livenessProbe.httpGet.path | string | `"/"` | Path used for the liveness probe. |
| livenessProbe.httpGet.port | string | `"http"` | Port used for the liveness probe. |
| livenessProbe.periodSeconds | int | `30` | Period in seconds between liveness probe checks. |
| livenessProbe.timeoutSeconds | int | `5` | Timeout in seconds for the liveness probe. |
| nameOverride | string | `""` | Overrides resource names |
| networkPolicy | object | `{"egress":[],"enabled":false,"ingress":null,"policyTypes":["Ingress"]}` | Configures NetworkPolicy for FusionAuth pods. By default, no NetworkPolicy is created. |
| networkPolicy.egress | list | `[]` | Egress rules for the NetworkPolicy. Egress is not restricted unless policyTypes includes Egress. When policyTypes includes Egress, set custom rules here to allow required outbound traffic such as database, search, and DNS connections. |
| networkPolicy.enabled | bool | `false` | Enables creation of a NetworkPolicy. When enabled with the default values, ingress to the FusionAuth HTTP port is allowed from any source and egress is not restricted. |
| networkPolicy.ingress | list/null | null | Ingress rules for the NetworkPolicy. The default null value renders an allow rule for TCP traffic to the FusionAuth HTTP port from any source. Set to an empty list to deny all ingress traffic, or provide custom rules to limit which pods or namespaces can reach FusionAuth. |
| networkPolicy.policyTypes | list | `["Ingress"]` | NetworkPolicy policy types to apply. |
| nodeSelector | object | `{}` | Define nodeSelector for kubernetes to use when scheduling fusionauth pods. |
| podAnnotations | object | `{}` | Define annotations for fusionauth pods. |
| podDisruptionBudget | object | `{"enabled":false,"maxUnavailable":null,"minAvailable":null}` | Configures the PodDisruptionBudget for FusionAuth pods. |
| podDisruptionBudget.enabled | bool | `false` | Enables creation of a PodDisruptionBudget |
| podDisruptionBudget.maxUnavailable | int/string/null | null | Maximum number of unavailable pods. Cannot be used with minAvailable. Defaults to replicaCount - 1. |
| podDisruptionBudget.minAvailable | int/string/null | null | Minimum number of available pods. Cannot be used with maxUnavailable. |
| podLabels | object | `{}` | Define labels for fusionauth pods. |
| podSecurityContext | object | `{}` | Security context for the pod. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| readinessProbe | object | `{"failureThreshold":5,"httpGet":{"path":"/","port":"http"},"timeoutSeconds":5}` | Configures a readinessProbe to ensure fusionauth is ready for requests |
| readinessProbe.failureThreshold | int | `5` | Failure threshold for the readiness probe. |
| readinessProbe.httpGet | object | `{"path":"/","port":"http"}` | Configures the readiness probe HTTP endpoint. |
| readinessProbe.httpGet.path | string | `"/"` | Path used for the readiness probe. |
| readinessProbe.httpGet.port | string | `"http"` | Port used for the readiness probe. |
| readinessProbe.timeoutSeconds | int | `5` | Timeout in seconds for the readiness probe. |
| replicaCount | int | `1` | The number of fusionauth-app instances to run |
| resources | object | `{}` | Define resource requests and limits for fusionauth-app. It is recommended to set these values when you understand FusionAuth's resource usage in your specific environment. |
| search | object | `{"basicAuth":{"enabled":false,"existingSecret":{"enabled":false,"name":"","passwordKey":"password","userKey":"username"},"password":"","username":""},"engine":"elasticsearch","host":"","port":9200,"protocol":"http"}` | Configures the search engine for fusionauth |
| search.basicAuth | object | `{"enabled":false,"existingSecret":{"enabled":false,"name":"","passwordKey":"password","userKey":"username"},"password":"","username":""}` | Configures elasticsearch basic auth credentials. Ignored when search.engine is NOT elasticsearch. |
| search.basicAuth.enabled | bool | `false` | Enables elasticsearch basic auth using inline username/password. Not required when search.basicAuth.existingSecret.enabled is true. |
| search.basicAuth.existingSecret | object | `{"enabled":false,"name":"","passwordKey":"password","userKey":"username"}` | Configures an existing secret that contains elasticsearch basic auth credentials. |
| search.basicAuth.existingSecret.enabled | bool | `false` | Use an existing secret for elasticsearch basic auth credentials. |
| search.basicAuth.existingSecret.name | string | `""` | The name of an existing secret that contains elasticsearch basic auth credentials. |
| search.basicAuth.existingSecret.passwordKey | string | `"password"` | The key in search.basicAuth.existingSecret.name that contains the elasticsearch password. |
| search.basicAuth.existingSecret.userKey | string | `"username"` | The key in search.basicAuth.existingSecret.name that contains the elasticsearch username. |
| search.basicAuth.password | string | `""` | Password to use with elasticsearch basic auth. Ignored when search.basicAuth.existingSecret.enabled is true. |
| search.basicAuth.username | string | `""` | Username to use with elasticsearch basic auth. Ignored when search.basicAuth.existingSecret.enabled is true. |
| search.engine | string | `"elasticsearch"` | Defines backend for fusionauth search capabilities. Valid values for engine are 'elasticsearch' or 'database'. |
| search.host | string | `""` | Hostname or ip to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch |
| search.port | int | `9200` | Port to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch |
| search.protocol | string | `"http"` | Protocol to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch |
| securityContext | object | `{}` | Security context for the fusionauth container. Ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| service | object | `{"annotations":{},"port":9011,"type":"ClusterIP"}` | Configures the Kubernetes service for FusionAuth. |
| service.annotations | object | `{}` | Extra annotations to add to service object |
| service.port | int | `9011` | Port for the Kubernetes service to expose |
| service.type | string | `"ClusterIP"` | Type of Kubernetes service to create |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":false,"name":""}` | Configures the Kubernetes service account for FusionAuth pods. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor | object | `{"annotations":{},"basicAuth":{},"enabled":false,"interval":null,"labels":{},"namespaceSelector":{},"path":"/api/prometheus/metrics","relabelings":[],"scrapeTimeout":null}` | Configures a Prometheus operator ServiceMonitor custom resource Ref: https://fusionauth.io/docs/v1/tech/tutorials/prometheus |
| serviceMonitor.annotations | object | `{}` | Annotations to add to the ServiceMonitor object. |
| serviceMonitor.basicAuth | object | `{}` | Configures basic auth for prometheus, this is required for the serviceMonitor to work with FusionAuth because metrics sit behind an authenticated endpoint |
| serviceMonitor.enabled | bool | `false` | Enables creation of a ServiceMonitor |
| serviceMonitor.interval | string/null | null | Interval at which Prometheus should scrape metrics. |
| serviceMonitor.labels | object | `{}` | Labels to add to the ServiceMonitor object. |
| serviceMonitor.namespaceSelector | object | `{}` | Namespace selector for the ServiceMonitor. |
| serviceMonitor.path | string | `"/api/prometheus/metrics"` | Configures path to metrics, defaults to FusionAuth's prometheus metrics API endpoint |
| serviceMonitor.relabelings | list | `[]` | Relabeling rules for the ServiceMonitor endpoint. |
| serviceMonitor.scrapeTimeout | string/null | null | Timeout for Prometheus metric scrapes. |
| startupProbe | object | `{"failureThreshold":20,"httpGet":{"path":"/","port":"http"},"periodSeconds":10,"timeoutSeconds":5}` | Configures a startupProbe to ensure fusionauth has finished starting up |
| startupProbe.failureThreshold | int | `20` | Failure threshold for the startup probe. |
| startupProbe.httpGet | object | `{"path":"/","port":"http"}` | Configures the startup probe HTTP endpoint. |
| startupProbe.httpGet.path | string | `"/"` | Path used for the startup probe. |
| startupProbe.httpGet.port | string | `"http"` | Port used for the startup probe. |
| startupProbe.periodSeconds | int | `10` | Period in seconds between startup probe checks. |
| startupProbe.timeoutSeconds | int | `5` | Timeout in seconds for the startup probe. |
| tolerations | list | `[]` | Define tolerations for kubernetes to use when scheduling fusionauth pods. |
| topologySpreadConstraints | list | `[]` | Define topologySpreadConstraints for kubernetes to use when scheduling fusionauth pods. |
