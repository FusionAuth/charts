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
Set apiVersion for HPA
*/}}
{{- define "fusionauth.HpaApiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
autoscaling/v2
{{- else -}}
autoscaling/v2beta2
{{- end -}}
{{- end -}}


{{/*
Set apiVersion for ingress
*/}}
{{- define "fusionauth.ingressApiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1" -}}
networking.k8s.io/v1
{{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
networking.k8s.io/v1beta1
{{- else -}}
extensions/v1beta1
{{- end -}}
{{- end -}}

{{/*
Set apiVersion for PodDisruptionBudget
*/}}
{{- define "fusionauth.PodDisruptionBudget" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" -}}
policy/v1
{{- else -}}
policy/v1beta1
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

{{- define "fusionauth.searchLogin" -}}
{{- if .Values.search.user -}}
{{- printf "%s:%s@" .Values.search.user .Values.search.password -}}
{{- else -}}
{{- printf "" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fusionauth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set name of secret to use for credentials
*/}}
{{- define "fusionauth.database.secretName" -}}
{{- if .Values.database.existingSecret -}}
{{- .Values.database.existingSecret -}}
{{- else -}}
{{ .Release.Name }}-credentials
{{- end -}}
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

{{/*
Determine probe path based on image tag and overrides
*/}}
{{- define "fusionauth.probePath" -}}
{{- $probeName := .probeName -}}
{{- $overridePath := "" -}}
{{- if eq $probeName "liveness" -}}
{{- $overridePath = .Values.livenessProbe.httpGet.path -}}
{{- else if eq $probeName "readiness" -}}
{{- $overridePath = .Values.readinessProbe.httpGet.path -}}
{{- else if eq $probeName "startup" -}}
{{- $overridePath = .Values.startupProbe.httpGet.path -}}
{{- end -}}
{{- if $overridePath -}}
{{- $overridePath -}}
{{- else -}}
{{- if semverCompare ">=1.52.0" .Values.image.tag -}}
/api/health
{{- else -}}
/
{{- end -}}
{{- end -}}
{{- end -}}
