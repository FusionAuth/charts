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
Current value: database.fusionauthUser.username.
Backward compatibility: database.user is deprecated but still accepted.
*/}}
{{- define "fusionauth.database.fusionauthUser.username" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- if $fusionauthUser.username -}}
{{- $fusionauthUser.username -}}
{{- else -}}
{{- $database.user | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve FusionAuth database password.
Current value: database.fusionauthUser.password.
Backward compatibility: database.password is deprecated but still accepted.
*/}}
{{- define "fusionauth.database.fusionauthUser.password" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- if $fusionauthUser.password -}}
{{- $fusionauthUser.password -}}
{{- else -}}
{{- $database.password | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve whether FusionAuth database credentials should come from an existing
secret.
Current value: database.fusionauthUser.existingSecret.enabled.
Backward compatibility: database.existingSecret used to configure a shared
database secret and is still accepted for the FusionAuth user.
*/}}
{{- define "fusionauth.database.fusionauthUser.existingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if $fusionauthUserExistingSecret.enabled -}}
true
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- if $legacyExistingSecret -}}true{{- else -}}false{{- end -}}
{{- else if $legacyExistingSecret -}}
{{- $legacyExistingSecret.enabled | default false -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve whether the FusionAuth database username should come from an existing
secret. This only uses the current value.
Backward compatibility: legacy database.existingSecret was password-only, so it
does not imply that the username comes from a secret.
*/}}
{{- define "fusionauth.database.fusionauthUser.usernameFromExistingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- if $fusionauthUserExistingSecret.enabled -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve the FusionAuth database Secret name.
Current value: database.fusionauthUser.existingSecret.name.
Backward compatibility: database.existingSecret used to configure a shared
database secret. A legacy string value is used directly as the secret name.
*/}}
{{- define "fusionauth.database.fusionauthUser.secretName" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if eq (include "fusionauth.database.fusionauthUser.existingSecret.enabled" .) "true" -}}
{{- if $fusionauthUserExistingSecret.name -}}
{{- $fusionauthUserExistingSecret.name -}}
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- required "database.existingSecret must not be empty when used as a secret name" $legacyExistingSecret -}}
{{- else -}}
{{- required "database.fusionauthUser.existingSecret.name is required when database.fusionauthUser.existingSecret.enabled is true" $legacyExistingSecret.name -}}
{{- end -}}
{{- else -}}
{{ .Release.Name }}-credentials
{{- end -}}
{{- end -}}

