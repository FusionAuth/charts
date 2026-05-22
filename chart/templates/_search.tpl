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
{{- else if or .Values.search.user .Values.search.password .Values.search.basicAuth.existingSecret.enabled -}}
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
{{- printf "%s:%s@" $username $password -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether chart-managed Elasticsearch/OpenSearch env and wait behavior
should be rendered.
*/}}
{{- define "fusionauth.search.chartEnabled" -}}
{{- if eq .Values.search.engine "elasticsearch" -}}true{{- else -}}false{{- end -}}
{{- end -}}
