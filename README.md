<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/digma-helm-dark.png">
    <source media="(prefers-color-scheme: light)" srcset="assets/digma-helm-light.png">
    <img width="410" height="200" src="assets/digma-helm-light.png" alt="digma+helm logos">
  </picture>
  <br/>
  This branch (<code>gh-pages</code>) contains the <b>published</b> charts for digma
  <br/>
  (see <a href="https://github.com/digma-ai/helm-chart/tree/main">main</a> branch)
</p>

## Installation

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

Usage:
- View the `digma-plugin-api-service-lb` service (via kubectl/dashboard/..), copy the its **public ip**, and set it to the **digma url** in the digma's ide plugin settings.
- View the `digma-collector-api-service-lb` service (via kubectl/dashboard/..), copy the its **public ip**, and set it as otlp collector in your code (port **5049** for **http**, and **5050** for **gRpc**).
## Configuration
<table>
    <thead>
        <tr>
            <th align="left">Value</th>
            <th align="left">Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
          <td><code>debug</code><i>(boolean)</i></td>
              <td>When <b>true</b>, one more pod is deployed, containing <br/><ul><li>ELK+APM</li><li>PgAdmin</li><li>Redis Commander</li></ul>Default <b>False</b>.</td>
            </tr>
        <tr>
          <td><code>&lt;service&gt;.host</code> <i>(string)</i></td>
              <td>Defines the application's service name (internal dns), <b>as template</b> (e.g. <code>"{{.Release.Name}}-elasticsearch"</code>)</td>
            </tr>
        <tr>
          <td><code>digmaCollectorApi.expose</code><i>(boolean)</i></td>
            <td>When <b>true</b> digma's otlp collector is exposed to the internet via public ip.<br/>Default <b>true</b>.</td>
          </tr>
        <tr>
          <td><code>digmaPluginApi.expose</code> <i>(boolean)</i></td>
            <td>When <b>true</b> digma's plugin api is exposed to the internet via public ip.<br/>Default <b>true</b>.</td>
          </tr>
        <tr>
          <td><code>digmaPluginApi.accesstoken</code> <i>(string)</i></td>
            <td>Access token for plugin authentication. Set any string you want here, and set the same one in the IDE plugin settings.</td>
        </tr>
    </tbody>
</table>

## Examples
Clone this repository and follow the steps to deploy digma and a sample app.
### Basic
#### 1. Create namespaces:
```
kubectl create namespace digma-ns
kubectl create namespace staging-ns
```
#### 2. Install digma:
```
helm install digma src/digma -n digma-ns
```
#### 3. Install the sample app:
```
helm install go digma/sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns -n staging-ns
```

### Using [traefik](https://github.com/traefik/traefik)
#### 1. Create namespaces:
```
kubectl create namespace digma-ns
kubectl create namespace staging-ns
kubectl create namespace traefik-ns
```

#### 2. Install digma:
```
helm install digma digma/digma --set digmaCollectorApi.expose=false,digmaPluginApi.expose=false -n digma-ns
```

#### 3. Install the sample app:
```
helm install go src/sample-app-go --set otlpExporter.host=digma-collector-api.digma-ns,expose=false -n staging-ns
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
kubectl apply -f src/traefic/digma-ingress-route.yaml -n digma-ns
kubectl apply -f src/traefic/sample-ingress-route.yaml -n staging-ns
```

