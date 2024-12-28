FROM ubuntu:latest

# Set up environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Copy limited packages list
COPY data/03b.limited-packages /data/

# Install packages in batches and retry failed ones
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends apt-utils figlet; \
    total=$(cat /data/03b.limited-packages | wc -l); \
    batch=50; \
    count=0; \
    failed_log=/data/failed-packages.log; \
    touch "$failed_log"; \
    split -l $batch /data/03b.limited-packages /tmp/batch_; \
    for batch_file in /tmp/batch_*; do \
        echo "Installing batch from $batch_file" | figlet; \
        xargs -a "$batch_file" apt-get install -y --no-install-recommends || true; \
        for package in $(cat "$batch_file"); do \
            count=$((count + 1)); \
            echo "$package": "$count" / "$total" | figlet; \
            if ! dpkg -s "$package" >/dev/null 2>&1; then \
                echo "Retrying installation of $package"; \
                if ! apt-get install -y --no-install-recommends "$package"; then \
                    echo "$package failed" >> "$failed_log"; \
                    echo "$package failed"; \
                fi; \
            fi; \
        done; \
    done; \
    rm -rf /var/lib/apt/lists/* /tmp/batch_*

# Copy binaries list and the script
COPY data/03c.binary-names /data/
COPY scripts/04.extract-help.sh /scripts/04.extract-help.sh

# Ensure the script is executable
RUN chmod +x /scripts/04.extract-help.sh

# Default command
CMD ["/scripts/04.extract-help.sh", "/data", "/data/03c.binary-names"]
