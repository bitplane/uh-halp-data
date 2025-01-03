#!/bin/bash

# Script to run the Docker container and extract help texts

set -eux

# Ensure the output directory and log directory exist
mkdir -p data/04.generate-help
mkdir -p log
touch log/04.generate-help.log

# Define the image name
image_name="uh-halp-data-binaries:ubuntu-final-$(uname -m)"

# Run the Docker container to extract help texts
echo "Running Docker container to generate help texts..."
docker run --rm -it \
    -v $(pwd)/data/04.generate-help:/data/04.generate-help \
    -v $(pwd)/data/03c.binary-names:/data/03c.binary-names:ro \
    -v $(pwd)/scripts:/scripts:ro \
    $image_name \
    sh /scripts/04.extract-help.sh /data /data/03c.binary-names | tee -a log/04.generate-help.log

echo "Help texts generated and saved to data/04.generate-help"
