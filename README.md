# Digma's Helm-Charts
This repository functions both as the source control and the chart repository for digma helm-charts, and consists of:
- Digmas services
  - Collector
  - PluginApi
  - Analytics
- Databases/Queues
  - Redis
  - Postgres
  - InfluxDB
  - RabbitMq
- Services for debugging *(can be disabled by setting `debug=false`)*
  - ELK+APM
  - PgAdmin
  - Redis Commander

## Installing

Add Digma's chart repository to Helm:
```bash
helm repo add digma https://digma-ai.github.io/helm-chart/
```

Update the chart repository:
```bash
helm repo update
```

Deploy digma:
```bash
helm install digma digma/digma
```

## Install Digma + Sample app (Standard)
#### 1. Create namespaces:
```
kubectl create digma-ns
kubectl create staging-ns
```
#### 2. Install digma:
```
helm install digma digma/digma -n digma-ns
```
#### 3. Install the sample app:
```
helm install go digma/sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns -n staging-ns
```

## Install Digma + Sample app (Using [traefik](https://github.com/traefik/traefik))
#### 1. Create namespaces:
```
kubectl create digma-ns
kubectl create staging-ns
kubectl create traefik-ns
```

#### 2. Install digma:
```
helm install digma digma/digma --set digmaCollectorApi.expose=false,digmaPluginApi.expose=false -n digma-ns
```
- `digmaCollectorApi.expose=false` - Do not to expose digma's otlp collector via public ip.
- `digmaPluginApi.expose=false` - Do not to expose digma's plugin api via public ip.


#### 3. Install the sample app:
```
helm install go digma/sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns,expose=false -n staging-ns
```

#### 4. Install traefik:
```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --set providers.kubernetesCRD.namespaces={staging-ns\,digma-ns},ports.digma.port=5051,ports.digma.expose=true,ports.digma.exposedPort=5051,ports.digma.protocol=TCP,logs.access.enabled=true,additionalArguments={--serversTransport.insecureSkipVerify=true} -n traefik-ns
```
- `providers.kubernetesCRD.namespaces={staging-ns\,digma-ns}` - Listen for routes modifications on the `staging-ns` and `digma-ns` namespaces as well.
- `ports.digma.port=5051, ... ,ports.digma.protocol=TCP` - Expose a new entrypoint called `digma`, that listens to port 5051 for digma's plugin api.
- `logs.access.enabled=true` - Log every access attempt to for debugging purpose.
- `additionalArguments={--serversTransport.insecureSkipVerify=true}` - Disable SSL certificate verification for backends.

#### 5. Add traefik IngressRoutes:
Download the following yaml files:
[digma-ingress-route.yaml](https://github.com/digma-ai/helm-chart/blob/main/src/traefik/digma-ingress-route.yaml)
```yaml
# digma-ingress-route.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: digma-plugin-api-traefik-route
  namespace: digma-ns
spec:
  entryPoints:
  - digma # [1] A new entrypoint that needs to be configured in the traefik
  routes:
  - kind: Rule
    match: Path(`/`) 
    services:
    - kind: Service
      name: digma-plugin-api # [2] The digma's plugin api service name
      port: 5051
```
[sample-ingress-route.yaml](https://github.com/digma-ai/helm-chart/blob/main/src/traefik/sample-ingress-route.yaml)
```yaml
# sample-ingress-route.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: go-traefik-route
  namespace: staging-ns
spec:
  entryPoints:
  - web
  routes:
  - kind: Rule
    match: PathPrefix(`/go`)
    services:
    - kind: Service
      name: go-service-cip
      port: 8011
```

Apply them in namespaces beside the referenced service:
```
kubectl apply -f traefic/digma-ingress-route.yaml -n digma-ns
kubectl apply -f traefic/sample-ingress-route.yaml -n staging-ns
```

## `helm` Cheat sheet

Install:
```
helm install digma --generate-name
```

Uinstall:
```
helm uninstall digma-xxxxx
```

Test (dry run):
```
helm install digma-test digma --debug --dry-run 
```
