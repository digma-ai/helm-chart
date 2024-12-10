# digma-ng

![Version: 1.0.254](https://img.shields.io/badge/Version-1.0.254-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.166-health-alpha.4](https://img.shields.io/badge/AppVersion-0.3.166--health--alpha.4-informational?style=flat-square)

A Helm chart containing Digma's services

**Homepage:** <https://github.com/digma-ai/digma>

## TL;DR

```console
helm repo add digma https://digma-ai.github.io/helm-chart/
helm repo update
helm dependencies build
kubectl create namespace digma
helm upgrade --install digma digma/digma-ng -n digma

```
## Introduction

This chart bootstraps a [Digma](https://digma.ai) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+

## Installing the Chart

To install the chart with the release name `my-release`:
```console
helm install my-release
```
## Values

### Global Digma parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.deployment.size | string | `"medium"` | adjusts the deployment to efficiently handle different scales of workload, and can be either small, medium, or large. |
| digma.accessToken | string | `nil` | access token for plugin authentication, and set the same one in the IDE plugin settings. |
| digma.licenseKey | string | `nil` | a digma license to use,If you've signed up for a free Digma account you should have received a Digma license to use. You can use this [link](https://digma.ai/sign-up/) to sign up |
| digma.report.enabled | bool | `false` | daily issues report enabled |
| digma.report.scheduledTimeUtc | string | `nil` | scheduled time of the report, HH:mm:ss (24-hour format) |
| digma.report.uiExternalBaseUrl | string | `nil` | UI external service URL (automatically detected if not set) |
| digma.report.recipients.to | string | `nil` | email recipients, list of recipients separated by semicolons (;) |
| digma.report.recipients.cc | string | `nil` | report email additional recipients, list of recipients separated by semicolons (;) |
| digma.report.recipients.bcc | string | `nil` | hidden from other recipients, list of recipients separated by semicolons (;) |
| digma.report.emailGateway.apiKey | string | `nil` | Email gateway email api key |
| digma.report.emailGateway.url | string | `nil` | Email gateway URL |

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
| commonLabels | object | `{}` | Labels to add to all deployed objects |
| commonAnnotations | object | `{}` | Annotations to add to all deployed objects |
| diagnosticMode.enabled | bool | `false` | Enable diagnostic mode (all probes will be disabled) |

### CollectorWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| collectorWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| collectorWorker.image.pullSecrets | list | `[]` | image pull secrets |
| collectorWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"collectorWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| collectorWorker.service.ports.http | int | `5052` | HTTP service port, health check at /healthz |
| collectorWorker.podLabels | object | `{}` | Extra labels for pods |
| collectorWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| collectorWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| collectorWorker.tolerations | list | `[]` | Tolerations for pods assignment |
| collectorWorker.affinity | object | `{}` | Affinity for pods assignment |
| collectorWorker.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| collectorWorker.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| collectorWorker.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| collectorWorker.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| collectorWorker.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| collectorWorker.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| collectorWorker.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| collectorWorker.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| collectorWorker.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| collectorWorker.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| collectorWorker.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| collectorWorker.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| collectorWorker.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

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
| otelCollector.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| otelCollector.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| otelCollector.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| otelCollector.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| otelCollector.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| otelCollector.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| otelCollector.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| otelCollector.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| otelCollector.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| otelCollector.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| otelCollector.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| otelCollector.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

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
| collectorApi.service.ports.http | int | `5049` | HTTP port listen to path: /v1/traces, health check at /healthz |
| collectorApi.podLabels | object | `{}` | Extra labels for pods |
| collectorApi.podAnnotations | object | `{}` | Extra annotations for pods |
| collectorApi.nodeSelector | object | `{}` | Node labels for pods assignment |
| collectorApi.tolerations | list | `[]` | Tolerations for pods assignment |
| collectorApi.affinity | object | `{}` | Affinity for pods assignment |
| collectorApi.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| collectorApi.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| collectorApi.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| collectorApi.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| collectorApi.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| collectorApi.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| collectorApi.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| collectorApi.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| collectorApi.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| collectorApi.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| collectorApi.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| collectorApi.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

### AnalyticsApi parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| analyticsApi.secured | bool | `true` | Indicates whether the analytics API uses a secured HTTPS connection. Set to false if ingress is enabled |
| analyticsApi.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| analyticsApi.image.pullSecrets | list | `[]` | image pull secrets |
| analyticsApi.replicas | int | `1` | Number of replicas to deploy |
| analyticsApi.service.type | string | `"ClusterIP"` | service type |
| analyticsApi.service.annotations | object | `{}` | Additional custom annotations for service |
| analyticsApi.service.ports.http | int | `5051` | HTTP service port, health check at /healthz |
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
| analyticsApi.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| analyticsApi.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| analyticsApi.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| analyticsApi.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| analyticsApi.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| analyticsApi.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| analyticsApi.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| analyticsApi.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| analyticsApi.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| analyticsApi.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| analyticsApi.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| analyticsApi.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

### MeasurementAnalysis parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| measurementAnalysis.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| measurementAnalysis.image.pullSecrets | list | `[]` | image pull secrets |
| measurementAnalysis.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"measurementAnalysis\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| measurementAnalysis.service.ports.http | int | `5054` | HTTP service port, health check at /healthz |
| measurementAnalysis.podLabels | object | `{}` | Extra labels for pods |
| measurementAnalysis.podAnnotations | object | `{}` | Extra annotations for pods |
| measurementAnalysis.nodeSelector | object | `{}` | Node labels for pods assignment |
| measurementAnalysis.tolerations | list | `[]` | Tolerations for pods assignment |
| measurementAnalysis.affinity | object | `{}` | Affinity for pods assignment |
| measurementAnalysis.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| measurementAnalysis.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| measurementAnalysis.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| measurementAnalysis.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| measurementAnalysis.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| measurementAnalysis.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| measurementAnalysis.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| measurementAnalysis.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| measurementAnalysis.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| measurementAnalysis.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| measurementAnalysis.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| measurementAnalysis.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| measurementAnalysis.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

### Scheduler parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| scheduler.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| scheduler.image.pullSecrets | list | `[]` | image pull secrets |
| scheduler.replicas | int | `1` | Number of replicas to deploy |
| scheduler.service.ports.http | int | `5053` | HTTP service port, health check at /healthz |
| scheduler.podLabels | object | `{}` | Extra labels for pods |
| scheduler.podAnnotations | object | `{}` | Extra annotations for pods |
| scheduler.nodeSelector | object | `{}` | Node labels for pods assignment |
| scheduler.tolerations | list | `[]` | Tolerations for pods assignment |
| scheduler.affinity | object | `{}` | Affinity for pods assignment |
| scheduler.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| scheduler.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| scheduler.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| scheduler.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| scheduler.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| scheduler.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| scheduler.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| scheduler.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| scheduler.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| scheduler.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| scheduler.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| scheduler.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

### PipelineWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pipelineWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| pipelineWorker.image.pullSecrets | list | `[]` | image pull secrets |
| pipelineWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"pipelineWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| pipelineWorker.service.ports.http | int | `5055` | HTTP service port, health check at /healthz |
| pipelineWorker.podLabels | object | `{}` | Extra labels for pods |
| pipelineWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| pipelineWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| pipelineWorker.tolerations | list | `[]` | Tolerations for pods assignment |
| pipelineWorker.affinity | object | `{}` | Affinity for pods assignment |
| pipelineWorker.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| pipelineWorker.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| pipelineWorker.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| pipelineWorker.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| pipelineWorker.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| pipelineWorker.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| pipelineWorker.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| pipelineWorker.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| pipelineWorker.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| pipelineWorker.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| pipelineWorker.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| pipelineWorker.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

### UI parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nginx.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| nginx.image.pullSecrets | list | `[]` | image pull secrets |
| nginx.replicas | int | `1` | Number of replicas to deploy |
| nginx.podLabels | object | `{}` | Extra labels for pods |
| nginx.podAnnotations | object | `{}` | Extra annotations for pods |
| nginx.nodeSelector | object | `{}` | Node labels for pods assignment |
| nginx.tolerations | list | `[]` | Tolerations for pods assignment |
| nginx.affinity | object | `{}` | Affinity for pods assignment |
| nginx.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| nginx.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| nginx.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| nginx.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| nginx.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| nginx.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| nginx.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| nginx.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| nginx.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| nginx.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| nginx.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| nginx.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| ui.service.type | string | `"ClusterIP"` | service type |
| ui.service.annotations | object | `{}` | Additional custom annotations for service |
| ui.service.ports.http | int | `80` | HTTP service port |
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
| metricsExporter.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| metricsExporter.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| metricsExporter.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| metricsExporter.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| metricsExporter.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| metricsExporter.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| metricsExporter.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| metricsExporter.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| metricsExporter.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| metricsExporter.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| metricsExporter.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| metricsExporter.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

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
| otelCollectorDf.service.ports.health | int | `13133` | health check service port |
| otelCollectorDf.service.ports.grpc | int | `4317` | HTTP gRPC service port |
| otelCollectorDf.service.ports.prometheus_scraper | int | `8889` | prometheus scraper service port |
| otelCollectorDf.podLabels | object | `{}` | Extra labels for pods |
| otelCollectorDf.podAnnotations | object | `{}` | Extra annotations for pods |
| otelCollectorDf.nodeSelector | object | `{}` | Node labels for pods assignment |
| otelCollectorDf.tolerations | list | `[]` | Tolerations for pods assignment |
| otelCollectorDf.affinity | object | `{}` | Affinity for pods assignment |
| otelCollectorDf.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| otelCollectorDf.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| otelCollectorDf.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| otelCollectorDf.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| otelCollectorDf.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| otelCollectorDf.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| otelCollectorDf.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| otelCollectorDf.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| otelCollectorDf.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| otelCollectorDf.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| otelCollectorDf.readinessProbe.failureThreshold | int | `12` | Failure threshold for readinessProbe |
| otelCollectorDf.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

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
| kafka.controller.replicaCount | int | `1` | Number of Kafka controller-eligible nodes |
| kafka.controller.podLabels | object | `{}` | Extra labels for pods |
| kafka.controller.podAnnotations | object | `{}` | Extra annotations for pods |
| kafka.controller.nodeSelector | object | `{}` | Node labels for pods assignment |
| kafka.controller.tolerations | list | `[]` | Tolerations for pods assignment |
| kafka.controller.affinity | object | `{}` | Affinity for pods assignment |
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