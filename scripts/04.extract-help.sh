#/bin/sh

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

if man | grep "This system has been minimized" >/dev/null; then
    skip_manpages=1
else
    skip_manpages=0
fi


tmp_dir=/tmp/get-help-script
mkdir -p "$tmp_dir"

# Read binaries from input file
cat "$binary_file" | while read -r binary_name; do

    cmd_dir="$tmp_dir/$binary_name"

    echo "Processing $binary_name" | tee -a "$log_file"

    mkdir "$cmd_dir" || continue

    stdout_file="$cmd_dir/stdout"
    stderr_file="$cmd_dir/stderr"
    manpage_file="$cmd_dir/manpage"

    if [ $skip_manpages -eq 0 ]; then
        man "$binary_name" > "$manpage_file"
        test -s "$manpage_file" || rm "$manpage_file"
    fi

    if which $binary_name; then
        bash -c "
        timeout 1s -s KILL "$binary_name" --help >"$stdout_file" 2>"$stderr_file" || \
            timeout -s KILL 1s "$binary_name" -h >"$stdout_file" 2>"$stderr_file"
            " </dev/null
    fi

    total_lines=$(cat "$cmd_dir"/* | wc -l)

    if [ $total_lines -le 3 ] || [ $total_lines -ge 2000 ]; then
        # Not enough outputs = gtfo
        echo "$binary_name FAIL" | tee -a "$done_log"
    else
        # Copy results back to output directory
        cp -r "$cmd_dir" "$output_dir/$binary_name"
        echo "$binary_name OK" | tee -a "$done_log"
    fi
done

