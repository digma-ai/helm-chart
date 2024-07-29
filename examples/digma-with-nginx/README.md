# Digma & Nginx
This repo shows an example of using digma and exposing its endpoints via **nginx**.

1. Build dependencies:<br/>
    ``` bash
    helm dependency build
    ```

2. Modify the <code>ingress.yaml</code> file with your <code>ingressClassName</code> if needed.

3. Install chart: <br/>
    ``` bash
    helm install digma . -n digma  --set digma.digma.licenseKey=[LICENSE] --set domain=[DOMAIN]
    ```