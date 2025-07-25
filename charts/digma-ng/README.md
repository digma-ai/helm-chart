# digma-ng




![Version: 1.0.367](https://img.shields.io/badge/Version-1.0.367-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.341](https://img.shields.io/badge/AppVersion-0.3.341-informational?style=flat-square) 

A Helm chart containing Digma's services

**Homepage:** <https://github.com/digma-ai/digma>




## License Key
Digma will not function without a valid license key.
You can obtain a license key by signing up for a free account using this [link](https://digma.ai/sign-up/).

## Applying the License Key
To apply the license key, set the digma.licenseKey value in your Helm chart to the key provided by Digma.

## TL;DR
```console
helm repo add digma https://digma-ai.github.io/helm-chart/
helm repo update
kubectl create namespace digma
DIGMA_LICENSE='XXX' # license key provided by Digma
helm upgrade --install digma digma/digma-ng -n digma --set digma.licenseKey=$DIGMA_LICENSE

```
## Introduction

This chart bootstraps a [Digma](https://digma.ai) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+

## Installing the Chart
1. Create a local `myvalues.yaml` file that contains the default values.
2. Set a valid Digma license key in the myvalues.yaml file
3. Deploy the Digma Helm chart to your Kubernetes cluster.
To install the chart with the release name `digma`:
```console
helm repo add digma https://digma-ai.github.io/helm-chart/
helm repo update
kubectl create namespace digma
helm upgrade --install digma digma/digma-ng -n digma -f myvalues.yaml

```
## Expose Digma Services
The service(s) created by the deployment can be exposed within or outside the cluster using any of the following approaches:
- **ClusterIP [Default]**: This exposes the service(s) on a cluster-internal IP address. This approach makes the corresponding service(s) reachable only from within the cluster. Set service.type=ClusterIP to choose this approach.
- **Ingres**s: This requires an Ingress controller to be installed in the Kubernetes cluster. Set ingress.enabled=true to expose the corresponding service(s) through Ingress.
- **NodePort**: This exposes the service(s) on each node's IP address at a static port (the NodePort). This approach makes the corresponding service(s) reachable from outside the cluster by requesting the static port using the node's IP address, such as NODE-IP:NODE-PORT. Set service.type=NodePort to choose this approach.
- **LoadBalancer**: This exposes the service(s) externally using a cloud provider's load balancer. Set service.type=LoadBalancer to choose this approach.
### Service-Specific Exposures
#### Analytics API
This endpoint needs to be accessible to the IDE plugin.
```yaml
analyticsApi:
  service:
    type: ClusterIP
    ..
  ingress:
    enabled: false
```
#### Collector
The application should be able to send observability data to the IP/DNS of this endpoint.
```yaml
collectorApi:
  service:
    type: ClusterIP
    ..
  ingress:
    enabled: false
```
#### UI
This endpoint serves the Digma web application as well as additional services.
```yaml
ui:
  service:
    type: ClusterIP
    ..
  ingress:
    enabled: false
```
#### Jaeger
Digma bundles its own Jaeger service that aggregates sample traces for various insights, performance metrics, and exceptions.
```yaml
jaeger:
  service:
    type: ClusterIP
    ..
  ingress:
    enabled: false
```

## Handle Zone-Specific Constraints
Digma uses multiple StatefulSets.
1. ### Enforce Zone-Affinity for StatefulSet Pods
   Ensure the StatefulSet pod remains in the same zone as its data by configuring node affinity.
   ####  Affinity Example
   Here’s how to set node affinity for the StatefulSets in values.yaml:
    ```yaml
    elasticsearch:
      master:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: topology.kubernetes.io/zone
                      operator: In
                      values:
                        - <zone>
    kafka:
      controller:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: topology.kubernetes.io/zone
                      operator: In
                      values:
                        - <zone>
    postgresql:
      primary:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: topology.kubernetes.io/zone
                      operator: In
                      values:
                        - <zone>
    redis:
      master:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: topology.kubernetes.io/zone
                      operator: In
                      values:
                        - <zone>
    ```
2. ### Use Multi-Zone Storage
   Use storage solutions that replicate data across zones
## Digma AI

Digma includes a built-in integration with [Anthropic](https://www.anthropic.com/) and [OpenAI](https://platform.openai.com/docs/api-reference) to enhance **query observability** and **developer experience** through intelligent suggestions.

### 🚀 Enabling the AI Feature

To activate Anthropic-based suggestions in Digma, add the following configuration:

```yaml
ai:
  enabled: true
  extraEnvVars:
    - name: API_KEY   # [Required]
      value: <API_KEY>
    - name: VENDOR
      value: <VENDOR> # [Required] Possible Options: [Claude,OpenAi,Grok,Gemini]
    - name: URL
      value: <URL>    # [Optional] AI provider url, Default will be used if not set. Override this value if you are using a custom endpoint
    - name: MODEL
      value: <MODEL>  # [Optional] Default will be used if not set
```

The following environment variables can be configured to control the AI integration:

| Variable Name            | Description                                                                          | Required | Default                                   |
|--------------------------|--------------------------------------------------------------------------------------|----------|-------------------------------------------|
| `API_KEY`                | The API key issued by the selected vendor for access.                                | ✅       | —                                         |
| `VENDOR`                 | Vendor to use for the AI integration. Possible Options: [Claude,OpenAi,Grok,Gemini]  | ✅       | —                                         |
| `URL`                    | URL of the AI provider, anthropic/openai based on the selected vendor.               | ❌       | AI provider default endpoint will be used |
| `MODEL`                  | Model to use for the AI integration. See default models in table below.              | ❌       | default will be used for each vendor      |

Default Models by Vendor:

| Vendor    | Default Model               |
|-----------|----------------------------|
| Claude    | claude-3-5-sonnet-latest   |
| OpenAi    | gpt-4                      |
| Grok      | grok-1                     |
| Gemini    | gemini-2.0-flash           |





## PostgreSQL Backup
The Digma-ng Helm chart provides an optional PostgreSQL backup job for debugging and troubleshooting purposes. This guide explains how to enable and configure the backup feature.

### Enabling the Backup Job
To enable the PostgreSQL backup job, set the following values in your Helm deployment configuration:
```yaml
postgresql_backup:
  enabled: true
  presigned_url: "<YOUR_PRESIGNED_URL>"
```
Required Parameters:
	•	postgresql_backup.enabled: Set to true to enable the backup job.
	•	postgresql_backup.presigned_url: The presigned URL provided by Digma for the S3 bucket.

How It Works
	•	When the backup job is enabled, a Kubernetes Job is created.
	•	The job performs the following tasks:
        1.	Connects to the PostgreSQL database.
        2.	Creates a backup file.
        3.	Uploads the backup file to the provided presigned S3 URL.

## ⚠️ Troubleshooting

### Elasticsearch Kernel Requirements

Elasticsearch requires certain **kernel parameters** to be set at the **host level** in order to function properly. If these values are not correctly configured in the underlying OS, the Elasticsearch containers may fail to start, displaying error messages related to system limits.

📚 For more details, refer to the official Bitnami documentation:  
➡️ [Bitnami Elasticsearch – Default Kernel Settings](https://github.com/bitnami/charts/tree/main/bitnami/elasticsearch#default-kernel-settings)

---

#### 🛡️ Security Tool Warnings

Some **security scanners or admission controllers** (e.g., Kyverno, Gatekeeper, Pod Security Admission) may **warn or block** the deployment because the Elasticsearch chart includes an **init container** that requires elevated privileges to set `vm.max_map_count`. This is essential for Elasticsearch to operate, as it relies on memory-mapped files extensively.

---

#### ✅ Managed Kubernetes (EKS, AKS) — Safe to Skip Init Container

In most managed Kubernetes environments like **EKS**, **AKS**, or **GKE**, the required kernel setting is **already applied** by default:
vm.max_map_count = 262144

You can verify this from any running non-Elasticsearch pod:

```bash
cat /proc/sys/vm/max_map_count
```
If the output is at least 262144, You can safely disable the init container by adding the following to your values.yaml:
```yaml
elasticsearch:
  master:
    podSecurityContext:
      enabled: false
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
| digma.report.emailGateway | object | `{"apiKey":null,"url":null}` | Email gateway settings (legacy) |
| digma.report.emailGateway.apiKey | string | `nil` | Email gateway API key |
| digma.report.emailGateway.url | string | `nil` | Email gateway URL |
| digma.emailSettings | object | `{"apiKey":null,"url":null}` | Email settings configuration |
| digma.emailSettings.url | string | `nil` | Email gateway URL |
| digma.emailSettings.apiKey | string | `nil` | Email gateway API key |
| digma.externals.postgresql.host | string | `""` | Host of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |
| digma.externals.postgresql.user | string | `""` | User of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |
| digma.externals.postgresql.password | string | `""` | Password of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |
| digma.externals.postgresql.port | int | `5432` | Port of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |

### Authentication

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.auth.emailVerificationEnabled | bool | `false` | Enable email verification for new users. If enabled, emailSettings.url must be set |
| digma.auth.email | string | `nil` | Admin user email (must be provided together with password) |
| digma.auth.password | string | `nil` | Admin user password (must be provided together with email), requires a minimum length of 6 characters and at least one non-alphanumeric character. |
| digma.auth.allowedEmailDomains | string | `nil` | Comma-separated or semicolon-separated list of allowed email domains for user registration |
| digma.auth.securedCookie | bool | `true` | Setting auth cookie secure flag. Set to false if ui is accessed via http |

### Social Login

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.socialLogin.enabled | bool | `false` | enable social login |
| digma.socialLogin.google.clientId | string | `nil` | google clientId |

### Social Login     

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.socialLogin.google.secret | string | `nil` | google secret |

### MCP parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.mcp.enabled | bool | `true` | enable mcp |

### Observability parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| observability.useLocal | bool | `true` | Use local observability, Deploys Prometheus and Grafana  |
| observability.environmentName | string | `"digma"` | Environments represent different deployment stages or scopes |
| observability.otlp.remoteEndpoint | string | `nil` | Please note this parameter, cannot be set while useLocal is true, If no port is defined, port 443 will be added automatically  |
| observability.otlp.samplerProbability | float | `0.1` | Control the fraction of traces that are sampled |
| observability.otlp.exportTraces | bool | `true` | Export traces |
| observability.otlp.exportMetrics | bool | `true` | Export metrics |
| observability.otlp.exportLogs | bool | `true` | Export logs |

### Common parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.tolerations | list | `[]` | Tolerations to add to all deployed objects, except prometheus and redis |
| kubeVersion | string | `""` | kubeVersion Override Kubernetes version |
| commonLabels | object | `{}` | Labels to add to all deployed objects |
| commonAnnotations | object | `{}` | Annotations to add to all deployed objects |
| diagnosticMode.enabled | bool | `false` | Enable diagnostic mode (all probes will be disabled) |
| extraDeploy | list | `[]` | Array of extra objects to deploy with the release |

### Global Docker image parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.imagePullSecrets | list | `[]` | Global Docker registry secret names as an array |

### CollectorWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| collectorWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| collectorWorker.image.pullSecrets | list | `[]` | image pull secrets |
| collectorWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"collectorWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| collectorWorker.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| collectorWorker.service.ports.http | int | `5052` | HTTP service port, health check at /healthz |
| collectorWorker.podLabels | object | `{}` | Extra labels for pods |
| collectorWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| collectorWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| collectorWorker.tolerations | list | `[]` | Tolerations for pods assignment |
| collectorWorker.affinity | object | `{}` | Affinity for pods assignment |
| collectorWorker.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| collectorWorker.app.extraIgnoreEndpoints | list | `[]` | Array with extra ignore Endpoints variables to add |
| collectorWorker.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| collectorWorker.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| collectorWorker.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| collectorWorker.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| collectorWorker.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| collectorWorker.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| collectorWorker.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| collectorWorker.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| collectorWorker.readinessProbe.path | string | `"/readiness"` | Path for livenessProbe |
| collectorWorker.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| collectorWorker.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| collectorWorker.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| collectorWorker.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| collectorWorker.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| collectorWorker.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| collectorWorker.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| collectorWorker.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Otel Collector parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| otelCollector.receivers.datadog.enabled | bool | `false` | Enable/disable the Datadog receiver |
| otelCollector.receivers.otelHttp.enabled | bool | `true` | Enable/disable the OTLP HTTP receiver |
| otelCollector.receivers.otelGRPC.enabled | bool | `true` | Enable/disable the OTLP GRPC receiver |
| otelCollector.samplingPercentage | int | `100` | telemetry data that should be sampled and sent to the backend |
| otelCollector.existingConfigmap | string | `""` | The name of an existing ConfigMap with your custom configuration |
| otelCollector.existingConfigmapKey | string | `""` | The name of the key with the config file |
| otelCollector.image.registry | string | `"docker.io"` | image registry |
| otelCollector.image.repository | string | `"otel/opentelemetry-collector-contrib"` | image repository |
| otelCollector.image.tag | string | `"0.103.0"` | image tag |
| otelCollector.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| otelCollector.image.pullSecrets | list | `[]` | image pull secrets |
| otelCollector.configuration | string | `"extensions:\n  health_check:\n    endpoint: \"0.0.0.0:{{ .Values.otelCollector.service.ports.health }}\"\nreceivers:\n  otlp/grpc:\n    protocols:\n      grpc:\n        endpoint: 0.0.0.0:{{ .Values.otelCollector.service.ports.grpc }}\n  otlp/http:\n    protocols:\n      http:\n        endpoint: 0.0.0.0:{{ .Values.otelCollector.service.ports.http }}\n  datadog:\n    endpoint: 0.0.0.0:{{ .Values.otelCollector.service.ports.datadog }}\nprocessors:\n  batch:\n    timeout: 1000ms\n    send_batch_size: 500\n    send_batch_max_size: 500\n  probabilistic_sampler:\n    sampling_percentage: {{ .Values.otelCollector.samplingPercentage }}\n  transform:\n    trace_statements:\n      - context: span\n        statements:\n          - set(resource.attributes[\"scm.commit.id\"], attributes[\"_dd.git.commit.sha\"]) where attributes[\"_dd.git.commit.sha\"] != nil\n          - set(resource.attributes[\"digma.environment\"], attributes[\"digma.environment\"]) where attributes[\"digma.environment\"] != nil\n          - set(resource.attributes[\"digma.environment.type\"], attributes[\"digma.environment.type\"]) where attributes[\"digma.environment.type\"] != nil\n          - set(resource.attributes[\"service.name\"], attributes[\"_dd.base_service\"]) where attributes[\"_dd.base_service\"] != nil\n          - set(attributes[\"db.statement\"], attributes[\"sql.query\"]) where attributes[\"sql.query\"] != nil\n          - set(attributes[\"db.system\"], attributes[\"db.type\"]) where attributes[\"db.type\"] != nil\n          - set(attributes[\"db.name\"], attributes[\"db.instance\"]) where attributes[\"db.instance\"] != nil\nexporters:\n  logging:\n    loglevel: debug\n  otlphttp:\n    endpoint: http://{{ include \"digma.collector-api\" . }}:{{ .Values.collectorApi.service.ports.http }}\n    compression: gzip\n    tls:\n      insecure: true\n    sending_queue:\n      enabled: true\n      num_consumers: 100\n      queue_size: 1000\n  otlp:\n    endpoint: {{ include \"digma.collector-api\" . }}:{{ .Values.collectorApi.service.ports.grpc }}\n    tls:\n      insecure: true\n    sending_queue:\n      enabled: true\n      num_consumers: 100\n      queue_size: 1000\nservice:\n  extensions: [health_check]\n  pipelines:\n    traces/1:\n      receivers: [otlp/http]\n      processors: [probabilistic_sampler, batch]\n      exporters: [otlphttp]\n    traces/2:\n      receivers: [otlp/grpc]\n      processors: [probabilistic_sampler, batch]\n      exporters: [otlphttp]\n    traces/datadog:\n      receivers: [datadog]\n      processors: [probabilistic_sampler, transform, batch]\n      exporters: [otlphttp]\n"` | This content will be stored in the the config.yaml file and the content can be a template. |
| otelCollector.replicas | int | `1` | Number of replicas to deploy |
| otelCollector.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| otelCollector.service.type | string | `"ClusterIP"` | service type |
| otelCollector.service.annotations | object | `{}` | Additional custom annotations for service |
| otelCollector.service.ports.health | int | `13133` | health check service port |
| otelCollector.service.ports.grpc | int | `4317` | gRPC port |
| otelCollector.service.ports.http | int | `4318` | HTTP port listen to path: /v1/traces |
| otelCollector.service.ports.datadog | int | `8126` | Datadog port |
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
| otelCollector.datadog.ingress.enabled | bool | `false` | Enable ingress |
| otelCollector.datadog.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| otelCollector.datadog.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| otelCollector.datadog.ingress.hostname | string | `nil` | Default host for the ingress record |
| otelCollector.datadog.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| otelCollector.datadog.ingress.path | string | `"/"` | The Path to otelCollector. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| otelCollector.datadog.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| otelCollector.datadog.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| otelCollector.datadog.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| otelCollector.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| otelCollector.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| otelCollector.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| otelCollector.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| otelCollector.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| otelCollector.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| otelCollector.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| otelCollector.readinessProbe.path | string | `"/"` | Path for readinessProbe |
| otelCollector.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| otelCollector.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| otelCollector.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| otelCollector.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| otelCollector.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| otelCollector.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| otelCollector.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| otelCollector.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### CollectorApi parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| collectorApi.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| collectorApi.image.pullSecrets | list | `[]` | image pull secrets |
| collectorApi.replicas | int | `2` | Number of replicas to deploy |
| collectorApi.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
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
| collectorApi.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| collectorApi.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| collectorApi.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| collectorApi.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| collectorApi.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| collectorApi.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| collectorApi.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| collectorApi.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| collectorApi.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| collectorApi.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| collectorApi.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| collectorApi.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| collectorApi.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| collectorApi.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| collectorApi.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| collectorApi.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| collectorApi.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| collectorApi.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### AnalyticsApi parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| analyticsApi.secured | bool | `true` | Indicates whether the analytics API uses a secured HTTPS connection. will be set to false when ingress is enabled |
| analyticsApi.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| analyticsApi.image.pullSecrets | list | `[]` | image pull secrets |
| analyticsApi.replicas | int | `1` | Number of replicas to deploy |
| analyticsApi.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| analyticsApi.service.type | string | `"ClusterIP"` | service type |
| analyticsApi.service.annotations | object | `{}` | Additional custom annotations for service |
| analyticsApi.service.ports.http | int | `5051` | HTTP service port, health check at /healthz |
| analyticsApi.podLabels | object | `{}` | Extra labels for pods |
| analyticsApi.podAnnotations | object | `{}` | Extra annotations for pods |
| analyticsApi.nodeSelector | object | `{}` | Node labels for pods assignment |
| analyticsApi.tolerations | list | `[]` | Tolerations for pods assignment |
| analyticsApi.affinity | object | `{}` | Affinity for pods assignment |
| analyticsApi.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| analyticsApi.ingress.enabled | bool | `false` | Enable ingress, secured parameter will be set to false |
| analyticsApi.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| analyticsApi.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| analyticsApi.ingress.hostname | string | `nil` | Default host for the ingress record |
| analyticsApi.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| analyticsApi.ingress.path | string | `"/"` | The Path to AnalyticsApi. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| analyticsApi.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| analyticsApi.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| analyticsApi.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| analyticsApi.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| analyticsApi.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| analyticsApi.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| analyticsApi.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| analyticsApi.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| analyticsApi.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| analyticsApi.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| analyticsApi.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| analyticsApi.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| analyticsApi.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| analyticsApi.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| analyticsApi.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| analyticsApi.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| analyticsApi.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| analyticsApi.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| analyticsApi.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| analyticsApi.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### MeasurementAnalysis parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| measurementAnalysis.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| measurementAnalysis.image.pullSecrets | list | `[]` | image pull secrets |
| measurementAnalysis.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"measurementAnalysis\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| measurementAnalysis.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| measurementAnalysis.service.ports.http | int | `5054` | HTTP service port, health check at /healthz |
| measurementAnalysis.podLabels | object | `{}` | Extra labels for pods |
| measurementAnalysis.podAnnotations | object | `{}` | Extra annotations for pods |
| measurementAnalysis.nodeSelector | object | `{}` | Node labels for pods assignment |
| measurementAnalysis.tolerations | list | `[]` | Tolerations for pods assignment |
| measurementAnalysis.affinity | object | `{}` | Affinity for pods assignment |
| measurementAnalysis.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| measurementAnalysis.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| measurementAnalysis.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| measurementAnalysis.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| measurementAnalysis.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| measurementAnalysis.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| measurementAnalysis.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| measurementAnalysis.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| measurementAnalysis.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| measurementAnalysis.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| measurementAnalysis.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| measurementAnalysis.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| measurementAnalysis.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| measurementAnalysis.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| measurementAnalysis.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| measurementAnalysis.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| measurementAnalysis.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| measurementAnalysis.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Scheduler parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| scheduler.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| scheduler.image.pullSecrets | list | `[]` | image pull secrets |
| scheduler.replicas | int | `1` | Number of replicas to deploy |
| scheduler.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| scheduler.service.ports.http | int | `5053` | HTTP service port, health check at /healthz |
| scheduler.podLabels | object | `{}` | Extra labels for pods |
| scheduler.podAnnotations | object | `{}` | Extra annotations for pods |
| scheduler.nodeSelector | object | `{}` | Node labels for pods assignment |
| scheduler.tolerations | list | `[]` | Tolerations for pods assignment |
| scheduler.affinity | object | `{}` | Affinity for pods assignment |
| scheduler.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| scheduler.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| scheduler.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| scheduler.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| scheduler.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| scheduler.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| scheduler.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| scheduler.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| scheduler.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| scheduler.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| scheduler.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| scheduler.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| scheduler.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| scheduler.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| scheduler.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| scheduler.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| scheduler.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| scheduler.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### PipelineWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pipelineWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| pipelineWorker.image.pullSecrets | list | `[]` | image pull secrets |
| pipelineWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"pipelineWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| pipelineWorker.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| pipelineWorker.service.ports.http | int | `5055` | HTTP service port, health check at /healthz |
| pipelineWorker.podLabels | object | `{}` | Extra labels for pods |
| pipelineWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| pipelineWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| pipelineWorker.tolerations | list | `[]` | Tolerations for pods assignment |
| pipelineWorker.affinity | object | `{}` | Affinity for pods assignment |
| pipelineWorker.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| pipelineWorker.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| pipelineWorker.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| pipelineWorker.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| pipelineWorker.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| pipelineWorker.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| pipelineWorker.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| pipelineWorker.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| pipelineWorker.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| pipelineWorker.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| pipelineWorker.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| pipelineWorker.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| pipelineWorker.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| pipelineWorker.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| pipelineWorker.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| pipelineWorker.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| pipelineWorker.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| pipelineWorker.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### UI parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nginx.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| nginx.image.pullSecrets | list | `[]` | image pull secrets |
| nginx.replicas | int | `1` | Number of replicas to deploy |
| nginx.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1000}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
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
| nginx.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| nginx.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| nginx.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| nginx.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| nginx.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| ui.apps | list | `["admin","agentic","email-confirmation","ide-launcher","login"]` | List of UI applications/folders |
| ui.service.type | string | `"ClusterIP"` | service type |
| ui.service.annotations | object | `{}` | Additional custom annotations for service |
| ui.service.ports.http | int | `8080` | HTTP service port |
| ui.ingress.enabled | bool | `false` | Enable ingress |
| ui.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| ui.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| ui.ingress.hostname | string | `nil` | Default host for the ingress record |
| ui.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| ui.ingress.path | string | `"/"` | The Path to UI. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| ui.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| ui.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| ui.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |

### AI parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ai.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| ai.image.pullSecrets | list | `[]` | image pull secrets |
| ai.replicas | int | `1` | Number of replicas to deploy |
| ai.service.type | string | `"ClusterIP"` | service type |
| ai.service.annotations | object | `{}` | Additional custom annotations for service |
| ai.service.ports.http | int | `5056` | HTTP port listen to path: /analyze, health check at /health |
| ai.podLabels | object | `{}` | Extra labels for pods |
| ai.podAnnotations | object | `{}` | Extra annotations for pods |
| ai.nodeSelector | object | `{}` | Node labels for pods assignment |
| ai.tolerations | list | `[]` | Tolerations for pods assignment |
| ai.affinity | object | `{}` | Affinity for pods assignment |
| ai.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| ai.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| ai.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| ai.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| ai.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| ai.livenessProbe.path | string | `"/health"` | Path for livenessProbe |
| ai.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| ai.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| ai.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| ai.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| ai.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| ai.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| ai.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| ai.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| ai.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| ai.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| ai.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| ai.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

### Agentic parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agentic.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| agentic.image.pullSecrets | list | `[]` | image pull secrets |
| agentic.replicas | int | `1` | Number of replicas to deploy |
| agentic.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1000}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| agentic.service.type | string | `"ClusterIP"` | service type |
| agentic.service.annotations | object | `{}` | Additional custom annotations for service |
| agentic.service.ports.http | int | `8000` | HTTP port listen to path: /analyze, health check at /health |
| agentic.podLabels | object | `{}` | Extra labels for pods |
| agentic.podAnnotations | object | `{}` | Extra annotations for pods |
| agentic.nodeSelector | object | `{}` | Node labels for pods assignment |
| agentic.tolerations | list | `[]` | Tolerations for pods assignment |
| agentic.affinity | object | `{}` | Affinity for pods assignment |
| agentic.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| agentic.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| agentic.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| agentic.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| agentic.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| agentic.livenessProbe.path | string | `"/health"` | Path for livenessProbe |
| agentic.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| agentic.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| agentic.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| agentic.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| agentic.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| agentic.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| agentic.readinessProbe.path | string | `"/health"` | Path for readinessProbe |
| agentic.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| agentic.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| agentic.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| agentic.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| agentic.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |

### MetricsExporter parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| metricsExporter.enabled | bool | `true` | Enable k8s metrics exporter |
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
| metricsExporter.readinessProbe.path | string | `"/"` | Path for readinessProbe |
| metricsExporter.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| metricsExporter.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| metricsExporter.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| metricsExporter.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
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
| otelCollectorDf.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
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
| otelCollectorDf.readinessProbe.path | string | `"/"` | Path for readinessProbe |
| otelCollectorDf.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| otelCollectorDf.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| otelCollectorDf.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| otelCollectorDf.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| otelCollectorDf.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| otelCollectorDf.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| otelCollectorDf.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| otelCollectorDf.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Postgresql parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.primary.podLabels | object | `{}` | Extra labels for pods |
| postgresql.primary.podAnnotations | object | `{}` | Extra annotations for pods |
| postgresql.primary.nodeSelector | object | `{}` | Node labels for pods assignment |
| postgresql.primary.tolerations | string | `"{{ include \"common.tplvalues.render\" (dict \"value\" .Values.global.tolerations \"context\" $) }}"` | Tolerations for pods assignment |
| postgresql.primary.affinity | object | `{}` | Affinity for pods assignment |
| postgresql.primary.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| postgresql.primary.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| postgresql.primary.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| postgresql.metrics.enabled | bool | `true` | Start a prometheus exporter |

### Redis parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis.metrics.enabled | bool | `true` | Start a sidecar prometheus exporter to expose Redis® metrics |
| redis.master.podLabels | object | `{}` | Extra labels for pods |
| redis.master.podAnnotations | object | `{}` | Extra annotations for pods |
| redis.master.nodeSelector | object | `{}` | Node labels for pods assignment |
| redis.master.tolerations | list | `[]` | Tolerations for pods assignment |
| redis.master.affinity | object | `{}` | Affinity for pods assignment |
| redis.master.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| redis.master.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| redis.master.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Jaeger parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| jaeger.publicBaseUrl | string | `""` | jaeger external or public URL, automatically detected if not set |
| jaeger.image.registry | string | `"docker.io"` | image registry |
| jaeger.image.repository | string | `"jaegertracing/all-in-one"` | image repository |
| jaeger.image.tag | string | `"1.61.0"` | image tag |
| jaeger.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| jaeger.image.pullSecrets | list | `[]` | image pull secrets |
| jaeger.replicas | int | `1` | Number of replicas to deploy |
| jaeger.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1000}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
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
| jaeger.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| jaeger.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| jaeger.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Elasticsearch parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| elasticsearch.master.podLabels | object | `{}` | Extra labels for pods |
| elasticsearch.master.podAnnotations | object | `{}` | Extra annotations for pods |
| elasticsearch.master.nodeSelector | object | `{}` | Node labels for pods assignment |
| elasticsearch.master.tolerations | string | `"{{ include \"common.tplvalues.render\" (dict \"value\" .Values.global.tolerations \"context\" $) }}"` | Tolerations for pods assignment |
| elasticsearch.master.affinity | object | `{}` | Affinity for pods assignment |
| elasticsearch.master.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| elasticsearch.master.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| elasticsearch.master.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Grafana parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| grafana.grafana.podLabels | object | `{}` | Extra labels for pods |
| grafana.grafana.podAnnotations | object | `{}` | Extra annotations for pods |
| grafana.grafana.nodeSelector | object | `{}` | Node labels for pods assignment |
| grafana.grafana.tolerations | string | `"{{ include \"common.tplvalues.render\" (dict \"value\" .Values.global.tolerations \"context\" $) }}"` | Tolerations for pods assignment |
| grafana.grafana.affinity | object | `{}` | Affinity for pods assignment |

### Prometheus parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| prometheus.server.updateStrategy | object | `{"type":"Recreate"}` | Prometheus deployment strategy type. Is a deployment resource therefore, Strategy type should be set to Recreate to avoid dead locks |
| prometheus.server.podLabels | object | `{}` | Extra labels for pods |
| prometheus.server.podAnnotations | object | `{}` | Extra annotations for pods |
| prometheus.server.nodeSelector | object | `{}` | Node labels for pods assignment |
| prometheus.server.tolerations | list | `[]` | Tolerations for pods assignment |
| prometheus.server.affinity | object | `{}` | Affinity for pods assignment |
| prometheus.server.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| prometheus.server.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| prometheus.server.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Kafka parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kafka.controller.replicaCount | int | `1` | Number of Kafka controller-eligible nodes |
| kafka.controller.extraConfig | string | `"offsets.topic.replication.factor=1\ntransaction.state.log.replication.factor=1\nlog.retention.check.interval.ms = 120000\nlog.roll.ms = 120000\nlog.retention.minutes = 10\n"` | Additional configuration to be appended at the end of the generated Kafka configuration file. |
| kafka.controller.podLabels | object | `{}` | Extra labels for pods |
| kafka.controller.podAnnotations | object | `{}` | Extra annotations for pods |
| kafka.controller.nodeSelector | object | `{}` | Node labels for pods assignment |
| kafka.controller.tolerations | string | `"{{ include \"common.tplvalues.render\" (dict \"value\" .Values.global.tolerations \"context\" $) }}"` | Tolerations for pods assignment |
| kafka.controller.affinity | object | `{}` | Affinity for pods assignment |
| kafka.controller.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| kafka.controller.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| kafka.controller.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |

### Postgresql-Backup parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql_backup.enabled | bool | `false` | postgresql backup enabled |
| postgresql_backup.presigned_url | string | `""` | Url to upload the backup file, provided by Digma |
| postgresql_backup.annotations | object | `{}` | Extra annotations for job |
## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | clickhouse | 8.0.7 |
| oci://registry-1.docker.io/bitnamicharts | common | 2.x.x |
| oci://registry-1.docker.io/bitnamicharts | elasticsearch | 21.4.1 |
| oci://registry-1.docker.io/bitnamicharts | elasticsearchlogs(elasticsearch) | 21.4.1 |
| oci://registry-1.docker.io/bitnamicharts | grafana | 11.3.26 |
| oci://registry-1.docker.io/bitnamicharts | kafka | 31.0.0 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 16.2.1 |
| oci://registry-1.docker.io/bitnamicharts | prometheus | 1.3.28 |
| oci://registry-1.docker.io/bitnamicharts | redis | 20.3.0 |