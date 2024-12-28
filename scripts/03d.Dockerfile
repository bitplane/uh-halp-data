# Dockerfile for Step 03d: Build and Install Packages in Docker

FROM ubuntu:latest

# Set up environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Copy limited packages list
COPY data/03b.limited-packages /data/
COPY scripts/03d.install-packages.sh /scripts/03d.install-packages.sh

# Ensure the script is executable
RUN chmod +x /scripts/03d.install-packages.sh

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils figlet && rm -rf /var/lib/apt/lists/*

# Install packages using the script
RUN /scripts/03d.install-packages.sh /data/03b.limited-packages /data/03d.failed-packages.log

# Copy binaries list and the extract-help script
COPY data/03c.binary-names /data/
COPY scripts/04.extract-help.sh /scripts/04.extract-help.sh

# Ensure the extract-help script is executable
RUN chmod +x /scripts/04.extract-help.sh

# Default command
CMD ["/scripts/04.extract-help.sh", "/data", "/data/03c.binary-names"]
