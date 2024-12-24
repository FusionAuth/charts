# FusionAuth Helm Chart

![Build Status](https://github.com/FusionAuth/charts/actions/workflows/release.yml/badge.svg)

[FusionAuth](https://fusionauth.io/) is a modern platform for Customer Identity and Access Management (CIAM). FusionAuth provides APIs and a responsive web user interface to support login, registration, localized email, multi-factor authentication, reporting, and much more.


## Important Upgrade Info

* **In `1.0.0` and later, the FusionAuth app version will now default to the latest available at the time of the chart's release.** Release notes will indicate the FusionAuth version included in the chart.

⚠️ You can (and probably should) override the `image.tag` field in `values.yaml` to pin the desired version of the FusionAuth application. This ensures that upgrading the helm chart doesn't unexpectedly upgrade the FusionAuth version.


* **In `0.8.0`, the `environment` value is now an array instead of an object.** Make sure to reformat your values when you update.

* **In `0.4.0`, the external postgresql and elasticsearch charts were dropped.** You will need to maintain those dependencies on your own.

## Installing the Chart

You can read the official instructions, including install steps for AWS, GCP, and Azure, in the [FusionAuth Kubernetes installation guide](https://fusionauth.io/docs/get-started/download-and-install/kubernetes/fusionauth-deployment).

### Prerequisites

* PostgreSQL or MySQL database
* ElasticSearch or OpenSearch instance (optional)

⚠️ Though an ElasticSearch or OpenSearch instance is optional, it is strongly recommended for most use cases.

### Installation

To install the chart with the release name `my-fusionauth`:

```shell
helm repo add fusionauth https://fusionauth.github.io/charts
helm install my-fusionauth fusionauth/fusionauth \
  --set database.host=[database host] \
  --set database.user=[database username] \
  --set database.password=[database password] \
  --set search.host=[elasticsearch host]
```


## Setting Up a Test Deployment

This will install FusionAuth and its prerequisites in a single kubernetes namespace, with a configuration suitable for evaluation and testing. **This configuration is not suitable for production.**

Set a few environment variables.
```
export FA_NS=fusionauth-test    # Namespace we will deploy everything to
export FA_APP_HELM=fusionauth   # Name of the FusionAuth helm installation
export FA_PSQL_HELM=postgres    # Name of the Postgres helm installation
export FA_SRCH_HELM=opensearch  # Name of the Opensearch helm installation
```

Create and switch to the test namespace.
```shell
kubectl create namespace $FA_NS
kubectl config set-context --current --namespace=$FA_NS
```

### Install PostgreSQL
```shell
helm install -n $FA_NS $FA_PSQL_HELM oci://registry-1.docker.io/bitnamicharts/postgresql
```

### Install Opensearch

Opensearch is optional, but highly recommended. See the note below.
```shell
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm install -n $FA_NS $FA_SRCH_HELM opensearch/opensearch \
--set singleNode=true \
--set-json 'extraEnvs=[{"name":"DISABLE_SECURITY_PLUGIN","value":"true"}]'
```

### Install FusionAuth

Wait for the Postgres and Opensearch pods to be ready, then install FusionAuth.
```shell
export FA_PSQL_PASS=$(kubectl get secret postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
helm repo add fusionauth https://fusionauth.github.io/charts
helm install -n $FA_NS $FA_APP_HELM fusionauth/fusionauth \
--set database.host=$FA_PSQL_HELM-postgresql \
--set database.user=fusionauth \
--set database.password=$FA_PSQL_PASS \
--set search.host=$FA_SRCH_HELM-cluster-master
```

📝 For test deployments, you can remove `--set search.host` and add `--set search.engine=database` to configure FusionAuth to use the database for search instead of a dedicated search host. This is **not recommended** for real-world use, as search performance will be greatly reduced.

### Connect to FusionAuth

Create a port forward to connect to the FusionAuth app.
```shell
kubectl port-forward svc/$FA_APP_HELM-fusionauth 9011:9011
```

You should now be able to connect to the FusionAuth application at http://localhost:9011 to start the initial setup.

📝 You may wish to set up an ingress instead of using a port forward. See the table below for how to configure the FusionAuth chart values to add an ingress.


## Chart Values

<table>
    <thead>
        <tr>
            <th>Key</th>
            <th>Type</th>
            <th>Default</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><code>affinity</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Configure affinity rules for the fusionauth Deployment.</td>
        </tr>
        <tr>
            <td><code>annotations</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define annotations for fusionauth Deployment.</td>
        </tr>
        <tr>
            <td><code>app.memory</code></td>
            <td>string</td>
            <td><code>"256M"</code></td>
            <td>Configures the amount of memory to allocate to the Java VM (sets <code>FUSIONAUTH_APP_MEMORY</code>).</td>
        </tr>
        <tr>
            <td><code>app.runtimeMode</code></td>
            <td>string</td>
            <td><code>"development"</code></td>
            <td>Configures runtime mode (sets <code>FUSIONAUTH_APP_RUNTIME_MODE</code>). Must be <code>development</code> or <code>production</code>.</td>
        </tr>
        <tr>
            <td><code>app.silentMode</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Configures silent mode (sets <code>FUSIONAUTH_APP_SILENT_MODE</code>). Must be <code>true</code> or <code>false</code>.</td>
        </tr>
        <tr>
            <td><code>autoscaling.enabled</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enable Horizontal Pod Autoscaling. See the values file for more HPA parameters.</td>
        </tr>
        <tr>
            <td><code>autoscaling.minReplicas</code></td>
            <td>int</td>
            <td><code>2</code></td>
            <td>Minimum number of running instances when HPA is enabled. Ignored when <code>autoscaling.enabled</code> is <code>false</code>.</td>
        </tr>
        <tr>
            <td><code>autoscaling.maxReplicas</code></td>
            <td>int</td>
            <td><code>5</code></td>
            <td>Maximum number of running instances when HPA is enabled. Ignored when <code>autoscaling.enabled</code> is <code>false</code>.</td>
        </tr>
        <tr>
            <td><code>autoscaling.targetCPU</code></td>
            <td>int</td>
            <td><code>50</code></td>
            <td>CPU use % threshold to trigger a HPA scale up. Ignored when <code>autoscaling.enabled</code> is <code>false</code>.</td>
        </tr>
        <tr>
            <td><code>database.existingSecret</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>The name of an existing Kubernetes Secret that contains the database passwords.</td>
        </tr>
        <tr>
            <td><code>database.host</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Hostname or IP address of the fusionauth database.</td>
        </tr>
        <tr>
            <td><code>database.name</code></td>
            <td>string</td>
            <td><code>"fusionauth"</code></td>
            <td>Name of the fusionauth database.</td>
        </tr>
        <tr>
            <td><code>database.password</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database password for fusionauth to use in normal operation - not required if <code>database.existingSecret</code> is configured.</td>
        </tr>
        <tr>
            <td><code>database.port</code></td>
            <td>int</td>
            <td><code>5432</code></td>
            <td>Port used by the fusionauth database.</td>
        </tr>
        <tr>
            <td><code>database.protocol</code></td>
            <td>string</td>
            <td><code>"postgresql"</code></td>
            <td>Should either be <code>postgresql</code> or <code>mysql</code>. Protocol for jdbc connection to database.</td>
        </tr>
        <tr>
            <td><code>database.root.password</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database password for fusionauth to use during initial bootstrap - not required if <code>database.existingSecret</code> is configured.</td>
        </tr>
        <tr>
            <td><code>database.root.user</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database username for fusionauth to use during initial bootstrap - not required if you have manually bootstrapped your database.</td>
        </tr>
        <tr>
            <td><code>database.tls</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Configures whether or not to use tls when connecting to the database.</td>
        </tr>
        <tr>
            <td><code>database.tlsMode</code></td>
            <td>string</td>
            <td><code>"require"</code></td>
            <td>If tls is enabled, this configures the mode.</td>
        </tr>
        <tr>
            <td><code>database.user</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database username for fusionauth to use in normal operation.</td>
        </tr>
        <tr>
            <td><code>dnsConfig</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define <code>dnsConfig</code> for fusionauth pods.</td>
        </tr>
        <tr>
            <td><code>dnsPolicy</code></td>
            <td>string</td>
            <td><code>"ClusterFirst"</code></td>
            <td>Define <code>dnsPolicy</code> for fusionauth pods.</td>
        </tr>
        <tr>
            <td><code>environment</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Configure additional environment variables.</td>
        </tr>
        <tr>
            <td><code>extraVolumeMounts</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define mount paths for <code>extraVolumes</code>.</td>
        </tr>
        <tr>
            <td><code>extraContainers</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Create containers for the pods. Can be used for sidecars, ambassador, and adapter patterns.</td>
        </tr>
        <tr>
            <td><code>extraInitContainers</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Add extra init containers. Can be used for setup or wait for other dependent services.</td>
        </tr>
        <tr>
            <td><code>extraVolumes</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define extra volumes to mount in the deployment.</td>
        </tr>
        <tr>
            <td><code>fullnameOverride</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Overrides full resource names.</td>
        </tr>
        <tr>
            <td><code>image.pullPolicy</code></td>
            <td>string</td>
            <td><code>"IfNotPresent"</code></td>
            <td>Kubernetes image pullPolicy to use for fusionauth-app.</td>
        </tr>
        <tr>
            <td><code>image.repository</code></td>
            <td>string</td>
            <td><code>"fusionauth/fusionauth-app"</code></td>
            <td>The image repository to use for fusionauth-app.</td>
        </tr>
        <tr>
            <td><code>image.tag</code></td>
            <td>string</td>
            <td><code>"${APP_VERSION}"</code></td>
            <td>The image tag to pull for fusionauth-app (this is the fusionauth-app version).</td>
        </tr>
        <tr>
            <td><code>imagePullSecrets</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Configures Kubernetes secrets to use for pulling images from private repositories.</td>
        </tr>
        <tr>
            <td><code>ingress.annotations</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Configure annotations to add to the ingress object.</td>
        </tr>
        <tr>
            <td><code>ingress.enabled</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enables ingress creation for fusionauth.</td>
        </tr>
        <tr>
            <td><code>ingress.extraPaths</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define path objects which will be inserted before regular paths. Can be useful for things like ALB Ingress Controller actions.</td>
        </tr>
        <tr>
            <td><code>ingress.hosts</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>List of hostnames to configure the ingress with.</td>
        </tr>
        <tr>
            <td><code>ingress.ingressClassName</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Specify the <code>ingressClass</code> to be used by the Ingress.</td>
        </tr>
        <tr>
            <td><code>ingress.paths</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Paths to be used by the Ingress.</td>
        </tr>
        <tr>
            <td><code>ingress.tls</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>List of secrets used to configure TLS for the ingress.</td>
        </tr>
        <tr>
            <td><code>initContainers.waitForDb</code></td>
            <td>bool</td>
            <td><code>true</code></td>
            <td>Create an init container which waits for the database to be ready.</td>
        </tr>
        <tr>
            <td><code>initContainers.waitForEs</code></td>
            <td>bool</td>
            <td><code>true</code></td>
            <td>Create an init container which waits for elasticsearch to be ready.</td>
        </tr>
        <tr>
            <td><code>initContainers.image.repository</code></td>
            <td>string</td>
            <td><code>"busybox"</code></td>
            <td>Image to use for <code>initContainers</code> docker image.</td>
        </tr>
        <tr>
            <td><code>initContainers.image.tag</code></td>
            <td>string</td>
            <td><code>"1.36.1"</code></td>
            <td>Tag to use for <code>initContainers</code> docker image.</td>
        </tr>
        <tr>
            <td><code>initContainers.resources</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Resource requests and limits to use for <code>initContainers</code>.</td>
        </tr>
        <tr>
            <td><code>kickstart.data</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Fusionauth <a href="https://fusionauth.io/docs/get-started/download-and-install/development/kickstart">kickstart settings</a>.</td>
        </tr>
        <tr>
            <td><code>kickstart.enabled</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enable fusionauth kickstart settings.</td>
        </tr>
        <tr>
            <td><code>lifecycle</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define custom <code>lifecycle</code> settings for the deployment.</td>
        </tr>
        <tr>
            <td><code>livenessProbe</code></td>
            <td>object</td>
            <td>
              <pre lang="yaml">
<!--         -->livenessProbe:
<!--         -->  httpGet:
<!--         -->    path: /
<!--         -->    port: http
<!--         -->  failureThreshold: 3
<!--         -->  periodSeconds: 30
<!--         -->  timeoutSeconds: 5</pre></td>
            <td>Configures a <code>livenessProbe</code> to ensure fusionauth is running.</td>
        </tr>
        <tr>
            <td><code>nameOverride</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Overrides resource names.</td>
        </tr>
        <tr>
            <td><code>nodeSelector</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define <code>nodeSelector</code> for kubernetes to use when scheduling fusionauth pods.</td>
        </tr>
        <tr>
            <td><code>podAnnotations</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define <code>annotations</code> for fusionauth pods.</td>
        </tr>
        <tr>
            <td><code>podDisruptionBudget.enabled</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enables creation of a <code>PodDisruptionBudget</code>.</td>
        </tr>
        <tr>
            <td><code>readinessProbe</code></td>
            <td>object</td>
            <td>
              <pre lang="yaml">
<!--         -->readinessProbe:
<!--         -->  httpGet:
<!--         -->    path: /
<!--         -->    port: http
<!--         -->  failureThreshold: 5
<!--         -->  timeoutSeconds: 5</pre></td>
            <td>Configures a <code>readinessProbe</code> to ensure fusionauth is ready for requests.</td>
        </tr>
        <tr>
            <td><code>replicaCount</code></td>
            <td>int</td>
            <td><code>1</code></td>
            <td>The number of fusionauth-app instances to run.</td>
        </tr>
        <tr>
            <td><code>resources</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define resource requests and limits for fusionauth-app.</td>
        </tr>
        <tr>
            <td><code>search.engine</code></td>
            <td>string</td>
            <td><code>"elasticsearch"</code></td>
            <td>Protocol to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td><code>search.host</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Hostname or ip to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td><code>search.port</code></td>
            <td>int</td>
            <td><code>9200</code></td>
            <td>Port to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td><code>search.protocol</code></td>
            <td>string</td>
            <td><code>"http"</code></td>
            <td>Protocol to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td><code>service.annotations</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Extra annotations to add to the service object.</td>
        </tr>
        <tr>
            <td><code>service.port</code></td>
            <td>int</td>
            <td><code>9011</code></td>
            <td>Port for the Kubernetes service to expose.</td>
        </tr>
        <tr>
            <td><code>service.spec</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Any extra fields to add to the service object spec.</td>
        </tr>
        <tr>
            <td><code>service.type</code></td>
            <td>string</td>
            <td><code>"ClusterIP"</code></td>
            <td>Type of Kubernetes service to create.</td>
        </tr>
        <tr>
            <td><code>serviceAccount.annotations</code></td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Extra annotations to add to the service account object.</td>
        </tr>
        <tr>
            <td><code>serviceAccount.automount</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Automatically mount a service account's API credentials.</td>
        </tr>
        <tr>
            <td><code>serviceAccount.create</code></td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>If set to <code>true</code>, service account will be created. Otherwise, the <code>default</code> serviceaccount will be used.</td>
        </tr>
        <tr>
            <td><code>serviceAccount.name</code></td>
            <td>string</td>
            <td><code>""</code></td>
            <td>The name of the service account to use. If not set and <code>create</code> is <code>true</code>, a name is generated using the fullname template.</td>
        </tr>
        <tr>
            <td><code>startupProbe</code></td>
            <td>object</td>
            <td>
              <pre lang="yaml">
<!--         -->startupProbe:
<!--         -->  httpGet:
<!--         -->    path: /
<!--         -->    port: http
<!--         -->  failureThreshold: 20
<!--         -->  periodSeconds: 10
<!--         -->  timeoutSeconds: 5</pre></td>
            <td>Configures a <code>startupProbe</code> to ensure fusionauth has finished starting up.</td>
        </tr>
        <tr>
            <td><code>tolerations</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define <code>tolerations</code> for kubernetes to use when scheduling fusionauth pods.</td>
        </tr>
        <tr>
            <td><code>topologySpreadConstraints</code></td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define <code>topologySpreadConstraints</code> for kubernetes to use when scheduling fusionauth pods.</td>
        </tr>
    </tbody>
</table>
