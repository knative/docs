"""Offline integration tests: uv run python -m unittest discover -s test -p 'test_*.py'."""

import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest

import yaml


REPO = Path(__file__).resolve().parents[1]
PAGE = '''# Includes

--8<-- "outer.md"

{% include "outer.jinja" %}

--8<--
sections.md:chosen
--8<--
'''


class SnippetTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.docs = self.root / "docs"
        self.put("docs/index.md", "# Home\n")
        self.snippets(self.docs / "snippets", "CHECKOUT")
        self.config = {
            "site_name": "Snippet tests",
            "docs_dir": "docs",
            "site_dir": "site",
            "hooks": [str(REPO / "hack/snippets.py")],
            "markdown_extensions": [{"pymdownx.snippets": {"base_path": "docs/snippets"}}],
            "plugins": [
                {"exclude": {"glob": ["snippets/*"]}},
                {"macros": {
                    "module_name": str(REPO / "hack/macros"),
                    "include_dir": "docs/snippets",
                    "on_error_fail": True,
                }},
            ],
        }

    def put(self, path, text):
        path = self.root / path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def snippets(self, root, marker):
        root.mkdir(parents=True, exist_ok=True)
        for name, text in {
            "outer.md": '--8<-- "inner.md"\n',
            "inner.md": f"PYMDOWN-{marker}\n",
            "outer.jinja": '{% include "inner.jinja" %}\n',
            "inner.jinja": f"JINJA-{marker}\n",
            "sections.md": f"OMITTED\n--8<-- [start:chosen]\nSECTION-{marker}\n--8<-- [end:chosen]\n",
        }.items():
            (root / name).write_text(text)

    def command(self, *args, success=True, env=None):
        result = subprocess.run(
            args, cwd=self.root, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, env=env,
        )
        if success:
            self.assertEqual(result.returncode, 0, result.stdout)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout)
        return result

    def build(self, success=True):
        self.put("mkdocs.yml", yaml.safe_dump(self.config))
        return self.command(sys.executable, "-m", "mkdocs", "build", "--strict", success=success)

    def assembled(self):
        versions = {"development": "DEVELOP", "docs": "CURRENT", "v1.22-docs": "OLDER"}
        self.put("docs/versions.json", json.dumps([{"version": v} for v in versions]))
        for version, marker in versions.items():
            self.snippets(self.root / ".snippets" / version, marker)
            self.put(f"docs/{version}/index.md", PAGE)
        return versions

    def assert_page(self, version, marker, others):
        html = (self.root / "site" / version / "index.html").read_text()
        for kind in ("PYMDOWN", "JINJA", "SECTION"):
            self.assertIn(f"{kind}-{marker}", html)
            for other in others:
                self.assertNotIn(f"{kind}-{other}", html)
        self.assertNotIn("OMITTED", html)

    def test_versions_and_nested_includes_are_isolated(self):
        versions = self.assembled()
        # Unversioned pages explicitly use checkout snippets.
        self.put("docs/community/index.md", PAGE)
        self.build()
        for version, marker in versions.items():
            self.assert_page(version, marker, set(versions.values()) - {marker} | {"CHECKOUT"})
        self.assert_page("community", "CHECKOUT", versions.values())
        self.assertFalse((self.root / "site/.snippets").exists())
        self.assertFalse((self.root / "site/snippets").exists())

    def test_single_checkout_and_local_preview(self):
        self.put("docs/versioned/index.md", PAGE)
        self.build()
        self.assert_page("versioned", "CHECKOUT", [])

        # Match mkdocs.local.yml's source-path remapping, using the real hook.
        self.config["hooks"].append(str(REPO / "hack/local_preview.py"))
        self.config["plugins"].append({"redirects": {"redirect_maps": {}}})
        self.build()
        self.assert_page("docs", "CHECKOUT", [])

        # Rebuild in the same process, as mkdocs serve does, without retaining
        # stale Jinja templates. Include the same template twice across builds.
        self.command(sys.executable, "-c", '''
from pathlib import Path
from mkdocs.commands.build import build
from mkdocs.config import load_config
config = load_config("mkdocs.yml", strict=True)
build(config)
for path in Path("docs/snippets").iterdir():
    path.write_text(path.read_text().replace("CHECKOUT", "EDITED"))
build(config)
''')
        self.assert_page("docs", "EDITED", ["CHECKOUT"])

    def test_missing_nested_snippets_fail_without_checkout_fallback(self):
        for name in ("inner.md", "inner.jinja"):
            with self.subTest(name=name):
                self.assembled()
                (self.root / ".snippets/docs" / name).unlink()
                result = self.build(success=False)
                self.assertIn(name, result.stdout)

    def test_missing_snapshot_fails_without_checkout_fallback(self):
        self.assembled()
        shutil.rmtree(self.root / ".snippets/docs")
        result = self.build(success=False)
        self.assertIn("Missing snippet snapshot", result.stdout)

    def test_build_script_copies_snippets_from_each_release(self):
        # Exercise the actual assembly script using tiny local release branches.
        # Only the API downloads are stubbed; git and MkDocs run normally.
        self.put("mkdocs.yml", yaml.safe_dump(self.config))
        self.put("config/redirects.yml", "plugins:\n  redirects:\n    redirect_maps: {}\n")
        self.put("docs/versioned/index.md", PAGE)
        self.put("docs/versioned/.meta.yml", "{}\n")
        self.put("docs/versioned/serving/reference/serving-api.md", "# Serving\n")
        self.put("docs/versioned/eventing/reference/eventing-api.md", "# Eventing\n")
        self.put("golang/example.html", "vanity URL\n")
        self.put("golang/_redirects", "")
        self.put(".gitignore", "site/\n")
        self.command("git", "init", "-b", "main")
        self.command("git", "config", "user.name", "Snippet Test")
        self.command("git", "config", "user.email", "test@example.com")
        self.command("git", "add", ".")
        self.command("git", "commit", "-m", "Main fixture")
        self.command("git", "remote", "add", "origin", str(self.root))
        # Follow build.sh's supported releases so routine release bumps do not
        # require changing the test fixtures.
        version_line = next(line for line in (REPO / "hack/build.sh").read_text().splitlines()
                            if line.startswith("VERSIONS=("))
        releases = shlex.split(version_line.split("(", 1)[1].split(")", 1)[0])
        for version in releases:
            self.command("git", "checkout", "-b", f"release-{version}", "main")
            self.snippets(self.docs / "snippets", version)
            self.command("git", "add", ".")
            self.command("git", "commit", "-m", f"Release {version}")
            self.command("git", "update-ref", f"refs/remotes/origin/release-{version}", "HEAD")
        self.command("git", "checkout", "main")
        self.put("bin/curl", "#!/bin/sh\nprintf '# API reference\\n'\n")
        (self.root / "bin/curl").chmod(0o755)
        self.put("bin/mkdocs", f'#!/bin/sh\nexec "{sys.executable}" -m mkdocs "$@"\n')
        (self.root / "bin/mkdocs").chmod(0o755)
        temp = self.root / "build-temp"
        temp.mkdir()
        env = dict(os.environ, GITHUB_TOKEN="unused", CI="false", TMPDIR=str(temp),
                   PATH=str(self.root / "bin") + os.pathsep + os.environ["PATH"])
        self.command("bash", str(REPO / "hack/build.sh"), "--strict", env=env)
        versions = {"development": "CHECKOUT", "docs": releases[0],
                    **{f"v{version}-docs": version for version in releases[1:]}}
        for version, marker in versions.items():
            self.assert_page(version, marker, set(versions.values()) - {marker})

        # BUILD_VERSIONS=no still assembles the checkout's snippet snapshot.
        env["BUILD_VERSIONS"] = "no"
        self.command("bash", str(REPO / "hack/build.sh"), "--strict", env=env)
        self.assert_page("docs", "CHECKOUT", releases)


if __name__ == "__main__":
    unittest.main()
