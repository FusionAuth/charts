{{/* vim: set filetype=mustache: */}}
{{/*
Resolve the reserved kickstart config volume name.
*/}}
{{- define "fusionauth.kickstart.volumeName" -}}
{{- printf "%s-config-volume" (include "fusionauth.fullname" .) -}}
{{- end -}}

{{/*
Resolve whether the database wait init container should be rendered.
*/}}
{{- define "fusionauth.deployment.waitForDb.enabled" -}}
{{- if eq (include "fusionauth.initContainers.waitForDb" .) "true" -}}true{{- else -}}false{{- end -}}
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
{{- include "fusionauth.database.validate" . }}
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
Render FusionAuth container environment variables.
*/}}
{{- define "fusionauth.deployment.env" -}}
{{- $databaseRootUserConfigured := eq (include "fusionauth.database.rootUser.configured" .) "true" -}}
{{- $searchExistingSecretEnabled := .Values.search.basicAuth.existingSecret.enabled -}}
{{- $chartSearchEnabled := eq (include "fusionauth.search.chartEnabled" .) "true" -}}
{{- if .Values.environment }}{{ toYaml .Values.environment }}{{ end -}}
- name: DATABASE_USERNAME
  value: {{ required "database.dbUser.username is required; legacy database.user is also accepted" (include "fusionauth.database.dbUser.username" .) | quote }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "fusionauth.database.dbUser.secretName" . }}
      key: {{ include "fusionauth.database.dbUser.passwordKey" . | quote }}
{{- if $databaseRootUserConfigured }}
- name: DATABASE_ROOT_USERNAME
  value: {{ include "fusionauth.database.rootUser.username" . | quote }}
- name: DATABASE_ROOT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "fusionauth.database.rootUser.secretName" . }}
      key: {{ include "fusionauth.database.rootUser.passwordKey" . | quote }}
{{- end }}
- name: DATABASE_URL
  value: {{ include "fusionauth.database.url" . | quote }}
- name: SEARCH_TYPE
  value: {{ .Values.search.engine | quote }}
{{- if $chartSearchEnabled }}
{{- if $searchExistingSecretEnabled }}
- name: SEARCH_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ required "search.basicAuth.existingSecret.name is required when search basic auth uses an existing secret" .Values.search.basicAuth.existingSecret.name | quote }}
      key: {{ .Values.search.basicAuth.existingSecret.userKey | default "username" | quote }}
- name: SEARCH_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ required "search.basicAuth.existingSecret.name is required when search basic auth uses an existing secret" .Values.search.basicAuth.existingSecret.name | quote }}
      key: {{ .Values.search.basicAuth.existingSecret.passwordKey | default "password" | quote }}
{{- end }}
- name: SEARCH_SERVERS
  value: "{{ .Values.search.protocol }}://{{ include "fusionauth.searchLogin" . }}{{- required "search.host is required when search.engine is elasticsearch" .Values.search.host -}}:{{ .Values.search.port }}"
{{- end }}
- name: FUSIONAUTH_APP_MEMORY
  value: {{ .Values.app.memory | quote }}
- name: FUSIONAUTH_APP_RUNTIME_MODE
  value: {{ .Values.app.runtimeMode | quote }}
- name: FUSIONAUTH_APP_SILENT_MODE
  value: {{ .Values.app.silentMode | quote }}
{{- if .Values.kickstart.enabled }}
- name: FUSIONAUTH_APP_KICKSTART_FILE
  value: {{ .Values.kickstart.file | quote }}
{{- end }}
{{- end -}}
