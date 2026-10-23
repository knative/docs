"""Run with: uv run --locked python -m unittest discover -s hack -p 'test_local_preview.py'."""

import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace

from mkdocs.config import load_config
from mkdocs.structure.files import File, Files

from local_preview import local_path, on_config, on_files


class LocalPreviewTests(unittest.TestCase):
    def test_only_product_paths_are_remapped(self):
        self.assertEqual(local_path("versioned/serving/README.md"), "docs/serving/README.md")
        for path in ("blog/index.md", "https://example.com/versioned/page", "docs/README.md"):
            self.assertEqual(local_path(path), path)

    def test_local_config_preserves_production_config(self):
        production = load_config("mkdocs.yml")
        local = load_config("mkdocs.local.yml")
        on_config(local)
        self.assertNotIn("version", local.extra)
        self.assertIn("version", production.extra)
        self.assertEqual(local.docs_dir, production.docs_dir)
        self.assertIn("docs/contributing/about.md", local.plugins["redirects"].config["redirect_maps"])
        self.assertIn("versioned/contributing/about.md", production.plugins["redirects"].config["redirect_maps"])
        # Reconfiguration during live reload is safe.
        on_config(local)
        self.assertIn("docs/contributing/about.md", local.plugins["redirects"].config["redirect_maps"])

    def test_source_content_edit_links_and_asset_paths_survive_remapping(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "versioned/serving/README.md"
            source.parent.mkdir(parents=True)
            source.write_text("# Serving\n")
            asset = source.parent / "diagram.svg"
            asset.write_text("<svg/>")
            page = File("versioned/serving/README.md", directory, directory, True)
            image = File("versioned/serving/diagram.svg", directory, directory, True)
            blog = File("blog/index.md", directory, directory, True)
            # Exercise already-cached URLs as well.
            self.assertEqual(page.url, "versioned/serving/")
            config = SimpleNamespace(
                site_dir=directory, use_directory_urls=True,
                plugins=SimpleNamespace(_current_plugin=None),
            )
            files = on_files(Files([page, image, blog]), config)
            self.assertIs(files.get_file_from_path("docs/serving/README.md"), page)
            self.assertIsNone(files.get_file_from_path("versioned/serving/README.md"))
            self.assertEqual(page.url, "docs/serving/")
            self.assertEqual(page.dest_uri, "docs/serving/index.html")
            self.assertEqual(page.edit_uri, "versioned/serving/README.md")
            self.assertEqual(page.abs_src_path, str(source))
            self.assertEqual(page.content_string, "# Serving\n")
            self.assertEqual(image.dest_uri, "docs/serving/diagram.svg")
            self.assertEqual(image.abs_src_path, str(asset))
            self.assertEqual(blog.url, "blog/")
            self.assertIn("Docs: docs", files.get_file_from_path(".nav.yml").content_string)


if __name__ == "__main__":
    unittest.main()
