#!/usr/bin/env python3

import argparse
import random
import requests
import sys
import json
import logging
from logging.handlers import RotatingFileHandler


def setup_logger():
    logger = logging.getLogger("binary_ranking")
    logger.setLevel(logging.DEBUG)

    # File handler for /tmp debug log
    file_handler = RotatingFileHandler(
        "/tmp/binary_ranking_debug.log", maxBytes=10**6, backupCount=3
    )
    file_formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
    file_handler.setFormatter(file_formatter)
    logger.addHandler(file_handler)

    return logger


logger = setup_logger()


def load_lines(lines):
    binary_dict = {}

    for line in lines:
        line = line.strip()
        if not line:
            continue

        parts = line.split()

        if len(parts) == 2:
            path_binary, repo = parts
            path, binary = (
                path_binary.rsplit("/", 1) if "/" in path_binary else ("", path_binary)
            )
            binary_dict[binary] = {
                "path": path if path else None,
                "repo": repo,
                "score": 0,  # Default score
            }
        elif len(parts) == 1:
            binary = parts[0]
            binary_dict[binary] = {
                "path": None,
                "repo": None,
                "score": 0,  # Default score
            }

    return binary_dict


def load_file(file_name):
    with open(file_name, "r") as file:
        lines = file.readlines()
    return load_lines(lines)


def chunker(keys, batch_size):
    random.shuffle(keys)
    for i in range(0, len(keys), batch_size):
        yield keys[i : i + batch_size]


def rank(keys, host, port):
    url = f"http://{host}:{port}/api/generate"
    payload = {
        "model": "llama3",
        "system": "You are bash-cache-priority, an AI program that decides which commands the user is most likely to type. Input is a list of binaries. Output is an ordered list by likelihood of being entered on the keyboard. Respond with just the command names in order of likelihood.",
        "prompt": "\n".join(keys),
    }
    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()

        responses = []
        for line in response.text.strip().split("\n"):
            try:
                data = json.loads(line)
                if "response" in data:
                    responses.append(data["response"])
            except json.JSONDecodeError as e:
                logger.error(f"JSON decode error: {e} with line: {line}")
                continue

        output = "".join(responses).split("\n")

        filtered_output = []
        for line in output:
            if not line.strip():
                continue  # Skip blanks

            parts = line.split()
            if len(parts) > 2:
                continue  # Skip yapping

            command = parts[-1]
            if command in keys:
                filtered_output.append(command)

            if len(parts) == 1 and "." in parts[0]:
                number, *rest = parts[0].split(".", 1)
                if number.isdigit() and rest[0] in keys:
                    filtered_output.append(rest[0])

        logger.debug(f"Full response: {response.text}")
        return filtered_output

    except requests.RequestException as e:
        logger.error(f"Error making request to {url}: {e}")
        return []


def score(dictionary, batch_size, host, port, keys):
    total = len(keys)
    count = 0
    for batch in chunker(keys, batch_size):
        ranked = rank(batch, host, port)
        for i, name in enumerate(reversed(ranked), start=1):
            dictionary[name]["score"] += i
            print(f"{dictionary[name]['score']} {name}")
        count += batch_size
        if ranked:
            logger.info(f"{count}/{total} - winner: {ranked[0]}")


def score_all(dictionary, batch_size, host, port):
    keys = list(dictionary.keys())
    while len(keys) > batch_size:
        mean_score = sum(dictionary[key]["score"] for key in keys) / len(keys)
        keys = [key for key in keys if dictionary[key]["score"] >= mean_score]
        score(dictionary, batch_size, host, port, keys)


def main():
    parser = argparse.ArgumentParser(
        description="Process a file containing binary paths and repos."
    )
    parser.add_argument("file_name", type=str, help="The name of the file to process")
    parser.add_argument(
        "--batch-size", type=int, default=10, help="Batch size for processing"
    )
    parser.add_argument("--seed", type=int, help="Random seed for reproducibility")
    parser.add_argument(
        "--host", type=str, default="localhost", help="Host for ranking service"
    )
    parser.add_argument(
        "--port", type=int, default=11434, help="Port for ranking service"
    )
    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    binary_data = load_file(args.file_name)
    logger.info(f"Batch size: {args.batch_size}")
    logger.info(f"Total commands: {len(binary_data)}")

    score_all(binary_data, args.batch_size, args.host, args.port)


if __name__ == "__main__":
    main()
