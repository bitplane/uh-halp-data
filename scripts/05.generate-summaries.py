#!/usr/bin/env python3

import argparse
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

def main():
    parser = argparse.ArgumentParser(description="Generate command summaries from JSON responses.")
    parser.add_argument("command_name", help="The name of the command.")
    parser.add_argument("help_file", help="Path to the help file.")
    parser.add_argument("output_file", help="Path to save the generated summary.")
    parser.add_argument("--host", default="localhost", help="LLM service host.")
    parser.add_argument("--port", default=11434, type=int, help="LLM service port.")
    args = parser.parse_args()

    # Load help text
    with open(args.help_file, 'r') as f:
        help_text = f.read()

    # Generate summary
    summary = generate_summary(args.command_name, help_text, args.host, args.port)

    # Save summary
    if summary:
        save_output(args.output_file, summary)
        print(f"\nSummary saved to {args.output_file}", file=sys.stderr)
    else:
        print("\nFailed to generate summary.", file=sys.stderr)

if __name__ == "__main__":
    main()
