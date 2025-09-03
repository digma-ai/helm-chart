# digma-ng




![Version: 1.0.377](https://img.shields.io/badge/Version-1.0.377-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.349](https://img.shields.io/badge/AppVersion-0.3.349-informational?style=flat-square) 

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

### Agentic parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agentic.affinity | object | `{}` | Affinity for pods assignment |
| agentic.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| agentic.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| agentic.image.pullSecrets | list | `[]` | image pull secrets |
| agentic.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| agentic.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| agentic.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| agentic.livenessProbe.path | string | `"/health"` | Path for livenessProbe |
| agentic.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| agentic.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| agentic.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| agentic.nodeSelector | object | `{}` | Node labels for pods assignment |
| agentic.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| agentic.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| agentic.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| agentic.podAnnotations | object | `{}` | Extra annotations for pods |
| agentic.podLabels | object | `{}` | Extra labels for pods |
| agentic.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1000}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| agentic.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| agentic.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| agentic.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| agentic.readinessProbe.path | string | `"/health"` | Path for readinessProbe |
| agentic.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| agentic.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| agentic.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| agentic.replicas | int | `1` | Number of replicas to deploy |
| agentic.service.annotations | object | `{}` | Additional custom annotations for service |
| agentic.service.ports.http | int | `8000` | HTTP port listen to path: /analyze, health check at /health |
| agentic.service.type | string | `"ClusterIP"` | service type |
| agentic.serviceAccount | object | `{"annotations":{}}` | Annotations to add to the ServiceAccount Metadata |
| agentic.tolerations | list | `[]` | Tolerations for pods assignment |

### AI parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ai.affinity | object | `{}` | Affinity for pods assignment |
| ai.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| ai.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| ai.image.pullSecrets | list | `[]` | image pull secrets |
| ai.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| ai.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| ai.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| ai.livenessProbe.path | string | `"/health"` | Path for livenessProbe |
| ai.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| ai.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| ai.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| ai.nodeSelector | object | `{}` | Node labels for pods assignment |
| ai.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| ai.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| ai.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| ai.podAnnotations | object | `{}` | Extra annotations for pods |
| ai.podLabels | object | `{}` | Extra labels for pods |
| ai.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| ai.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| ai.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| ai.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| ai.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| ai.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| ai.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| ai.replicas | int | `1` | Number of replicas to deploy |
| ai.service.annotations | object | `{}` | Additional custom annotations for service |
| ai.service.ports.http | int | `5056` | HTTP port listen to path: /analyze, health check at /health |
| ai.service.type | string | `"ClusterIP"` | service type |
| ai.tolerations | list | `[]` | Tolerations for pods assignment |

### AnalyticsApi parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| analyticsApi.affinity | object | `{}` | Affinity for pods assignment |
| analyticsApi.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| analyticsApi.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| analyticsApi.image.pullSecrets | list | `[]` | image pull secrets |
| analyticsApi.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| analyticsApi.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| analyticsApi.ingress.enabled | bool | `false` | Enable ingress, secured parameter will be set to false |
| analyticsApi.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| analyticsApi.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| analyticsApi.ingress.hostname | string | `nil` | Default host for the ingress record |
| analyticsApi.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| analyticsApi.ingress.path | string | `"/"` | The Path to AnalyticsApi. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| analyticsApi.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| analyticsApi.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| analyticsApi.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| analyticsApi.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| analyticsApi.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| analyticsApi.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| analyticsApi.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| analyticsApi.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| analyticsApi.nodeSelector | object | `{}` | Node labels for pods assignment |
| analyticsApi.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| analyticsApi.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| analyticsApi.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| analyticsApi.podAnnotations | object | `{}` | Extra annotations for pods |
| analyticsApi.podLabels | object | `{}` | Extra labels for pods |
| analyticsApi.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| analyticsApi.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| analyticsApi.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| analyticsApi.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| analyticsApi.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| analyticsApi.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| analyticsApi.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| analyticsApi.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| analyticsApi.replicas | int | `1` | Number of replicas to deploy |
| analyticsApi.secured | bool | `true` | Indicates whether the analytics API uses a secured HTTPS connection. will be set to false when ingress is enabled |
| analyticsApi.service.annotations | object | `{}` | Additional custom annotations for service |
| analyticsApi.service.ports.http | int | `5051` | HTTP service port, health check at /healthz |
| analyticsApi.service.type | string | `"ClusterIP"` | service type |
| analyticsApi.tolerations | list | `[]` | Tolerations for pods assignment |

### CollectorApi parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| collectorApi.affinity | object | `{}` | Affinity for pods assignment |
| collectorApi.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| collectorApi.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| collectorApi.image.pullSecrets | list | `[]` | image pull secrets |
| collectorApi.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| collectorApi.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| collectorApi.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| collectorApi.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| collectorApi.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| collectorApi.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| collectorApi.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| collectorApi.nodeSelector | object | `{}` | Node labels for pods assignment |
| collectorApi.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| collectorApi.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| collectorApi.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| collectorApi.podAnnotations | object | `{}` | Extra annotations for pods |
| collectorApi.podLabels | object | `{}` | Extra labels for pods |
| collectorApi.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| collectorApi.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| collectorApi.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| collectorApi.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| collectorApi.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| collectorApi.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| collectorApi.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| collectorApi.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| collectorApi.replicas | int | `2` | Number of replicas to deploy |
| collectorApi.service.annotations | object | `{}` | Additional custom annotations for service |
| collectorApi.service.ports.grpc | int | `5050` | gRPC service port |
| collectorApi.service.ports.http | int | `5049` | HTTP port listen to path: /v1/traces, health check at /healthz |
| collectorApi.service.ports.internal | int | `5048` | internal service port |
| collectorApi.service.type | string | `"ClusterIP"` | service type |
| collectorApi.tolerations | list | `[]` | Tolerations for pods assignment |

### CollectorWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| collectorWorker.affinity | object | `{}` | Affinity for pods assignment |
| collectorWorker.app.extraIgnoreEndpoints | list | `[]` | Array with extra ignore Endpoints variables to add |
| collectorWorker.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| collectorWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| collectorWorker.image.pullSecrets | list | `[]` | image pull secrets |
| collectorWorker.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| collectorWorker.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| collectorWorker.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| collectorWorker.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| collectorWorker.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| collectorWorker.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| collectorWorker.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| collectorWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| collectorWorker.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| collectorWorker.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| collectorWorker.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| collectorWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| collectorWorker.podLabels | object | `{}` | Extra labels for pods |
| collectorWorker.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| collectorWorker.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| collectorWorker.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| collectorWorker.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| collectorWorker.readinessProbe.path | string | `"/readiness"` | Path for livenessProbe |
| collectorWorker.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| collectorWorker.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| collectorWorker.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| collectorWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"collectorWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| collectorWorker.service.ports.http | int | `5052` | HTTP service port, health check at /healthz |
| collectorWorker.tolerations | list | `[]` | Tolerations for pods assignment |

### Common parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonAnnotations | object | `{}` | Annotations to add to all deployed objects |
| commonLabels | object | `{}` | Labels to add to all deployed objects |
| diagnosticMode.enabled | bool | `false` | Enable diagnostic mode (all probes will be disabled) |
| extraDeploy | list | `[]` | Array of extra objects to deploy with the release |
| global.tolerations | list | `[]` | Tolerations to add to all deployed objects, except prometheus and redis |
| kubeVersion | string | `""` | kubeVersion Override Kubernetes version |

