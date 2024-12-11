#!/bin/bash

has_wsl() {
    wsl --version &> /dev/null && return 0 || return 1
}

# Ensure helm-docs is installed
if has_wsl; then
    if ! wsl command -v helm-docs &> /dev/null; then
        echo "helm-docs not installed. See 'DEVELOPMENT.md' on the repo root folder to install it on wsl."
        exit 1
    fi
else
    if ! command -v helm-docs &> /dev/null; then
        echo "helm-docs not installed. Install it using 'brew install helm-docs'."
        exit 1
    fi
fi


# Set the chart directories (update the path as needed)
CHARTS_DIR="charts"

# Generate docs for each chart
# for chart in $(find $CHARTS_DIR -type f -name "Chart.yaml" -exec dirname {} \;); do
#    echo "Generating docs for $chart..."
chart='charts/digma-ng'
if has_wsl; then
    wsl bash -c "helm-docs --chart-search-root \"$chart\" -s file --ignore-non-descriptions"
else
    helm-docs --chart-search-root "$chart" -s file --ignore-non-descriptions
fi
# done

echo "Helm docs generation complete."