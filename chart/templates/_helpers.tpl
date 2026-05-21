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
