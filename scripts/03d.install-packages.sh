#!/bin/bash

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
    packages="$@"
    echo "Installing packages: $packages"
    apt-get install -y --no-install-recommends $packages | grep -Ev '^Get:'
    echo "Running autoremove to clean up unnecessary packages."
    apt-get autoremove -y || echo "Autoremove failed, continuing..."
    
    echo TOTAL: $(dpkg -l | grep '^ii' | wc -l) | figlet
}

export -f install_and_cleanup

echo "Processing batch: $batch_file"
cat $batch_file | xargs -n20 bash -c 'install_and_cleanup "$@"' _ || true
batch_packages=$(cat "$batch_file")

for package in $batch_packages; do
    echo "$package" | figlet
    if ! dpkg -s "$package" >/dev/null 2>&1; then
        echo "$package failed" >> "$failed_log"
        echo "$package failed"
    fi
done
echo TOTAL: $(dpkg -l | grep '^ii' | wc -l)
