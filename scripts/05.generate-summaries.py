#!/usr/bin/env python3

import argparse
import requests
import sys
import json
from jinja2 import Template

# Template for the refined prompt
PROMPT_TEMPLATE = """
There is a program called "{{ command_name }}". It performs the following function:

{{ help_text }}

We want to understand how this program is used in real-world scenarios. Generate:
1. A one-line summary of the program's purpose.
2. List other commands that are frequently used with it, or are related.
3. A list of 10 realistic use cases where humans commonly use this program. Each use case should:
   - Be unique and practical.
   - Focus on real-world tasks, ones that can be solved by typing the command name in.
   - Describe a reason why you'd type the program into the console.
   - Focus mainly on common scenarios, rather than exotic or speculative ones.

Here’s an example for the `ls` command:

**COMMAND NAME:** ls  
**SUMMARY:** Lists the contents of directories.  
**RELATED:**
* find, xargs, file, stat, du, sort
**USE:**
1. I want to see what files are in this directory.
2. Which file in here is the biggest?
3. Do any of these files have broken permissions?
4. Are there .txt files in this dir? 
5. Which one of these files just got written to?
6. How many files are in here?
7. What hidden files are in here?
8. Combine with `grep` to find specific filenames in a directory.
9. Pass these files to `xargs` and pass to another program.
10. Save this list of files for later.

Now, generate outputs for the following command:

**COMMAND NAME:** {{ command_name }}  
**SUMMARY:**  
**USE CASES:**
"""

def prompt_llm(prompt, host, port):
    url = f"http://{host}:{port}/api/generate"
    payload = {
        "model": "llama3",
        "system": "You are an expert in generating realistic use-case scenarios for command-line tools. Input is a command name and its help documentation. Output is a structured prompt to help humans understand how to use the tool effectively.",
        "prompt": prompt,
    }
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        return response.json().get("response", "")
    except requests.RequestException as e:
        print(f"Error contacting the LLM service: {e}", file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(
        description="Generate use-case prompts for a given command name."
    )
    parser.add_argument("command_name", type=str, help="The name of the command to generate use-case prompts for.")
    parser.add_argument("help_file", type=str, help="Path to the help file for the command.")
    parser.add_argument("output_file", type=str, help="Path to save the generated use-case prompt.")
    parser.add_argument("--host", type=str, default="localhost", help="Host for the LLM service.")
    parser.add_argument("--port", type=int, default=11434, help="Port for the LLM service.")
    args = parser.parse_args()

    # Load the help text
    with open(args.help_file, "r") as f:
        help_text = f.read().strip()

    # Render the prompt
    template = Template(PROMPT_TEMPLATE)
    prompt = template.render(command_name=args.command_name, help_text=help_text)

    # Send the prompt to the LLM
    response = prompt_llm(prompt, args.host, args.port)

    if response:
        # Save the response to the output file
        with open(args.output_file, "w") as f:
            f.write(response)
        print(f"Generated use-case prompt saved to {args.output_file}")
    else:
        print("Failed to generate use-case prompt.", file=sys.stderr)

if __name__ == "__main__":
    main()
