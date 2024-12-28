#!/usr/bin/env python3

import argparse
import logging

def load_binaries(file_name):
    """Loads binaries and their associated data from a file."""
    with open(file_name, 'r') as f:
        binary_dict = {}
        for line in f:
            line = line.strip()
            if not line:
                continue

            parts = line.split()

            if len(parts) == 2:
                path_binary, repo = parts
                path, binary = path_binary.rsplit('/', 1) if '/' in path_binary else ('', path_binary)
                binary_dict[binary] = {
                    "path": path if path else None,
                    "repo": repo,
                    "score": 0  # Default score
                }
            elif len(parts) == 1:
                binary = parts[0]
                binary_dict[binary] = {
                    "path": None,
                    "repo": None,
                    "score": 0  # Default score
                }

    return binary_dict

def load_scores(log_file, binary_dict):
    """Loads scores from the popularity contest log into the binary dictionary."""
    with open(log_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            parts = line.split()
            if len(parts) != 2:
                continue

            score, binary = parts
            try:
                score = int(score)
                if binary in binary_dict:
                    binary_dict[binary]["score"] += score
            except ValueError:
                continue

def build_package_scores(binary_dict):
    """Builds a dictionary of package scores from the binary dictionary."""
    package_scores = {}

    for binary, data in binary_dict.items():
        repo = data.get("repo")
        if not repo:
            continue

        package = repo.split('/')[-1]  # Take the rightmost part of the repo path
        package_scores[package] = package_scores.get(package, 0) + data["score"]

    return package_scores

def main():
    parser = argparse.ArgumentParser(description="Generate package priority list for Dockerfile.")
    parser.add_argument('--data-file', type=str, default='data/01.binaries', help="Path to the binaries data file.")
    parser.add_argument('--log-file', type=str, default='data/02a.popularity-contest', help="Path to the popularity contest log file.")
    args = parser.parse_args()

    # Load binaries and scores
    binary_dict = load_binaries(args.data_file)
    load_scores(args.log_file, binary_dict)

    # Build package scores and sort by score
    package_scores = build_package_scores(binary_dict)
    sorted_packages = sorted(package_scores.items(), key=lambda x: x[1], reverse=True)

    # Print packages in priority order
    for package, score in sorted_packages:
        print(f"{score} {package}")

if __name__ == "__main__":
    main()
