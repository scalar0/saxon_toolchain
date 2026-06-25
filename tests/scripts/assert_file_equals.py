"""Compare two files after normalizing a final trailing newline."""

from __future__ import annotations

import pathlib
import sys


def _normalized(path: str) -> str:
    return pathlib.Path(path).read_text(encoding="utf-8").rstrip("\n")


def main() -> int:
    actual, expected = sys.argv[1:3]
    actual_text = _normalized(actual)
    expected_text = _normalized(expected)
    if actual_text != expected_text:
        print("Actual output did not match expected output.", file=sys.stderr)
        print("--- expected", file=sys.stderr)
        print(expected_text, file=sys.stderr)
        print("--- actual", file=sys.stderr)
        print(actual_text, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
