import sys
from ruamel.yaml import YAML


def increment_version(version, level):
    """
    Increment the version number at the specified level.

    :param version: The current version as a string (e.g., "1.2.3").
    :param level: The level to increment ('major', 'minor', 'patch').
    :return: The incremented version as a string.
    """
    major, minor, patch = map(int, version.split('.'))

    if level == 'major':
        major += 1
        minor = 0
        patch = 0
    elif level == 'minor':
        minor += 1
        patch = 0
    elif level == 'patch':
        patch += 1
    else:
        raise ValueError("Invalid level. Choose 'major', 'minor' or 'patch'.")

    return f"{major}.{minor}.{patch}"


def update_deployment_version(version, chart_version, deployment_yml):
    yml = YAML()
    with open(deployment_yml, 'r') as file:
        docs = list(yml.load_all(file))
    excludes = ["digma-ds-deployment"]
    for data in docs:
        app_name = data['metadata']['name']
        if data['kind'] != 'Deployment' or app_name in excludes:
            continue

        containers = data['spec']['template']['spec']['containers']
        for container in containers:
            image = container['image']
            # Split the image string to get the version part
            image_name = image.split(':')[0]
            container['image'] = f'{image_name}:{version}'
            app_version_dic = next(e for e in container['env'] if e['name'] == 'ApplicationVersion')
            app_version_dic['value'] = version
            chart_version_dic = next(e for e in container['env'] if e['name'] == 'ChartVersion')
            chart_version_dic['value'] = chart_version

    with open(deployment_yml, 'w') as file:
        yml.dump_all(docs, file)


def update(version, chart_file_path, chart_version_level):
    update_chart_version(version, chart_file_path, chart_version_level)


def update_chart_version(version, chart_file_path, chart_version_level):
    yml = YAML()
    with open(chart_file_path, 'r') as file:
        chart = yml.load(file)

    chart['appVersion'] = version

    current_chart_version = chart['version']
    print(f"Current version: {current_chart_version}")
    # Increment the version
    new_version = increment_version(current_chart_version, chart_version_level)
    print(f"New version: {new_version}")
    # Update the version in the chart data
    chart['version'] = new_version

    with open(chart_file_path, 'w') as file:
        yml.dump(chart, file)

    return new_version

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: version_updater.py <new-version> <chart-location>")
        sys.exit(1)

    new_version = sys.argv[1]
    chart_yml = sys.argv[2]
    
    update(new_version, chart_yml, 'patch')

