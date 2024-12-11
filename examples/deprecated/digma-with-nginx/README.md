# Digma & Nginx
This repo shows an example of using digma and exposing its endpoints via **nginx**.

### Prerequisites 
- k8s cluster with [nginx-controller](https://github.com/kubernetes/ingress-nginx).
- Domain that is and its sub-domains are pointing to the nginx controller public address.

### Deploy

1. Clone this repo:
    ``` bash
    git clone https://github.com/digma-ai/helm-chart
    ```

2. Access the example's folder:
    ``` bash
    cd helm-chart/examples/digma-with-nginx
    ```

3. Build dependencies:<br/>
    ``` bash
    helm dependency build
    ```

4. Install chart: <br/>
    ``` bash
    helm install digma . -n digma  --set digma.digma.licenseKey=[LICENSE] --set domain=[DOMAIN]
    ```
