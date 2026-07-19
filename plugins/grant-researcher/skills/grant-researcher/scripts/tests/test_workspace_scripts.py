from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPTS = Path(__file__).resolve().parents[1]
INIT = SCRIPTS / "init_grant_workspace.py"
VALIDATE = SCRIPTS / "validate_grant_workspace.py"


class WorkspaceScriptsTest(unittest.TestCase):
    def make_repo(self, root: Path) -> Path:
        repo = root / "demo-repo"
        repo.mkdir()
        subprocess.run(["git", "init", "-q", str(repo)], check=True)
        return repo

    def test_initialize_validate_and_rerun(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = self.make_repo(Path(tmp))
            command = [
                "python3",
                str(INIT),
                "NSF Physics Frontiers Centers",
                "--repo-root",
                str(repo),
                "--sponsor",
                "NSF",
            ]
            first = subprocess.run(command, check=True, capture_output=True, text=True)
            result = json.loads(first.stdout)
            workspace = Path(result["workspace"])
            self.assertTrue((workspace / "grant.json").is_file())
            self.assertTrue((workspace / "research" / "award-landscape.md").is_file())

            subprocess.run(["python3", str(VALIDATE), str(workspace)], check=True)
            second = subprocess.run(command, check=True, capture_output=True, text=True)
            rerun = json.loads(second.stdout)
            self.assertIn("grant.json", rerun["skipped"])
            self.assertEqual([], rerun["created"])

    def test_rejects_non_git_directory(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            result = subprocess.run(
                ["python3", str(INIT), "Example Grant", "--repo-root", tmp],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertNotEqual(0, result.returncode)
            self.assertIn("not inside a Git repository", result.stderr)


if __name__ == "__main__":
    unittest.main()
