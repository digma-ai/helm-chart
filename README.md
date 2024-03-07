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

## Cheat sheet

Install:
```
helm install dig src/digma
```

Uinstall:
```
helm uninstall dig
```

Test:
```
helm install dig src/digma --debug --dry-run 
```
