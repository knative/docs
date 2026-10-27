"""Check publication safety without starting MkDocs or an HTTP server."""

from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock

from dev_server import Builder, State
from preview_inputs import PreviewInputs


class PreviewBuildTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.workspace = self.root / "output"
        self.workspace.mkdir()
        self.state = State(self.workspace)
        self.sources = PreviewInputs(self.root)
        self.builder = Builder(self.state, self.sources, "mkdocs.local.yml", "http://localhost/")

    def test_only_new_release_cache_files_are_ignored_during_build(self):
        page = str(self.root / "docs/index.md")
        cached = str(self.root / ".cache/docs-preview/release-1.23/docs/index.md")
        changed = self.builder.inputs_changed_during_build
        self.assertFalse(changed({page: "same"}, {page: "same", cached: "new"}))
        self.assertTrue(changed({page: "old"}, {page: "new"}))
        self.assertTrue(changed({cached: "old"}, {cached: "new"}))
        self.assertTrue(changed({cached: "old"}, {}))

    def test_failed_build_keeps_published_site_and_input_snapshot(self):
        self.sources.inputs = {"previous": "snapshot"}
        self.builder.render_pages = Mock(side_effect=RuntimeError("render failed"))
        generation = self.workspace / "previous"
        (generation / "site").mkdir(parents=True)
        (generation / "site/index.html").write_text("Last successful build")
        self.state.publish(generation)

        with self.assertLogs("preview", level="ERROR"):
            self.assertEqual(self.builder.build(0), "failed")

        self.assertEqual(self.state.generation, generation)
        self.assertEqual((self.state.published / "index.html").read_text(), "Last successful build")
        self.assertEqual(self.sources.inputs, {"previous": "snapshot"})
        self.assertEqual(self.state.error, "render failed")
        self.assertEqual(list(self.workspace.glob("build-*")), [])

    def test_inputs_changed_while_rendering_are_retried_without_publication(self):
        def render(generation, **kwargs):
            self.state.changed()
            return {"pages": {}, "versions": []}

        self.builder.render_pages = Mock(side_effect=render)
        self.assertEqual(self.builder.build(0), "retry")
        self.assertIsNone(self.state.generation)
        self.assertIsNone(self.sources.inputs)
        self.assertEqual(list(self.workspace.glob("build-*")), [])

    def test_snapshot_changes_are_caught_even_without_a_watcher_event(self):
        docs = self.root / "docs"
        docs.mkdir()
        page = docs / "index.md"
        page.write_text("Before")

        def render(generation, **kwargs):
            page.write_text("After")
            return {"pages": {}, "versions": []}

        self.builder.render_pages = Mock(side_effect=render)
        self.assertEqual(self.builder.build(0), "retry")
        self.assertIsNone(self.state.generation)
        self.assertIsNone(self.sources.inputs)
        self.assertEqual(list(self.workspace.glob("build-*")), [])


if __name__ == "__main__":
    unittest.main()
