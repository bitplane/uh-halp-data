# Dockerfile for Step 03d: Install Packages in Docker

ARG BASE_IMAGE
FROM $BASE_IMAGE

# Set up environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Copy the batch file into the container at its original location
ARG BATCH_FILE
COPY $BATCH_FILE /$BATCH_FILE

# Ensure the failed log file is visible in /data
RUN touch /data/failed-packages.log

# Run the install script for the batch
RUN /scripts/03d.install-packages.sh /$BATCH_FILE /data/failed-packages.log

# Default command (does nothing, expects further steps)
CMD ["/bin/bash"]
