{{/* vim: set filetype=mustache: */}}
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
