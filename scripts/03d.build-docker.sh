#!/bin/bash

# Script to build the base Docker image and process batches incrementally

set -eux

# Ensure the data directory exists
mkdir -p data

# Build the base Docker image
echo "Building base image..."
docker build --progress=plain -t uh-halp-data-binaries:ubuntu-base -f scripts/03d.Dockerfile-base . 2>&1 | tee log/03d.base-build.log
base_image=uh-halp-data-binaries:ubuntu-base

# Split the filtered packages file into batches
batch_size=500
mkdir -p data/03d.packages
split -a 3 -d -l $batch_size data/03b.limited-packages data/03d.packages/

echo $base_image

# Process each batch
for batch_file in data/03d.packages/*; do
    num=$(echo $(basename "$batch_file") | bc)
    batch_tag=ubuntu-$(( num * batch_size + batch_size ))-$(uname -m)
    echo "Building image for $batch_file..."

    # Build the Docker image for the current batch and log output
    docker build --progress=plain \
        --build-arg BASE_IMAGE=$base_image \
        --build-arg BATCH_FILE=$batch_file \
        -t uh-halp-data-binaries:$batch_tag \
        -f scripts/03d.Dockerfile . 2>&1 | tee log/03d.build-"$batch_tag".log

    # Update the base image for the next iteration
    base_image=uh-halp-data-binaries:$batch_tag

    # Extract failed log
    failed_log_container_path="/data/failed-packages.log"
    host_log_path="log/failed-packages-$batch_tag.log"
    echo "Extracting failed log from the batch image..."
    docker run --rm $base_image cat "$failed_log_container_path" > "$host_log_path" || echo "No failed log found in the batch image."
done

# Final image tag
docker tag $base_image uh-halp-data-binaries:ubuntu-final-$(uname -m)
echo "Final image built: uh-halp-data-binaries:ubuntu-final-$(uname -m)"
