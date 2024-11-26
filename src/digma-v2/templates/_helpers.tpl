{{- define "replicas.value" -}}
{{- $value := .value -}}
{{- if (typeOf $value | eq "float64") -}}
{{ $value }}
{{- else -}}
{{ tpl $value .context }}
{{- end -}}
{{- end -}}

{{/*
Return the proper postgres fullname
*/}}
{{- define "digma.postgresql" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "postgresql" "chartValues" .Values.postgresql "context" $) -}}
{{- end -}}

{{- define "digma.influx.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "influxdb" "chartValues" .Values.influxdb "context" $) -}}
{{- end -}}

{{- define "env.influx" -}}
- name: influx2__Url
  value: {{ printf "http://%s:%v" (include "digma.influx.fullname" .) .Values.influxdb.service.ports.http }}
{{- end -}}

{{/*
Return the proper redis fullname
*/}}
{{- define "digma.redis.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "redis" "chartValues" .Values.redis "context" $) -}}
{{- end -}}

{{/*
Create a default fully qualified Redis name.
*/}}
{{- define "digma.redis.host" -}}
{{- if .Values.redis.enabled -}}
    {{- printf "%s-master" (include "digma.redis.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{- print .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper scheduler fullname
*/}}
{{- define "digma.scheduler" -}}
  {{- printf "%s-scheduler" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper digma fullname
*/}}
{{- define "digma.jaeger" -}}
  {{- printf "%s-jaeger" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
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
Return the proper otel collector df fullname
*/}}
{{- define "digma.otel-collector-df" -}}
  {{- printf "%s-otel-collector-df" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper otel collector df fullname
*/}}
{{- define "digma.otel-collector-df-prometheus-scraper-url" -}}
{{ printf "%s:%v" (include "digma.otel-collector-df" .) .Values.otelCollectorDf.service.ports.prometheus_scraper }}
{{- end -}}


{{/*
Return the proper otel collector fullname
*/}}
{{- define "digma.otel-collector" -}}
  {{- printf "%s-otel-collector" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper collector api fullname
*/}}
{{- define "digma.collector-api" -}}
  {{- printf "%s-collector-api" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}
  
{{/*
Return the proper analytics api fullname
*/}}
{{- define "digma.analytics-api" -}}
  {{- printf "%s-analytics-api" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Return the proper ui fullname
*/}}
{{- define "digma.ui" -}}
  {{- printf "%s-ui" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}


{{/*
Return the proper metrics exporter fullname
*/}}
{{- define "digma.k8s-metrics-exporter" -}}
  {{- printf "%s-k8s-metrics-exporter" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}


{{- define "digma.k8s-metrics-exporter-target" -}}
{{ printf "%s:%v" ( include "digma.k8s-metrics-exporter" . ) .Values.metricsExporter.service.ports.http}}
{{- end -}}



{{- define "env.digmaEnv" -}}
- name: DEPLOYMENT_ENV
  value: {{ .Values.digma.environmentName }}
{{- end -}}

      
{{- define "env.digmaSite" -}}
- name: Site
  value: {{ .Values.digma.siteName }}
{{- end -}}


{{- define "env.postgres" -}}
- name: ConnectionStrings__Postgres
  value:  {{ printf "Server=%s;Port=%v;Database=digma_analytics;User Id=%s;Password=%s;" ( include "digma.postgresql" . )  .Values.postgresql.primary.service.ports.postgresql .Values.postgresql.auth.username .Values.postgresql.auth.password}}
{{- end -}}


{{- define "env.kafka" -}}
- name: Kafka__Urls__0
  value: {{ tpl .Values.kafka.host . }}:9092
{{- end -}}


{{- define "env.redis" -}}
- name: CacheSettings__RedisConnection
  value: {{ (include "digma.redis.host" .) }}
- name: ExternalLogging__ConnectionString
  value: {{ (include "digma.redis.host" .) }}
{{- end -}}

{{- define "env.jaeger" -}}
- name: Jaeger__OtlpUrl
  value: {{ printf "http://%s:%v" (include "digma.jaeger" .) .Values.jaeger.service.ports.grpc_internal }}
{{- end -}}

# Digma to meloona
{{- define "env.otlpExporter" -}}
- name: OtlpExporterUrl
  value: {{ printf "http://%s-otel-collector:4317" (.Release.Name)}}
{{- end -}}

{{- define "env.otlpExportTraces" -}}
- name: OtlpExportTraces
  value: {{ quote .Values.digmaSelfDiagnosis.otlpExportTraces }}
{{- end -}}


{{- define "env.otlpExportMetrics" -}}
- name: OtlpExportMetrics
  value: {{ quote .Values.digmaSelfDiagnosis.otlpExportMetrics }}
{{- end -}}


{{- define "env.otlpExportLogs" -}}
- name: OtlpExportLogs
  value: {{ quote .Values.digmaSelfDiagnosis.otlpExportLogs }}
{{- end -}}


{{- define "digma.grafana.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "grafana" "chartValues" .Values.grafana "context" $) -}}
{{- end -}}

{{- define "digma.prometheus.fullname" -}}
  {{- printf "%s-service" (include "digma.prometheus" .) }}
{{- end -}}

{{- define "digma.prometheus" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "prometheus" "chartValues" .Values.prometheus "context" $) -}}
{{- end -}}

{{- define "digma.prometheus.url" -}}
{{ printf "http://%s:%v" (include "digma.prometheus.fullname" .) .Values.prometheus.server.service.ports.http }}
{{- end -}}


{{- define "digma.elasticsearch.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "elasticsearch" "chartValues" .Values.elasticsearch "context" $) -}}
{{- end -}}

{{- define "digma.elasticsearch.url" -}}
 {{ printf "http://%s:%v" (include "digma.elasticsearch.fullname" .) .Values.elasticsearch.service.ports.restAPI }}
{{- end -}}

{{- define "env.elasticsearch" -}}
- name: ElasticSearch__Uri
  value: {{ include "digma.elasticsearch.url" . }}
{{- end -}}

{{- define "env.versions" -}}
- name: ApplicationVersion
  value: {{.Chart.AppVersion}}
- name: ChartVersion
  value: {{.Chart.Version}}
{{- end -}}



{{- define "env.isCentralize" -}}
- name: IsCentralize
  value: {{.Values.digma.isCentralize | quote}}
{{- end -}}


{{- define "env.licenseKey" -}}
- name: DIGMA_LICENSE_KEY
  value: {{ required "A valid .Values.digma.licenseKey entry is required. If you've signed up for a free Digma account you should have received a Digma license to use. check https://docs.digma.ai/digma-developer-guide/installation/central-on-prem-install" .Values.digma.licenseKey }}
{{- end -}}

{{- define "env.digmaEnvType" -}}
- name: DIGMA_ENV_TYPE
  value: {{ .Values.digma.environmentType }}
{{- end -}}




{{- define "imagePullSecrets" -}}
{{- if .Values.imagePullSecretName -}}
imagePullSecrets:
- name: {{ .Values.imagePullSecretName }}
{{- end -}}
{{- end -}}

{{- define "tolerations" -}}
tolerations:
  {{- toYaml .Values.tolerations | nindent 8 }}
{{- end -}}

{{- define "nodeSelector" -}}
nodeSelector:
  {{- toYaml .Values.nodeSelector | nindent 8 }}
{{- end -}}