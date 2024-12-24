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
            <td>affinity</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Configure affinity rules for the fusionauth Deployment.</td>
        </tr>
        <tr>
            <td>annotations</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define annotations for fusionauth Deployment.</td>
        </tr>
        <tr>
            <td>app.memory</td>
            <td>string</td>
            <td><code>"256M"</code></td>
            <td>Configures the amount of memory to allocate to the Java VM (sets <code>FUSIONAUTH_APP_MEMORY</code>).</td>
        </tr>
        <tr>
            <td>app.runtimeMode</td>
            <td>string</td>
            <td><code>"development"</code></td>
            <td>Configures runtime mode (sets <code>FUSIONAUTH_APP_RUNTIME_MODE</code>). Must be <code>development</code> or <code>production</code>.</td>
        </tr>
        <tr>
            <td>app.silentMode</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Configures silent mode (sets <code>FUSIONAUTH_APP_SILENT_MODE</code>). Must be <code>true</code> or <code>false</code>.</td>
        </tr>
        <tr>
            <td>autoscaling.enabled</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enable Horizontal Pod Autoscaling. See the values file for more HPA parameters.</td>
        </tr>
        <tr>
            <td>autoscaling.minReplicas</td>
            <td>int</td>
            <td><code>2</code></td>
            <td>Minimum number of running instances when HPA is enabled. Ignored when <code>autoscaling.enabled</code> is <code>false</code>.</td>
        </tr>
        <tr>
            <td>autoscaling.maxReplicas</td>
            <td>int</td>
            <td><code>5</code></td>
            <td>Maximum number of running instances when HPA is enabled. Ignored when <code>autoscaling.enabled</code> is <code>false</code>.</td>
        </tr>
        <tr>
            <td>autoscaling.targetCPU</td>
            <td>int</td>
            <td><code>50</code></td>
            <td>CPU use % threshold to trigger a HPA scale up. Ignored when <code>autoscaling.enabled</code> is <code>false</code>.</td>
        </tr>
        <tr>
            <td>database.existingSecret</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>The name of an existing Kubernetes Secret that contains the database passwords.</td>
        </tr>
        <tr>
            <td>database.host</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Hostname or IP address of the fusionauth database.</td>
        </tr>
        <tr>
            <td>database.name</td>
            <td>string</td>
            <td><code>"fusionauth"</code></td>
            <td>Name of the fusionauth database.</td>
        </tr>
        <tr>
            <td>database.password</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database password for fusionauth to use in normal operation - not required if <code>database.existingSecret</code> is configured.</td>
        </tr>
        <tr>
            <td>database.port</td>
            <td>int</td>
            <td><code>5432</code></td>
            <td>Port used by the fusionauth database.</td>
        </tr>
        <tr>
            <td>database.protocol</td>
            <td>string</td>
            <td><code>"postgresql"</code></td>
            <td>Should either be <code>postgresql</code> or <code>mysql</code>. Protocol for jdbc connection to database.</td>
        </tr>
        <tr>
            <td>database.root.password</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database password for fusionauth to use during initial bootstrap - not required if <code>database.existingSecret</code> is configured.</td>
        </tr>
        <tr>
            <td>database.root.user</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database username for fusionauth to use during initial bootstrap - not required if you have manually bootstrapped your database.</td>
        </tr>
        <tr>
            <td>database.tls</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Configures whether or not to use tls when connecting to the database.</td>
        </tr>
        <tr>
            <td>database.tlsMode</td>
            <td>string</td>
            <td><code>"require"</code></td>
            <td>If tls is enabled, this configures the mode.</td>
        </tr>
        <tr>
            <td>database.user</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Database username for fusionauth to use in normal operation.</td>
        </tr>
        <tr>
            <td>dnsConfig</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define <code>dnsConfig</code> for fusionauth pods.</td>
        </tr>
        <tr>
            <td>dnsPolicy</td>
            <td>string</td>
            <td><code>"ClusterFirst"</code></td>
            <td>Define <code>dnsPolicy</code> for fusionauth pods.</td>
        </tr>
        <tr>
            <td>environment</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Configure additional environment variables.</td>
        </tr>
        <tr>
            <td>extraVolumeMounts</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define mount paths for <code>extraVolumes</code>.</td>
        </tr>
        <tr>
            <td>extraContainers</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Create containers for the pods. Can be used for sidecars, ambassador, and adapter patterns.</td>
        </tr>
        <tr>
            <td>extraInitContainers</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Add extra init containers. Can be used for setup or wait for other dependent services.</td>
        </tr>
        <tr>
            <td>extraVolumes</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define extra volumes to mount in the deployment.</td>
        </tr>
        <tr>
            <td>fullnameOverride</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Overrides full resource names.</td>
        </tr>
        <tr>
            <td>image.pullPolicy</td>
            <td>string</td>
            <td><code>"IfNotPresent"</code></td>
            <td>Kubernetes image pullPolicy to use for fusionauth-app.</td>
        </tr>
        <tr>
            <td>image.repository</td>
            <td>string</td>
            <td><code>"fusionauth/fusionauth-app"</code></td>
            <td>The image repository to use for fusionauth-app.</td>
        </tr>
        <tr>
            <td>image.tag</td>
            <td>string</td>
            <td><code>"${APP_VERSION}"</code></td>
            <td>The image tag to pull for fusionauth-app (this is the fusionauth-app version).</td>
        </tr>
        <tr>
            <td>imagePullSecrets</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Configures Kubernetes secrets to use for pulling images from private repositories.</td>
        </tr>
        <tr>
            <td>ingress.annotations</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Configure annotations to add to the ingress object.</td>
        </tr>
        <tr>
            <td>ingress.enabled</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enables ingress creation for fusionauth.</td>
        </tr>
        <tr>
            <td>ingress.extraPaths</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define path objects which will be inserted before regular paths. Can be useful for things like ALB Ingress Controller actions.</td>
        </tr>
        <tr>
            <td>ingress.hosts</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>List of hostnames to configure the ingress with.</td>
        </tr>
        <tr>
            <td>ingress.ingressClassName</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Specify the <code>ingressClass</code> to be used by the Ingress.</td>
        </tr>
        <tr>
            <td>ingress.paths</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Paths to be used by the Ingress.</td>
        </tr>
        <tr>
            <td>ingress.tls</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>List of secrets used to configure TLS for the ingress.</td>
        </tr>
        <tr>
            <td>initContainers.waitForDb</td>
            <td>bool</td>
            <td><code>true</code></td>
            <td>Create an init container which waits for the database to be ready.</td>
        </tr>
        <tr>
            <td>initContainers.waitForEs</td>
            <td>bool</td>
            <td><code>true</code></td>
            <td>Create an init container which waits for elasticsearch to be ready.</td>
        </tr>
        <tr>
            <td>initContainers.image.repository</td>
            <td>string</td>
            <td><code>"busybox"</code></td>
            <td>Image to use for <code>initContainers</code> docker image.</td>
        </tr>
        <tr>
            <td>initContainers.image.tag</td>
            <td>string</td>
            <td><code>"1.36.1"</code></td>
            <td>Tag to use for <code>initContainers</code> docker image.</td>
        </tr>
        <tr>
            <td>initContainers.resources</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Resource requests and limits to use for <code>initContainers</code>.</td>
        </tr>
        <tr>
            <td>kickstart.data</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Fusionauth <a href="https://fusionauth.io/docs/get-started/download-and-install/development/kickstart">kickstart settings</a>.</td>
        </tr>
        <tr>
            <td>kickstart.enabled</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enable fusionauth kickstart settings.</td>
        </tr>
        <tr>
            <td>lifecycle</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define custom <code>lifecycle</code> settings for the deployment.</td>
        </tr>
        <tr>
            <td>livenessProbe</td>
            <td>object</td>
            <td>
              <pre lang="json">
