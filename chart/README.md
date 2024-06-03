# FusionAuth Helm Chart

![Build Status](https://github.com/FusionAuth/charts/actions/workflows/release.yml/badge.svg)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting, and much more.

## Installing the Chart

You can read the official instructions, including install steps for AWS, GCP, and Azure, in the [FusionAuth Kubernetes installation guide](https://fusionauth.io/docs/get-started/download-and-install/kubernetes/fusionauth-deployment).

### Prerequisites

* PostgreSQL or MySQL database
* ElasticSearch or OpenSearch instance (optional)

⚠️ Though an ElasticSearch or OpenSearch instance is optional, it is strongly recommended for most use cases.

### Installation

To install the chart with the release name `my-fusionauth`:

```console
$ helm repo add fusionauth https://fusionauth.github.io/charts
$ helm install my-fusionauth fusionauth/fusionauth \
  --set database.host=[database host] \
  --set database.user=[database username] \
  --set database.password=[database password] \
  --set search.host=[elasticsearch host]
```

📝 For test deployments, you can remove `--set search.host` and add `--set search.engine=database` to configure FusionAuth to use the database for search instead of a dedicated search host. This is **not recommended** for real-world use, as search performance will be greatly reduced.

### Uninstallation

To uninstall/delete the `my-fusionauth` release:

```console
$ helm delete my-fusionauth
```

## Versions

The helm chart is versioned independently from FusionAuth app releases. However, the latest version of the helm chart will default to the latest version of FusionAuth.

📝 You can and probably should override the `image.tag` field in `values.yaml` to run your desired version of the FusionAuth application.

## Important Upgrade Info

* **In `1.0.0` and later, the FusionAuth app version will now default to the latest available.** Release notes will indicate if the chart includes a newer version of FusionAuth. If you wish to override this behavior, set `image.tag` when deploying.

* **In `0.8.0`, the `environment` value is now an array instead of an object.** Make sure to reformat your values when you update.

* **In `0.4.0`, the external postgresql and elasticsearch charts were dropped.** You will need to maintain those dependencies on your own.

## Chart Values

| Key                             | Type   | Default                                                                                              | Description                                                                                                                      |
| ------------------------------- | ------ | ---------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| affinity                        | object | `{}`                                                                                                 | Configure affinity rules for the fusionauth Deployment.                                                                          |
| annotations                     | object | `{}`                                                                                                 | Define annotations for fusionauth Deployment.                                                                                    |
| app.memory                      | string | `"256M"`                                                                                             | Configures the amount of memory to allocate to the Java VM (sets `FUSIONAUTH_APP_MEMORY`).                                       |
| app.runtimeMode                 | string | `"development"`                                                                                      | Configures runtime mode (sets `FUSIONAUTH_APP_RUNTIME_MODE`). Must be `development` or `production`.                             |
| app.silentMode                  | bool   | `false`                                                                                              | Configures silent mode (sets `FUSIONAUTH_APP_SILENT_MODE`). Must be `true` or `false`.                                           |
| autoscaling.enabled             | bool   | `false`                                                                                              | Enable Horizontal Pod Autoscaling. See the values file for more HPA parameters.                                                  |
| autoscaling.minReplicas         | int    | `2`                                                                                                  | Minimum number of running instances when HPA is enabled. Ignored when `autoscaling.enabled` is `false`.                          |
| autoscaling.maxReplicas         | int    | `5`                                                                                                  | Maximum number of running instances when HPA is enabled. Ignored when `autoscaling.enabled` is `false`.                          |
| autoscaling.targetCPU           | int    | `50`                                                                                                 | CPU use % threshold to trigger a HPA scale up. Ignored when `autoscaling.enabled` is `false`.                                    |
| database.existingSecret         | string | `""`                                                                                                 | The name of an existing Kubernetes Secret that contains the database passwords.                                                  |
| database.host                   | string | `""`                                                                                                 | Hostname or IP address of the fusionauth database.                                                                               |
| database.name                   | string | `"fusionauth"`                                                                                       | Name of the fusionauth database.                                                                                                 |
| database.password               | string | `""`                                                                                                 | Database password for fusionauth to use in normal operation - not required if `database.existingSecret` is configured.           |
| database.port                   | int    | `5432`                                                                                               | Port used by the fusionauth database.                                                                                            |
| database.protocol               | string | `"postgresql"`                                                                                       | Should either be `postgresql` or `mysql`. Protocol for jdbc connection to database.                                              |
| database.root.password          | string | `""`                                                                                                 | Database password for fusionauth to use during initial bootstrap - not required if `database.existingSecret` is configured.      |
| database.root.user              | string | `""`                                                                                                 | Database username for fusionauth to use during initial bootstrap - not required if you have manually bootstrapped your database. |
| database.tls                    | bool   | `false`                                                                                              | Configures whether or not to use tls when connecting to the database.                                                            |
| database.tlsMode                | string | `"require"`                                                                                          | If tls is enabled, this configures the mode.                                                                                     |
| database.user                   | string | `""`                                                                                                 | Database username for fusionauth to use in normal operation.                                                                     |
| dnsConfig                       | object | `{}`                                                                                                 | Define `dnsConfig` for fusionauth pods.                                                                                          |
| dnsPolicy                       | string | `"ClusterFirst"`                                                                                     | Define `dnsPolicy` for fusionauth pods.                                                                                          |
| environment                     | list   | `[]`                                                                                                 | Configure additional environment variables.                                                                                      |
| extraVolumeMounts               | list   | `[]`                                                                                                 | Define mount paths for `extraVolumes`.                                                                                           |
| extraContainers                 | list   | `[]`                                                                                                 | Create containers for the pods. Can be used for sidecars, ambassador, and adapter patterns.                                      |
| extraInitContainers             | list   | `[]`                                                                                                 | Add extra init containers. Can be used for setup or wait for other dependent services.                                           |
| extraVolumes                    | list   | `[]`                                                                                                 | Define extra volumes to mount in the deployment.                                                                                 |
| fullnameOverride                | string | `""`                                                                                                 | Overrides full resource names.                                                                                                   |
| image.pullPolicy                | string | `"IfNotPresent"`                                                                                     | Kubernetes image pullPolicy to use for fusionauth-app.                                                                           |
| image.repository                | string | `"fusionauth/fusionauth-app"`                                                                        | The image repository to use for fusionauth-app.                                                                                  |
| image.tag                       | string | `"${APP_VERSION}"`                                                                                   | The image tag to pull for fusionauth-app (this is the fusionauth-app version).                                                   |
| imagePullSecrets                | list   | `[]`                                                                                                 | Configures Kubernetes secrets to use for pulling images from private repositories.                                               |
| ingress.annotations             | object | `{}`                                                                                                 | Configure annotations to add to the ingress object.                                                                              |
| ingress.enabled                 | bool   | `false`                                                                                              | Enables ingress creation for fusionauth.                                                                                         |
| ingress.extraPaths              | list   | `[]`                                                                                                 | Define path objects which will be inserted before regular paths. Can be useful for things like ALB Ingress Controller actions.   |
| ingress.hosts                   | list   | `[]`                                                                                                 | List of hostnames to configure the ingress with.                                                                                 |
| ingress.ingressClassName        | string | `""`                                                                                                 | Specify the `ingressClass` to be used by the Ingress.                                                                            |
| ingress.paths                   | list   | `[]`                                                                                                 | Paths to be used by the Ingress.                                                                                                 |
| ingress.tls                     | list   | `[]`                                                                                                 | List of secrets used to configure TLS for the ingress.                                                                           |
| initContainers.waitForDb        | bool   | `true`                                                                                               | Create an init container which waits for the database to be ready.                                                               |
| initContainers.waitForEs        | bool   | `true`                                                                                               | Create an init container which waits for elasticsearch to be ready.                                                              |
| initContainers.image.repository | string | `"busybox"`                                                                                          | Image to use for `initContainers` docker image.                                                                                  |
| initContainers.image.tag        | string | `"1.36.1"`                                                                                           | Tag to use for `initContainers` docker image.                                                                                    |
| initContainers.resources        | object | `{}`                                                                                                 | Resource requests and limits to use for `initContainers`.                                                                        |
| kickstart.data                  | object | `{}`                                                                                                 | Fusionauth [kickstart settings](https://fusionauth.io/docs/get-started/download-and-install/development/kickstart).              |
| kickstart.enabled               | bool   | `false`                                                                                              | Enable fusionauth kickstart settings.                                                                                            |
| lifecycle                       | object | `{}`                                                                                                 | Define custom `lifecycle` settings for the deployment.                                                                           |
| livenessProbe                   | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":30,"timeoutSeconds":5}`  | Configures a `livenessProbe` to ensure fusionauth is running.                                                                    |
| nameOverride                    | string | `""`                                                                                                 | Overrides resource names.                                                                                                        |
| nodeSelector                    | object | `{}`                                                                                                 | Define `nodeSelector` for kubernetes to use when scheduling fusionauth pods.                                                     |
| podAnnotations                  | object | `{}`                                                                                                 | Define `annotations` for fusionauth pods.                                                                                        |
| podDisruptionBudget.enabled     | bool   | `false`                                                                                              | Enables creation of a `PodDisruptionBudget`.                                                                                     |
| readinessProbe                  | object | `{"failureThreshold":5,"httpGet":{"path":"/","port":"http"},"timeoutSeconds":5}`                     | Configures a `readinessProbe` to ensure fusionauth is ready for requests.                                                        |
| replicaCount                    | int    | `1`                                                                                                  | The number of fusionauth-app instances to run.                                                                                   |
| resources                       | object | `{}`                                                                                                 | Define resource requests and limits for fusionauth-app.                                                                          |
| search.engine                   | string | `"elasticsearch"`                                                                                    | Protocol to use when connecting to elasticsearch. Ignored when `search.engine` is NOT `elasticsearch`.                           |
| search.host                     | string | `""`                                                                                                 | Hostname or ip to use when connecting to elasticsearch. Ignored when `search.engine` is NOT `elasticsearch`.                     |
| search.port                     | int    | `9200`                                                                                               | Port to use when connecting to elasticsearch. Ignored when `search.engine` is NOT `elasticsearch`.                               |
| search.protocol                 | string | `"http"`                                                                                             | Protocol to use when connecting to elasticsearch. Ignored when `search.engine` is NOT `elasticsearch`.                           |
| service.annotations             | object | `{}`                                                                                                 | Extra annotations to add to the service object.                                                                                  |
| service.port                    | int    | `9011`                                                                                               | Port for the Kubernetes service to expose.                                                                                       |
| service.spec                    | object | `{}`                                                                                                 | Any extra fields to add to the service object spec.                                                                              |
| service.type                    | string | `"ClusterIP"`                                                                                        | Type of Kubernetes service to create.                                                                                            |
| serviceAccount.annotations      | object | `{}`                                                                                                 | Extra annotations to add to the service account object.                                                                          |
| serviceAccount.automount        | bool   | `false`                                                                                              | Automatically mount a service account's API credentials.                                                                         |
| serviceAccount.create           | bool   | `false`                                                                                              | If set to `true`, service account will be created. Otherwise, the `default` serviceaccount will be used.                         |
| serviceAccount.name             | string | `""`                                                                                                 | The name of the service account to use. If not set and `create` is `true`, a name is generated using the fullname template.      |
| startupProbe                    | object | `{"failureThreshold":20,"httpGet":{"path":"/","port":"http"},"periodSeconds":10,"timeoutSeconds":5}` | Configures a `startupProbe` to ensure fusionauth has finished starting up.                                                       |
| tolerations                     | list   | `[]`                                                                                                 | Define `tolerations` for kubernetes to use when scheduling fusionauth pods.                                                      |
| topologySpreadConstraints       | list   | `[]`                                                                                                 | Define `topologySpreadConstraints` for kubernetes to use when scheduling fusionauth pods.                                        |
