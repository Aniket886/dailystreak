#!/usr/bin/env python3
import json
import os
import sys
import urllib.error
import urllib.request


def main() -> int:
    api_key = os.environ.get("GROQ_API_KEY", "").strip()
    model = os.environ.get("GROQ_MODEL", "llama-3.3-70b-versatile").strip()
    prompt = sys.stdin.read().strip()

    if not api_key or not prompt:
        print("Groq request skipped: missing API key or prompt.", file=sys.stderr)
        return 1

    payload = {
        "model": model,
        "temperature": 0.9,
        "max_tokens": 120,
        "stream": False,
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
            "Accept": "application/json",
            "User-Agent": "personal-notes-workflow/1.0",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=45) as response:
            body = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        error_body = exc.read().decode("utf-8", errors="replace").strip()
        print(f"Groq HTTP error {exc.code}: {error_body}", file=sys.stderr)
        return 1
    except urllib.error.URLError as exc:
        print(f"Groq network error: {exc.reason}", file=sys.stderr)
        return 1
    except TimeoutError:
        print("Groq timeout error: request timed out.", file=sys.stderr)
        return 1
    except json.JSONDecodeError as exc:
        print(f"Groq response parse error: {exc}", file=sys.stderr)
        return 1

    try:
        content = body["choices"][0]["message"]["content"].strip()
    except (KeyError, IndexError, TypeError) as exc:
        print(f"Groq response shape error: {exc}", file=sys.stderr)
        return 1

    content = " ".join(content.split())
    if not content:
        print("Groq returned empty content.", file=sys.stderr)
        return 1

    print(content)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
