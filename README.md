<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/images/digma-helm-dark.png">
    <source media="(prefers-color-scheme: light)" srcset=".github/images/digma-helm-light.png">
    <img width="446" height="200" src=".github/images/digma-helm-light.png" alt="digma+helm logos">
  </picture>
   <br/>
  This branch (<code>main</code>) contains the <b>source code</b> for the charts
  <br/>
  (see <a href="https://github.com/digma-ai/helm-chart/tree/gh-pages">gh-pages</a> branch for the published ones)
</p>

## User Guide
Switch to the `gh-pages` branch to see the [full user guide](https://github.com/digma-ai/helm-chart/tree/gh-pages).

## Publish 
To publish a new verion for the chart, just update the charts version, the push to main.

## Installation

Add Digma's chart repository to Helm:
```bash
helm repo add digma https://digma-ai.github.io/helm-chart/
```

Update the chart repository:
```bash
helm repo update
```

## Set up Digma on AWS

### Internal passthrough
```
helm install digma digma/digma --values https://raw.githubusercontent.com/digma-ai/helm-chart/main/src/digma-configs/aws-internal.yaml --set digma.licenseKey=[DIGMA_LICENSE] --namespace digma --create-namespace
```

### External passthrough
```
helm install digma digma/digma --values https://raw.githubusercontent.com/digma-ai/helm-chart/main/src/digma-configs/aws-internet.yaml --set digma.licenseKey=[DIGMA_LICENSE] --namespace digma --create-namespace
```

## Set up Digma on GKE

### Internal passthrough
```
helm install digma digma/digma --values https://raw.githubusercontent.com/digma-ai/helm-chart/main/src/digma-configs/gcp-internal.yaml --set digma.licenseKey=[DIGMA_LICENSE] --namespace digma --create-namespace
```

### External passthrough
```
helm install digma digma/digma --values https://raw.githubusercontent.com/digma-ai/helm-chart/main/src/digma-configs/gcp-internet.yaml --set digma.licenseKey=[DIGMA_LICENSE] --namespace digma --create-namespace
```