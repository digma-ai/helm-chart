import yaml
import sys


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


def update_chart_version(version, chart_file_path):
    with open(chart_file_path, 'r') as file:
        chart = yaml.safe_load(file)

    chart['appVersion'] = version

    current_chart_version = chart['version']
    print(f"Current version: {current_chart_version}")
    # Increment the version
    new_version = increment_version(current_chart_version, 'patch')
    print(f"New version: {new_version}")
    # Update the version in the chart data
    chart['version'] = new_version

    with open(chart_file_path, 'w') as file:
        yaml.safe_dump(chart, file, default_flow_style=False)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: version_updater.py <new-version> <chart-location> <deployment-location>")
        sys.exit(1)

    new_version = sys.argv[1]
    chart_yml = sys.argv[2]
    deployment_yml = sys.argv[3]
    

    update_chart_version(new_version, chart_yml)
