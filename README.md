# FusionAuth Helm Chart [![K8s Best Practices](https://insights.fairwinds.com/v0/gh/drivenrole/charts/badge.svg)](https://insights.fairwinds.com/gh/drivenrole/charts)

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

| Key                         | Type   | Default                                                                                              | Description                                                                                                                                                                 |
| --------------------------- | ------ | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| affinity                    | object | `{}`                                                                                                 |                                                                                                                                                                             |
| annotations                 | object | `{}`                                                                                                 | Define annotations for fusionauth deployment.                                                                                                                               |
| app.memory                  | string | `"256M"`                                                                                             | Configures runtime mode for fusionauth. Should be 'development' or 'production'                                                                                             |
| app.runtimeMode             | string | `"development"`                                                                                      |                                                                                                                                                                             |
| database.existingSecret     | string | `""`                                                                                                 | The name of an existing secret that contains the database passwords                                                                                                         |
| database.host               | string | `""`                                                                                                 | Port of the database instance                                                                                                                                               |
| database.name               | string | `"fusionauth"`                                                                                       | Name of the fusionauth database                                                                                                                                             |
| database.password           | string | `""`                                                                                                 | Database password for fusionauth to use in normal operation - not required if database.existingSecret is configured                                                         |
| database.port               | int    | `5432`                                                                                               |                                                                                                                                                                             |
| database.protocol           | string | `"postgresql"`                                                                                       | Should either be postgresql or mysql. Protocol for jdbc connection to database                                                                                              |
| database.root.password      | string | `""`                                                                                                 | Database password for fusionauth to use during initial bootstrap - not required if database.existingSecret is configured or if you have manually bootstrapped your database |
| database.root.user          | string | `""`                                                                                                 | Database username for fusionauth to use during initial bootstrap - not required if you have manually bootstrapped your database                                             |
| database.tls                | bool   | `false`                                                                                              | Configures whether or not to use tls when connecting to the database                                                                                                        |
| database.tlsMode            | string | `"require"`                                                                                          | If tls is enabled, this configures the mode                                                                                                                                 |
| database.user               | string | `""`                                                                                                 | Database username for fusionauth to use in normal operation                                                                                                                 |
| dnsConfig                   | object | `{}`                                                                                                 | Define dnsConfig for fusionauth pods.                                                                                                                                       |
| dnsPolicy                   | string | `"ClusterFirst"`                                                                                     | Define dnsPolicy for fusionauth pods.                                                                                                                                       |
| environment                 | array  | `[]`                                                                                                 |                                                                                                                                                                             |
| fullnameOverride            | string | `""`                                                                                                 | Overrides full resource names                                                                                                                                               |
| image.pullPolicy            | string | `"IfNotPresent"`                                                                                     | Kubernetes image pullPolicy to use for fusionauth-app                                                                                                                       |
| image.repository            | string | `"fusionauth/fusionauth-app"`                                                                        | The docker tag to pull for fusionauth-app                                                                                                                                   |
| image.tag                   | string | `"1.26.1"`                                                                                           |                                                                                                                                                                             |
| imagePullSecrets            | list   | `[]`                                                                                                 | Configures kubernetes secrets to use for pulling private images                                                                                                             |
| ingress.annotations         | object | `{}`                                                                                                 | Configure annotations to add to the ingress object                                                                                                                          |
| ingress.enabled             | bool   | `false`                                                                                              | Enables ingress creation for fusionauth.                                                                                                                                    |
| ingress.extraPaths          | list   | `[]`                                                                                                 | Define complete path objects, will be inserted before regular paths. Can be useful for things like ALB Ingress Controller actions                                           |
| ingress.hosts               | list   | `[]`                                                                                                 | List of hostnames to configure the ingress with                                                                                                                             |
| ingress.paths               | list   | `[]`                                                                                                 |                                                                                                                                                                             |
| ingress.tls                 | list   | `[]`                                                                                                 | List of secrets used to configure TLS for the ingress.                                                                                                                      |
| initImage.repository        | string | `"busybox"`                                                                                          | Tag to use for initContainers docker image                                                                                                                                  |
| initImage.tag               | string | `"latest"`                                                                                           |                                                                                                                                                                             |
| kickstart.data              | object | `{}`                                                                                                 |                                                                                                                                                                             |
| kickstart.enabled           | bool   | `false`                                                                                              |                                                                                                                                                                             |
| lifecycle                   | object | `{}`                                                                                                 |                                                                                                                                                                             |
| livenessProbe               | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"periodSeconds":30,"timeoutSeconds":5}`  | Configures a livenessProbe to ensure fusionauth is running                                                                                                                  |
| nameOverride                | string | `""`                                                                                                 | Overrides resource names                                                                                                                                                    |
| nodeSelector                | object | `{}`                                                                                                 | Define nodeSelector for kubernetes to use when scheduling fusionauth pods.                                                                                                  |
| podAnnotations              | object | `{}`                                                                                                 | Define annotations for fusionauth pods.                                                                                                                                     |
| podDisruptionBudget.enabled | bool   | `false`                                                                                              | Enables creation of a PodDisruptionBudget                                                                                                                                   |
| readinessProbe              | object | `{"failureThreshold":5,"httpGet":{"path":"/","port":"http"},"timeoutSeconds":5}`                     | Configures a readinessProbe to ensure fusionauth is ready for requests                                                                                                      |
| replicaCount                | int    | `1`                                                                                                  | The number of fusionauth-app instances to run                                                                                                                               |
| resources                   | object | `{}`                                                                                                 | Define resource requests and limits for fusionauth-app.                                                                                                                     |
| search.engine               | string | `"elasticsearch"`                                                                                    | Protocol to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch                                                                           |
| search.host                 | string | `""`                                                                                                 | Hostname or ip to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch                                                                     |
| search.port                 | int    | `9200`                                                                                               | Port to use when connecting to elasticsearch. Ignored when search.engine is NOT elasticsearch                                                                               |
| search.protocol             | string | `"http"`                                                                                             |                                                                                                                                                                             |
| service.annotations         | object | `{}`                                                                                                 | Extra annotations to add to service object                                                                                                                                  |
| service.port                | int    | `9011`                                                                                               | Port for the Kubernetes service to expose                                                                                                                                   |
| service.spec                | object | `{}`                                                                                                 | Any extra fields to add to the service object spec                                                                                                                          |
| service.type                | string | `"ClusterIP"`                                                                                        | Type of Kubernetes service to create                                                                                                                                        |
| startupProbe                | object | `{"failureThreshold":20,"httpGet":{"path":"/","port":"http"},"periodSeconds":10,"timeoutSeconds":5}` | Configures a startupProbe to ensure fusionauth has finished starting up                                                                                                     |
| tolerations                 | list   | `[]`                                                                                                 | Define tolerations for kubernetes to use when scheduling fusionauth pods.                                                                                                   |


## How to Contribute to fustionauth/charts 

1. Fork this repository, develop and test your Chart changes. Remember to sign off your commits as described in the "Sign Your Work" chapter.
1. Ensure your Chart changes follow the [technical](#technical-requirements) and [documentation](#documentation-requirements) guidelines, described below.
1. Submit a pull request.

***NOTE***: In order to make testing and merging of PRs easier, please submit changes to multiple charts in separate PRs.

### Technical Requirements

* All Chart dependencies should also be submitted independently
* Must pass the linter (`helm lint`)
* Must successfully launch with default values (`helm install .`)
    * All pods go to the running state (or NOTES.txt provides further instructions if a required value is missing e.g. [minecraft](https://github.com/helm/charts/blob/master/stable/minecraft/templates/NOTES.txt#L3))
    * All services have at least one endpoint
* Must include source GitHub repositories for images used in the Chart
* Images should not have any major security vulnerabilities
* Must be up-to-date with the latest stable Helm/Kubernetes features
* Should follow Kubernetes best practices
    * Include Health Checks wherever practical
    * Allow configurable [resource requests and limits](http://kubernetes.io/docs/user-guide/compute-resources/#resource-requests-and-limits-of-pod-and-container)
* Provide a method for data persistence (if applicable)
* Support application upgrades
* Allow customization of the application configuration
* Provide a secure default configuration
* Do not leverage alpha features of Kubernetes
* Includes a [NOTES.txt](https://helm.sh/docs/topics/charts/#chart-license-readme-and-notes) explaining how to use the application after install
* Follows [best practices](https://helm.sh/docs/chart_best_practices/)
  (especially for [labels](https://helm.sh/docs/chart_best_practices/labels/)
  and [values](https://helm.sh/docs/chart_best_practices/values/))

### Documentation Requirements

* Must include an in-depth `README.md`, including:
    * Short description of the Chart
    * Any prerequisites or requirements
    * Customization: explaining options in `values.yaml` and their defaults
* Must include a short `NOTES.txt`, including:
    * Any relevant post-installation information for the Chart
    * Instructions on how to access the application or service provided by the Chart

### Merge Approval and Release Process

A fusionauth charts maintainer will review the Chart change submission, and start a validation job in the CI to verify the technical requirements of the Chart. A maintainer may add "LGTM" (Looks Good To Me) or an equivalent comment to indicate that a PR is acceptable. Any change requires at least one LGTM. No pull requests can be merged until at least one maintainer signs off with an LGTM.

### License
Copyright 2021 FusionAuth, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.