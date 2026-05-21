{{/* vim: set filetype=mustache: */}}
{{/*
Configure TLS if enabled
*/}}
{{- define "fusionauth.databaseTLS" -}}
{{- if .Values.database.tls -}}
?sslmode={{ .Values.database.tlsMode }}
{{- end -}}
{{- end -}}

{{/*
Resolve FusionAuth database username.
- Current: database.dbUser.username
- Legacy:  database.user, which takes precedence when set for compatibility
*/}}
{{- define "fusionauth.database.dbUser.username" -}}
{{- $database := .Values.database | default dict -}}
{{- $dbUser := $database.dbUser | default dict -}}
{{- if $database.user -}}
{{- $database.user -}}
{{- else -}}
{{- $dbUser.username | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve FusionAuth database password.
- Current: database.dbUser.password
- Legacy:  database.password
*/}}
{{- define "fusionauth.database.dbUser.password" -}}
{{- $database := .Values.database | default dict -}}
{{- $dbUser := $database.dbUser | default dict -}}
{{- if $dbUser.password -}}
{{- $dbUser.password -}}
{{- else -}}
{{- $database.password | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Validate FusionAuth database credential combinations.
*/}}
{{- define "fusionauth.database.dbUser.validate" -}}
{{- $database := .Values.database | default dict -}}
{{- $dbUser := $database.dbUser | default dict -}}
{{- if and $database.password (not $database.user) -}}
{{- fail "database.user is required when database.password is set" -}}
{{- end -}}
{{- if and $dbUser.password (not $dbUser.username) -}}
{{- fail "database.dbUser.username is required when database.dbUser.password is set" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether FusionAuth database credentials should come from an existing
secret.
- Current: database.dbUser.existingSecret.enabled
- Legacy:  database.existingSecret string
*/}}
{{- define "fusionauth.database.dbUser.existingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $dbUser := $database.dbUser | default dict -}}
{{- $dbUserExistingSecret := $dbUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if $dbUserExistingSecret.enabled -}}
true
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- if $legacyExistingSecret -}}true{{- else -}}false{{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve the FusionAuth database Secret name.
- Current: database.dbUser.existingSecret.name
- Legacy:  database.existingSecret
*/}}
{{- define "fusionauth.database.dbUser.secretName" -}}
{{- $database := .Values.database | default dict -}}
{{- $dbUser := $database.dbUser | default dict -}}
{{- $dbUserExistingSecret := $dbUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if eq (include "fusionauth.database.dbUser.existingSecret.enabled" .) "true" -}}
{{- if $dbUserExistingSecret.enabled -}}
{{- required "database.dbUser.existingSecret.name is required when database.dbUser.existingSecret.enabled is true" $dbUserExistingSecret.name -}}
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- required "database.existingSecret must not be empty when used as a secret name" $legacyExistingSecret -}}
{{- else -}}
{{- required "database.dbUser.existingSecret.name is required when database.dbUser.existingSecret.enabled is true" $dbUserExistingSecret.name -}}
{{- end -}}
{{- else -}}
{{ .Release.Name }}-db-credentials
{{- end -}}
{{- end -}}

