#!/usr/bin/env python3
import json
import os
import sys
import urllib.request


def main() -> int:
    api_key = os.environ.get("GROQ_API_KEY", "").strip()
    model = os.environ.get("GROQ_MODEL", "llama-3.1-8b-instant").strip()
    prompt = sys.stdin.read().strip()

    if not api_key or not prompt:
        return 1

    payload = {
        "model": model,
        "temperature": 0.9,
        "max_tokens": 120,
        "messages": [
            {
                "role": "system",
                "content": (
                    "You write short, believable personal notes and idea lines. "
                    "Use only the facts given in the prompt. "
                    "Do not invent awards, employers, analytics, or private details. "
                    "Return only one concise line of plain text with no bullets, no quotes, and no markdown."
                ),
            },
            {"role": "user", "content": prompt},
        ],
    }

    req = urllib.request.Request(
        "https://api.groq.com/openai/v1/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    with urllib.request.urlopen(req, timeout=45) as response:
        body = json.loads(response.read().decode("utf-8"))

    content = body["choices"][0]["message"]["content"].strip()
    content = " ".join(content.split())
    if not content:
        return 1

    print(content)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
