# Dockerfile for Step 03d: Install Packages in Docker
ARG BASE_IMAGE
FROM $BASE_IMAGE

# Set up environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Package file goes in
ARG BATCH_FILE
COPY $BATCH_FILE /$BATCH_FILE

# Run the install script for this batch
RUN /scripts/03d.install-packages.sh /$BATCH_FILE /data/failed-packages.log

# Default command
CMD ["/bin/bash"]
