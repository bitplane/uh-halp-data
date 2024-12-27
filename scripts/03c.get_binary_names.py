#!/usr/bin/env python3

import argparse

def load_packages(file_name):
    """Loads package names into a set."""
    with open(file_name, 'r') as f:
        return set(line.strip() for line in f if line.strip())

def process_binaries(binary_file, package_set):
    """Processes binaries and outputs binary names for matching packages."""
    with open(binary_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            # Split by space to separate path and repo/package
            parts = line.split()
            if len(parts) != 2:
                continue

            path, package = parts

            # Extract the last components of path and package
            binary_name = path.split('/')[-1]
            package_name = package.split('/')[-1]

            if package_name in package_set:
                print(binary_name)

def main():
    parser = argparse.ArgumentParser(description="Extract binary names for specified packages.")
    parser.add_argument('binary_file', type=str, help="Path to the binary file containing paths and packages.")
    parser.add_argument('package_file', type=str, help="Path to the file with limited packages.")
    args = parser.parse_args()

    package_set = load_packages(args.package_file)
    process_binaries(args.binary_file, package_set)

if __name__ == "__main__":
    main()
