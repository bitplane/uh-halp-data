#!/usr/bin/env python3

import sys
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

def main():
    if len(sys.argv) != 2:
        print("Usage: ./test-use-case-prompt.py <command_name>", file=sys.stderr)
        sys.exit(1)

    command_name = sys.argv[1]
    help_text = sys.stdin.read().strip()

    # Load the template
    template = Template(PROMPT_TEMPLATE)
    prompt = template.render(command_name=command_name, help_text=help_text)

    # Print the generated prompt for the LLM
    print(prompt)

if __name__ == "__main__":
    main()
