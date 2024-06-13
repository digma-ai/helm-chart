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

def update_chart_version(version):
    chart_file = 'src/digma//Chart.yaml'  # Adjust this path if needed

    with open(chart_file, 'r') as file:
        chart = yaml.safe_load(file)

    chart['appVersion'] = version

    current_chart_version = chart['version']
    print(f"Current version: {current_chart_version}")
    # Increment the version
    new_version = increment_version(current_chart_version, 'patch')
    print(f"New version: {new_version}")
    # Update the version in the chart data
    chart['version'] = new_version
    
    with open(chart_file, 'w') as file:
        yaml.safe_dump(chart, file, default_flow_style=False)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: update_chart_version.py <new-version>")
        sys.exit(1)
    
    new_version = sys.argv[1]
    update_chart_version(new_version)
