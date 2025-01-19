#!/usr/bin/env python3

import os
import json
import requests
import sys
from jinja2 import Template

PROMPT_TEMPLATE = """
There is a program called "{{ command_name }}". It performs the following function:

{{ help_text }}

We want to understand how this program is used in real-world scenarios. Generate:
1. A one-line summary of the program's purpose.
2. List other commands that are frequently used with it, or are related.
3. A list of 10 realistic use cases where humans commonly use this program.
"""

def generate_summary(command_name, help_text, host, port):
    """Generate a command summary by sending a request to the LLM service."""
    url = f"http://{host}:{port}/api/generate"
    template = Template(PROMPT_TEMPLATE)
    prompt = template.render(command_name=command_name, help_text=help_text)

    payload = {
        "model": "llama3",
        "prompt": prompt,
        "system": "You are an AI system for generating realistic use cases for command-line tools.",
    }

    try:
        with requests.post(url, json=payload, stream=True) as response:
            response.raise_for_status()

            full_response = ""
            for line in response.iter_lines():
                if line.strip():  # Skip empty lines
                    try:
                        item = json.loads(line)
                        if "response" in item:
                            full_response += item["response"]
                            # Write progress to stderr without newlines
                            print(item["response"], end="", file=sys.stderr, flush=True)
                    except json.JSONDecodeError:
                        print(f" [Skipping invalid JSON line: {line}] ", file=sys.stderr, flush=True)

            return full_response
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return None

def save_output(output_file, content):
    """Save generated content to a file."""
    with open(output_file, 'w') as f:
        f.write(content)

def process_directory(command_dir, host, port):
    """Process a single directory, generating a summary from help.txt."""
    help_file = os.path.join(command_dir, "help.txt")
    summary_file = os.path.join(command_dir, "summary.txt")

    if not os.path.exists(help_file) or os.path.getsize(help_file) == 0:
        sys.stderr.write(f"Skipping {command_dir}: no valid help.txt\n")
        save_output(summary_file, "No valid help data available.\n")
        return

    command_name = os.path.basename(command_dir)

    with open(help_file, "r") as f:
        help_text = f.read()

    if not help_text.strip():
        sys.stderr.write(f"Skipping {command_dir}: help.txt is empty or blank\n")
        save_output(summary_file, "No valid help data available.\n")
        return

    summary = generate_summary(command_name, help_text, host, port)
    if summary:
        save_output(summary_file, summary)
        print(f"\nSummary saved to {summary_file}", file=sys.stderr)
    else:
        sys.stderr.write(f"Failed to generate summary for {command_dir}\n")
        save_output(summary_file, "Failed to generate summary.\n")

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Generate summaries for all commands in a directory.")
    parser.add_argument("input_dir", help="Path to the directory containing command subdirectories.")
    parser.add_argument("--host", default="localhost", help="LLM service host.")
    parser.add_argument("--port", default=11434, type=int, help="LLM service port.")
    args = parser.parse_args()

    for command_dir in sorted(os.listdir(args.input_dir)):
        full_path = os.path.join(args.input_dir, command_dir)
        if not os.path.isdir(full_path):
            continue

        process_directory(full_path, args.host, args.port)

if __name__ == "__main__":
    main()