### Global Digma parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.accessToken | string | `nil` | access token for plugin authentication, and set the same one in the IDE plugin settings. |
| digma.deployment.size | string | `"medium"` | adjusts the deployment to efficiently handle different scales of workload, and can be either small, medium, or large. |
| digma.emailSettings | object | `{"apiKey":null,"url":null}` | Email settings configuration |
| digma.emailSettings.apiKey | string | `nil` | Email gateway API key |
| digma.emailSettings.url | string | `nil` | Email gateway URL |
| digma.externals.postgresql.host | string | `""` | Host of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |
| digma.externals.postgresql.password | string | `""` | Password of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |
| digma.externals.postgresql.port | int | `5432` | Port of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |
| digma.externals.postgresql.user | string | `""` | User of an external PostgreSQL instance to connect (only if postgresql.enabled=false) |
| digma.licenseKey | string | `nil` | a digma license to use,If you've signed up for a free Digma account you should have received a Digma license to use. You can use this [link](https://digma.ai/sign-up/) to sign up |
| digma.report.emailGateway | object | `{"apiKey":null,"url":null}` | Email gateway settings (legacy) |
| digma.report.emailGateway.apiKey | string | `nil` | Email gateway API key |
| digma.report.emailGateway.url | string | `nil` | Email gateway URL |
| digma.report.enabled | bool | `false` | daily issues report enabled |
| digma.report.recipients.bcc | string | `nil` | hidden from other recipients, list of recipients separated by semicolons (;) |
| digma.report.recipients.cc | string | `nil` | report email additional recipients, list of recipients separated by semicolons (;) |
| digma.report.recipients.to | string | `nil` | email recipients, list of recipients separated by semicolons (;) |
| digma.report.scheduledTimeUtc | string | `nil` | scheduled time of the report, HH:mm:ss (24-hour format) |
| digma.report.uiExternalBaseUrl | string | `nil` | UI external service URL (automatically detected if not set) |

### Authentication

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.auth.allowedEmailDomains | string | `nil` | Comma-separated or semicolon-separated list of allowed email domains for user registration |
| digma.auth.email | string | `nil` | Admin user email (must be provided together with password) |
| digma.auth.emailVerificationEnabled | bool | `false` | Enable email verification for new users. If enabled, emailSettings.url must be set |
| digma.auth.password | string | `nil` | Admin user password (must be provided together with email), requires a minimum length of 6 characters and at least one non-alphanumeric character. |
| digma.auth.securedCookie | bool | `true` | Setting auth cookie secure flag. Set to false if ui is accessed via http |

### MCP parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.mcp.enabled | bool | `true` | enable mcp |

### Social Login

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.socialLogin.enabled | bool | `false` | enable social login |
| digma.socialLogin.google.clientId | string | `nil` | google clientId |

### Social Login     

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| digma.socialLogin.google.secret | string | `nil` | google secret |

### Global Docker image parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.imagePullSecrets | list | `[]` | Global Docker registry secret names as an array |

### Grafana parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| grafana.grafana.affinity | object | `{}` | Affinity for pods assignment |
| grafana.grafana.nodeSelector | object | `{}` | Node labels for pods assignment |
| grafana.grafana.podAnnotations | object | `{}` | Extra annotations for pods |
| grafana.grafana.podLabels | object | `{}` | Extra labels for pods |
| grafana.grafana.tolerations | string | `"{{ include \"common.tplvalues.render\" (dict \"value\" .Values.global.tolerations \"context\" $) }}"` | Tolerations for pods assignment |

### Jaeger parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| jaeger.affinity | object | `{}` | Affinity for pods assignment |
| jaeger.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| jaeger.image.pullSecrets | list | `[]` | image pull secrets |
| jaeger.image.registry | string | `"docker.io"` | image registry |
| jaeger.image.repository | string | `"jaegertracing/all-in-one"` | image repository |
| jaeger.image.tag | string | `"1.72.0"` | image tag |
| jaeger.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| jaeger.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| jaeger.ingress.enabled | bool | `false` | Enable ingress |
| jaeger.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| jaeger.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| jaeger.ingress.hostname | string | `nil` | Default host for the ingress record |
| jaeger.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| jaeger.ingress.path | string | `"/"` | The Path to UI. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| jaeger.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| jaeger.nodeSelector | object | `{}` | Node labels for pods assignment |
| jaeger.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| jaeger.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| jaeger.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| jaeger.podAnnotations | object | `{}` | Extra annotations for pods |
| jaeger.podLabels | object | `{}` | Extra labels for pods |
| jaeger.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1000}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| jaeger.publicBaseUrl | string | `""` | jaeger external or public URL, automatically detected if not set |
| jaeger.replicas | int | `1` | Number of replicas to deploy |
| jaeger.service.annotations | object | `{}` | Additional custom annotations for service |
| jaeger.service.ports.grpc_internal | int | `4317` | gRPC collector internal service port |
| jaeger.service.ports.http_ui | int | `16686` | UI HTTP service port |
| jaeger.service.type | string | `"ClusterIP"` | service type |
| jaeger.tolerations | list | `[]` | Tolerations for pods assignment |

### Kafka parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| kafka.controller.affinity | object | `{}` | Affinity for pods assignment |
| kafka.controller.config | object | `{"log":{"retention":{"check":{"interval":{"ms":120000}},"minutes":10},"roll":{"ms":120000}}}` | Additional Kafka configuration properties |
| kafka.controller.nodeSelector | object | `{}` | Node labels for pods assignment |
| kafka.controller.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| kafka.controller.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| kafka.controller.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| kafka.controller.podAnnotations | object | `{}` | Extra annotations for pods |
| kafka.controller.podLabels | object | `{}` | Extra labels for pods |
| kafka.controller.tolerations | string | `"{{ include \"common.tplvalues.render\" (dict \"value\" .Values.global.tolerations \"context\" $) }}"` | Tolerations for pods assignment |

### MeasurementAnalysis parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| measurementAnalysis.affinity | object | `{}` | Affinity for pods assignment |
| measurementAnalysis.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| measurementAnalysis.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| measurementAnalysis.image.pullSecrets | list | `[]` | image pull secrets |
| measurementAnalysis.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| measurementAnalysis.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| measurementAnalysis.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| measurementAnalysis.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| measurementAnalysis.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| measurementAnalysis.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| measurementAnalysis.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| measurementAnalysis.nodeSelector | object | `{}` | Node labels for pods assignment |
| measurementAnalysis.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| measurementAnalysis.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| measurementAnalysis.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| measurementAnalysis.podAnnotations | object | `{}` | Extra annotations for pods |
| measurementAnalysis.podLabels | object | `{}` | Extra labels for pods |
| measurementAnalysis.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| measurementAnalysis.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| measurementAnalysis.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| measurementAnalysis.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| measurementAnalysis.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| measurementAnalysis.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| measurementAnalysis.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| measurementAnalysis.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| measurementAnalysis.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"measurementAnalysis\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| measurementAnalysis.service.ports.http | int | `5054` | HTTP service port, health check at /healthz |
| measurementAnalysis.tolerations | list | `[]` | Tolerations for pods assignment |

### MetricsExporter parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| metricsExporter.affinity | object | `{}` | Affinity for pods assignment |
| metricsExporter.enabled | bool | `true` | Enable k8s metrics exporter |
| metricsExporter.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| metricsExporter.image.pullSecrets | list | `[]` | image pull secrets |
| metricsExporter.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| metricsExporter.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| metricsExporter.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| metricsExporter.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| metricsExporter.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| metricsExporter.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| metricsExporter.nodeSelector | object | `{}` | Node labels for pods assignment |
| metricsExporter.podAnnotations | object | `{}` | Extra annotations for pods |
| metricsExporter.podLabels | object | `{}` | Extra labels for pods |
| metricsExporter.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| metricsExporter.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| metricsExporter.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| metricsExporter.readinessProbe.path | string | `"/"` | Path for readinessProbe |
| metricsExporter.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| metricsExporter.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| metricsExporter.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| metricsExporter.replicas | int | `1` | Number of replicas to deploy |
| metricsExporter.service.annotations | object | `{}` | Additional custom annotations for service |
| metricsExporter.service.ports.http | int | `9091` | HTTP service port |
| metricsExporter.serviceAccount | object | `{"annotations":{}}` | Annotations to add to the ServiceAccount Metadata |
| metricsExporter.tolerations | list | `[]` | Tolerations for pods assignment |

