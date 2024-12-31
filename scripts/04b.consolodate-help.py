#!/usr/bin/env python3

import os
import argparse
import sys

def consolidate_help_files(command_dir):
    """Consolidates stdout, stderr, and manpage into a single help output."""
    files_to_check = ["stdout", "stderr", "manpage"]
    consolidated_content = []

    for filename in files_to_check:
        file_path = os.path.join(command_dir, filename)
        if os.path.exists(file_path):
            with open(file_path, "r") as f:
                content = f.read().strip()
                if content:
                    consolidated_content.append(f"=== {filename.upper()} ===\n{content}\n")

    if consolidated_content:
        return "\n".join(consolidated_content)
    else:
        return None

def main():
    parser = argparse.ArgumentParser(
        description="Consolidate help files for a single command directory into a single output."
    )
    parser.add_argument(
        "command_dir", 
        help="Directory containing command help files (stdout, stderr, manpage)."
    )
    args = parser.parse_args()

    if not os.path.isdir(args.command_dir):
        print(f"Error: {args.command_dir} is not a valid directory", file=sys.stderr)
        sys.exit(1)

    consolidated_help = consolidate_help_files(args.command_dir)
    if consolidated_help:
        print(consolidated_help)
    else:
        print(f"Warning: No help content found in {args.command_dir}", file=sys.stderr)

if __name__ == "__main__":
    main()
