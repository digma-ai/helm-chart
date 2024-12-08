#!/bin/bash

# Ensure helm-docs is installed
if ! command -v helm-docs &> /dev/null; then
    echo "helm-docs not installed. Install it using 'brew install helm-docs'."
    exit 1
fi

# Set the chart directories (update the path as needed)
CHARTS_DIR="charts"

# Generate docs for each chart
for chart in $(find $CHARTS_DIR -type f -name "Chart.yaml" -exec dirname {} \;); do
    echo "Generating docs for $chart..."
    helm-docs --chart-search-root "$chart" -s file --ignore-non-descriptions
done

echo "Helm docs generation complete."