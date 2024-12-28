#!/bin/sh

# Script to install packages in batches and log failures

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <packages_file> <failed_log>"
    exit 1
fi

packages_file="$1"
failed_log="$2"

# Create or clear the failed log file
touch "$failed_log"
: > "$failed_log"

batch_size=50
temp_dir=$(mktemp -d)

trap "rm -rf $temp_dir" EXIT

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

# Split packages into batches
split -d -l $batch_size "$packages_file" "$temp_dir/batch_"

count=0
total=$(wc -l < "$packages_file")

for batch_file in "$temp_dir"/batch_*; do
    echo
    echo "Processing batch:"
    echo "$batch_file" | figlet
    echo

    batch_packages=$(cat "$batch_file")
    install_and_cleanup "$batch_packages"

    for package in $batch_packages; do

        count=$((count + 1))

        echo "$package: $count / $total" | figlet

        if ! dpkg -s "$package" >/dev/null 2>&1; then
            echo "$package failed" >> "$failed_log"
            echo "$package failed"
        fi
    done

done
