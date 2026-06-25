"""Smoke test the Saxon-HE command-line target."""

from __future__ import annotations

import subprocess
import sys


def main() -> int:
    saxon = sys.argv[1]
    completed = subprocess.run(
        [saxon, "-?"],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    if "SaxonJ-HE" not in completed.stdout:
        print("Expected Saxon help output to contain 'SaxonJ-HE'.", file=sys.stderr)
        print(completed.stdout, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
