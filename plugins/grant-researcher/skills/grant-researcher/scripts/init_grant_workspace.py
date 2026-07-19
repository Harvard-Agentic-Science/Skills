#!/usr/bin/env python3
"""Create an idempotent grant-research workspace inside a Git repository."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    slug = re.sub(r"-+", "-", slug)
    if not slug:
        raise ValueError("grant name does not produce a usable slug")
    return slug[:80].rstrip("-")


def resolve_git_root(candidate: Path) -> Path:
    result = subprocess.run(
        ["git", "-C", str(candidate), "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise ValueError(f"not inside a Git repository: {candidate}")
    return Path(result.stdout.strip()).resolve()


def safe_relative_dir(value: str) -> Path:
    path = Path(value)
    if path.is_absolute() or ".." in path.parts or not path.parts:
        raise ValueError("--root-dir must be a safe relative path")
    return path


def render(text: str, values: dict[str, str]) -> str:
    for key, value in values.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def copy_templates(template_root: Path, destination: Path, values: dict[str, str]) -> tuple[list[str], list[str]]:
    created: list[str] = []
    skipped: list[str] = []
    for source in sorted(template_root.rglob("*")):
        relative = source.relative_to(template_root)
        target = destination / relative
        if source.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists():
            skipped.append(str(relative))
            continue
        content = source.read_text(encoding="utf-8")
        target.write_text(render(content, values), encoding="utf-8")
        created.append(str(relative))
    return created, skipped


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("grant_name", help="Human-readable grant or opportunity name")
    parser.add_argument("--repo-root", default=".", help="Path inside the target Git repository")
    parser.add_argument("--root-dir", default="grants", help="Relative parent directory for grant workspaces")
    parser.add_argument("--slug", help="Workspace slug; defaults to a normalized grant name")
    parser.add_argument("--sponsor", default="", help="Funding sponsor")
    parser.add_argument("--opportunity-id", default="", help="Official opportunity identifier")
    parser.add_argument("--official-url", default="", help="Canonical official landing page")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        repo_root = resolve_git_root(Path(args.repo_root).expanduser().resolve())
        root_dir = safe_relative_dir(args.root_dir)
        slug = slugify(args.slug or args.grant_name)
    except ValueError as exc:
        parser.error(str(exc))

    if Path(slug).name != slug or slug in {".", ".."}:
        parser.error("--slug must be a single safe path component")

    workspace = repo_root / root_dir / slug
    workspace.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    values = {
        "grant_name": args.grant_name,
        "slug": slug,
        "created_at": today,
    }
    template_root = Path(__file__).resolve().parent.parent / "assets" / "workspace-template"
    if not template_root.is_dir():
        parser.error(f"workspace template is missing: {template_root}")

    created, skipped = copy_templates(template_root, workspace, values)
    manifest_path = workspace / "grant.json"
    if manifest_path.exists():
        skipped.append("grant.json")
    else:
        manifest = {
            "schema_version": 1,
            "grant_name": args.grant_name,
            "slug": slug,
            "sponsor": args.sponsor or None,
            "opportunity_id": args.opportunity_id or None,
            "official_url": args.official_url or None,
            "created_at": today,
            "last_researched_at": None,
            "status": "researching",
            "stage": "discovery",
            "next_deadline": None,
        }
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
        created.append("grant.json")

    result = {
        "grant_name": args.grant_name,
        "slug": slug,
        "repo_root": str(repo_root),
        "workspace": str(workspace),
        "created": sorted(created),
        "skipped": sorted(skipped),
    }
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
