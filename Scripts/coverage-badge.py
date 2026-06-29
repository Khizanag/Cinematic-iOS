#!/usr/bin/env python3
"""Compute core-logic line coverage and write docs/coverage.json.

Run `swift test --package-path Package/<pkg> --enable-code-coverage` for each
pure package first, then run this. It reads each run's llvm-cov export and
counts only that package's own Sources/ — so a dependency compiled into
another package's run is never double-counted — and writes a shields.io
endpoint badge the Pages site serves.
"""
from __future__ import annotations

import json
import subprocess
import sys

PACKAGES = ["MVIKit", "CinematicDomain", "CinematicData"]


def color(pct: int) -> str:
    if pct >= 90:
        return "brightgreen"
    if pct >= 80:
        return "green"
    if pct >= 70:
        return "yellowgreen"
    if pct >= 60:
        return "yellow"
    return "red"


def main() -> int:
    total = covered = 0
    for package in PACKAGES:
        path = subprocess.run(
            ["swift", "test", "--package-path", f"Package/{package}", "--show-codecov-path"],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
        report = json.load(open(path))
        own_sources = f"/Package/{package}/Sources/"
        for file in report["data"][0]["files"]:
            if own_sources in file["filename"]:
                total += file["summary"]["lines"]["count"]
                covered += file["summary"]["lines"]["covered"]

    if total == 0:
        print("no coverage data — run `swift test --enable-code-coverage` first", file=sys.stderr)
        return 1

    pct = round(covered / total * 100)
    badge = {"schemaVersion": 1, "label": "coverage", "message": f"{pct}%", "color": color(pct)}
    with open("docs/coverage.json", "w") as out:
        json.dump(badge, out)
        out.write("\n")
    print(f"core-logic coverage: {covered}/{total} = {pct}%")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
