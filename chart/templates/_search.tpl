{{/* vim: set filetype=mustache: */}}
{{/*
Resolve whether search basic auth is enabled.
Current value: search.basicAuth.enabled.
Backward compatibility: deprecated search.user/search.password still imply that
basic auth is enabled.
*/}}
{{- define "fusionauth.search.basicAuth.enabled" -}}
{{- if .Values.search.basicAuth.enabled -}}
true
{{- else if or .Values.search.user .Values.search.password .Values.search.basicAuth.existingSecret.enabled (eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_USERNAME")) "true") (eq (include "fusionauth.environment.has" (dict "context" . "name" "SEARCH_PASSWORD")) "true") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Build the search login prefix for SEARCH_SERVERS.
Backward compatibility: deprecated search.user/search.password still render the
same URL prefix.
*/}}
{{- define "fusionauth.searchLogin" -}}
{{- if .Values.search.basicAuth.existingSecret.enabled -}}
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
