# helm-chart
This repo is going to function as a standard helm chart repository

## How To Run
### Standard
Create namespaces:
```
kubectl create digma-ns
kubectl create staging-ns
```

Install digma:
```
helm install digma digma-chart -n digma-ns
```

Install the sample app:
```
helm install go sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns -n staging-ns
```
### Using [traefik](https://github.com/traefik/traefik)
Create namespaces:
```
kubectl create digma-ns
kubectl create staging-ns
kubectl create traefik-ns
```

Install digma:
```
helm install digma digma-chart -n digma-ns
```

Install the sample app:
```
helm install go sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns,traefik=true -n staging-ns
```

Install traefik:
```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --set providers.kubernetesCRD.namespaces={staging-ns\,digma-ns} -n traefik-ns
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