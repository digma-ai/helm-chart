# helm-chart
This repo is going to function as a standard helm chart repository


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