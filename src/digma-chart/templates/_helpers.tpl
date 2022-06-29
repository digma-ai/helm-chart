{{- define "env.postgres" -}}
- name: ConnectionStrings__Postgres
  value:  {{ printf "Server=%s;Port=%v;Database=digma_analytics;User Id=%s;Password=%s;" ( tpl .Values.postgres.host . ) .Values.postgres.port .Values.postgres.username .Values.postgres.password}}
{{- end -}}


{{- define "env.redis" -}}
- name: CacheSettings__RedisConnection
  value: {{ tpl .Values.redis.host . }}
{{- end -}}


{{- define "env.influx" -}}
- name: influx2__Url
  value: {{ printf " http://%s:8086" (tpl .Values.influx.host .)}}
{{- end -}}


{{- define "env.rabbit" -}}
- name: RabbitMq__Host
  value: {{ tpl .Values.rabbit.host . }}
- name: RabbitMq__Username
  value: {{ .Values.rabbit.username}}
- name: RabbitMq_Password
  value: {{ .Values.rabbit.password}}
{{- end -}}


{{- define "env.otlpExporter" -}}
- name: OtlpExporterUrl
  value: {{ printf " http://%s:8200" (tpl .Values.elasticApmServer.host .)}}
{{- end -}}