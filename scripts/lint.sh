#!/bin/bash

# Path to your Helm chart directory
CHART_DIR="charts/digma-ng"

echo "Running helm lint on $CHART_DIR..."
echo "$(pwd):/charts/digma-ng"
docker run --rm -v "$(pwd)" quay.io/helmpack/chart-testing:latest ct list-changed

CURRENT_DIR=$(pwd)/charts
echo "The current directory is: $CURRENT_DIR"

docker run --rm \
  -v "$CURRENT_DIR" \
  quay.io/helmpack/chart-testing:latest \
  ls -la

changed=$(docker run --rm -v "$(pwd):/charts/digma-ng" quay.io/helmpack/chart-testing:latest ct list-changed)

echo "Changed charts: $changed"
if [[ -n "$changed" ]]; then
echo "asdasd"
fi


# Run helm lint
helm lint "$CHART_DIR"
RESULT=$?

if [ $RESULT -ne 0 ]; then
    echo "Helm lint failed. Fix the issues before committing."
    exit 1
fi

echo "Helm lint passed. Proceeding with commit."
exit 0