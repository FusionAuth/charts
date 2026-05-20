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
Resolve the reserved kickstart config volume name.
*/}}
{{- define "fusionauth.kickstart.volumeName" -}}
{{- printf "%s-config-volume" (include "fusionauth.fullname" .) -}}
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
Resolve FusionAuth database username.
Current value: database.fusionauthUser.username.
Backward compatibility: database.user is deprecated but still accepted.
*/}}
{{- define "fusionauth.database.fusionauthUser.username" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- if $fusionauthUser.username -}}
{{- $fusionauthUser.username -}}
{{- else -}}
{{- $database.user | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve FusionAuth database password.
Current value: database.fusionauthUser.password.
Backward compatibility: database.password is deprecated but still accepted.
*/}}
{{- define "fusionauth.database.fusionauthUser.password" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- if $fusionauthUser.password -}}
{{- $fusionauthUser.password -}}
{{- else -}}
{{- $database.password | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether FusionAuth database credentials should come from an existing
secret.
Current value: database.fusionauthUser.existingSecret.enabled.
Backward compatibility: database.existingSecret used to configure a shared
database secret and is still accepted for the FusionAuth user.
*/}}
{{- define "fusionauth.database.fusionauthUser.existingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if $fusionauthUserExistingSecret.enabled -}}
true
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- if $legacyExistingSecret -}}true{{- else -}}false{{- end -}}
{{- else if $legacyExistingSecret -}}
{{- $legacyExistingSecret.enabled | default false -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve whether the FusionAuth database username should come from an existing
secret. This only uses the current value.
Backward compatibility: legacy database.existingSecret was password-only, so it
does not imply that the username comes from a secret.
*/}}
{{- define "fusionauth.database.fusionauthUser.usernameFromExistingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- if $fusionauthUserExistingSecret.enabled -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve the FusionAuth database Secret name.
Current value: database.fusionauthUser.existingSecret.name.
Backward compatibility: database.existingSecret used to configure a shared
database secret. A legacy string value is used directly as the secret name.
*/}}
{{- define "fusionauth.database.fusionauthUser.secretName" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if eq (include "fusionauth.database.fusionauthUser.existingSecret.enabled" .) "true" -}}
{{- if $fusionauthUserExistingSecret.name -}}
{{- $fusionauthUserExistingSecret.name -}}
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- required "database.existingSecret must not be empty when used as a secret name" $legacyExistingSecret -}}
{{- else -}}
{{- required "database.fusionauthUser.existingSecret.name is required when database.fusionauthUser.existingSecret.enabled is true" $legacyExistingSecret.name -}}
{{- end -}}
{{- else -}}
{{ .Release.Name }}-credentials
{{- end -}}
{{- end -}}

