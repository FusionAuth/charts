{{/* vim: set filetype=mustache: */}}
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
