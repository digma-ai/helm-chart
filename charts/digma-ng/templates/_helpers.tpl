{{- define "replicas.value" -}}
{{- $value := .value -}}
{{- if (typeOf $value | eq "float64") -}}
{{ $value }}
{{- else -}}
{{ tpl $value .context }}
{{- end -}}
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
Return the proper collector api fullname
*/}}
{{- define "digma.collector-api" -}}
  {{- printf "%s-collector-api" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper scheduler fullname
*/}}
{{- define "digma.scheduler" -}}
  {{- printf "%s-scheduler" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}


{{/*
Return the proper collector-worker fullname
*/}}
{{- define "digma.collector-worker" -}}
  {{- printf "%s-collector-worker" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper pipeline-worker fullname
*/}}
{{- define "digma.pipeline-worker" -}}
  {{- printf "%s-pipeline-worker" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper measurement-analysis fullname
*/}}
{{- define "digma.measurement-analysis" -}}
  {{- printf "%s-measurement-analysis" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper ui fullname
*/}}
{{- define "digma.ui" -}}
  {{- printf "%s-ui" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper ui service external url
*/}}
{{- define "digma.report.uiServiceBaseUrl" -}}
{{- if not (empty (default "" .Values.digma.report.uiExternalBaseUrl)) -}}
{{.Values.digma.report.uiExternalBaseUrl}}
{{- else }}
{{- if and .Values.ui.ingress.enabled (and .Values.ui.ingress.hostname (ne .Values.ui.ingress.hostname "")) }}
{{- printf "https://%s" .Values.ui.ingress.hostname -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper otel collector fullname
*/}}
{{- define "digma.otel-collector" -}}
  {{- printf "%s-otel-collector" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Get the otel collector configuration configmap.
*/}}
{{- define "otel-collector.configmapName" -}}
{{- if .Values.otelCollector.existingConfigmap -}}
    {{- include "common.tplvalues.render" (dict "value" .Values.otelCollector.existingConfigmap "context" .) -}}
{{- else }}
    {{- include "digma.otel-collector" . -}}
{{- end -}}
{{- end -}}

{{/*
Get the otel collector configuration configmap key.
*/}}
{{- define "otel-collector.configmapKey" -}}
{{- if .Values.otelCollector.existingConfigmapKey -}}
    {{- include "common.tplvalues.render" (dict "value" .Values.otelCollector.existingConfigmapKey "context" .) -}}
{{- else }}
    {{- printf "config.yaml" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper otel collector df (dogfooding) fullname
*/}}
{{- define "digma.otel-collector-df" -}}
  {{- printf "%s-otel-collector-df" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper otel collector df scraper url
*/}}
{{- define "digma.otel-collector-df-prometheus-scraper-url" -}}
{{- printf "%s:%v" (include "digma.otel-collector-df" .) .Values.otelCollectorDf.service.ports.prometheus_scraper -}}
{{- end -}}

{{/*
Return the proper otel collector df grpc url
*/}}
{{- define "digma.otel-collector-df-grpc" -}}
{{ printf "http://%s:%v" (include "digma.otel-collector-df" .) .Values.otelCollectorDf.service.ports.grpc }}
{{- end -}}


{{/*
Return the proper debug fullname
*/}}
{{- define "digma.debug" -}}
{{- printf "%s-debug" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper postgres fullname
*/}}
{{- define "digma.postgresql" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{/*
Return postgres connectivity env
*/}}
{{- define "env.postgres" -}}
- name: ConnectionStrings__Postgres
  value:  {{ printf "Server=%s;Port=%v;Database=digma_analytics;User Id=%s;Password=%s;" ( include "digma.database.host" . ) ( include "digma.database.port" . ) ( include "digma.database.user" . ) ( include "digma.database.password" . )}}
{{- end -}}

{{/*
Return the Database Hostname
*/}}
{{- define "digma.database.host" -}}
{{- ternary (include "digma.postgresql" .) .Values.digma.externals.postgresql.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the proper postgresql metrics url
*/}}
{{- define "digma.postgresql.metrics.url" -}}
{{- if eq (include "digma.postgresql.metrics.enabled" .) "true" -}}
{{ printf "%s:%v" (include "digma.postgresql.metrics.host" .) .Values.postgresql.metrics.containerPorts.metrics }}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper postgresql metrics host
*/}}
{{- define "digma.postgresql.metrics.host" -}}
{{- if eq (include "digma.postgresql.metrics.enabled" .) "true" -}}
{{- printf "%s-metrics" (include "digma.postgresql.fullname" .) | trunc 63 | trimSuffix "-" -}}
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
{{- ternary .Values.postgresql.auth.username .Values.digma.externals.postgresql.user .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Return the proper influx fullname
*/}}
{{- define "digma.influx.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "influxdb" "chartValues" .Values.influxdb "context" $) -}}
{{- end -}}

{{/*
Return influx connectivity env
*/}}
{{- define "env.influx" -}}
- name: influx2__Url
  value: {{ printf "http://%s:%v" (include "digma.influx.fullname" .) .Values.influxdb.influxdb.service.ports.http }}
{{- end -}}

{{/*
Return the proper redis fullname
*/}}
{{- define "digma.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Return redis connectivity env
*/}}
{{- define "env.redis" -}}
- name: CacheSettings__RedisConnection
  value: {{ (include "digma.redis.host" .) }}
- name: ExternalLogging__ConnectionString
  value: {{ (include "digma.redis.host" .) }}
{{- end -}}


{{/*
Return the proper redis host
*/}}
{{- define "digma.redis.host" -}}
{{- if .Values.redis.enabled -}}
    {{- printf "%s-master" (include "digma.redis.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{- print .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper redis metrics host
*/}}
{{- define "digma.redis.metrics.host" -}}
{{- if eq (include "digma.redis.metrics.enabled" .) "true" -}}
{{- printf "%s-metrics" (include "digma.redis.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper redis metrics url
*/}}
{{- define "digma.redis.metrics.url" -}}
{{- if eq (include "digma.redis.metrics.enabled" .) "true" -}}
{{ printf "%s:%v" (include "digma.redis.metrics.host" .) .Values.redis.metrics.containerPorts.http }}
{{- else -}}
{{- print "" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper redis metrics enabled
*/}}
{{- define "digma.redis.metrics.enabled" -}}
{{- if and .Values.redis.metrics.enabled .Values.redis.enabled -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Return the proper jaeger fullname
*/}}
{{- define "digma.jaeger" -}}
  {{- printf "%s-jaeger" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper jaeger-ui fullname
*/}}
{{- define "digma.jaeger.ui" -}}
  {{- printf "%s-jaeger-ui" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}


{{/*
Return the proper nginx fullname
*/}}
{{- define "digma.nginx" -}}
  {{- printf "%s-nginx" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return jaeger connectivity env
*/}}
{{- define "env.jaeger" -}}
- name: Jaeger__OtlpUrl
  value: {{ printf "http://%s:%v" (include "digma.jaeger" .) .Values.jaeger.service.ports.grpc_internal }}
{{- end -}}

{{/*
Return the proper elasticsearch fullname
*/}}
{{- define "digma.elasticsearch.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "elasticsearch" "chartValues" .Values.elasticsearch "context" $) -}}
{{- end -}}

{{/*
Return elasticsearch url
*/}}
{{- define "digma.elasticsearch.url" -}}
 {{ printf "http://%s:%v" (include "digma.elasticsearch.fullname" .) .Values.elasticsearch.service.ports.restAPI }}
{{- end -}}

{{/*
Return elasticsearch connectivity env
*/}}
{{- define "env.elasticsearch" -}}
- name: ElasticSearch__Uri
  value: {{ include "digma.elasticsearch.url" . }}
{{- end -}}

{{/*
Return the proper kafka fullname
*/}}
{{- define "digma.kafka.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "kafka" "chartValues" .Values.kafka "context" $) -}}
{{- end -}}

{{/*
Return kafka client url
*/}}
{{- define "digma.kafka.client" -}}
{{ printf "%s:%v" (include "digma.kafka.fullname" .) .Values.kafka.service.ports.client }}
{{- end -}}

{{/*
Return kafka connectivity env
*/}}
{{- define "env.kafka" -}}
- name: Kafka__Urls__0
  value: {{include "digma.kafka.client" .}}
{{- end -}}

{{/*
Return the proper grafana fullname
*/}}
{{- define "digma.grafana.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "grafana" "chartValues" .Values.grafana "context" $) -}}
{{- end -}}


{{/*
Return the proper prometheus fullname
*/}}
{{- define "digma.prometheus.fullname" -}}
{{- printf "%s-server" (include "digma.prometheus" .) }}
{{- end -}}

{{/*
Return the proper prometheus name
*/}}
{{- define "digma.prometheus" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "prometheus" "chartValues" .Values.prometheus "context" $) -}}
{{- end -}}

{{/*
Return prometheus url
*/}}
{{- define "digma.prometheus.url" -}}
{{ printf "http://%s:%v" (include "digma.prometheus.fullname" .) .Values.prometheus.server.service.ports.http }}
{{- end -}}


{{/*
Return the proper metrics exporter fullname
*/}}
{{- define "digma.k8s-metrics-exporter" -}}
{{- printf "%s-k8s-metrics-exporter" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return metrics exporter target url
*/}}
{{- define "digma.k8s-metrics-exporter-target" -}}
{{ printf "%s:%v" ( include "digma.k8s-metrics-exporter" . ) .Values.metricsExporter.service.ports.http}}
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
Return true if observability enabled
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
  value: {{ required "A valid .Values.digma.licenseKey entry is required. If you've signed up for a free Digma account you should have received a Digma license to use. check https://docs.digma.ai/digma-developer-guide/installation/central-on-prem-install" .Values.digma.licenseKey }}
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
  value: "false"
  {{- end -}}
{{- end -}}