<!--         -->{
<!--         -->  "failureThreshold": 3,
<!--         -->  "httpGet": {
<!--         -->    "path": "/",
<!--         -->    "port": "http"
<!--         -->  },
<!--         -->  "periodSeconds": 30,
<!--         -->  "timeoutSeconds": 5
<!--         -->}</pre>
            </td>
            <td>Configures a <code>livenessProbe</code> to ensure fusionauth is running.</td>
        </tr>
        <tr>
            <td>nameOverride</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Overrides resource names.</td>
        </tr>
        <tr>
            <td>nodeSelector</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define <code>nodeSelector</code> for kubernetes to use when scheduling fusionauth pods.</td>
        </tr>
        <tr>
            <td>podAnnotations</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define <code>annotations</code> for fusionauth pods.</td>
        </tr>
        <tr>
            <td>podDisruptionBudget.enabled</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Enables creation of a <code>PodDisruptionBudget</code>.</td>
        </tr>
        <tr>
            <td>readinessProbe</td>
            <td>object</td>
            <td>
              <pre lang="json">
<!--         -->{
<!--         -->  "failureThreshold": 5,
<!--         -->  "httpGet": {
<!--         -->    "path": "/",
<!--         -->    "port": "http"
<!--         -->  },
<!--         -->  "timeoutSeconds": 5
<!--         -->}</pre>
            </td>
            <td>Configures a <code>readinessProbe</code> to ensure fusionauth is ready for requests.</td>
        </tr>
        <tr>
            <td>replicaCount</td>
            <td>int</td>
            <td><code>1</code></td>
            <td>The number of fusionauth-app instances to run.</td>
        </tr>
        <tr>
            <td>resources</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Define resource requests and limits for fusionauth-app.</td>
        </tr>
        <tr>
            <td>search.engine</td>
            <td>string</td>
            <td><code>"elasticsearch"</code></td>
            <td>Protocol to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td>search.host</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>Hostname or ip to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td>search.port</td>
            <td>int</td>
            <td><code>9200</code></td>
            <td>Port to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td>search.protocol</td>
            <td>string</td>
            <td><code>"http"</code></td>
            <td>Protocol to use when connecting to elasticsearch. Ignored when <code>search.engine</code> is NOT <code>elasticsearch</code>.</td>
        </tr>
        <tr>
            <td>service.annotations</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Extra annotations to add to the service object.</td>
        </tr>
        <tr>
            <td>service.port</td>
            <td>int</td>
            <td><code>9011</code></td>
            <td>Port for the Kubernetes service to expose.</td>
        </tr>
        <tr>
            <td>service.spec</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Any extra fields to add to the service object spec.</td>
        </tr>
        <tr>
            <td>service.type</td>
            <td>string</td>
            <td><code>"ClusterIP"</code></td>
            <td>Type of Kubernetes service to create.</td>
        </tr>
        <tr>
            <td>serviceAccount.annotations</td>
            <td>object</td>
            <td><code>{}</code></td>
            <td>Extra annotations to add to the service account object.</td>
        </tr>
        <tr>
            <td>serviceAccount.automount</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>Automatically mount a service account's API credentials.</td>
        </tr>
        <tr>
            <td>serviceAccount.create</td>
            <td>bool</td>
            <td><code>false</code></td>
            <td>If set to <code>true</code>, service account will be created. Otherwise, the <code>default</code> serviceaccount will be used.</td>
        </tr>
        <tr>
            <td>serviceAccount.name</td>
            <td>string</td>
            <td><code>""</code></td>
            <td>The name of the service account to use. If not set and <code>create</code> is <code>true</code>, a name is generated using the fullname template.</td>
        </tr>
        <tr>
            <td>startupProbe</td>
            <td>object</td>
            <td>
              <pre lang="json">
<!--         -->{
<!--         -->  "failureThreshold": 20,
<!--         -->  "httpGet": {
<!--         -->    "path": "/",
<!--         -->    "port": "http"
<!--         -->  },
<!--         -->  "periodSeconds": 10,
<!--         -->  "timeoutSeconds": 5
<!--         -->}</pre>
            </td>
            <td>Configures a <code>startupProbe</code> to ensure fusionauth has finished starting up.</td>
        </tr>
        <tr>
            <td>tolerations</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define <code>tolerations</code> for kubernetes to use when scheduling fusionauth pods.</td>
        </tr>
        <tr>
            <td>topologySpreadConstraints</td>
            <td>list</td>
            <td><code>[]</code></td>
            <td>Define <code>topologySpreadConstraints</code> for kubernetes to use when scheduling fusionauth pods.</td>
        </tr>
    </tbody>
</table>
