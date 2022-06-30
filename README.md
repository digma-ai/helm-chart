# helm-chart
This repo is going to function as a standard helm chart repository

### How To Run
digma:
```bash
helm install digma digma-chart -n digma-ns
```
sample app:
```bash
 helm install go sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns -n staging-ns
```
### `helm` Cheat sheet

Install:
```bash
helm install digma-chart --generate-name
```

Uinstall:
```bash
helm uninstall digma-chart-xxxxx
```

Test (dry run):
```bash
helm install digma-test digma-chart --debug --dry-run 
```