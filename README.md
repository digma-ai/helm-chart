# helm-chart
This repo is going to function as a standard helm chart repository

## How To Run (Standard)
#### 1. Create namespaces:
```
kubectl create digma-ns
kubectl create staging-ns
```
#### 2. Install digma:
```
helm install digma digma-chart -n digma-ns
```
#### 3. Install the sample app:
```
helm install go sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns -n staging-ns
```

## How To Run (Using [traefik](https://github.com/traefik/traefik))
#### 1. Create namespaces:
```
kubectl create digma-ns
kubectl create staging-ns
kubectl create traefik-ns
```

#### 2. Install digma:
```
helm install digma digma-chart --set digmaCollectorApi.expose=false,digmaPluginApi.expose=false -n digma-ns
```
- `digmaCollectorApi.expose=false` - Do not to expose digma's otlp collector via public ip.
- `digmaPluginApi.expose=false` - Do not to expose digma's plugin api via public ip.


#### 3. Install the sample app:
```
helm install go sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns,traefik=true -n staging-ns
```

#### 4. Install traefik:
```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --set providers.kubernetesCRD.namespaces={staging-ns\,digma-ns},ports.digma.port=5051,ports.digma.expose=true,ports.digma.exposedPort=5051,ports.digma.protocol=TCP -n traefik-ns
```
- `providers.kubernetesCRD.namespaces={staging-ns\,digma-ns}` - Listen for routes modifications on the `staging-ns` and `digma-ns` namespaces as well.
- `ports.digma.port=5051, ... ,ports.digma.protocol=TCP` - Expose a new entrypoint called `digma`, that listens to port 5051 for digma's plugin api.

#### 5. Add traefik IngressRoute:
Download the following yaml file ([digma-ingress-route.yaml](https://github.com/digma-ai/helm-chart/blob/main/src/traefik/digma-ingress-route.yaml)):
```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: digma-plugin-api-traefik-route
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

Apply it in the namespace beside digma's components:
```
kubectl apply -f digma-ingress-route.yaml -n digma-ns
```

## `helm` Cheat sheet

Install:
```
helm install digma-chart --generate-name
```

Uinstall:
```
helm uninstall digma-chart-xxxxx
```

Test (dry run):
```
helm install digma-test digma-chart --debug --dry-run 
```