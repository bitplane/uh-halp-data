#!/bin/sh

# Script to install a batch of packages and log failures

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <batch_file> <failed_log>"
    exit 1
fi

batch_file="$1"
failed_log="$2"

# Ensure the failed log file exists and append failures
touch "$failed_log"

install_and_cleanup() {
    packages="$1"
    echo "Installing packages: $packages"
    apt-get install -y --no-install-recommends $packages || {
        echo "Failed to install packages: $packages" >> "$failed_log"
        return 1
    }
    echo "Running autoremove to clean up unnecessary packages."
    apt-get autoremove -y || echo "Autoremove failed, continuing..."
}

batch_packages=$(cat "$batch_file")
echo "Processing batch: $batch_file"
install_and_cleanup "$batch_packages"

for package in $batch_packages; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
        echo "$package failed" >> "$failed_log"
        echo "$package failed"
    fi
done
