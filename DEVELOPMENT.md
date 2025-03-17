## Development Notes
- Set up a custom Git hooks directory:
  ```bash
  git config --local core.hooksPath .githooks/
  ```
  
## Install [`helm-docs`](https://github.com/norwoodj/helm-docs)

#### Windows
1. Open wsl
2. Add the repository:
   ```bash
   curl -sSL https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository | sudo bash
   ```
3. Install `helm-docs`:
   ```bash
   sudo apt install helm-docs
   ```
#### Mac
```bash
brew install norwoodj/tap/helm-docs
```

#### Windows with Scoop

1. Install scoop from Powershell
    ```bash
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    ```
2. Install helm-docs
    ```bash
    scoop install helm-docs
    ```
3. Generate docs
    ```bash
   helm-docs --chart-search-root 'charts/digma-ng' -s file --ignore-non-descriptions
```