{{/*
Resolve the FusionAuth database password key.
- Current: database.dbUser.existingSecret.passwordKey
- Legacy:  n/a
*/}}
{{- define "fusionauth.database.dbUser.passwordKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $dbUser := $database.dbUser | default dict -}}
{{- $dbUserExistingSecret := $dbUser.existingSecret | default dict -}}
{{- if and $dbUserExistingSecret.enabled $dbUserExistingSecret.passwordKey -}}
{{- $dbUserExistingSecret.passwordKey -}}
{{- else -}}
password
{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should create the FusionAuth database credentials
Secret. If DATABASE_PASSWORD is supplied through .Values.environment, that env
var takes precedence and the generated Secret is not needed.
*/}}
{{- define "fusionauth.database.dbUser.generatedSecret.enabled" -}}
{{- $existingSecret := eq (include "fusionauth.database.dbUser.existingSecret.enabled" .) "true" -}}
{{- $databasePasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_PASSWORD")) "true" -}}
{{- if and (not $existingSecret) (not $databasePasswordEnv) -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve root database username.
- Current: database.rootUser.username
- Legacy:  database.root.user, which takes precedence when set for compatibility
*/}}
{{- define "fusionauth.database.rootUser.username" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $legacyRootUser := $database.root | default dict -}}
{{- if $legacyRootUser.user -}}
{{- $legacyRootUser.user -}}
{{- else -}}
{{- $rootUser.username | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve root database password.
- Current: database.rootUser.password
- Legacy:  database.root.password
*/}}
{{- define "fusionauth.database.rootUser.password" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $legacyRootUser := $database.root | default dict -}}
{{- if $rootUser.password -}}
{{- $rootUser.password -}}
{{- else -}}
{{- $legacyRootUser.password | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Validate root database credential combinations.
*/}}
{{- define "fusionauth.database.rootUser.validate" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $legacyRootUser := $database.root | default dict -}}
{{- if and $legacyRootUser.password (not $legacyRootUser.user) -}}
{{- fail "database.root.user is required when database.root.password is set" -}}
{{- end -}}
{{- if and $rootUser.password (not $rootUser.username) -}}
{{- fail "database.rootUser.username is required when database.rootUser.password is set" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether root database credentials should come from an existing secret.
- Current: database.rootUser.existingSecret.enabled
- Legacy:  database.existingSecret string
*/}}
{{- define "fusionauth.database.rootUser.existingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if $rootUserExistingSecret.enabled -}}
true
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- if $legacyExistingSecret -}}true{{- else -}}false{{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve the root database Secret name.
- Current: database.rootUser.existingSecret.name
- Legacy:  database.existingSecret
*/}}
{{- define "fusionauth.database.rootUser.secretName" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if eq (include "fusionauth.database.rootUser.existingSecret.enabled" .) "true" -}}
{{- if $rootUserExistingSecret.enabled -}}
{{- required "database.rootUser.existingSecret.name is required when database.rootUser.existingSecret.enabled is true" $rootUserExistingSecret.name -}}
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- required "database.existingSecret must not be empty when used as a secret name" $legacyExistingSecret -}}
{{- else -}}
{{- required "database.rootUser.existingSecret.name is required when database.rootUser.existingSecret.enabled is true" $rootUserExistingSecret.name -}}
{{- end -}}
{{- else -}}
{{ .Release.Name }}-db-root-credentials
{{- end -}}
{{- end -}}

{{/*
Resolve the root database password key.
- Current: database.rootUser.existingSecret.passwordKey
- Legacy:  database.existingSecret string uses rootpassword
*/}}
{{- define "fusionauth.database.rootUser.passwordKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if and $rootUserExistingSecret.enabled $rootUserExistingSecret.passwordKey -}}
{{- $rootUserExistingSecret.passwordKey -}}
{{- else if and (not $rootUserExistingSecret.enabled) $legacyExistingSecret (kindIs "string" $legacyExistingSecret) -}}
rootpassword
{{- else -}}
password
{{- end -}}
{{- end -}}

{{/*
Resolve whether root database credentials are configured.
*/}}
{{- define "fusionauth.database.rootUser.configured" -}}
{{- $databaseRootUsernameEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_USERNAME")) "true" -}}
{{- if or (include "fusionauth.database.rootUser.username" .) $databaseRootUsernameEnv -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should create the root database credentials Secret.
If DATABASE_ROOT_PASSWORD is supplied through .Values.environment, that env var
takes precedence and the generated Secret is not needed.
*/}}
{{- define "fusionauth.database.rootUser.generatedSecret.enabled" -}}
{{- $existingSecret := eq (include "fusionauth.database.rootUser.existingSecret.enabled" .) "true" -}}
{{- $databaseRootPasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_ROOT_PASSWORD")) "true" -}}
{{- if and (eq (include "fusionauth.database.rootUser.configured" .) "true") (not $existingSecret) (not $databaseRootPasswordEnv) -}}true{{- else -}}false{{- end -}}
{{- end -}}
