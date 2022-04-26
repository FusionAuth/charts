# FusionAuth Helm Chart [![Build Status](https://travis-ci.org/FusionAuth/charts.svg?branch=master)](https://travis-ci.org/FusionAuth/charts)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting and much more.

### Notice
This repository is community maintained; and is provided to assist in your deployment and management of FusionAuth. Use of this software is not covered under the FusionAuth license agreement and is provided "as is" without warranty.  https://fusionauth.io/license

## Installing the Chart

### Important upgrade info:

In `0.8.0` the `environment` value is now an array instead of an object. Make sure to reformat your values when you update.

In `0.4.0`, the external postgresql and elasticsearch charts were dropped. You will need to maintain those dependencies on your own.

To install the chart with the release name `my-release`:

```console
$ helm repo add fusionauth https://fusionauth.github.io/charts
$ helm install my-release fusionauth/fusionauth
```

The command deploys FusionAuth.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Values

| Key                             | Type   | Default                                                                                              | Description                                                                                                                       |
| ------------------------------- | ------ | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| affinity                        | object | `{}`                                                                                                 |                                                                                                                                   |
| annotations                     | object | `{}`                                                                                                 | Define annotations for fusionauth deployment.                                                                                     |
| app.memory                      | string | `"256M"`                                                                                             | Configures runtime mode for fusionauth. Should be 'development' or 'production'                                                   |
| app.runtimeMode                 | string | `"development"`                                                                                      |                                                                                                                                   |
| autoscaling.enabled             | bool   | `false`                                                                                              |                                                                                                                                   |
| database.existingSecret         | string | `""`                                                                                                 | The name of an existing secret that contains the database passwords                                                               |
| database.host                   | string | `""`                                                                                                 | Port of the database instance                                                                                                     |
| database.name                   | string | `"fusionauth"`                                                                                       | Name of the fusionauth database                                                                                                   |
| database.password               | string | `""`                                                                                                 | Database password for fusionauth to use in normal operation - not required if database.existingSecret is configured               |
| database.port                   | int    | `5432`                                                                                               |                                                                                                                                   |
| database.protocol               | string | `"postgresql"`                                                                                       | Should either be postgresql or mysql. Protocol for jdbc connection to database                                                    |
| database.root.password          | string | `""`                                                                                                 | Database password for fusionauth to use during initial bootstrap - not required if database.existingSecret is configured          |
| database.root.user              | string | `""`                                                                                                 | Database username for fusionauth to use during initial bootstrap - not required if you have manually bootstrapped your database   |
| database.tls                    | bool   | `false`                                                                                              | Configures whether or not to use tls when connecting to the database                                                              |
| database.tlsMode                | string | `"require"`                                                                                          | If tls is enabled, this configures the mode                                                                                       |
| database.user                   | string | `""`                                                                                                 | Database username for fusionauth to use in normal operation                                                                       |
| dnsConfig                       | object | `{}`                                                                                                 | Define dnsConfig for fusionauth pods.                                                                                             |
| dnsPolicy                       | string | `"ClusterFirst"`                                                                                     | Define dnsPolicy for fusionauth pods.                                                                                             |
| environment                     | list   | `[]`                                                                                                 |                                                                                                                                   |
| extraVolumeMounts               | list   | `[]`                                                                                                 |                                                                                                                                   |
| extraVolumes                    | list   | `[]`                                                                                                 | Associate mountPath for each  extraVolumes                                                                                        |
| fullnameOverride                | string | `""`                                                                                                 | Overrides full resource names                                                                                                     |
| image.pullPolicy                | string | `"IfNotPresent"`                                                                                     | Kubernetes image pullPolicy to use for fusionauth-app                                                                             |
| image.repository                | string | `"fusionauth/fusionauth-app"`                                                                        | The docker tag to pull for fusionauth-app                                                                                         |
| image.tag                       | string | `"1.36.4"`                                                                                           |                                                                                                                                   |
| imagePullSecrets                | list   | `[]`                                                                                                 | Configures kubernetes secrets to use for pulling private images                                                                   |
| ingress.annotations             | object | `{}`                                                                                                 | Configure annotations to add to the ingress object                                                                                |
| ingress.enabled                 | bool   | `false`                                                                                              | Enables ingress creation for fusionauth.                                                                                          |
| ingress.extraPaths              | list   | `[]`                                                                                                 | Define complete path objects, will be inserted before regular paths. Can be useful for things like ALB Ingress Controller actions |
| ingress.hosts                   | list   | `[]`                                                                                                 | List of hostnames to configure the ingress with                                                                                   |
| ingress.paths                   | list   | `[]`                                                                                                 |                                                                                                                                   |
| ingress.tls                     | list   | `[]`                                                                                                 | List of secrets used to configure TLS for the ingress.                                                                            |
| initContainers.image.repository | string | `"busybox"`                                                                                          | Tag to use for initContainers docker image                                                                                        |
| initContainers.image.tag        | string | `"latest"`                                                                                           |                                                                                                                                   |
| initContainers.resources        | object | `{}`                                                                                                 | Resource requests and limits to use for initContainers                                                                            |
| kickstart.data                  | object | `{}`                                                                                                 |                                                                                                                                   |
| kickstart.enabled               | bool   | `false`                                                                                              |                                                                                                                                   |
| lifecycle                       | object | `{}`                                                                                                 |                                                                                                                                   |
| livenessProbe                   | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":30,"timeoutSeconds":5}`  | Configures a livenessProbe to ensure fusionauth is running                                                                        |
| nameOverride                    | string | `""`                                                                                                 | Overrides resource names                                                                                                          |
| nodeSelector                    | object | `{}`                                                                                                 | Define nodeSelector for kubernetes to use when scheduling fusionauth pods.                                                        |
| podAnnotations                  | object | `{}`                                                                                                 | Define annotations for fusionauth pods.                                                                                           |
| podDisruptionBudget.enabled     | bool   | `false`                                                                                              | Enables creation of a PodDisruptionBudget                                                                                         |
| readinessProbe                  | object | `{"failureThreshold":5,"httpGet":{"path":"/","port":"http"},"timeoutSeconds":5}`                     | Configures a readinessProbe to ensure fusionauth is ready for requests                                                            |
| replicaCount                    | int    | `1`                                                                                                  | The number of fusionauth-app instances to run                                                                                     |
| resources                       | object | `{}`                                                                                                 | Define resource requests and limits for fusionauth-app.                                                                           |
| search.engine                   | string | `"elasticsearch"`                                                                                    | Protocol to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch                                 |
| search.host                     | string | `""`                                                                                                 | Hostname or ip to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch                           |
| search.port                     | int    | `9200`                                                                                               | Port to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch                                     |
| search.protocol                 | string | `"http"`                                                                                             |                                                                                                                                   |
| service.annotations             | object | `{}`                                                                                                 | Extra annotations to add to service object                                                                                        |
| service.port                    | int    | `9011`                                                                                               | Port for the Kubernetes service to expose                                                                                         |
| service.spec                    | object | `{}`                                                                                                 | Any extra fields to add to the service object spec                                                                                |
| service.type                    | string | `"ClusterIP"`                                                                                        | Type of Kubernetes service to create                                                                                              |
| serviceAccount.create           | bool   | `false`                                                                                              | If set to `true` service account will be created. Otherwise, the default service account will be used                             |
| serviceAccount.name             | string | `""`                                                                                                 | Service account name to use. If not set the "default" service account will be used                                                |
| startupProbe                    | object | `{"failureThreshold":20,"httpGet":{"path":"/","port":"http"},"periodSeconds":10,"timeoutSeconds":5}` | Configures a startupProbe to ensure fusionauth has finished starting up                                                           |
| tolerations                     | list   | `[]`                                                                                                 | Define tolerations for kubernetes to use when scheduling fusionauth pods.                                                         |


## Releasing the Chart

You can release the chart by bumping the git tag:

```
cd <charts directory>
git tag 0.10.6
git push origin master --tags
```

To release to a new version of FusionAuth, update these 4 files:

```
README.md
chart/Chart.yaml
chart/examples/minikube/values.yaml
chart/values.yaml
```

with the new version number.
