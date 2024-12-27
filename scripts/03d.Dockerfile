FROM ubuntu:latest

# Set up environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    timeout procps && \
    rm -rf /var/lib/apt/lists/*

# Copy limited packages list
COPY data/03b.limited-packages /data/

# Install packages in bulk and retry failed ones
RUN set -eux; \
    apt-get update; \
    xargs -a /data/03b.limited-packages apt-get install -y --no-install-recommends || true; \
    for package in $(cat /data/03b.limited-packages); do \
        if ! dpkg -s "$package" >/dev/null 2>&1; then \
            echo "Retrying installation of $package"; \
            apt-get install -y --no-install-recommends "$package" || echo "$package failed"; \
        fi; \
    done; \
    rm -rf /var/lib/apt/lists/*

# Copy binaries list and the script
COPY data/03c.binary-names /data/
COPY scripts/04.extract-help.sh /scripts/04.extract-help.sh

# Ensure the script is executable
RUN chmod +x /scripts/04.extract-help.sh

# Default command
CMD ["/scripts/04.extract-help.sh", "/data", "/data/03c.binary-names"]
