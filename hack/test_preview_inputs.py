"""Run with: python -m unittest discover -s hack -p 'test_preview_*.py'."""

from pathlib import Path
import tempfile
import unittest

from preview_inputs import PreviewInputs


class PreviewInputsTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.sources = PreviewInputs(self.root)

    def snapshot(self, paths, digest="original"):
        return {str(self.root / path): digest for path in paths}

    def test_initial_build_renders_everything(self):
        self.assertEqual(self.sources.plan({}), ("all", set()))

    def test_unchanged_inputs_skip_build(self):
        self.sources.inputs = self.snapshot(["docs/versioned/index.md"])
        self.assertEqual(self.sources.plan(dict(self.sources.inputs)), ("none", set()))

    def test_existing_file_changes(self):
        cases = {
            "docs/versioned/index.md": "working",
            "docs/about/index.md": "working",
            "docs/blog/posts/example.md": "working",
            "docs/stylesheets/main.css": "assets",
            "docs/js/main.js": "assets",
            "docs/images/logo.webp": "assets",
            "overrides/assets/stylesheets/home.css": "assets",
            "docs/snippets/install.md": "all",
            "docs/versioned/.nav.yml": "all",
            "docs/versioned/.meta.yml": "all",
            "overrides/main.html": "all",
            "hack/macros.py": "all",
            "mkdocs.yml": "all",
            "config/versions.txt": "all",
            ".cache/docs-preview/release-1.23/docs/index.md": "all",
        }
        for path, expected in cases.items():
            with self.subTest(path=path):
                self.sources.inputs = self.snapshot([path])
                current = self.snapshot([path], digest="edited")
                self.assertEqual(self.sources.plan(current), (expected, set(current)))

    def test_added_or_deleted_files_rebuild_everything(self):
        for path in ("docs/versioned/new.md", "docs/images/new.svg",
                     "overrides/assets/new.css"):
            for adding in (True, False):
                with self.subTest(path=path, adding=adding):
                    populated = self.snapshot([path])
                    self.sources.inputs = {} if adding else populated
                    current = populated if adding else {}
                    self.assertEqual(self.sources.plan(current), ("all", set(populated)))

    def test_mixed_changes_use_broadest_rebuild(self):
        for paths, expected in (
            (["docs/images/logo.svg", "docs/versioned/index.md"], "working"),
            (["docs/versioned/index.md", "docs/snippets/install.md"], "all"),
            (["docs/images/logo.svg", "overrides/main.html"], "all"),
        ):
            with self.subTest(paths=paths):
                self.sources.inputs = self.snapshot(paths)
                current = self.snapshot(paths, digest="edited")
                self.assertEqual(self.sources.plan(current), (expected, set(current)))

    def test_external_dependency_rebuilds_everything(self):
        path = str(self.root.parent / "external-snippet.md")
        self.sources.inputs = {path: "original"}
        self.assertEqual(self.sources.plan({path: "edited"}), ("all", {path}))

    def test_shadowed_theme_asset_uses_normal_build(self):
        path = "overrides/assets/main.css"
        shadow = self.root / "docs/assets/main.css"
        shadow.parent.mkdir(parents=True)
        shadow.write_text("/* docs overrides the theme asset */")
        self.sources.inputs = self.snapshot([path])
        self.assertEqual(self.sources.plan(self.snapshot([path], "edited"))[0], "all")

    def test_asset_output_paths(self):
        for source, output in (
            ("docs/images/logo.svg", "images/logo.svg"),
            ("overrides/assets/main.css", "assets/main.css"),
            ("overrides/main.html", None),
        ):
            with self.subTest(source=source):
                self.assertEqual(self.sources.asset_path(self.root / source), output)

    def test_snapshot_detects_content_changes(self):
        docs = self.root / "docs"
        docs.mkdir()
        page = docs / "index.md"
        page.write_text("Before")
        self.sources.inputs = self.sources.snapshot()
        self.assertEqual(self.sources.plan(self.sources.snapshot())[0], "none")
        page.write_text("After")
        self.assertEqual(self.sources.plan(self.sources.snapshot())[0], "working")
        page.unlink()
        self.assertEqual(self.sources.plan(self.sources.snapshot())[0], "all")


if __name__ == "__main__":
    unittest.main()
