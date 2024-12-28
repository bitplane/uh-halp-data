#!/bin/sh

# Script to build the base Docker image and process batches incrementally

set -eux

# Ensure the data directory exists
mkdir -p data

# Build the base Docker image
echo "Building base image..."
docker build -t uh-halp-data-binaries:ubuntu-base -f scripts/03d.Dockerfile-base . | tee data/03d.base-build.log
base_image=uh-halp-data-binaries:ubuntu-base

# Split the filtered packages file into batches
batch_size=500
split -a 3 -d -l $batch_size data/03b.limited-packages data/03d.packages_

echo
echo $base_image
echo

# Process each batch
for batch_file in data/03d.packages_*; do
    batch_tag=$(basename "$batch_file")
    echo "Building image for $batch_file..."

    # Build the Docker image for the current batch and log output
    docker build \
        --build-arg BASE_IMAGE=$base_image \
        --build-arg BATCH_FILE=$batch_file \
        -t uh-halp-data-binaries:ubuntu-$batch_tag \
        -f scripts/03d.Dockerfile . | tee data/03d.build-$batch_tag.log

    # Update the base image for the next iteration
    base_image=uh-halp-data-binaries:ubuntu-$batch_tag
done

# Final image tag
docker tag $base_image uh-halp-data-binaries:ubuntu-final
echo "Final image built: uh-halp-data-binaries:ubuntu-final"
