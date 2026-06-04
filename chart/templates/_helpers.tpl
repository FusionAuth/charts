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
{{- $reserved := dict
  "DATABASE_USERNAME" "database.dbUser.username"
  "DATABASE_PASSWORD" "database.dbUser.password or database.dbUser.existingSecret"
  "DATABASE_ROOT_USERNAME" "database.rootUser.username"
  "DATABASE_ROOT_PASSWORD" "database.rootUser.password or database.rootUser.existingSecret"
  "DATABASE_URL" "database.url"
  "SEARCH_TYPE" "search.engine"
  "SEARCH_USERNAME" "search.basicAuth.username or search.basicAuth.existingSecret"
  "SEARCH_PASSWORD" "search.basicAuth.password or search.basicAuth.existingSecret"
  "SEARCH_SERVERS" "search.host, search.protocol, search.port, and search.basicAuth"
  "FUSIONAUTH_APP_MEMORY" "app.memory"
  "FUSIONAUTH_APP_RUNTIME_MODE" "app.runtimeMode"
  "FUSIONAUTH_APP_SILENT_MODE" "app.silentMode"
  "FUSIONAUTH_APP_KICKSTART_FILE" "kickstart.file"
-}}
{{- range .Values.environment -}}
{{- if hasKey $reserved .name -}}
{{- fail (printf "environment cannot override chart-managed variable %s; use chart value(s): %s" .name (get $reserved .name)) -}}
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
