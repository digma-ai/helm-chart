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
  value:  {{ printf "Server=%s;Port=%v;Database=digma_analytics;User Id=%s;Password=%s;" ( tpl .Values.postgres.host . ) .Values.postgres.port .Values.postgres.username .Values.postgres.password}}
{{- end -}}


{{- define "env.kafka" -}}
- name: Kafka__Urls__0
  value: {{ tpl .Values.kafka.host . }}:9092
{{- end -}}


{{- define "env.redis" -}}
- name: CacheSettings__RedisConnection
  value: {{ tpl .Values.redis.host . }}
{{- end -}}


{{- define "env.influx" -}}
- name: influx2__Url
  value: {{ printf " http://%s:8086" (tpl .Values.influx.host .)}}
{{- end -}}

{{- define "env.embeddedJaeger" -}}
{{- if .Values.embeddedJaeger.enabled -}}
- name: Jaeger__OtlpUrl
  value: {{ printf " http://%s:4317" (tpl .Values.embeddedJaeger.host .)}}
{{- end -}}
{{- end -}}

# Digma to meloona
{{- define "env.otlpExporter" -}}
- name: OtlpExporterUrl
  value: {{ .Values.digmaSelfDiagnosis.otlpExporterEndpoint }}
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


{{- define "env.otlpExporter2ElasticApm" -}}
- name: OtlpExporterUrl
  value: {{ printf "http://%s:8200" (tpl .Values.elasticApmServer.host .)}}
{{- end -}}


{{- define "env.elasticsearch" -}}
- name: ElasticSearch
  value: {{ printf " http://%s:9200" (tpl .Values.elasticsearch.host .)}}
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

