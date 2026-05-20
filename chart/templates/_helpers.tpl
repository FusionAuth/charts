{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fusionauth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fusionauth.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Configure TLS if enabled
*/}}
{{- define "fusionauth.databaseTLS" -}}
{{- if .Values.database.tls -}}
?sslmode={{ .Values.database.tlsMode }}
{{- end -}}
{{- end -}}

{{/*
Return true when .Values.environment contains an entry with the given name.
Used so user-provided environment variables can take precedence over chart
values without rendering duplicate env names.
*/}}
{{- define "fusionauth.environment.has" -}}
{{- $name := .name -}}
{{- $found := false -}}
{{- range .context.Values.environment -}}
{{- if eq .name $name -}}
{{- $found = true -}}
{{- end -}}
{{- end -}}
{{- if $found -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve deployment annotations.
Current value: deploymentAnnotations.
Backward compatibility: top-level annotations is deprecated but still accepted.
When both are set, deploymentAnnotations wins.
*/}}
{{- define "fusionauth.deploymentAnnotations" -}}
{{- if .Values.deploymentAnnotations -}}
{{- toYaml .Values.deploymentAnnotations -}}
{{- else if and (hasKey .Values "annotations") .Values.annotations -}}
{{- toYaml .Values.annotations -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether database credentials should come from an existing secret.
Current value: database.existingSecret.enabled.
Backward compatibility: database.existingSecret used to support a scalar secret
name. A legacy string value is treated as enabled=true with that secret name.
*/}}
{{- define "fusionauth.database.existingSecret.enabled" -}}
{{- if kindIs "string" .Values.database.existingSecret -}}
{{- if .Values.database.existingSecret -}}true{{- else -}}false{{- end -}}
{{- else -}}
{{- .Values.database.existingSecret.enabled | default false -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should create its database credentials Secret.
If DATABASE_PASSWORD or DATABASE_ROOT_PASSWORD are supplied through
.Values.environment, those env vars take precedence and their corresponding
generated Secret keys are not needed.
*/}}
{{- define "fusionauth.database.generatedSecret.enabled" -}}
{{- $existingSecret := eq (include "fusionauth.database.existingSecret.enabled" .) "true" -}}
{{- $databasePasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_PASSWORD")) "true" -}}
{{- $databaseRootUsernameEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_USERNAME")) "true" -}}
{{- $databaseRootPasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_PASSWORD")) "true" -}}
{{- $rootUserConfigured := or .Values.database.root.user $databaseRootUsernameEnv -}}
{{- if and (not $existingSecret) (or (not $databasePasswordEnv) (and $rootUserConfigured (not $databaseRootPasswordEnv))) -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve the database secret name.
Current value: database.existingSecret.name.
Backward compatibility: database.existingSecret used to support a scalar secret
name. A legacy string value is used directly as the secret name.
*/}}
{{- define "fusionauth.database.secretName" -}}
{{- if eq (include "fusionauth.database.existingSecret.enabled" .) "true" -}}
{{- if kindIs "string" .Values.database.existingSecret -}}
{{- required "database.existingSecret must not be empty when used as a secret name" .Values.database.existingSecret -}}
{{- else -}}
{{- required "database.existingSecret.name is required when database.existingSecret.enabled is true" .Values.database.existingSecret.name -}}
{{- end -}}
{{- else -}}
{{ .Release.Name }}-credentials
{{- end -}}
{{- end -}}

{{/*
Resolve the database password key.
Current value: database.existingSecret.passwordKey.
Backward compatibility: legacy scalar database.existingSecret values have no
key fields, so they use the default password key.
*/}}
{{- define "fusionauth.database.passwordKey" -}}
{{- if kindIs "map" .Values.database.existingSecret -}}
{{- .Values.database.existingSecret.passwordKey | default "password" -}}
{{- else -}}
password
{{- end -}}
{{- end -}}

{{/*
Resolve the database root password key.
Current value: database.existingSecret.rootPasswordKey.
Backward compatibility: legacy scalar database.existingSecret values have no
key fields, so they use the default root password key.
*/}}
{{- define "fusionauth.database.rootPasswordKey" -}}
{{- if kindIs "map" .Values.database.existingSecret -}}
{{- .Values.database.existingSecret.rootPasswordKey | default "rootpassword" -}}
{{- else -}}
rootpassword
{{- end -}}
{{- end -}}

{{/*
Resolve whether search basic auth is enabled.
Current value: search.basicAuth.enabled.
Backward compatibility: deprecated search.user/search.password and deprecated
search.existingSecret still imply that basic auth is enabled.
*/}}
{{- define "fusionauth.search.basicAuth.enabled" -}}
{{- if .Values.search.basicAuth.enabled -}}
true
{{- else if or .Values.search.user .Values.search.password (eq (include "fusionauth.search.existingSecret.enabled" .) "true") (eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_USERNAME")) "true") (eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_PASSWORD")) "true") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve whether search basic auth credentials should come from an existing
secret.
Current value: search.basicAuth.existingSecret.enabled.
Backward compatibility: deprecated search.existingSecret is still accepted as
either an object or a scalar secret name.
*/}}
{{- define "fusionauth.search.existingSecret.enabled" -}}
{{- if .Values.search.basicAuth.existingSecret.enabled -}}
true
{{- else if .Values.search.existingSecret -}}
{{- if kindIs "string" .Values.search.existingSecret -}}
{{- if .Values.search.existingSecret -}}true{{- else -}}false{{- end -}}
{{- else -}}
{{- .Values.search.existingSecret.enabled | default false -}}
{{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve the search existing secret name.
Current value: search.basicAuth.existingSecret.name.
Backward compatibility: deprecated search.existingSecret string values are used
directly, and deprecated search.existingSecret.name values are also accepted.
*/}}
{{- define "fusionauth.search.existingSecret.name" -}}
{{- if .Values.search.basicAuth.existingSecret.name -}}
{{- .Values.search.basicAuth.existingSecret.name -}}
{{- else if .Values.search.existingSecret -}}
{{- if kindIs "string" .Values.search.existingSecret -}}
{{- .Values.search.existingSecret -}}
{{- else -}}
{{- .Values.search.existingSecret.name -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the search username key.
Current value: search.basicAuth.existingSecret.userKey.
Backward compatibility: deprecated search.existingSecret.userKey is still
accepted.
*/}}
{{- define "fusionauth.search.existingSecret.userKey" -}}
{{- if .Values.search.basicAuth.existingSecret.userKey -}}
{{- .Values.search.basicAuth.existingSecret.userKey -}}
{{- else if and .Values.search.existingSecret (kindIs "map" .Values.search.existingSecret) .Values.search.existingSecret.userKey -}}
{{- .Values.search.existingSecret.userKey -}}
{{- else -}}
username
{{- end -}}
{{- end -}}

{{/*
Resolve the search password key.
Current value: search.basicAuth.existingSecret.passwordKey.
Backward compatibility: deprecated search.existingSecret.passwordKey is still
accepted.
*/}}
{{- define "fusionauth.search.existingSecret.passwordKey" -}}
{{- if .Values.search.basicAuth.existingSecret.passwordKey -}}
{{- .Values.search.basicAuth.existingSecret.passwordKey -}}
{{- else if and .Values.search.existingSecret (kindIs "map" .Values.search.existingSecret) .Values.search.existingSecret.passwordKey -}}
{{- .Values.search.existingSecret.passwordKey -}}
{{- else -}}
password
{{- end -}}
{{- end -}}

{{/*
Build the search login prefix for SEARCH_SERVERS.
Backward compatibility: this uses the search compatibility helpers above, so
deprecated search.user/search.password and search.existingSecret shapes still
render the same URL prefix.
*/}}
{{- define "fusionauth.searchLogin" -}}
{{- if eq (include "fusionauth.search.existingSecret.enabled" .) "true" -}}
$(SEARCH_USERNAME):$(SEARCH_PASSWORD)@
{{- else if eq (include "fusionauth.search.basicAuth.enabled" .) "true" -}}
{{- $username := "" -}}
{{- $password := "" -}}
{{- if .Values.search.basicAuth.enabled -}}
{{- $username = .Values.search.basicAuth.username -}}
{{- $password = .Values.search.basicAuth.password -}}
{{- else -}}
{{- $username = .Values.search.user -}}
{{- $password = .Values.search.password -}}
{{- end -}}
{{- if eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_USERNAME")) "true" -}}
{{- $username = "$(SEARCH_USERNAME)" -}}
{{- end -}}
{{- if eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_PASSWORD")) "true" -}}
{{- $password = "$(SEARCH_PASSWORD)" -}}
{{- end -}}
{{- printf "%s:%s@" $username $password -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the database wait init-container flag.
Current value: initContainers.waitForDatabase.
Backward compatibility: deprecated initContainers.waitForDb is still accepted.
When both are set, waitForDatabase wins.
*/}}
{{- define "fusionauth.initContainers.waitForDatabase" -}}
{{- if hasKey .Values.initContainers "waitForDatabase" -}}
{{- .Values.initContainers.waitForDatabase -}}
{{- else if hasKey .Values.initContainers "waitForDb" -}}
{{- .Values.initContainers.waitForDb -}}
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
Resolve the search wait init-container flag.
Current value: initContainers.waitForSearch.
Backward compatibility: deprecated initContainers.waitForEs is still accepted.
When both are set, waitForSearch wins.
*/}}
{{- define "fusionauth.initContainers.waitForSearch" -}}
{{- if hasKey .Values.initContainers "waitForSearch" -}}
{{- .Values.initContainers.waitForSearch -}}
{{- else if hasKey .Values.initContainers "waitForEs" -}}
{{- .Values.initContainers.waitForEs -}}
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fusionauth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels applied to FusionAuth resources.
*/}}
{{- define "fusionauth.labels" -}}
app.kubernetes.io/name: {{ include "fusionauth.name" . }}
helm.sh/chart: {{ include "fusionauth.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels used by Services, workload selectors, and pods.
Keep these stable because selector labels are immutable on several resources.
*/}}
{{- define "fusionauth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fusionauth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "fusionauth.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fusionauth.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