### UI parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nginx.affinity | object | `{}` | Affinity for pods assignment |
| nginx.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| nginx.image.pullSecrets | list | `[]` | image pull secrets |
| nginx.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| nginx.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| nginx.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| nginx.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| nginx.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| nginx.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| nginx.nodeSelector | object | `{}` | Node labels for pods assignment |
| nginx.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| nginx.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| nginx.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| nginx.podAnnotations | object | `{}` | Extra annotations for pods |
| nginx.podLabels | object | `{}` | Extra labels for pods |
| nginx.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1000}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| nginx.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| nginx.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| nginx.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| nginx.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| nginx.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| nginx.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| nginx.replicas | int | `1` | Number of replicas to deploy |
| nginx.tolerations | list | `[]` | Tolerations for pods assignment |
| ui.apps | list | `["admin","agentic","email-confirmation","ide-launcher","login"]` | List of UI applications/folders |
| ui.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| ui.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| ui.ingress.enabled | bool | `false` | Enable ingress |
| ui.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| ui.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| ui.ingress.hostname | string | `nil` | Default host for the ingress record |
| ui.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| ui.ingress.path | string | `"/"` | The Path to UI. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| ui.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| ui.service.annotations | object | `{}` | Additional custom annotations for service |
| ui.service.ports.http | int | `8080` | HTTP service port |
| ui.service.type | string | `"ClusterIP"` | service type |

### Observability parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| observability.environmentName | string | `"digma"` | Environments represent different deployment stages or scopes |
| observability.otlp.exportLogs | bool | `true` | Export logs |
| observability.otlp.exportMetrics | bool | `true` | Export metrics |
| observability.otlp.exportTraces | bool | `true` | Export traces |
| observability.otlp.remoteEndpoint | string | `nil` | Please note this parameter, cannot be set while useLocal is true, If no port is defined, port 443 will be added automatically  |
| observability.otlp.samplerProbability | float | `0.1` | Control the fraction of traces that are sampled |
| observability.useLocal | bool | `true` | Use local observability, Deploys Prometheus and Grafana  |

### Otel Collector parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| otelCollector.affinity | object | `{}` | Affinity for pods assignment |
| otelCollector.configuration | string | `"extensions:\n  health_check:\n    endpoint: \"0.0.0.0:{{ .Values.otelCollector.service.ports.health }}\"\nreceivers:\n  otlp/grpc:\n    protocols:\n      grpc:\n        endpoint: 0.0.0.0:{{ .Values.otelCollector.service.ports.grpc }}\n  otlp/http:\n    protocols:\n      http:\n        endpoint: 0.0.0.0:{{ .Values.otelCollector.service.ports.http }}\n  datadog:\n    endpoint: 0.0.0.0:{{ .Values.otelCollector.service.ports.datadog }}\nprocessors:\n  batch:\n    timeout: 1000ms\n    send_batch_size: 500\n    send_batch_max_size: 500\n  probabilistic_sampler:\n    sampling_percentage: {{ .Values.otelCollector.samplingPercentage }}\n  transform:\n    trace_statements:\n      - context: span\n        statements:\n          - set(resource.attributes[\"scm.commit.id\"], attributes[\"_dd.git.commit.sha\"]) where attributes[\"_dd.git.commit.sha\"] != nil\n          - set(resource.attributes[\"digma.environment\"], attributes[\"digma.environment\"]) where attributes[\"digma.environment\"] != nil\n          - set(resource.attributes[\"digma.environment.type\"], attributes[\"digma.environment.type\"]) where attributes[\"digma.environment.type\"] != nil\n          - set(resource.attributes[\"service.name\"], attributes[\"_dd.base_service\"]) where attributes[\"_dd.base_service\"] != nil\n          - set(attributes[\"db.statement\"], attributes[\"sql.query\"]) where attributes[\"sql.query\"] != nil\n          - set(attributes[\"db.system\"], attributes[\"db.type\"]) where attributes[\"db.type\"] != nil\n          - set(attributes[\"db.name\"], attributes[\"db.instance\"]) where attributes[\"db.instance\"] != nil\nexporters:\n  logging:\n    loglevel: debug\n  otlphttp:\n    endpoint: http://{{ include \"digma.collector-api\" . }}:{{ .Values.collectorApi.service.ports.http }}\n    compression: gzip\n    tls:\n      insecure: true\n    sending_queue:\n      enabled: true\n      num_consumers: 100\n      queue_size: 1000\n  otlp:\n    endpoint: {{ include \"digma.collector-api\" . }}:{{ .Values.collectorApi.service.ports.grpc }}\n    tls:\n      insecure: true\n    sending_queue:\n      enabled: true\n      num_consumers: 100\n      queue_size: 1000\nservice:\n  extensions: [health_check]\n  pipelines:\n    traces/1:\n      receivers: [otlp/http]\n      processors: [probabilistic_sampler, batch]\n      exporters: [otlphttp]\n    traces/2:\n      receivers: [otlp/grpc]\n      processors: [probabilistic_sampler, batch]\n      exporters: [otlphttp]\n    traces/datadog:\n      receivers: [datadog]\n      processors: [probabilistic_sampler, transform, batch]\n      exporters: [otlphttp]\n"` | This content will be stored in the the config.yaml file and the content can be a template. |
| otelCollector.datadog.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| otelCollector.datadog.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| otelCollector.datadog.ingress.enabled | bool | `false` | Enable ingress |
| otelCollector.datadog.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| otelCollector.datadog.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| otelCollector.datadog.ingress.hostname | string | `nil` | Default host for the ingress record |
| otelCollector.datadog.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| otelCollector.datadog.ingress.path | string | `"/"` | The Path to otelCollector. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| otelCollector.datadog.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| otelCollector.existingConfigmap | string | `""` | The name of an existing ConfigMap with your custom configuration |
| otelCollector.existingConfigmapKey | string | `""` | The name of the key with the config file |
| otelCollector.grpc.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| otelCollector.grpc.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| otelCollector.grpc.ingress.enabled | bool | `false` | Enable ingress |
| otelCollector.grpc.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| otelCollector.grpc.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| otelCollector.grpc.ingress.hostname | string | `nil` | Default host for the ingress record |
| otelCollector.grpc.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| otelCollector.grpc.ingress.path | string | `"/"` | The Path to otelCollector. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| otelCollector.grpc.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| otelCollector.http.ingress.annotations | string | `nil` | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| otelCollector.http.ingress.apiVersion | string | `""` | Force Ingress API version (automatically detected if not set) |
| otelCollector.http.ingress.enabled | bool | `false` | Enable ingress |
| otelCollector.http.ingress.extraPaths | list | `[]` | Any additional paths that may need to be added to the ingress under the main host |
| otelCollector.http.ingress.extraRules | list | `[]` | Additional rules to be covered with this ingress record |
| otelCollector.http.ingress.hostname | string | `nil` | Default host for the ingress record |
| otelCollector.http.ingress.ingressClassName | string | `nil` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) |
| otelCollector.http.ingress.path | string | `"/"` | The Path to otelCollector. You may need to set this to '/*' in order to use this with ALB ingress controllers. |
| otelCollector.http.ingress.pathType | string | `"ImplementationSpecific"` | Ingress path type |
| otelCollector.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| otelCollector.image.pullSecrets | list | `[]` | image pull secrets |
| otelCollector.image.registry | string | `"docker.io"` | image registry |
| otelCollector.image.repository | string | `"otel/opentelemetry-collector-contrib"` | image repository |
| otelCollector.image.tag | string | `"0.103.0"` | image tag |
| otelCollector.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| otelCollector.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| otelCollector.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| otelCollector.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| otelCollector.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| otelCollector.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| otelCollector.nodeSelector | object | `{}` | Node labels for pods assignment |
| otelCollector.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| otelCollector.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| otelCollector.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| otelCollector.podAnnotations | object | `{}` | Extra annotations for pods |
| otelCollector.podLabels | object | `{}` | Extra labels for pods |
| otelCollector.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| otelCollector.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| otelCollector.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| otelCollector.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| otelCollector.readinessProbe.path | string | `"/"` | Path for readinessProbe |
| otelCollector.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| otelCollector.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| otelCollector.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| otelCollector.receivers.datadog.enabled | bool | `false` | Enable/disable the Datadog receiver |
| otelCollector.receivers.otelGRPC.enabled | bool | `true` | Enable/disable the OTLP GRPC receiver |
| otelCollector.receivers.otelHttp.enabled | bool | `true` | Enable/disable the OTLP HTTP receiver |
| otelCollector.replicas | int | `1` | Number of replicas to deploy |
| otelCollector.samplingPercentage | int | `100` | telemetry data that should be sampled and sent to the backend |
| otelCollector.service.annotations | object | `{}` | Additional custom annotations for service |
| otelCollector.service.ports.datadog | int | `8126` | Datadog port |
| otelCollector.service.ports.grpc | int | `4317` | gRPC port |
| otelCollector.service.ports.health | int | `13133` | health check service port |
| otelCollector.service.ports.http | int | `4318` | HTTP port listen to path: /v1/traces |
| otelCollector.service.type | string | `"ClusterIP"` | service type |
| otelCollector.tolerations | list | `[]` | Tolerations for pods assignment |

