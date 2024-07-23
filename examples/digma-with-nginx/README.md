# Digma & Nginx
This repo shows an example of using digma and exposing its endpoints via **nginx**.

1. Build dependencies:<br/>
<code>helm dependency build</code>

2. Modify the <code>ingress.yaml</code> file with your <code>ingressClassName</code> if needed.

3. Run: <br/>
<code>helm install digma . -n digma --set domain=[YOUR-DOMAIN]</code>