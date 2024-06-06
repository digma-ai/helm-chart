#!/usr/bin/env python3
import sys

import yaml

def validate_image_version(chart_yaml: str, deployment_yaml: str):
    with open(chart_yaml, "r") as f:
        chart = yaml.load(f, yaml.FullLoader)
        image_ver = chart['appVersion']

    with open(deployment_yaml, "r") as stream:
        docs = yaml.load_all(stream, yaml.FullLoader)
        excludes = ["digma-ds-deployment"]
        for data in docs:
            app_name = data['metadata']['name']
            if data['kind'] != 'Deployment' or app_name in excludes:
                continue
            try:
                containers = data['spec']['template']['spec']['containers']
                for container in containers:
                    image = container['image']
                    # Split the image string to get the version part
                    version = image.split(':')[-1]
                    if version != image_ver:
                        print(
                            f"{app_name} - Image version '{version}' does not match the expected version from chart.yaml '{image_ver}'.")
                        return False

                    app_version = next(e for e in container['env'] if e['name'] == 'ApplicationVersion')
                    if app_version['value'] != version:
                        print(
                            f"{app_name} - Image version '{version}' does not match the ApplicationVersion '{app_version['value']}'.")
                        return False

            except KeyError as e:
                print(f"Key error: {e}")
                return False
    return True

def main():
    deployment_yml = 'rendered-deployment.yaml'
    chart_yml = 'Chart.yaml'
    chart_yml = sys.argv[1]
    deployment_yml = sys.argv[2]
    if not validate_image_version(chart_yml, deployment_yml):
        sys.exit(1)


if __name__ == "__main__":
    main()
