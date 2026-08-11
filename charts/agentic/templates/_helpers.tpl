{{- define "replicas.value" -}}
{{- $value := .value -}}
{{- if or (typeOf $value | eq "float64") (typeOf $value | eq "int") (typeOf $value | eq "json.Number") -}}
{{ $value }}
{{- else -}}
{{ tpl $value .context }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the member global Secret to use.
*/}}
{{- define "digma.global.secretName" -}}
{{ include "common.secrets.name" (dict "defaultNameSuffix" "global-secret" "context" $) }}
{{- end -}}

{{/*
Create the key of the apiKey secret key name to use.
*/}}
{{- define "digma.emailSettingsApiKey.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "emailSettingsApiKey") }}
{{- end -}}

{{/*
Create the key of the licenseKey secret key name to use.
*/}}
{{- define "digma.licenseKey.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "licenseKey") }}
{{- end -}}


{{/*
Create the key of the postgresqlPassword secret key name to use.
*/}}
{{- define "digma.postgresqlPassword.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "postgresqlPassword") }}
{{- end -}}



{{/*
Return the emailSettings apiKey using fallback so support backward compatibility
*/}}
{{- define "digma.emailSettings.apiKey" -}}
{{- $emailGatewayApiKey := .Values.digma.emailSettings.apiKey }}
{{- if not $emailGatewayApiKey -}}
{{- $emailGatewayApiKey = .Values.digma.report.emailGateway.apiKey }}
{{- end -}}
{{- if $emailGatewayApiKey -}}
{{- printf "%s" $emailGatewayApiKey -}}
{{- end -}}
{{- end -}}


{{/*
Return the proper agentic api fullname
*/}}
{{- define "digma.agentic" -}}
  {{- printf "%s-agentic" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper agentic api url
*/}}
{{- define "digma.agentic.url" -}}
{{ printf "http://%s:%v" (include "digma.agentic" .) .Values.agentic.service.ports.http }}
{{- end -}}


{{/*
Return the proper ai api fullname
*/}}
{{- define "digma.ai" -}}
  {{- printf "%s-ai" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper ai api url
*/}}
{{- define "digma.ai.url" -}}
{{ printf "http://%s:%v" (include "digma.ai" .) .Values.ai.service.ports.http }}
{{- end -}}

{{/*
Return the proper analytics api fullname
*/}}
{{- define "digma.analytics-api" -}}
  {{- printf "%s-analytics-api" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return calculated secured property value
*/}}
{{- define "digma.analytics-api.secured" -}}
{{- if .Values.analyticsApi.ingress.enabled -}}
false
{{- else -}}
{{.Values.analyticsApi.secured}}
{{- end -}}
{{- end -}}

{{/*
Return http or https depending on the secured property value
*/}}
{{- define "digma.analytics-api.protocol" -}}
{{- if eq "true" (include "digma.analytics-api.secured" .) }}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{/*
Create the name of the member analytics-api secret to use.
*/}}
{{- define "digma.analytics-api.secretName" -}}
{{- include "digma.analytics-api" . -}}
{{- end -}}

{{/*
Create the key of the authPassword key name to use.
*/}}
{{- define "digma.analytics-api.authPassword.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "authPassword") }}
{{- end -}}


{{/*
Create the key of the accessToken secret key name to use.
*/}}
{{- define "digma.analytics-api.accessToken.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "accessToken") }}
{{- end -}}

{{/*
Create the key of the socialLoginGoogleSecret key name to use.
*/}}
{{- define "digma.analytics-api.socialLoginGoogleSecret.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "socialLoginGoogleSecret") }}
{{- end -}}


{{/*
Return the proper ui fullname
*/}}
{{- define "digma.ui" -}}
  {{- printf "%s-ui" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper ui.secretName fullname
*/}}
{{- define "digma.ui.secretName" -}}
  {{- printf "%s-ui" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create the key of the postHogApiKey secret key name to use.
*/}}
{{- define "digma.ui.postHogApiKey.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "postHogApiKey") }}
{{- end -}}

{{/*
Create the key of the productFruitsWorkspaceCode secret key name to use.
*/}}
{{- define "digma.ui.productFruitsWorkspaceCode.secretKeyName" -}}
{{ include "common.secrets.key" (dict "key" "productFruitsWorkspaceCode") }}
{{- end -}}

{{/*
Return the UI service base URL
*/}}
{{- define "digma.uiServiceBaseUrl" -}}
{{- $uiExternalBaseUrl := .Values.digma.uiExternalBaseUrl | default .Values.digma.report.uiExternalBaseUrl }}
{{- if not (empty (default "" $uiExternalBaseUrl)) -}}
{{$uiExternalBaseUrl}}
{{- else }}
{{- if and .Values.ui.ingress.enabled (and .Values.ui.ingress.hostname (ne .Values.ui.ingress.hostname "")) }}
{{- printf "https://%s" .Values.ui.ingress.hostname -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper postgres fullname
*/}}
{{- define "digma.postgresql" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}


{{/*
Return the proper postgresql metrics url
*/}}
{{- define "digma.postgresql.metrics.url" -}}
{{- if eq (include "digma.postgresql.metrics.enabled" .) "true" -}}
{{ printf "%s-metrics:%v" (include "digma.postgresql" .) .Values.postgresql.metrics.containerPorts.metrics }}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper postgresql metrics enabled
*/}}
{{- define "digma.postgresql.metrics.enabled" -}}
{{- if and .Values.postgresql.metrics.enabled .Values.postgresql.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}


{{/*
Return postgres connectivity env
*/}}
{{- define "env.postgres" -}}
- name: ConnectionStrings__Postgres
  value:  {{ printf "Server=%s;Port=%v;Database=digma_analytics;User Id=%s;Password=${POSTGRES_PASSWORD};Include Error Detail=true;" ( include "digma.database.host" . ) ( include "digma.database.port" . ) ( include "digma.database.user" . ) }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "digma.global.secretName" . }}
      key: {{ include "digma.postgresqlPassword.secretKeyName" . }}
{{- end -}}

{{/*
Return the Database Hostname
*/}}
{{- define "digma.database.host" -}}
{{- ternary (include "digma.postgresql" .) .Values.digma.externals.postgresql.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "digma.database.port" -}}
{{- ternary .Values.postgresql.primary.service.ports.postgresql .Values.digma.externals.postgresql.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the Database User
*/}}
{{- define "digma.database.user" -}}
{{- ternary .Values.postgresql.auth.username .Values.digma.externals.postgresql.user .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the Database Password
*/}}
{{- define "digma.database.password" -}}
{{- ternary .Values.postgresql.auth.password .Values.digma.externals.postgresql.password .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the proper nginx fullname
*/}}
{{- define "digma.nginx" -}}
  {{- printf "%s-nginx" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return true if observability enabled
*/}}
{{- define "digma.observability.enabled" -}}
{{- if or (.Values.observability.useLocal) (not (empty (default "" .Values.observability.otlp.remoteEndpoint))) }}
{{- print "true" -}}
{{- else -}}
{{- print "false" -}}
{{- end -}}
{{- end -}}

{{/*
Return remote endpoint url
*/}}
{{- define "observability.otlp.remoteEndpoint" -}}
{{- if (not (empty (default "" .Values.observability.otlp.remoteEndpoint))) }}
  {{- if (regexMatch ".*:[0-9]+$" .Values.observability.otlp.remoteEndpoint) -}}
{{ .Values.observability.otlp.remoteEndpoint }}
  {{- else -}}
{{ .Values.observability.otlp.remoteEndpoint }}:443
  {{- end }}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}




{{- define "env.digma.app.common" -}}
- name: BACKEND_DEPLOYMENT_TYPE
  value: Helm
- name: IsCentralize
  value: "true"
- name: DIGMA_LICENSE_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "digma.global.secretName" . }}
      key: {{ include "digma.licenseKey.secretKeyName" . }}
- name: ApplicationVersion
  value: {{.Chart.AppVersion}}
- name: ChartVersion
  value: {{.Chart.Version}}
  {{- if eq "true" (include "digma.observability.enabled" .) }}
- name: Site
  value: {{ .Values.observability.environmentName }}
- name: DEPLOYMENT_ENV
  value: {{ .Values.observability.environmentName }}
- name: DIGMA_ENV_TYPE
  value: "Public"
- name: OtlpExporterUrl
  value: {{ include "digma.otel-collector-df-grpc" .}}
- name: OtlpSamplerProbability
  value: {{ .Values.observability.otlp.samplerProbability| quote }}
- name: OtlpExportTraces
  value: {{ quote .Values.observability.otlp.exportTraces }}
- name: OtlpExportMetrics
  value: {{ quote .Values.observability.otlp.exportMetrics }}
- name: OtlpExportLogs
  value: {{ quote .Values.observability.otlp.exportLogs }}
  {{- end -}}
{{- end -}}

{{/*
Return email gateway configuration environment variables
*/}}
{{- define "env.digma.emailGateway" -}}
{{- $emailGatewayUrl := .Values.digma.emailSettings.url }}
{{- if not $emailGatewayUrl -}}
{{- $emailGatewayUrl = .Values.digma.report.emailGateway.url }}
{{- end }}
{{- if $emailGatewayUrl }}
- name: "EmailGateway__Url"
  value: {{ $emailGatewayUrl | quote}}
{{- end }}

{{- if include "digma.emailSettings.apiKey" . }}
- name: "EmailGateway__ApiKey"
  valueFrom:
    secretKeyRef:
      name: {{ include "digma.global.secretName" . }}
      key: {{ include "digma.emailSettingsApiKey.secretKeyName" . }}
{{- end }}
{{- end }}

{{/*
Return UI service base URL environment variable for analytics service
*/}}
{{- define "env.digma.analytics.uiServiceBaseUrl" -}}
{{- $uiServiceBaseUrl := include "digma.uiServiceBaseUrl" . }}
{{- if ne $uiServiceBaseUrl "" }}
- name: "DigmaIdentityConfig__UIServiceBaseUrl"
  value: {{ $uiServiceBaseUrl | quote}}
{{- end }}
{{- end }}

{{/*
Return all auth environment variables
*/}}
{{- define "env.auth.all" -}}
- name: Auth__EmailVerificationEnabled
  value: {{ .Values.digma.auth.emailVerificationEnabled | quote }}
{{- if .Values.digma.auth.email }}
- name: Auth__Email
  value: {{ .Values.digma.auth.email | quote }}
{{- end }}
{{- if .Values.digma.auth.password }}
- name: Auth__Password
  valueFrom:
    secretKeyRef:
      name: {{ include "digma.analytics-api.secretName" . }}
      key: {{ include "digma.analytics-api.authPassword.secretKeyName" . }}
{{- end }}
{{- if .Values.digma.auth.allowedEmailDomains }}
- name: Auth__AllowedEmailDomains
  value: {{ .Values.digma.auth.allowedEmailDomains | quote }}
{{- end }}
{{- if hasKey .Values.digma.auth "securedCookie" }}
- name: Auth__SecuredCookie
  value: {{ .Values.digma.auth.securedCookie | quote }}
{{- end }}
{{- end -}}


{{- define "nginx.common.api.headers" -}}
            add_header          X-Content-Type-Options  "nosniff";
            add_header          Referrer-Policy         "same-origin";
{{- end -}}
{{- define "nginx.common.file.headers" -}}
  {{- range $key, $val := .Values.nginx.commonHeaders }}
    add_header {{ $key }} "{{ $val }}";
  {{- end }}
{{- end -}}

{{- define "nginx.common.file.headers.lua" -}}
  {{- range $key, $val := .Values.nginx.commonHeaders }}
    ngx.header["{{ $key }}"] = [[{{ $val }}]]
  {{- end }}
{{- end -}}