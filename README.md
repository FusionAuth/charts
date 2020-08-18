# FusionAuth Helm Chart [![Build Status](https://travis-ci.org/FusionAuth/charts.svg?branch=master)](https://travis-ci.org/FusionAuth/charts)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting and much more.

### Notice
This repository is community maintained; and is provided to assist in your deployment and management of FusionAuth. Use of this software is not covered under the FusionAuth license agreement and is provided "as is" without warranty.  https://fusionauth.io/license

## Installing the Chart

### Important upgrade info:
In `0.4.0`, the external postgresql and elasticsearch charts were dropped. You will need to maintain those dependencies on your own.

To install the chart with the release name `my-release`:

```console
$ helm repo add fusionauth https://fusionauth.github.io/charts
$ helm install fusionauth/fusionauth  --name my-release
```

The command deploys FusionAuth.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

| Parameter                 |                                                            Description                                                             |                                                                              Default |
| ------------------------- | :--------------------------------------------------------------------------------------------------------------------------------: | -----------------------------------------------------------------------------------: |
| `replicaCount`            |                                           The number of fusionauth-app instances to run                                            |                                                                                  `1` |
| `image.repository`        |                                        The name of the docker repository for fusionauth-app                                        |                                                          `fusionauth/fusionauth-app` |
| `image.tag`               |                                        The docker tag (version) of fusionauth-app to deploy                                        |                                                                             `1.16.0` |
| `image.pullPolicy`        |                                                 Kubernetes image pullPolicy to use                                                 |                                                                       `IfNotPresent` |
| `nameOverride`            |                                            Overrides name of resources created by chart                                            |                                                                                 `""` |
| `fullnameOverride`        |                                         Overrides full name of resources created by chart                                          |                                                                                 `""` |
| `service.type`            |                                                  Type of service to create in k8s                                                  |                                                                          `ClusterIP` |
| `service.port`            |                                          Defines container port as well as service port.                                           |                                                                               `9011` |
| `service.annotations`     |                                              Additional annotations to add to service                                              |                                                                                 `{}` |
| `service.spec`            |                                                 Additional spec to add to service                                                  |                                                                                 `{}` |
| `database.protocol`       |                             Database type to use. Should be one of the options supported by fusionauth                             |                                                                         `postgresql` |
| `database.host`           |                                                 Hostname of database to connect to                                                 |                                                                                 `""` |
| `database.port`           |                                                    Port for database connection                                                    |                                                                               `5432` |
| `database.tls`            |                                    Configure whether to enable tls for the database connection                                     |                                                                              `false` |
| `database.tlsMode`        |                                   If tls is enabled, this is the mode to set for the connection                                    |                                                                            `require` |
| `database.name`           |                                               The name of the database to connect to                                               |                                                                         `fusionauth` |
| `database.existingSecret` |    To use an existing secret, set `existingSecret` to the name of the secret. We expect two keys: `password` and `rootpassword`    |                                                                                 `""` |
| `database.user`           |                                             Configure username for database connection                                             |                                                                                 `""` |
| `database.password`       |                    Password to use for database connection. This should not be set if `existingSecret` is set.                     |                                                                                 `""` |
| `database.root.user`      |                                            Root username to use for database bootstrap                                             |                                                                                 `""` |
| `database.root.password`  |                     Root password to use for database bootstrap. Should not be set if `existingSecret` is set.                     |                                                                                 `""` |
| `search.engine`           |                            Engine to use for search. Should be set to a value fusionauth itself accepts                            |                                                                    `"elasticsearch"` |
| `search.protocol`         |                              protocol to use for search connection - only required for elasticsearch                               |                                                                               `http` |
| `search.host`             |                              Hostname to use for search connection - only required for elasticsearch                               |                                                                                 `""` |
| `search.port`             |                                Port to use for search connection - only required for elasticsearch                                 |                                                                               `9200` |
| `search.user`             |                                               Basic auth username for elasticsearch                                                |                                                                               `null` |
| `search.password`         |                                               Basic auth password for elasticsearch                                                |                                                                                `null |
| `environment.*`           |                        Optional map of values that will be created as environment variables inside the pod.                        |                                                            `FUSIONAUTH_MEMORY: 256M` |
| `kickstart.enabled`       |                                            Configure if fusionauth kickstart is enabled                                            |                                                                              `false` |
| `kickstart.data`          |                                            define kickstart data to pass to fusionauth                                             |                                                                                 `{}` |
| `ingress.enabled`         |                                                          Enables ingress                                                           |                                                                              `false` |
| `ingress.annotations`     |                                           Configures additional annotations for ingress                                            |                                                                                 `{}` |
| `ingress.paths`           |                                               Optional paths for the ingress object                                                |                                                                                 `[]` |
| `ingress.extraPaths`      | Define complete path objects, will be inserted before regular paths. Can be useful for things like ALB Ingress Controller actions. |                                                                                 `[]` |
| `ingress.hosts`           |                                          List of hostnames for the ingress to be aware of                                          |                                                                                 `[]` |
| `ingress.tls`             |                              Define complete tls object to configure optional tls for ingress` | `[]`                              |
| `resources`               |                                   Allows configuring resource requests and limits for fusionauth                                   |                                                                                 `{}` |
| `nodeSelector`            |                                                   Node labels for pod assignment                                                   |                                                                                 `{}` |
| `tolerations`             |                                                Toleration labels for pod assignment                                                |                                                                                 `[]` |
| `affinity`                |                                                         Affinity settings                                                          |                                                                                 `{}` |
| `annotations`             |                                               Annotations for the deployment object                                                |                                                                                 `{}` |
| `podAnnotations`          |                                                  Annotations for the pod objects                                                   |                                                                                 `{}` |
| `livenessProbe`           |                                              Configures liveness probe for deployment                                              |                        `{"httpGet": {"path":"/","port":"http"}, "periodSeconds":30}` |
| `readinessProbe`          |                                             Configures readiness probe for deployment                                              |                                            `{"httpGet": {"path":"/","port":"http"}}` |
| `startupProbe`            |                                              Configures startup probe for deployment                                               | `{"httpGet": {"path":"/","port":"http"}, "failureThreshold":20, "periodSeconds":10}` |