### Otel CollectorDF parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| otelCollectorDf.affinity | object | `{}` | Affinity for pods assignment |
| otelCollectorDf.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| otelCollectorDf.image.pullSecrets | list | `[]` | image pull secrets |
| otelCollectorDf.image.registry | string | `"docker.io"` | image registry |
| otelCollectorDf.image.repository | string | `"otel/opentelemetry-collector-contrib"` | image repository |
| otelCollectorDf.image.tag | string | `"0.103.0"` | image tag |
| otelCollectorDf.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| otelCollectorDf.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| otelCollectorDf.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| otelCollectorDf.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| otelCollectorDf.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| otelCollectorDf.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| otelCollectorDf.nodeSelector | object | `{}` | Node labels for pods assignment |
| otelCollectorDf.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| otelCollectorDf.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| otelCollectorDf.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| otelCollectorDf.podAnnotations | object | `{}` | Extra annotations for pods |
| otelCollectorDf.podLabels | object | `{}` | Extra labels for pods |
| otelCollectorDf.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| otelCollectorDf.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| otelCollectorDf.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| otelCollectorDf.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| otelCollectorDf.readinessProbe.path | string | `"/"` | Path for readinessProbe |
| otelCollectorDf.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| otelCollectorDf.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| otelCollectorDf.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| otelCollectorDf.replicas | int | `1` | Number of replicas to deploy |
| otelCollectorDf.service.annotations | object | `{}` | Additional custom annotations for service |
| otelCollectorDf.service.ports.grpc | int | `4317` | HTTP gRPC service port |
| otelCollectorDf.service.ports.health | int | `13133` | health check service port |
| otelCollectorDf.service.ports.prometheus_scraper | int | `8889` | prometheus scraper service port |
| otelCollectorDf.tolerations | list | `[]` | Tolerations for pods assignment |

### PipelineWorker parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pipelineWorker.affinity | object | `{}` | Affinity for pods assignment |
| pipelineWorker.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| pipelineWorker.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| pipelineWorker.image.pullSecrets | list | `[]` | image pull secrets |
| pipelineWorker.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| pipelineWorker.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| pipelineWorker.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| pipelineWorker.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| pipelineWorker.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| pipelineWorker.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| pipelineWorker.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| pipelineWorker.nodeSelector | object | `{}` | Node labels for pods assignment |
| pipelineWorker.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| pipelineWorker.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| pipelineWorker.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| pipelineWorker.podAnnotations | object | `{}` | Extra annotations for pods |
| pipelineWorker.podLabels | object | `{}` | Extra labels for pods |
| pipelineWorker.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| pipelineWorker.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| pipelineWorker.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| pipelineWorker.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| pipelineWorker.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| pipelineWorker.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| pipelineWorker.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| pipelineWorker.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| pipelineWorker.replicas | string | `"{{ index .Values.presets .Values.digma.deployment.size \"pipelineWorker\" \"replicas\" }}"` | replicas based on a given preset(.Values.digma.deployment.size) Number of replicas to deploy |
| pipelineWorker.service.ports.http | int | `5055` | HTTP service port, health check at /healthz |
| pipelineWorker.tolerations | list | `[]` | Tolerations for pods assignment |

### Postgresql parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.metrics.enabled | bool | `true` | Start a prometheus exporter |
| postgresql.primary.affinity | object | `{}` | Affinity for pods assignment |
| postgresql.primary.nodeSelector | object | `{}` | Node labels for pods assignment |
| postgresql.primary.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| postgresql.primary.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| postgresql.primary.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| postgresql.primary.podAnnotations | object | `{}` | Extra annotations for pods |
| postgresql.primary.podLabels | object | `{}` | Extra labels for pods |
| postgresql.primary.tolerations | string | `"{{ include \"common.tplvalues.render\" (dict \"value\" .Values.global.tolerations \"context\" $) }}"` | Tolerations for pods assignment |

### Postgresql-Backup parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql_backup.annotations | object | `{}` | Extra annotations for job |
| postgresql_backup.enabled | bool | `false` | postgresql backup enabled |
| postgresql_backup.presigned_url | string | `""` | Url to upload the backup file, provided by Digma |

### Prometheus parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| prometheus.server.affinity | object | `{}` | Affinity for pods assignment |
| prometheus.server.nodeSelector | object | `{}` | Node labels for pods assignment |
| prometheus.server.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| prometheus.server.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| prometheus.server.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| prometheus.server.podAnnotations | object | `{}` | Extra annotations for pods |
| prometheus.server.podLabels | object | `{}` | Extra labels for pods |
| prometheus.server.tolerations | list | `[]` | Tolerations for pods assignment |
| prometheus.server.updateStrategy | object | `{"type":"Recreate"}` | Prometheus deployment strategy type. Is a deployment resource therefore, Strategy type should be set to Recreate to avoid dead locks |

### Redis parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| redis.master.affinity | object | `{}` | Affinity for pods assignment |
| redis.master.nodeSelector | object | `{}` | Node labels for pods assignment |
| redis.master.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| redis.master.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| redis.master.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| redis.master.podAnnotations | object | `{}` | Extra annotations for pods |
| redis.master.podLabels | object | `{}` | Extra labels for pods |
| redis.master.tolerations | list | `[]` | Tolerations for pods assignment |
| redis.metrics.enabled | bool | `true` | Start a sidecar prometheus exporter to expose Redis® metrics |

