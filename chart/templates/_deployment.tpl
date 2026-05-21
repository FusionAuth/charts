{{/* vim: set filetype=mustache: */}}
{{/*
Resolve the reserved kickstart config volume name.
*/}}
{{- define "fusionauth.kickstart.volumeName" -}}
{{- printf "%s-config-volume" (include "fusionauth.fullname" .) -}}
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
{{- include "fusionauth.database.dbUser.validate" . }}
{{- include "fusionauth.database.rootUser.validate" . }}
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
{{- $databaseRootUserConfigured := eq (include "fusionauth.database.rootUser.configured" .) "true" -}}
{{- $searchExistingSecretEnabled := eq (include "fusionauth.search.existingSecret.enabled" .) "true" -}}
{{- $chartSearchEnabled := eq (include "fusionauth.search.chartEnabled" .) "true" -}}
{{- if .Values.environment }}{{ toYaml .Values.environment }}{{ end -}}
{{- if not $databaseUsernameEnv }}
- name: DATABASE_USERNAME
  value: {{ required "database.dbUser.username is required unless DATABASE_USERNAME is set in environment; legacy database.user is also accepted" (include "fusionauth.database.dbUser.username" .) | quote }}
{{- end }}
{{- if not $databasePasswordEnv }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "fusionauth.database.dbUser.secretName" . }}
      key: {{ include "fusionauth.database.dbUser.passwordKey" . | quote }}
{{- end }}
{{- if $databaseRootUserConfigured }}
{{- if not $databaseRootUsernameEnv }}
- name: DATABASE_ROOT_USERNAME
  value: {{ include "fusionauth.database.rootUser.username" . | quote }}
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
  value: "jdbc:{{ .Values.database.protocol }}://{{- required "database.host is required unless DATABASE_URL is set in environment" .Values.database.host -}}:{{ .Values.database.port }}/{{ .Values.database.name }}{{ include "fusionauth.databaseTLS" . }}"
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
  value: "{{ .Values.search.protocol }}://{{ include "fusionauth.searchLogin" . }}{{- required "search.host is required when search.engine is elasticsearch unless SEARCH_SERVERS is set in environment" .Values.search.host -}}:{{ .Values.search.port }}"
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
