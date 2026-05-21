{{/* vim: set filetype=mustache: */}}
{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fusionauth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels applied to FusionAuth resources.
*/}}
{{- define "fusionauth.labels" -}}
app.kubernetes.io/name: {{ include "fusionauth.name" . }}
helm.sh/chart: {{ include "fusionauth.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels used by Services, workload selectors, and pods.
Keep these stable because selector labels are immutable on several resources.
*/}}
{{- define "fusionauth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fusionauth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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
