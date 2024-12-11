# Digma & ALB (AWS Load Balancer Controller)
This repo shows an example of using digma and exposing its endpoints via **ALB**.

### Prerequisites 
- EKS cluster with [aws-load-balancer-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller).
- Domain that can be pointed to the a new ALB.
- Have a certificate for that domain.

### Deploy

1. Clone this repo:
    ``` bash
    git clone https://github.com/digma-ai/helm-chart
    ```

2. Access the example's folder:
    ``` bash
    cd helm-chart/examples/digma-with-alb
    ```

3. Build dependencies:<br/>
    ``` bash
    helm dependency build
    ```

4. Install chart: <br/>
    ``` bash
    helm install digma . -n digma  --set digma.digma.licenseKey=[LICENSE] --set domain=[DOMAIN]
    ```

5. Point domain to the new ALB:
    ``` bash
    kubectl get ingress -n digma    
    ```
    You should see something like this:
    ``` bash
    NAME                           CLASS   HOSTS         ADDRESS                                           PORTS   AGE
    digma-analytics-ingress        alb     example.com   k8s-digma-xxxxxxxxx.eu-west-1.elb.amazonaws.com   80      16h
    digma-collector-grpc-ingress   alb     example.com   k8s-digma-xxxxxxxxx.eu-west-1.elb.amazonaws.com   80      46m
    digma-collector-http-ingress   alb     *             k8s-digma-xxxxxxxxx.eu-west-1.elb.amazonaws.com   80      16h
    digma-jaeger-ingress           alb     *             k8s-digma-xxxxxxxxx.eu-west-1.elb.amazonaws.com   80      16h
    ```
    Access your domain management page (Route53?) and add a `A` record that points to the ALB's address from the domain and its sub-domain (e.g. `*.example.com`).
3. Open digma settings (Settings -> Tools -> Digma Plugin), and set the urls:
    | Field | ingress-by-port | ingress-by-host
    | --- | --- | --- |
    | Digma API URL | `https://{domain}:5051` | `https://analytics.{domain}` |
    | Jaeger Query URL | `https://{domain}:16686` | `https://jaeger.{domain}` |
    | untime observability backend URL | `http://{domain}:5049/v1/traces`<br/> or</br> `https://{domain}:5050` | `http://collector-http.{domain}/v1/traces`<br/> or</br> `https://collector-grpc.{domain}` |

> [!NOTE]  
> - Digma uses `ClusterIP` services that requires setting `target-type` annotation to `ip`: `alb.ingress.kubernetes.io/target-type: ip`