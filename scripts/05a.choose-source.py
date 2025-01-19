#!/usr/bin/env python3

import os
import sys

def evaluate_file(file_path):
    """Evaluate a file based on its content and size."""
    if not os.path.exists(file_path):
        return -100, "File does not exist", 0, 0

    file_size = os.path.getsize(file_path)
    if file_size == 0:
        return -100, "File is empty", file_size, 0
    if file_size > 102400:  # 100 KB limit
        return -100, "File is over 100 KB and useless", file_size, 0

    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        return -100, f"Error reading file: {e}", file_size, 0

    num_lines = len(lines)
    if num_lines < 5:
        return -100, "File contains fewer than 5 lines", file_size, num_lines

    contains_double_dash = any('--' in line for line in lines)
    score = 10 if contains_double_dash else 5

    return score, "File evaluated successfully", file_size, num_lines

def choose_best_help(dir_path):
    """Choose the best file for a command based on the scoring criteria."""
    files = {
        "manpage": os.path.join(dir_path, "manpage"),
        "stdout": os.path.join(dir_path, "stdout"),
        "stderr": os.path.join(dir_path, "stderr"),
    }
    scores = {}
    reasons = {}
    metadata = {}

    # Evaluate each file
    for key, file_path in files.items():
        score, reason, size, lines = evaluate_file(file_path)
        scores[key] = score
        reasons[key] = reason
        metadata[key] = {"size": size, "lines": lines, "contains_double_dash": "yes" if "--" in reason else "no"}

    # Choose the best based on priority and score
    priorities = ["manpage", "stdout", "stderr"]
    best_choice = None
    best_score = -float('inf')
    best_reason = ""

    for key in priorities:
        if scores[key] > best_score:
            best_choice = key
            best_score = scores[key]
            best_reason = reasons[key]

    return best_choice, best_reason, metadata

def write_summary(summary_dir, metadata, reason, best_choice):
    """Write the evaluation summary to extract.txt."""
    with open(os.path.join(summary_dir, "extract.txt"), "w") as f:
        for key, data in metadata.items():
            f.write(f"{key}: {data['size']} bytes, {data['lines']} lines, contains '--': {data['contains_double_dash']}\n")
        f.write(f"\nDecision: {best_choice} -> {reason}\n")

def write_help(summary_dir, best_file):
    """Write the contents of the best file to help.txt, cleaning up double spaces."""
    help_path = os.path.join(summary_dir, "help.txt")
    if best_file:
        with open(best_file, "r") as infile, open(help_path, "w") as outfile:
            for line in infile:
                outfile.write(line.lstrip("  "))  # Remove leading double spaces
    else:
        # Leave help.txt blank
        open(help_path, "w").close()

def main(source_dir, target_dir):
    if not os.path.exists(target_dir):
        os.makedirs(target_dir)

    for command_dir in sorted(os.listdir(source_dir)):
        source_path = os.path.join(source_dir, command_dir)
        if not os.path.isdir(source_path):
            continue

        summary_dir = os.path.join(target_dir, command_dir)
        os.makedirs(summary_dir, exist_ok=True)

        best_choice, reason, metadata = choose_best_help(source_path)
        best_file = os.path.join(source_path, best_choice) if best_choice else None

        # Write evaluation summary
        write_summary(summary_dir, metadata, reason, best_choice)

        # Write help.txt or handle missing data
        if best_file and metadata[best_choice]["size"] > 0:
            write_help(summary_dir, best_file)
        else:
            sys.stderr.write(f"No useful help data for {command_dir}\n")
            write_help(summary_dir, None)

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Evaluate help files and generate summaries.")
    parser.add_argument("source_dir", help="Path to the source directory (e.g., data/04.generate-help).")
    parser.add_argument("target_dir", help="Path to the target directory (e.g., data/05.generate-summaries).")
    args = parser.parse_args()

    main(args.source_dir, args.target_dir)
