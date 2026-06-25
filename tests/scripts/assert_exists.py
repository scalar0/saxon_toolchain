from __future__ import annotations

import pathlib
import sys

for arg in sys.argv[1:]:
    path = pathlib.Path(arg)
    if not path.exists():
        raise SystemExit(f"missing expected file: {path}")