{{/*
Resolve the FusionAuth database username key.
Current value: database.fusionauthUser.existingSecret.usernameKey.
Backward compatibility: legacy database.existingSecret values did not support a
username key, so they use the default username key.
*/}}
{{- define "fusionauth.database.fusionauthUser.usernameKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $fusionauthUserExistingSecret.usernameKey | default "username" -}}
{{- end -}}

{{/*
Resolve the FusionAuth database password key.
Current value: database.fusionauthUser.existingSecret.passwordKey.
Backward compatibility: database.existingSecret.passwordKey is deprecated but
still accepted.
*/}}
{{- define "fusionauth.database.fusionauthUser.passwordKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- $fusionauthUserExistingSecretConfigured := or $fusionauthUserExistingSecret.enabled $fusionauthUserExistingSecret.name -}}
{{- if and $fusionauthUserExistingSecretConfigured $fusionauthUserExistingSecret.passwordKey -}}
{{- $fusionauthUserExistingSecret.passwordKey -}}
{{- else if and $legacyExistingSecret (kindIs "map" $legacyExistingSecret) $legacyExistingSecret.passwordKey -}}
{{- $legacyExistingSecret.passwordKey -}}
{{- else -}}
password
{{- end -}}
{{- end -}}

{{/*
Resolve whether the root database username should come from an existing secret.
This only uses the current value.
Backward compatibility: legacy database.existingSecret was password-only, so it
does not imply that the username comes from a secret.
*/}}
{{- define "fusionauth.database.rootUser.usernameFromExistingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- if $rootUserExistingSecret.enabled -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should create the FusionAuth database credentials
Secret. If DATABASE_PASSWORD is supplied through .Values.environment, that env
var takes precedence and the generated Secret is not needed.
*/}}
{{- define "fusionauth.database.fusionauthUser.generatedSecret.enabled" -}}
{{- $existingSecret := eq (include "fusionauth.database.fusionauthUser.existingSecret.enabled" .) "true" -}}
{{- $databasePasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_PASSWORD")) "true" -}}
{{- if and (not $existingSecret) (not $databasePasswordEnv) -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve root database username.
Current value: database.rootUser.username.
Backward compatibility: database.root.user is deprecated but still accepted.
*/}}
{{- define "fusionauth.database.rootUser.username" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $legacyRootUser := $database.root | default dict -}}
{{- if $rootUser.username -}}
{{- $rootUser.username -}}
{{- else -}}
{{- $legacyRootUser.user | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve root database password.
Current value: database.rootUser.password.
Backward compatibility: database.root.password is deprecated but still accepted.
*/}}
{{- define "fusionauth.database.rootUser.password" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $legacyRootUser := $database.root | default dict -}}
{{- if $rootUser.password -}}
{{- $rootUser.password -}}
{{- else -}}
{{- $legacyRootUser.password | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether root database credentials should come from an existing secret.
Current value: database.rootUser.existingSecret.enabled.
Backward compatibility: database.existingSecret used to configure a shared
database secret and is still accepted for the root user.
*/}}
{{- define "fusionauth.database.rootUser.existingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if $rootUserExistingSecret.enabled -}}
true
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- if $legacyExistingSecret -}}true{{- else -}}false{{- end -}}
{{- else if $legacyExistingSecret -}}
{{- $legacyExistingSecret.enabled | default false -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve the root database Secret name.
Current value: database.rootUser.existingSecret.name.
Backward compatibility: database.existingSecret used to configure a shared
database secret. A legacy string value is used directly as the secret name.
*/}}
{{- define "fusionauth.database.rootUser.secretName" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if eq (include "fusionauth.database.rootUser.existingSecret.enabled" .) "true" -}}
{{- if $rootUserExistingSecret.name -}}
{{- $rootUserExistingSecret.name -}}
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- required "database.existingSecret must not be empty when used as a secret name" $legacyExistingSecret -}}
{{- else -}}
{{- required "database.rootUser.existingSecret.name is required when database.rootUser.existingSecret.enabled is true" $legacyExistingSecret.name -}}
{{- end -}}
{{- else -}}
{{ .Release.Name }}-root-credentials
{{- end -}}
{{- end -}}

{{/*
Resolve the root database username key.
Current value: database.rootUser.existingSecret.usernameKey.
Backward compatibility: legacy database.existingSecret values did not support a
username key, so they use the default username key.
*/}}
{{- define "fusionauth.database.rootUser.usernameKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $rootUserExistingSecret.usernameKey | default "username" -}}
{{- end -}}

{{/*
Resolve the root database password key.
Current value: database.rootUser.existingSecret.passwordKey.
Backward compatibility: database.existingSecret.rootPasswordKey is deprecated
but still accepted.
*/}}
{{- define "fusionauth.database.rootUser.passwordKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- $rootUserExistingSecretConfigured := or $rootUserExistingSecret.enabled $rootUserExistingSecret.name -}}
{{- if and $rootUserExistingSecretConfigured $rootUserExistingSecret.passwordKey -}}
{{- $rootUserExistingSecret.passwordKey -}}
{{- else if and $legacyExistingSecret (kindIs "map" $legacyExistingSecret) $legacyExistingSecret.rootPasswordKey -}}
{{- $legacyExistingSecret.rootPasswordKey -}}
{{- else if and $legacyExistingSecret (kindIs "string" $legacyExistingSecret) -}}
rootpassword
{{- else -}}
password
{{- end -}}
{{- end -}}

{{/*
Resolve whether root database credentials are configured.
*/}}
{{- define "fusionauth.database.rootUser.configured" -}}
{{- $databaseRootUsernameEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_USERNAME")) "true" -}}
{{- if or (include "fusionauth.database.rootUser.username" .) $databaseRootUsernameEnv (eq (include "fusionauth.database.rootUser.usernameFromExistingSecret.enabled" .) "true") -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should create the root database credentials Secret.
If DATABASE_ROOT_PASSWORD is supplied through .Values.environment, that env var
takes precedence and the generated Secret is not needed.
*/}}
{{- define "fusionauth.database.rootUser.generatedSecret.enabled" -}}
{{- $existingSecret := eq (include "fusionauth.database.rootUser.existingSecret.enabled" .) "true" -}}
{{- $databaseRootPasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_PASSWORD")) "true" -}}
{{- if and (eq (include "fusionauth.database.rootUser.configured" .) "true") (not $existingSecret) (not $databaseRootPasswordEnv) -}}true{{- else -}}false{{- end -}}
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
Resolve whether chart-managed Elasticsearch/OpenSearch env and wait behavior
should be rendered. SEARCH_TYPE supplied through .Values.environment takes
precedence over the chart search values.
*/}}
{{- define "fusionauth.search.chartEnabled" -}}
{{- $searchTypeEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_TYPE")) "true" -}}
{{- if and (not $searchTypeEnv) (eq .Values.search.engine "elasticsearch") -}}true{{- else -}}false{{- end -}}
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
Resolve whether the database wait init container should be rendered.
DATABASE_URL supplied through .Values.environment takes precedence over the
chart database values, so the chart does not wait on database.host in that mode.
*/}}
{{- define "fusionauth.deployment.waitForDatabase.enabled" -}}
{{- $databaseUrlEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_URL")) "true" -}}
{{- if and (not $databaseUrlEnv) (eq (include "fusionauth.initContainers.waitForDatabase" .) "true") .Values.database.host -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve whether the search wait init container should be rendered.
*/}}
{{- define "fusionauth.deployment.waitForSearch.enabled" -}}
{{- if and (eq (include "fusionauth.search.chartEnabled" .) "true") (eq (include "fusionauth.initContainers.waitForSearch" .) "true") .Values.search.host -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Validate deployment-only conflicts before rendering the Deployment manifest.
*/}}
{{- define "fusionauth.deployment.validate" -}}
{{- if hasKey .Values.podLabels "app.kubernetes.io/name" }}
{{- fail "podLabels cannot override reserved selector label app.kubernetes.io/name" }}
{{- end }}
{{- if hasKey .Values.podLabels "app.kubernetes.io/instance" }}
{{- fail "podLabels cannot override reserved selector label app.kubernetes.io/instance" }}
{{- end }}
{{- $kickstartVolumeName := include "fusionauth.kickstart.volumeName" . }}
{{- if .Values.kickstart.enabled }}
{{- range .Values.extraVolumes }}
{{- if eq .name $kickstartVolumeName }}
{{- fail (printf "extraVolumes cannot use reserved kickstart volume name %s" $kickstartVolumeName) }}
{{- end }}
{{- end }}
{{- range .Values.extraVolumeMounts }}
{{- if eq .name $kickstartVolumeName }}
{{- fail (printf "extraVolumeMounts cannot use reserved kickstart volume name %s" $kickstartVolumeName) }}
{{- end }}
{{- if eq .mountPath "/kickstart" }}
{{- fail "extraVolumeMounts cannot use reserved kickstart mountPath /kickstart when kickstart.enabled is true" }}
{{- end }}
{{- end }}
{{- end }}
{{- range .Values.extraInitContainers }}
{{- if has .name (list "wait-for-db" "wait-for-search") }}
{{- fail (printf "extraInitContainers cannot use reserved init container name %s" .name) }}
{{- end }}
{{- end }}
{{- range .Values.extraContainers }}
{{- if eq .name $.Chart.Name }}
{{- fail (printf "extraContainers cannot use reserved container name %s" $.Chart.Name) }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Render FusionAuth container environment variables. User-supplied entries in
.Values.environment are rendered first and take precedence over chart-managed
entries with the same name.
*/}}
{{- define "fusionauth.deployment.env" -}}
{{- $databaseUsernameEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_USERNAME")) "true" -}}
{{- $databasePasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_PASSWORD")) "true" -}}
{{- $databaseRootUsernameEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_USERNAME")) "true" -}}
{{- $databaseRootPasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_PASSWORD")) "true" -}}
{{- $databaseUrlEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_URL")) "true" -}}
{{- $searchTypeEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_TYPE")) "true" -}}
{{- $searchUsernameEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_USERNAME")) "true" -}}
{{- $searchPasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_PASSWORD")) "true" -}}
{{- $searchServersEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_SERVERS")) "true" -}}
{{- $appMemoryEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "FUSIONAUTH_APP_MEMORY")) "true" -}}
{{- $appRuntimeModeEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "FUSIONAUTH_APP_RUNTIME_MODE")) "true" -}}
{{- $appSilentModeEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "FUSIONAUTH_APP_SILENT_MODE")) "true" -}}
{{- $appKickstartFileEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "FUSIONAUTH_APP_KICKSTART_FILE")) "true" -}}
{{- $databaseFusionAuthUsernameFromExistingSecretEnabled := eq (include "fusionauth.database.fusionauthUser.usernameFromExistingSecret.enabled" .) "true" -}}
{{- $databaseRootUsernameFromExistingSecretEnabled := eq (include "fusionauth.database.rootUser.usernameFromExistingSecret.enabled" .) "true" -}}
{{- $databaseRootUserConfigured := eq (include "fusionauth.database.rootUser.configured" .) "true" -}}
{{- $searchExistingSecretEnabled := eq (include "fusionauth.search.existingSecret.enabled" .) "true" -}}
{{- $chartSearchEnabled := eq (include "fusionauth.search.chartEnabled" .) "true" -}}
{{- if .Values.environment }}{{ toYaml .Values.environment }}{{ end -}}
{{- if not $databaseUsernameEnv }}
- name: DATABASE_USERNAME
  {{- if $databaseFusionAuthUsernameFromExistingSecretEnabled }}
  valueFrom:
    secretKeyRef:
      name: {{ include "fusionauth.database.fusionauthUser.secretName" . }}
      key: {{ include "fusionauth.database.fusionauthUser.usernameKey" . | quote }}
  {{- else }}
  value: {{ required "A valid username for the database is required!" (include "fusionauth.database.fusionauthUser.username" .) | quote }}
  {{- end }}
{{- end }}
{{- if not $databasePasswordEnv }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "fusionauth.database.fusionauthUser.secretName" . }}
      key: {{ include "fusionauth.database.fusionauthUser.passwordKey" . | quote }}
{{- end }}
{{- if $databaseRootUserConfigured }}
{{- if not $databaseRootUsernameEnv }}
- name: DATABASE_ROOT_USERNAME
  {{- if $databaseRootUsernameFromExistingSecretEnabled }}
  valueFrom:
    secretKeyRef:
      name: {{ include "fusionauth.database.rootUser.secretName" . }}
      key: {{ include "fusionauth.database.rootUser.usernameKey" . | quote }}
  {{- else }}
  value: {{ include "fusionauth.database.rootUser.username" . | quote }}
  {{- end }}
{{- end }}
{{- if not $databaseRootPasswordEnv }}
- name: DATABASE_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "fusionauth.database.rootUser.secretName" . }}
      key: {{ include "fusionauth.database.rootUser.passwordKey" . | quote }}
{{- end }}
{{- end }}
{{- if not $databaseUrlEnv }}
- name: DATABASE_URL
  value: "jdbc:{{ .Values.database.protocol }}://{{- required "A valid database host is required!" .Values.database.host -}}:{{ .Values.database.port }}/{{ .Values.database.name }}{{ include "fusionauth.databaseTLS" . }}"
{{- end }}
{{- if not $searchTypeEnv }}
- name: SEARCH_TYPE
  value: {{ .Values.search.engine | quote }}
{{- end }}
{{- if or $chartSearchEnabled $searchServersEnv }}
{{- if and $searchExistingSecretEnabled (not $searchUsernameEnv) }}
- name: SEARCH_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ required "search.basicAuth.existingSecret.name is required when search basic auth uses an existing secret" (include "fusionauth.search.existingSecret.name" .) | quote }}
      key: {{ include "fusionauth.search.existingSecret.userKey" . | quote }}
{{- end }}
{{- if and $searchExistingSecretEnabled (not $searchPasswordEnv) }}
- name: SEARCH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ required "search.basicAuth.existingSecret.name is required when search basic auth uses an existing secret" (include "fusionauth.search.existingSecret.name" .) | quote }}
      key: {{ include "fusionauth.search.existingSecret.passwordKey" . | quote }}
{{- end }}
{{- end }}
{{- if and $chartSearchEnabled (not $searchServersEnv) }}
- name: SEARCH_SERVERS
  value: "{{ .Values.search.protocol }}://{{ include "fusionauth.searchLogin" . }}{{- required "A valid elasticsearch host is required!" .Values.search.host -}}:{{ .Values.search.port }}"
{{- end }}
{{- if not $appMemoryEnv }}
- name: FUSIONAUTH_APP_MEMORY
  value: {{ .Values.app.memory | quote }}
{{- end }}
{{- if not $appRuntimeModeEnv }}
- name: FUSIONAUTH_APP_RUNTIME_MODE
  value: {{ .Values.app.runtimeMode | quote }}
{{- end }}
{{- if not $appSilentModeEnv }}
- name: FUSIONAUTH_APP_SILENT_MODE
  value: {{ .Values.app.silentMode | quote }}
{{- end }}
{{- if and .Values.kickstart.enabled (not $appKickstartFileEnv) }}
- name: FUSIONAUTH_APP_KICKSTART_FILE
  value: {{ .Values.kickstart.file | quote }}
{{- end }}
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