### Scheduler parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| scheduler.affinity | object | `{}` | Affinity for pods assignment |
| scheduler.extraEnvVars | list | `[]` | Array with extra environment variables to add |
| scheduler.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| scheduler.image.pullSecrets | list | `[]` | image pull secrets |
| scheduler.livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| scheduler.livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| scheduler.livenessProbe.initialDelaySeconds | int | `120` | Initial delay seconds for livenessProbe |
| scheduler.livenessProbe.path | string | `"/healthz"` | Path for livenessProbe |
| scheduler.livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| scheduler.livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| scheduler.livenessProbe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| scheduler.nodeSelector | object | `{}` | Node labels for pods assignment |
| scheduler.pdb.create | bool | `false` | Enable PodDisruptionBudget |
| scheduler.pdb.maxUnavailable | string | `""` | Set PodDisruptionBudget minAvailable |
| scheduler.pdb.minAvailable | string | `""` | Set PodDisruptionBudget minAvailable |
| scheduler.podAnnotations | object | `{}` | Extra annotations for pods |
| scheduler.podLabels | object | `{}` | Extra labels for pods |
| scheduler.podSecurityContext | object | `{"enabled":true,"runAsNonRoot":true,"runAsUser":1654}` | Pod Security Context, ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| scheduler.readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| scheduler.readinessProbe.failureThreshold | int | `24` | Failure threshold for readinessProbe |
| scheduler.readinessProbe.initialDelaySeconds | int | `20` | Initial delay seconds for readinessProbe |
| scheduler.readinessProbe.path | string | `"/readiness"` | Path for readinessProbe |
| scheduler.readinessProbe.periodSeconds | int | `10` | Period seconds for readinessProbe |
| scheduler.readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| scheduler.readinessProbe.timeoutSeconds | int | `10` | Timeout seconds for readinessProbe |
| scheduler.replicas | int | `1` | Number of replicas to deploy |
| scheduler.service.ports.http | int | `5053` | HTTP service port, health check at /healthz |
| scheduler.tolerations | list | `[]` | Tolerations for pods assignment |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agentic.enabled | bool | `false` |  |
| agentic.image.registry | string | `"docker.io"` |  |
| agentic.image.repository | string | `"digmatic/digma-agentic"` |  |
| agentic.image.tag | string | `"0.0.145"` |  |
| agentic.resources.limits.cpu | string | `"750m"` |  |
| agentic.resources.limits.memory | string | `"768Mi"` |  |
| agentic.resources.requests.cpu | string | `"500m"` |  |
| agentic.resources.requests.memory | string | `"512Mi"` |  |
| ai.enabled | bool | `false` |  |
| ai.image.registry | string | `"docker.io"` |  |
| ai.image.repository | string | `"digmatic/digma-ai"` |  |
| ai.image.tag | string | `"0.0.27"` |  |
| ai.resources.limits.cpu | string | `"750m"` |  |
| ai.resources.limits.memory | string | `"768Mi"` |  |
| ai.resources.requests.cpu | string | `"500m"` |  |
| ai.resources.requests.memory | string | `"512Mi"` |  |
| analyticsApi.image.registry | string | `"docker.io"` |  |
| analyticsApi.image.repository | string | `"digmatic/digma-analytics"` |  |
| analyticsApi.resources.limits.cpu | string | `"800m"` |  |
| analyticsApi.resources.limits.memory | string | `"800Mi"` |  |
| analyticsApi.resources.requests.cpu | string | `"100m"` |  |
| analyticsApi.resources.requests.memory | string | `"300Mi"` |  |
| clickhouse.auth.password | string | `"clickhouse"` |  |
| clickhouse.auth.username | string | `"clickhouse"` |  |
| clickhouse.enabled | bool | `false` |  |
| clickhouse.metrics.enabled | bool | `true` |  |
| clickhouse.pdb.create | bool | `false` |  |
| clickhouse.pdb.maxUnavailable | string | `""` |  |
| clickhouse.pdb.minAvailable | string | `""` |  |
| clickhouse.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| clickhouse.persistence.enabled | bool | `true` |  |
| clickhouse.persistence.size | string | `"50Gi"` |  |
| clickhouse.persistence.storageClass | string | `""` |  |
| clickhouse.replicaCount | int | `1` |  |
| clickhouse.resources.limits.cpu | int | `4` |  |
| clickhouse.resources.limits.memory | string | `"8Gi"` |  |
| clickhouse.resources.requests.cpu | int | `2` |  |
| clickhouse.resources.requests.memory | string | `"4Gi"` |  |
| clickhouse.service.ports.http | int | `8123` |  |
| clickhouse.service.ports.native | int | `9000` |  |
| clickhouse.service.type | string | `"ClusterIP"` |  |
| clickhouse.shards | int | `1` |  |
| clickhouse.zookeeper.enabled | bool | `false` |  |
| collectorApi.image.registry | string | `"docker.io"` |  |
| collectorApi.image.repository | string | `"digmatic/digma-collector"` |  |
| collectorApi.resources.limits.cpu | float | `1.5` |  |
| collectorApi.resources.limits.memory | string | `"1024Mi"` |  |
| collectorApi.resources.requests.cpu | string | `"500m"` |  |
| collectorApi.resources.requests.memory | string | `"768Mi"` |  |
| collectorWorker.env.BlockedTrace__TraceSpansLimit | int | `3000` |  |
| collectorWorker.env.ExtendedObservability__Enable | bool | `true` |  |
| collectorWorker.env.Sampling__Enable | bool | `true` |  |
| collectorWorker.env.ThresholdOptions__RecentActivityUpdateThresholdSeconds | int | `30` |  |
| collectorWorker.env.TraceTempStorage__TraceForJaegerExpirationInMinutes | int | `10` |  |
| collectorWorker.image.registry | string | `"docker.io"` |  |
| collectorWorker.image.repository | string | `"digmatic/digma-collector-worker"` |  |
| collectorWorker.resources.limits.cpu | float | `1.5` |  |
| collectorWorker.resources.limits.memory | string | `"1536Mi"` |  |
| collectorWorker.resources.requests.cpu | float | `1` |  |
| collectorWorker.resources.requests.memory | string | `"1024Mi"` |  |
| debug.enabled | bool | `false` |  |
| debug.kafkaUi.image.pullPolicy | string | `"IfNotPresent"` |  |
| debug.kafkaUi.image.registry | string | `"docker.io"` |  |
| debug.kafkaUi.image.repository | string | `"provectuslabs/kafka-ui"` |  |
| debug.kafkaUi.image.tag | string | `"v0.7.1"` |  |
| debug.kafkaUi.port | int | `8080` |  |
| debug.pgadmin.env[0].name | string | `"PGADMIN_DEFAULT_EMAIL"` |  |
| debug.pgadmin.env[0].value | string | `"admin@admin.com"` |  |
| debug.pgadmin.env[1].name | string | `"PGADMIN_DEFAULT_PASSWORD"` |  |
| debug.pgadmin.env[1].value | string | `"admin"` |  |
| debug.pgadmin.image.pullPolicy | string | `"IfNotPresent"` |  |
| debug.pgadmin.image.registry | string | `"docker.io"` |  |
| debug.pgadmin.image.repository | string | `"dpage/pgadmin4"` |  |
| debug.pgadmin.image.tag | string | `"latest"` |  |
| debug.pgadmin.port | int | `8082` |  |
| debug.pullSecrets | list | `[]` |  |
| debug.redisCommander.image.pullPolicy | string | `"IfNotPresent"` |  |
| debug.redisCommander.image.registry | string | `"ghcr.io"` |  |
| debug.redisCommander.image.repository | string | `"joeferner/redis-commander"` |  |
| debug.redisCommander.image.tag | string | `"latest"` |  |
| debug.redisCommander.port | int | `8081` |  |
| digma.uiExternalBaseUrl | string | `""` |  |
| elasticsearchlogs.enabled | bool | `false` |  |
| global.security.allowInsecureImages | bool | `true` |  |
| grafana.admin.password | string | `"JNeCDfQ$SYlp5T"` |  |
| grafana.admin.user | string | `"admin"` |  |
| grafana.dashboardsConfigMaps[0].configMapName | string | `"digma-grafana-activities-dashboards"` |  |
| grafana.dashboardsConfigMaps[0].fileName | string | `"activities.json"` |  |
| grafana.dashboardsConfigMaps[1].configMapName | string | `"digma-grafana-environment-dashboards"` |  |
| grafana.dashboardsConfigMaps[1].fileName | string | `"environment.json"` |  |
| grafana.dashboardsConfigMaps[2].configMapName | string | `"digma-grafana-kafka-dashboards"` |  |
| grafana.dashboardsConfigMaps[2].fileName | string | `"kafka.json"` |  |
| grafana.dashboardsConfigMaps[3].configMapName | string | `"digma-grafana-apps-dashboards"` |  |
| grafana.dashboardsConfigMaps[3].fileName | string | `"apps.json"` |  |
| grafana.dashboardsConfigMaps[4].configMapName | string | `"digma-grafana-redis-dashboards"` |  |
| grafana.dashboardsConfigMaps[4].fileName | string | `"redis.json"` |  |
| grafana.dashboardsConfigMaps[5].configMapName | string | `"digma-grafana-postgres-dashboards"` |  |
| grafana.dashboardsConfigMaps[5].fileName | string | `"postgres.json"` |  |
| grafana.dashboardsProvider.enabled | bool | `true` |  |
| grafana.datasources.secretName | string | `"grafana-datasource"` |  |
| grafana.grafana.resources.limits.cpu | string | `"750m"` |  |
| grafana.grafana.resources.limits.memory | string | `"768Mi"` |  |
| grafana.grafana.resources.requests.cpu | string | `"500m"` |  |
| grafana.grafana.resources.requests.memory | string | `"512Mi"` |  |
| grafana.grafana.updateStrategy.type | string | `"Recreate"` |  |
| grafana.image.repository | string | `"bitnamilegacy/grafana"` |  |
| grafana.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` |  |
| jaeger.args | list | `[]` |  |
| jaeger.resources.limits.cpu | string | `"750m"` |  |
| jaeger.resources.limits.memory | string | `"768Mi"` |  |
| jaeger.resources.requests.cpu | string | `"500m"` |  |
| jaeger.resources.requests.memory | string | `"512Mi"` |  |
| kafka.broker.pdb.create | bool | `false` |  |
| kafka.controller.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| kafka.controller.persistence.enabled | bool | `true` |  |
| kafka.controller.persistence.size | string | `"80Gi"` |  |
| kafka.controller.replicaCount | int | `1` |  |
| kafka.controller.resources.limits.cpu | int | `2` |  |
| kafka.controller.resources.limits.memory | string | `"3Gi"` |  |
| kafka.controller.resources.requests.cpu | string | `"500m"` |  |
| kafka.controller.resources.requests.memory | string | `"2Gi"` |  |
| kafka.image.pullPolicy | string | `"IfNotPresent"` |  |
| kafka.image.registry | string | `"docker.io"` |  |
| kafka.image.repository | string | `"apache/kafka"` |  |
| kafka.image.tag | string | `"3.9.1"` |  |
| kafka.kraft.clusterId | string | `"h4U35I9QRnGhbgsEQAlXAw"` |  |
| kafka.listeners.client.protocol | string | `"PLAINTEXT"` |  |
| kafka.listeners.controller.protocol | string | `"PLAINTEXT"` |  |
| kafka.listeners.external.protocol | string | `"PLAINTEXT"` |  |
| kafka.listeners.interbroker.protocol | string | `"PLAINTEXT"` |  |
| kafka.service.ports.client | int | `9092` |  |
| kafka.service.ports.controller | int | `9093` |  |
| measurementAnalysis.env.ThresholdOptions__UpsertEndpointThresholdSeconds | int | `5` |  |
| measurementAnalysis.env.ThresholdOptions__UpsertSpanFlowMetadataThresholdSeconds | int | `5` |  |
| measurementAnalysis.env.ThresholdOptions__UpsertSpanFlowTraceThresholdHours | int | `24` |  |
| measurementAnalysis.env.ThresholdOptions__UpsertSpansThresholdSeconds | int | `5` |  |
| measurementAnalysis.image.registry | string | `"docker.io"` |  |
| measurementAnalysis.image.repository | string | `"digmatic/digma-measurement-analysis"` |  |
| measurementAnalysis.resources.limits.cpu | string | `"800m"` |  |
| measurementAnalysis.resources.limits.memory | string | `"1024Mi"` |  |
| measurementAnalysis.resources.requests.cpu | string | `"500m"` |  |
| measurementAnalysis.resources.requests.memory | string | `"512Mi"` |  |
| metricsExporter.image.registry | string | `"docker.io"` |  |
| metricsExporter.image.repository | string | `"digmatic/k8s-metrics-exporter"` |  |
| metricsExporter.image.tag | string | `"0.0.12"` |  |
| metricsExporter.resources.limits.cpu | string | `"750m"` |  |
| metricsExporter.resources.limits.memory | string | `"768Mi"` |  |
| metricsExporter.resources.requests.cpu | string | `"500m"` |  |
| metricsExporter.resources.requests.memory | string | `"512Mi"` |  |
| nginx.commonHeaders.Content-Security-Policy | string | `"default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline' https://*.google.com https://*.posthog.com https://*.productfruits.com; connect-src 'self' http://localhost:* https://*.posthog.com https://*.productfruits.com https://productfruits.help/ wss://*.productfruits.com; worker-src 'self' blob: data:; img-src 'self' https://*.posthog.com https://*.productfruits.com blob: data:; style-src 'self' 'unsafe-inline' https://*.posthog.com https://*.productfruits.com; font-src 'self' https://*.posthog.com; frame-src https://*.productfruits.com; media-src https://*.posthog.com blob:;"` |  |
| nginx.commonHeaders.Permissions-Policy | string | `"accelerometer=(), ambient-light-sensor=(), attribution-reporting=(), autoplay=(), bluetooth=(), browsing-topics=(), camera=(), compute-pressure=(), cross-origin-isolated=(), deferred-fetch=(), deferred-fetch-minimal=(), display-capture=(), document-domain=(), encrypted-media=(), fullscreen=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), identity-credentials-get=(), idle-detection=(), local-fonts=(), magnetometer=(), microphone=(), midi=(), otp-credentials=(), payment=(), picture-in-picture=(), publickey-credentials-create=(), publickey-credentials-get=(), screen-wake-lock=(), serial=(), speaker-selection=(), storage-access=(), usb=(), web-share=(), window-management=(), xr-spatial-tracking=()"` |  |
| nginx.commonHeaders.Referrer-Policy | string | `"same-origin"` |  |
| nginx.commonHeaders.X-Content-Type-Options | string | `"nosniff"` |  |
| nginx.commonHeaders.X-Frame-Options | string | `"DENY"` |  |
| nginx.image.registry | string | `"docker.io"` |  |
| nginx.image.repository | string | `"digmatic/digma-ui"` |  |
| nginx.image.tag | string | `"16.8.1"` |  |
| nginx.resources.limits.cpu | string | `"200m"` |  |
| nginx.resources.limits.memory | string | `"200Mi"` |  |
| nginx.resources.requests.cpu | string | `"100m"` |  |
| nginx.resources.requests.memory | string | `"100Mi"` |  |
| opensearch.clusterName | string | `"opensearch-cluster"` |  |
| opensearch.config."opensearch.yml" | string | `"cluster.name: opensearch-cluster\nnetwork.host: 0.0.0.0\nplugins.security.disabled: true\ndiscovery.type: single-node\n"` |  |
| opensearch.config."performance-analyzer.properties" | string | `"# Minimal configuration to prevent startup errors\nwebservice-port = 9600\nrpc-port = 9650\nhttps-enabled = false\ncleanup-metrics-db-files = true\n"` |  |
| opensearch.config.plugin-stats-metadata | string | `"# Empty metadata file to prevent errors\n"` |  |
| opensearch.extraEnvs[0].name | string | `"OPENSEARCH_JAVA_OPTS"` |  |
| opensearch.extraEnvs[0].value | string | `"-Xmx2g -Xms2g"` |  |
| opensearch.extraVolumeMounts[0].mountPath | string | `"/usr/share/opensearch/config/opensearch-performance-analyzer/performance-analyzer.properties"` |  |
| opensearch.extraVolumeMounts[0].name | string | `"config"` |  |
| opensearch.extraVolumeMounts[0].subPath | string | `"performance-analyzer.properties"` |  |
| opensearch.extraVolumeMounts[1].mountPath | string | `"/usr/share/opensearch/config/opensearch-performance-analyzer/plugin-stats-metadata"` |  |
| opensearch.extraVolumeMounts[1].name | string | `"config"` |  |
| opensearch.extraVolumeMounts[1].subPath | string | `"plugin-stats-metadata"` |  |
| opensearch.httpPort | int | `9200` |  |
| opensearch.masterService | string | `"opensearch-cluster-master"` |  |
| opensearch.nodeAffinity | object | `{}` |  |
| opensearch.nodeGroup | string | `"master"` |  |
| opensearch.nodeSelector | object | `{}` |  |
| opensearch.persistence.enabled | bool | `true` |  |
| opensearch.persistence.size | string | `"80Gi"` |  |
| opensearch.podAffinity | object | `{}` |  |
| opensearch.replicas | int | `1` |  |
| opensearch.resources.limits.cpu | string | `"2000m"` |  |
| opensearch.resources.limits.memory | string | `"4Gi"` |  |
| opensearch.resources.requests.cpu | string | `"1000m"` |  |
| opensearch.resources.requests.memory | string | `"2Gi"` |  |
| opensearch.service.type | string | `"ClusterIP"` |  |
| opensearch.singleNode | bool | `true` |  |
| opensearch.tolerations | list | `[]` |  |
| opensearch.transportPort | int | `9300` |  |
| otelCollector.resources.limits.cpu | string | `"750m"` |  |
| otelCollector.resources.limits.memory | string | `"1536Mi"` |  |
| otelCollector.resources.requests.cpu | string | `"500m"` |  |
| otelCollector.resources.requests.memory | string | `"512Mi"` |  |
| otelCollectorDf.configuration | string | `"extensions:\n  health_check:\n    endpoint: \"0.0.0.0:{{ .Values.otelCollectorDf.service.ports.health }}\"\nreceivers:\n  otlp:\n    protocols: \n      grpc:\n        endpoint: 0.0.0.0:{{ .Values.otelCollectorDf.service.ports.grpc }}\n  kafkametrics:\n    protocol_version: 2.0.0\n    collection_interval: 10s\n    brokers: [{{include \"digma.kafka.client\" .}}]\n    scrapers:\n      - brokers\n      - topics\n      - consumers\n  prometheus/k8s_metrics:\n    config:\n      scrape_configs:\n        - job_name: k8s-metrics\n          scrape_interval: 5s\n          static_configs:\n            - targets: [{{ include \"digma.k8s-metrics-exporter-target\" . }}]\n  {{ if eq (include \"digma.redis.metrics.enabled\" .) \"true\" }}\n  prometheus/redis:\n    config:\n      scrape_configs:\n        - job_name: k8s-metrics\n          scrape_interval: 5s\n          static_configs:\n            - targets: [{{ include \"digma.redis.metrics.url\" . }}]\n  {{ end }}\n  {{ if eq (include \"digma.postgresql.metrics.enabled\" .) \"true\" }}\n  prometheus/postgresql:\n    config:\n      scrape_configs:\n        - job_name: k8s-metrics\n          scrape_interval: 5s\n          static_configs:\n            - targets: [{{ include \"digma.postgresql.metrics.url\" . }}]\n  {{ end }}\n  {{ if eq (include \"digma.clickhouse.metrics.enabled\" .) \"true\" }}\n  prometheus/clickhouse:\n    config:\n      scrape_configs:\n        - job_name: k8s-metrics\n          scrape_interval: 5s\n          static_configs:\n            - targets: [{{ include \"digma.clickhouse.metrics.url\" . }}]\n  {{ end }}\nprocessors:\n  batch:\n  attributes/add_source_env:\n    actions:\n      - key: source_env\n        value: {{.Values.observability.environmentName}}\n        action: insert\nexporters:\n  logging:\n    verbosity: detailed\n  {{- if eq .Values.observability.useLocal true }}\n  prometheus:\n    endpoint: 0.0.0.0:{{ .Values.otelCollectorDf.service.ports.prometheus_scraper }}\n    send_timestamps: true\n    metric_expiration: 10m\n  {{- else }}\n  otlp/remote:\n    endpoint: {{ include \"observability.otlp.remoteEndpoint\" .}}\n  {{- end }}\nservice:\n  extensions: [health_check]\n  pipelines:\n    {{- if eq .Values.observability.useLocal true }}\n    metrics:\n      receivers: [otlp, kafkametrics, prometheus/k8s_metrics{{- if eq (include \"digma.redis.metrics.enabled\" .) \"true\" -}}, prometheus/redis {{- end }}{{- if eq (include \"digma.postgresql.metrics.enabled\" .) \"true\" -}}, prometheus/postgresql {{- end }}{{- if eq (include \"digma.clickhouse.metrics.enabled\" .) \"true\" -}}, prometheus/clickhouse {{- end }}]\n      processors: [attributes/add_source_env, batch]\n      exporters: [prometheus]\n    {{- else }}\n    traces:\n      receivers: [otlp]\n      processors: [batch]\n      exporters: [otlp/remote]\n    metrics:\n      receivers: [otlp, kafkametrics, prometheus/k8s_metrics{{- if eq (include \"digma.redis.metrics.enabled\" .) \"true\" -}}, prometheus/redis {{- end }}{{- if eq (include \"digma.postgresql.metrics.enabled\" .) \"true\" -}}, prometheus/postgresql {{- end }}{{- if eq (include \"digma.clickhouse.metrics.enabled\" .) \"true\" -}}, prometheus/clickhouse {{- end }}]\n      processors: [attributes/add_source_env, batch]\n      exporters: [otlp/remote]\n    logs:\n      receivers: [otlp]\n      processors: [attributes/add_source_env, batch]\n      exporters: [otlp/remote]\n    {{- end }}\n"` |  |
| otelCollectorDf.resources.limits.cpu | string | `"750m"` |  |
| otelCollectorDf.resources.limits.memory | string | `"1536Mi"` |  |
| otelCollectorDf.resources.requests.cpu | string | `"500m"` |  |
| otelCollectorDf.resources.requests.memory | string | `"1024Mi"` |  |
| pipelineWorker.image.registry | string | `"docker.io"` |  |
| pipelineWorker.image.repository | string | `"digmatic/digma-pipeline-worker"` |  |
| pipelineWorker.resources.limits.cpu | string | `"750m"` |  |
| pipelineWorker.resources.limits.memory | string | `"1024Mi"` |  |
| pipelineWorker.resources.requests.cpu | string | `"500m"` |  |
| pipelineWorker.resources.requests.memory | string | `"512Mi"` |  |
| postgresql.architecture | string | `"standalone"` |  |
| postgresql.auth.database | string | `"postgres"` |  |
| postgresql.auth.enablePostgresUser | bool | `false` |  |
| postgresql.auth.password | string | `"postgres"` |  |
| postgresql.auth.username | string | `"postgres"` |  |
| postgresql.containerPorts.postgresql | int | `5432` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.image.repository | string | `"bitnamilegacy/postgresql"` |  |
| postgresql.metrics.collectors.stat_bgwriter | bool | `false` |  |
| postgresql.metrics.containerPorts.metrics | int | `9187` |  |
| postgresql.metrics.image.registry | string | `"docker.io"` |  |
| postgresql.metrics.image.repository | string | `"bitnamilegacy/postgres-exporter"` |  |
| postgresql.primary.extendedConfiguration | string | `"shared_buffers = '800MB'\nlogging_collector = on\nlog_directory ='log'\n# log_min_duration_statement = 500 # Log queries that take longer than 500ms\nshared_preload_libraries ='pg_stat_statements'\npg_stat_statements.max = 10000  # Max queries stored in memory\npg_stat_statements.track = all  # Track all queries\npg_stat_statements.track_utility = off  # Ignore utility commands (CREATE, DROP)\npg_stat_statements.save = on  # Preserve stats across restarts\npg_stat_statements.track_planning = off  # Avoid tracking query planning time\n"` |  |
| postgresql.primary.extraEnvVars[0].name | string | `"POSTGRESQL_MAX_CONNECTIONS"` |  |
| postgresql.primary.extraEnvVars[0].value | string | `"400"` |  |
| postgresql.primary.initdb.scripts."enable_pg_stat_statements.sql" | string | `"CREATE EXTENSION IF NOT EXISTS pg_stat_statements;\n"` |  |
| postgresql.primary.livenessProbe.failureThreshold | int | `10` |  |
| postgresql.primary.livenessProbe.initialDelaySeconds | int | `60` |  |
| postgresql.primary.livenessProbe.periodSeconds | int | `60` |  |
| postgresql.primary.networkPolicy.enabled | bool | `false` |  |
| postgresql.primary.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| postgresql.primary.persistence.enabled | bool | `true` |  |
| postgresql.primary.persistence.size | string | `"50Gi"` |  |
| postgresql.primary.readinessProbe.failureThreshold | int | `10` |  |
| postgresql.primary.readinessProbe.initialDelaySeconds | int | `60` |  |
| postgresql.primary.readinessProbe.periodSeconds | int | `60` |  |
| postgresql.primary.resources.limits.cpu | int | `2` |  |
| postgresql.primary.resources.limits.memory | string | `"3300Mi"` |  |
| postgresql.primary.resources.requests.cpu | float | `1` |  |
| postgresql.primary.resources.requests.memory | string | `"2048Mi"` |  |
| postgresql.primary.service.ports.postgresql | int | `5432` |  |
| postgresql.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` |  |
| postgresql_backup.image.pullPolicy | string | `"IfNotPresent"` |  |
| postgresql_backup.image.registry | string | `"docker.io"` |  |
| postgresql_backup.image.repository | string | `"postgres"` |  |
| postgresql_backup.image.tag | float | `17.1` |  |
| postgresql_backup.pullSecrets | list | `[]` |  |
| presets.large.collectorWorker.replicas | int | `6` |  |
| presets.large.measurementAnalysis.replicas | int | `4` |  |
| presets.large.pipelineWorker.replicas | int | `4` |  |
| presets.medium.collectorWorker.replicas | int | `4` |  |
| presets.medium.measurementAnalysis.replicas | int | `4` |  |
| presets.medium.pipelineWorker.replicas | int | `1` |  |
| presets.small.collectorWorker.replicas | int | `1` |  |
| presets.small.measurementAnalysis.replicas | int | `1` |  |
| presets.small.pipelineWorker.replicas | int | `1` |  |
| prometheus.alertmanager.enabled | bool | `false` |  |
| prometheus.alertmanager.image.repository | string | `"bitnamilegacy/alertmanager"` |  |
| prometheus.enabled | bool | `false` |  |
| prometheus.image.repository | string | `"bitnamilegacy/prometheus"` |  |
| prometheus.server.existingConfigmap | string | `"{{ .Release.Name }}-prometheus-server"` |  |
| prometheus.server.existingConfigmapKey | string | `"prometheus.yaml"` |  |
| prometheus.server.image.repository | string | `"bitnamilegacy/prometheus"` |  |
| prometheus.server.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| prometheus.server.persistence.enabled | bool | `true` |  |
| prometheus.server.persistence.size | string | `"40Gi"` |  |
| prometheus.server.resources.limits.cpu | float | `1` |  |
| prometheus.server.resources.limits.memory | string | `"768Mi"` |  |
| prometheus.server.resources.requests.cpu | string | `"750m"` |  |
| prometheus.server.resources.requests.memory | string | `"512Mi"` |  |
| prometheus.server.service.ports.http | int | `9090` |  |
| prometheus.server.service.type | string | `"ClusterIP"` |  |
| redis.architecture | string | `"standalone"` |  |
| redis.auth.enabled | bool | `false` |  |
| redis.enabled | bool | `true` |  |
| redis.image.repository | string | `"bitnamilegacy/redis"` |  |
| redis.master.extraFlags[0] | string | `"--maxmemory 2g"` |  |
| redis.master.extraFlags[1] | string | `"--maxmemory-policy allkeys-lru"` |  |
| redis.master.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| redis.master.persistence.enabled | bool | `true` |  |
| redis.master.persistence.size | string | `"10Gi"` |  |
| redis.master.resources.limits.cpu | float | `1.5` |  |
| redis.master.resources.limits.memory | string | `"3072Mi"` |  |
| redis.master.resources.requests.cpu | float | `1` |  |
| redis.master.resources.requests.memory | string | `"2048Mi"` |  |
| redis.metrics.containerPorts.http | int | `9121` |  |
| redis.metrics.image.repository | string | `"bitnamilegacy/redis-exporter"` |  |
| redis.sentinel.image.repository | string | `"bitnamilegacy/redis-sentinel"` |  |
| redis.sysctlImage.repository | string | `"bitnamilegacy/os-shell"` |  |
| redis.volumePermissions.image.repository | string | `"bitnamilegacy/os-shell"` |  |
| scheduler.image.registry | string | `"docker.io"` |  |
| scheduler.image.repository | string | `"digmatic/digma-scheduler"` |  |
| scheduler.resources.limits.cpu | string | `"750m"` |  |
| scheduler.resources.limits.memory | string | `"1024Mi"` |  |
| scheduler.resources.requests.cpu | string | `"200m"` |  |
| scheduler.resources.requests.memory | string | `"300Mi"` |  |
| toolhive-operator.operator.rbac.scope | string | `"cluster"` |  |
| toolhive-operator.operator.resources.limits.cpu | string | `"500m"` |  |
| toolhive-operator.operator.resources.limits.memory | string | `"128Mi"` |  |
| toolhive-operator.operator.resources.requests.cpu | string | `"100m"` |  |
| toolhive-operator.operator.resources.requests.memory | string | `"64Mi"` |  |
| toolhive.enabled | bool | `false` |  |
| ui.postHogApiKey | string | `"phc_5sy6Kuv1EYJ9GAdWPeGl7gx31RAw7BR7NHnOuLCUQZK"` |  |
| ui.productFruitsWorkspaceCode | string | `"GBNh54uJtBaeWuOq"` |  |
| ui.sandboxEnabled | bool | `false` |  |
## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://opensearch-project.github.io/helm-charts/ | opensearch | 3.2.1 |
| oci://ghcr.io/stacklok/toolhive | toolhive-operator | 0.2.6 |
| oci://ghcr.io/stacklok/toolhive | toolhive-operator-crds | 0.0.16 |
| oci://registry-1.docker.io/bitnamicharts | clickhouse | 8.0.7 |
| oci://registry-1.docker.io/bitnamicharts | common | 2.x.x |
| oci://registry-1.docker.io/bitnamicharts | elasticsearchlogs(elasticsearch) | 21.4.1 |
| oci://registry-1.docker.io/bitnamicharts | grafana | 11.3.26 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 16.2.1 |
| oci://registry-1.docker.io/bitnamicharts | prometheus | 1.3.28 |
| oci://registry-1.docker.io/bitnamicharts | redis | 20.3.0 |