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
Fail when .Values.environment attempts to override chart-managed FusionAuth
environment variables. Use the corresponding chart values instead.
*/}}
{{- define "fusionauth.environment.validate" -}}
{{- $reserved := list
  "DATABASE_USERNAME"
  "DATABASE_PASSWORD"
  "DATABASE_ROOT_USERNAME"
  "DATABASE_ROOT_PASSWORD"
  "DATABASE_URL"
  "SEARCH_TYPE"
  "SEARCH_USERNAME"
  "SEARCH_PASSWORD"
  "SEARCH_SERVERS"
  "FUSIONAUTH_APP_MEMORY"
  "FUSIONAUTH_APP_RUNTIME_MODE"
  "FUSIONAUTH_APP_SILENT_MODE"
  "FUSIONAUTH_APP_KICKSTART_FILE"
-}}
{{- range .Values.environment -}}
{{- if has .name $reserved -}}
{{- fail (printf "environment cannot override chart-managed variable %s; use the corresponding chart value instead" .name) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Build a container image reference.

repository keeps its historical meaning: a full image repository path that may
already include a registry. When registry is explicitly set, either on the image
or globally, it replaces any registry already present in repository.
*/}}
{{- define "fusionauth.image" -}}
{{- $root := .root -}}
{{- $image := .image -}}
{{- $repository := $image.repository -}}
{{- $globalRegistry := $root.Values.global.imageRegistry -}}
{{- $registry := default $globalRegistry $image.registry -}}
{{- if $registry -}}
{{- $repositoryParts := splitList "/" $repository -}}
{{- $firstPart := first $repositoryParts -}}
{{- if or (contains "." $firstPart) (contains ":" $firstPart) (eq $firstPart "localhost") -}}
{{- $repository = join "/" (rest $repositoryParts) -}}
{{- end -}}
{{- printf "%s/%s:%s" (trimSuffix "/" $registry) $repository $image.tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $image.tag -}}
{{- end -}}
{{- end -}}
