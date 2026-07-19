#!/usr/bin/env python3
"""Validate the required structure of a grant-research workspace."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


REQUIRED_FILES = (
    "grant.json",
    "README.md",
    "research/opportunity.md",
    "research/award-landscape.md",
    "research/fit-and-strategy.md",
    "research/partners-and-team.md",
    "proposal/concept.md",
    "proposal/requirements-checklist.md",
    "sources/source-index.md",
    "logs/research-log.md",
)

REQUIRED_MANIFEST_FIELDS = (
    "schema_version",
    "grant_name",
    "slug",
    "created_at",
    "status",
    "stage",
)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", help="Path to grants/<slug>")
    args = parser.parse_args()
    workspace = Path(args.workspace).expanduser().resolve()

    errors: list[str] = []
    for relative in REQUIRED_FILES:
        path = workspace / relative
        if not path.is_file():
            errors.append(f"missing required file: {relative}")

    manifest_path = workspace / "grant.json"
    if manifest_path.is_file():
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"invalid grant.json: {exc}")
        else:
            for field in REQUIRED_MANIFEST_FIELDS:
                if field not in manifest or manifest[field] in (None, ""):
                    errors.append(f"grant.json missing value: {field}")
            if manifest.get("schema_version") != 1:
                errors.append("grant.json schema_version must be 1")

    if errors:
        print("Grant workspace validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(f"Grant workspace is valid: {workspace}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
