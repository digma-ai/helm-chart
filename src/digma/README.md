<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="../../.github/images/digma-helm-dark.png">
    <source media="(prefers-color-scheme: light)" srcset="../../.github/images/digma-helm-light.png">
    <img width="446" height="200" src="../../.github/images/digma-helm-light.png" alt="digma+helm logos">
  </picture>
</p>
# digma

![Version: 1.0.254](https://img.shields.io/badge/Version-1.0.254-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.165](https://img.shields.io/badge/AppVersion-0.3.165-informational?style=flat-square)

A Helm chart containing Digma's services and dbs

**Homepage:** <https://github.com/digma-ai/digma>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | common | 2.x.x |
| oci://registry-1.docker.io/bitnamicharts | elasticsearch | 21.3.17 |
| oci://registry-1.docker.io/bitnamicharts | grafana | 11.3.26 |
| oci://registry-1.docker.io/bitnamicharts | influxdb | 6.3.22 |
| oci://registry-1.docker.io/bitnamicharts | kafka | 31.0.0 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 16.2.1 |
| oci://registry-1.docker.io/bitnamicharts | prometheus | 1.3.28 |
| oci://registry-1.docker.io/bitnamicharts | redis | 20.3.0 |

# Some Long Description

This is a sample README with custom overrides.
Check the template in [README.md.gotmpl](README.md.gotmpl).

## Values

### Global Digma parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.deployment.size | string | `"medium"` | replicas based on a given preset |
| digma.accessToken | string | `nil` | replicas based on a given preset |
| digma.licenseKey | string | `nil` | replicas based on a given preset |

### Observability parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| observability.useLocal | bool | `true` | Use local observability, Deploys Prometheus and Grafana  |
| observability.siteName | string | `"undefined"` | siteName |
| observability.environmentName | string | `"digma"` | Environments represent different deployment stages or scopes |
| observability.otlp.remoteEndpoint | string | `nil` | Please note this parameter, cannot be set while useLocal is true |
| observability.otlp.samplerProbability | float | `0.1` | Control the fraction of traces that are sampled |
| observability.otlp.exportTraces | bool | `true` | Export traces |
| observability.otlp.exportMetrics | bool | `true` | Export metrics |

### Global Docker image parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.imagePullSecrets | list | `[]` | Global Docker registry secret names as an array |

### Common parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kubeVersion | string | `""` | kubeVersion Override Kubernetes version |
| commonLabels | object | `{}` | commonLabels Labels to add to all deployed objects |
| commonAnnotations | object | `{}` | commonAnnotations Annotations to add to all deployed objects |

### CollectorWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| collectorWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| collectorWorker.image.pullSecrets | list | `[]` | image pull secrets |
| collectorWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"collectorWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| collectorWorker.podLabels | object | `{}` | Extra labels for pods |
| collectorWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| collectorWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| collectorWorker.tolerations | list | `[]` | Tolerations for pods assignment |
| collectorWorker.affinity | object | `{}` | Affinity for pods assignment |
| collectorWorker.extraEnvVars | list | `[]` | Array with extra environment variables to add |

### Otel Collector parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| otelCollector.samplingPercentage | int | `100` | telemetry data that should be sampled and sent to the backend |
| otelCollector.existingConfigmap | string | `""` | The name of an existing ConfigMap with your custom configuration |
| otelCollector.existingConfigmapKey | string | `""` | The name of the key with the config file |
| otelCollector.image.registry | string | `"docker.io"` | image registry |
| otelCollector.image.repository | string | `"otel/opentelemetry-collector-contrib"` | image repository |
| otelCollector.image.tag | string | `"0.103.0"` | image tag |
| otelCollector.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| otelCollector.image.pullSecrets | list | `[]` | image pull secrets |
| otelCollector.replicas | int | `1` | Number of replicas to deploy |
| otelCollector.service.type | string | `"ClusterIP"` | service type |
| otelCollector.service.annotations | object | `{}` | Additional custom annotations for service |
| otelCollector.service.ports.health | int | `13133` | health check service port |
| otelCollector.service.ports.grpc | int | `4317` | gRPC port |
| otelCollector.service.ports.http | int | `4318` | HTTP port listen to path: /v1/traces |
| otelCollector.podLabels | object | `{}` | Extra labels for pods |
| otelCollector.podAnnotations | object | `{}` | Extra annotations for pods |
| otelCollector.nodeSelector | object | `{}` | Node labels for pods assignment |
| otelCollector.tolerations | list | `[]` | Tolerations for pods assignment |
| otelCollector.affinity | object | `{}` | Affinity for pods assignment |
| otelCollector.grpc.ingress.enabled | bool | `false` | Enable ingress |
| otelCollector.grpc.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| otelCollector.grpc.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| otelCollector.grpc.ingress.hostname | string | `nil` | Default host for the ingress record |
| otelCollector.grpc.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| otelCollector.grpc.ingress.path | string | `"/"` | The Path to otelCollector. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| otelCollector.grpc.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| otelCollector.grpc.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| otelCollector.grpc.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| otelCollector.http.ingress.enabled | bool | `false` | Enable ingress |
| otelCollector.http.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| otelCollector.http.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| otelCollector.http.ingress.hostname | string | `nil` | Default host for the ingress record |
| otelCollector.http.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| otelCollector.http.ingress.path | string | `"/"` | The Path to otelCollector. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| otelCollector.http.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| otelCollector.http.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| otelCollector.http.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |

### CollectorApi parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| collectorApi.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| collectorApi.image.pullSecrets | list | `[]` | image pull secrets |
| collectorApi.replicas | int | `1` | Number of replicas to deploy |
| collectorApi.service.type | string | `"ClusterIP"` | service type |
| collectorApi.service.annotations | object | `{}` | Additional custom annotations for service |
| collectorApi.service.ports.internal | int | `5048` | internal service port |
| collectorApi.service.ports.grpc | int | `5050` | gRPC service port |
| collectorApi.service.ports.http | int | `5049` | HTTP port listen to path: /v1/traces |
| collectorApi.podLabels | object | `{}` | Extra labels for pods |
| collectorApi.podAnnotations | object | `{}` | Extra annotations for pods |
| collectorApi.nodeSelector | object | `{}` | Node labels for pods assignment |
| collectorApi.tolerations | list | `[]` | Tolerations for pods assignment |
| collectorApi.affinity | object | `{}` | Affinity for pods assignment |

### AnalyticsApi parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| analyticsApi.secured | bool | `true` | Indicates whether the analytics API uses a secured HTTPS connection. Set to false if ingress is enabled |
| analyticsApi.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| analyticsApi.image.pullSecrets | list | `[]` | image pull secrets |
| analyticsApi.replicas | int | `1` | Number of replicas to deploy |
| analyticsApi.service.type | string | `"ClusterIP"` | service type |
| analyticsApi.service.annotations | object | `{}` | Additional custom annotations for service |
| analyticsApi.service.ports.http | int | `5051` | HTTP service port |
| analyticsApi.podLabels | object | `{}` | Extra labels for pods |
| analyticsApi.podAnnotations | object | `{}` | Extra annotations for pods |
| analyticsApi.nodeSelector | object | `{}` | Node labels for pods assignment |
| analyticsApi.tolerations | list | `[]` | Tolerations for pods assignment |
| analyticsApi.affinity | object | `{}` | Affinity for pods assignment |
| analyticsApi.ingress.enabled | bool | `false` | Enable ingress |
| analyticsApi.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| analyticsApi.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| analyticsApi.ingress.hostname | string | `nil` | Default host for the ingress record |
| analyticsApi.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| analyticsApi.ingress.path | string | `"/"` | The Path to AnalyticsApi. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| analyticsApi.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| analyticsApi.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| analyticsApi.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |

### MeasurementAnalysis parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| measurementAnalysis.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| measurementAnalysis.image.pullSecrets | list | `[]` | image pull secrets |
| measurementAnalysis.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"measurementAnalysis\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| measurementAnalysis.podLabels | object | `{}` | Extra labels for pods |
| measurementAnalysis.podAnnotations | object | `{}` | Extra annotations for pods |
| measurementAnalysis.nodeSelector | object | `{}` | Node labels for pods assignment |
| measurementAnalysis.tolerations | list | `[]` | Tolerations for pods assignment |
| measurementAnalysis.affinity | object | `{}` | Affinity for pods assignment |
| measurementAnalysis.extraEnvVars | list | `[]` | Array with extra environment variables to add |

### Scheduler parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| scheduler.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| scheduler.image.pullSecrets | list | `[]` | image pull secrets |
| scheduler.replicas | int | `1` | Number of replicas to deploy |
| scheduler.service.type | string | `"ClusterIP"` | service type |
| scheduler.service.annotations | object | `{}` | Additional custom annotations for service |
| scheduler.service.ports.internal | int | `3053` | Internal HTTP service port |
| scheduler.podLabels | object | `{}` | Extra labels for pods |
| scheduler.podAnnotations | object | `{}` | Extra annotations for pods |
| scheduler.nodeSelector | object | `{}` | Node labels for pods assignment |
| scheduler.tolerations | list | `[]` | Tolerations for pods assignment |
| scheduler.affinity | object | `{}` | Affinity for pods assignment |

### PipelineWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pipelineWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| pipelineWorker.image.pullSecrets | list | `[]` | image pull secrets |
| pipelineWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"pipelineWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| pipelineWorker.podLabels | object | `{}` | Extra labels for pods |
| pipelineWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| pipelineWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| pipelineWorker.tolerations | list | `[]` | Tolerations for pods assignment |
| pipelineWorker.affinity | object | `{}` | Affinity for pods assignment |

### UI parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ui.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| ui.image.pullSecrets | list | `[]` | image pull secrets |
| ui.replicas | int | `1` | Number of replicas to deploy |
| ui.service.type | string | `"ClusterIP"` | service type |
| ui.service.annotations | object | `{}` | Additional custom annotations for service |
| ui.service.ports.http | int | `80` | HTTP service port |
| ui.podLabels | object | `{}` | Extra labels for pods |
| ui.podAnnotations | object | `{}` | Extra annotations for pods |
| ui.nodeSelector | object | `{}` | Node labels for pods assignment |
| ui.tolerations | list | `[]` | Tolerations for pods assignment |
| ui.affinity | object | `{}` | Affinity for pods assignment |
| ui.ingress.enabled | bool | `false` | Enable ingress |
| ui.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| ui.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| ui.ingress.hostname | string | `nil` | Default host for the ingress record |
| ui.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| ui.ingress.path | string | `"/"` | The Path to UI. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| ui.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| ui.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| ui.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |

### MetricsExporter parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| metricsExporter.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| metricsExporter.image.pullSecrets | list | `[]` | image pull secrets |
| metricsExporter.replicas | int | `1` | Number of replicas to deploy |
| metricsExporter.service.annotations | object | `{}` | Additional custom annotations for service |
| metricsExporter.service.ports.http | int | `9091` | HTTP service port |
| metricsExporter.podLabels | object | `{}` | Extra labels for pods |
| metricsExporter.podAnnotations | object | `{}` | Extra annotations for pods |
| metricsExporter.nodeSelector | object | `{}` | Node labels for pods assignment |
| metricsExporter.tolerations | list | `[]` | Tolerations for pods assignment |
| metricsExporter.affinity | object | `{}` | Affinity for pods assignment |
| metricsExporter.serviceAccount | object | `{"annotations":{}}` | Annotations to add to the ServiceAccount Metadata |

### Otel CollectorDF parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| otelCollectorDf.image.registry | string | `"docker.io"` | image registry |
| otelCollectorDf.image.repository | string | `"otel/opentelemetry-collector-contrib"` | image repository |
| otelCollectorDf.image.tag | string | `"0.103.0"` | image tag |
| otelCollectorDf.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| otelCollectorDf.image.pullSecrets | list | `[]` | image pull secrets |
| otelCollectorDf.replicas | int | `1` | Number of replicas to deploy |
| otelCollectorDf.service.annotations | object | `{}` | Additional custom annotations for service |
| otelCollectorDf.service.ports.grpc | int | `4317` | HTTP gRPC service port |
| otelCollectorDf.service.ports.prometheus_scraper | int | `8889` | prometheus scraper service port |
| otelCollectorDf.podLabels | object | `{}` | Extra labels for pods |
| otelCollectorDf.podAnnotations | object | `{}` | Extra annotations for pods |
| otelCollectorDf.nodeSelector | object | `{}` | Node labels for pods assignment |
| otelCollectorDf.tolerations | list | `[]` | Tolerations for pods assignment |
| otelCollectorDf.affinity | object | `{}` | Affinity for pods assignment |

### Influxdb parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| influxdb.podLabels | object | `{}` | Extra labels for pods |
| influxdb.podAnnotations | object | `{}` | Extra annotations for pods |
| influxdb.nodeSelector | object | `{}` | Node labels for pods assignment |
| influxdb.tolerations | list | `[]` | Tolerations for pods assignment |
| influxdb.affinity | object | `{}` | Affinity for pods assignment |

### Postgresql parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.primary.podLabels | object | `{}` | Extra labels for pods |
| postgresql.primary.podAnnotations | object | `{}` | Extra annotations for pods |
| postgresql.primary.nodeSelector | object | `{}` | Node labels for pods assignment |
| postgresql.primary.tolerations | list | `[]` | Tolerations for pods assignment |
| postgresql.primary.affinity | object | `{}` | Affinity for pods assignment |

### Redis parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis.master.podLabels | object | `{}` | Extra labels for pods |
| redis.master.podAnnotations | object | `{}` | Extra annotations for pods |
| redis.master.nodeSelector | object | `{}` | Node labels for pods assignment |
| redis.master.tolerations | list | `[]` | Tolerations for pods assignment |
| redis.master.affinity | object | `{}` | Affinity for pods assignment |

### Jaeger parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| jaeger.image.registry | string | `"docker.io"` | image registry |
| jaeger.image.repository | string | `"jaegertracing/all-in-one"` | image repository |
| jaeger.image.tag | string | `"1.61.0"` | image tag |
| jaeger.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| jaeger.image.pullSecrets | list | `[]` | image pull secrets |
| jaeger.replicas | int | `1` | Number of replicas to deploy |
| jaeger.service.type | string | `"ClusterIP"` | service type |
| jaeger.service.annotations | object | `{}` | Additional custom annotations for service |
| jaeger.service.ports.http_ui | int | `16686` | UI HTTP service port |
| jaeger.service.ports.grpc_internal | int | `4317` | gRPC collector internal service port |
| jaeger.podLabels | object | `{}` | Extra labels for pods |
| jaeger.podAnnotations | object | `{}` | Extra annotations for pods |
| jaeger.nodeSelector | object | `{}` | Node labels for pods assignment |
| jaeger.tolerations | list | `[]` | Tolerations for pods assignment |
| jaeger.affinity | object | `{}` | Affinity for pods assignment |
| jaeger.ingress.enabled | bool | `false` | Enable ingress |
| jaeger.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| jaeger.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| jaeger.ingress.hostname | string | `nil` | Default host for the ingress record |
| jaeger.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| jaeger.ingress.path | string | `"/"` | The Path to UI. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| jaeger.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| jaeger.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| jaeger.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |

### Elasticsearch parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| elasticsearch.master.podLabels | object | `{}` | Extra labels for pods |
| elasticsearch.master.podAnnotations | object | `{}` | Extra annotations for pods |
| elasticsearch.master.nodeSelector | object | `{}` | Node labels for pods assignment |
| elasticsearch.master.tolerations | list | `[]` | Tolerations for pods assignment |
| elasticsearch.master.affinity | object | `{}` | Affinity for pods assignment |

### Grafana parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| grafana.grafana.podLabels | object | `{}` | Extra labels for pods |
| grafana.grafana.podAnnotations | object | `{}` | Extra annotations for pods |
| grafana.grafana.nodeSelector | object | `{}` | Node labels for pods assignment |
| grafana.grafana.tolerations | list | `[]` | Tolerations for pods assignment |
| grafana.grafana.affinity | object | `{}` | Affinity for pods assignment |

### Prometheus parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| prometheus.server.podLabels | object | `{}` | Extra labels for pods |
| prometheus.server.podAnnotations | object | `{}` | Extra annotations for pods |
| prometheus.server.nodeSelector | object | `{}` | Node labels for pods assignment |
| prometheus.server.tolerations | list | `[]` | Tolerations for pods assignment |
| prometheus.server.affinity | object | `{}` | Affinity for pods assignment |

### Kafka parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kafka.controller.podLabels | object | `{}` | Extra labels for pods |
| kafka.controller.podAnnotations | object | `{}` | Extra annotations for pods |
| kafka.controller.nodeSelector | object | `{}` | Node labels for pods assignment |
| kafka.controller.tolerations | list | `[]` | Tolerations for pods assignment |
| kafka.controller.affinity | object | `{}` | Affinity for pods assignment |
