#!/bin/sh

# Output directory for results
data_dir="$1"
if [ -z "$data_dir" ]; then
    echo "Usage: $0 <output_directory> <binary_file>"
    exit 1
fi

binary_file="$2"
if [ -z "$binary_file" ]; then
    echo "Usage: $0 <output_directory> <binary_file>"
    exit 1
fi

output_dir="$data_dir/04.generate-help"
mkdir -p "$output_dir"

log_file="$output_dir/log.txt"
done_log="$output_dir/done.log"

total=$(cat $binary_file | wc -l)
tmp_dir=$(mktemp -d -p /tmp)

# Read binaries from input file
cat "$binary_file" | while read -r binary_name; do


    cmd_dir="$tmp_dir/$binary_name"

    echo "Processing $binary_name" | tee -a "$log_file"

    mkdir "$cmd_dir" || continue

    stdout_file="$cmd_dir/stdout"
    stderr_file="$cmd_dir/stderr"

    # Run the command and capture outputs
    timeout 5s "$binary_name" --help >"$stdout_file" 2>"$stderr_file" || {
        timeout 5s "$binary_name" -h >"$stdout_file" 2>"$stderr_file" || {
            echo "$binary_name FAIL" | tee -a "$done_log"
            cp -r "$cmd_dir" "$output_dir/$binary_name" 2>/dev/null || true
            continue
        }
    }

    # Check for extra files created during execution
    additional_files=$(ls "$cmd_dir" | grep -v -e "stdout" -e "stderr")
    if [ -n "$additional_files" ]; then
        echo "$binary_name CREATED EXTRA FILES" | tee -a "$log_file"
    fi

    # Copy results back to output directory
    cp -r "$cmd_dir" "$output_dir/$binary_name"

    echo "$binary_name OK" | tee -a "$done_log"
done