{{/*
Resolve the FusionAuth database username key.
Current value: database.fusionauthUser.existingSecret.usernameKey.
Backward compatibility: legacy database.existingSecret values did not support a
username key, so they use the default username key.
*/}}
{{- define "fusionauth.database.fusionauthUser.usernameKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $fusionauthUserExistingSecret.usernameKey | default "username" -}}
{{- end -}}

{{/*
Resolve the FusionAuth database password key.
Current value: database.fusionauthUser.existingSecret.passwordKey.
Backward compatibility: database.existingSecret.passwordKey is deprecated but
still accepted.
*/}}
{{- define "fusionauth.database.fusionauthUser.passwordKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $fusionauthUser := $database.fusionauthUser | default dict -}}
{{- $fusionauthUserExistingSecret := $fusionauthUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- $fusionauthUserExistingSecretConfigured := or $fusionauthUserExistingSecret.enabled $fusionauthUserExistingSecret.name -}}
{{- if and $fusionauthUserExistingSecretConfigured $fusionauthUserExistingSecret.passwordKey -}}
{{- $fusionauthUserExistingSecret.passwordKey -}}
{{- else if and $legacyExistingSecret (kindIs "map" $legacyExistingSecret) $legacyExistingSecret.passwordKey -}}
{{- $legacyExistingSecret.passwordKey -}}
{{- else -}}
password
{{- end -}}
{{- end -}}

{{/*
Resolve whether the chart should create the FusionAuth database credentials
Secret. If DATABASE_PASSWORD is supplied through .Values.environment, that env
var takes precedence and the generated Secret is not needed.
*/}}
{{- define "fusionauth.database.fusionauthUser.generatedSecret.enabled" -}}
{{- $existingSecret := eq (include "fusionauth.database.fusionauthUser.existingSecret.enabled" .) "true" -}}
{{- $databasePasswordEnv := eq (include "fusionauth.environment.has" (dict "context" . "name" "DATABASE_PASSWORD")) "true" -}}
{{- if and (not $existingSecret) (not $databasePasswordEnv) -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve root database username.
Current value: database.rootUser.username.
Backward compatibility: database.root.user is deprecated but still accepted.
*/}}
{{- define "fusionauth.database.rootUser.username" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $legacyRootUser := $database.root | default dict -}}
{{- if $rootUser.username -}}
{{- $rootUser.username -}}
{{- else -}}
{{- $legacyRootUser.user | default "" -}}
{{- end -}}
{{- end -}}

{{/*
Resolve root database password.
Current value: database.rootUser.password.
Backward compatibility: database.root.password is deprecated but still accepted.
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
Resolve whether root database credentials should come from an existing secret.
Current value: database.rootUser.existingSecret.enabled.
Backward compatibility: database.existingSecret used to configure a shared
database secret and is still accepted for the root user.
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
{{- else if $legacyExistingSecret -}}
{{- $legacyExistingSecret.enabled | default false -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Resolve whether the root database username should come from an existing secret.
This only uses the current value.
Backward compatibility: legacy database.existingSecret was password-only, so it
does not imply that the username comes from a secret.
*/}}
{{- define "fusionauth.database.rootUser.usernameFromExistingSecret.enabled" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- if $rootUserExistingSecret.enabled -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{/*
Resolve the root database Secret name.
Current value: database.rootUser.existingSecret.name.
Backward compatibility: database.existingSecret used to configure a shared
database secret. A legacy string value is used directly as the secret name.
*/}}
{{- define "fusionauth.database.rootUser.secretName" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- if eq (include "fusionauth.database.rootUser.existingSecret.enabled" .) "true" -}}
{{- if $rootUserExistingSecret.name -}}
{{- $rootUserExistingSecret.name -}}
{{- else if kindIs "string" $legacyExistingSecret -}}
{{- required "database.existingSecret must not be empty when used as a secret name" $legacyExistingSecret -}}
{{- else -}}
{{- required "database.rootUser.existingSecret.name is required when database.rootUser.existingSecret.enabled is true" $legacyExistingSecret.name -}}
{{- end -}}
{{- else -}}
{{ .Release.Name }}-root-credentials
{{- end -}}
{{- end -}}

{{/*
Resolve the root database username key.
Current value: database.rootUser.existingSecret.usernameKey.
Backward compatibility: legacy database.existingSecret values did not support a
username key, so they use the default username key.
*/}}
{{- define "fusionauth.database.rootUser.usernameKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $rootUserExistingSecret.usernameKey | default "username" -}}
{{- end -}}

{{/*
Resolve the root database password key.
Current value: database.rootUser.existingSecret.passwordKey.
Backward compatibility: database.existingSecret.rootPasswordKey is deprecated
but still accepted.
*/}}
{{- define "fusionauth.database.rootUser.passwordKey" -}}
{{- $database := .Values.database | default dict -}}
{{- $rootUser := $database.rootUser | default dict -}}
{{- $rootUserExistingSecret := $rootUser.existingSecret | default dict -}}
{{- $legacyExistingSecret := $database.existingSecret -}}
{{- $rootUserExistingSecretConfigured := or $rootUserExistingSecret.enabled $rootUserExistingSecret.name -}}
{{- if and $rootUserExistingSecretConfigured $rootUserExistingSecret.passwordKey -}}
{{- $rootUserExistingSecret.passwordKey -}}
{{- else if and $legacyExistingSecret (kindIs "map" $legacyExistingSecret) $legacyExistingSecret.rootPasswordKey -}}
{{- $legacyExistingSecret.rootPasswordKey -}}
{{- else if and $legacyExistingSecret (kindIs "string" $legacyExistingSecret) -}}
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
{{- if or (include "fusionauth.database.rootUser.username" .) $databaseRootUsernameEnv (eq (include "fusionauth.database.rootUser.usernameFromExistingSecret.enabled" .) "true") -}}true{{- else -}}false{{- end -}}
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
