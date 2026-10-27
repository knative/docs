"""Explicitly cached release pages for normal MkDocs builds of the working copy."""

import json
from pathlib import Path

from mkdocs.structure.files import File
from mkdocs.structure.pages import Page


class CachedPage(Page):
    """A complete navigation/anchor view; intentionally not re-rendered."""


class CachedFile(File):
    def is_modified(self):
        return False


def restore_page(original, config, entry):
    file = CachedFile(original.src_uri, original.src_dir, config.site_dir,
                      config.use_directory_urls, dest_uri=entry["dest_uri"])
    file.abs_src_path = original.abs_src_path
    file.edit_uri = original.edit_uri
    page = CachedPage(entry["title"], file, config)
    page.meta = entry["meta"]
    page.present_anchor_ids = set(entry["anchors"])
    return file


def index_pages(files):
    return {
        file.src_uri: {
            "url": file.url, "dest_uri": file.dest_uri,
            "title": str(file.page.title or ""),
            "anchors": sorted(file.page.present_anchor_ids),
            "meta": file.page.meta, "cached": isinstance(file, CachedFile),
        }
        for file in files
        if file.page is not None and file.page.present_anchor_ids is not None
    }


def signature(index):
    """Only semantic page/index changes invalidate other versions' selectors."""
    return {source: {key: page[key] for key in ("url", "dest_uri", "title", "anchors", "meta")}
            for source, page in index["pages"].items()}


def load_plan(config):
    plan = config.extra.get("preview_build", {})
    path = plan.get("cache_index")
    return plan, json.loads(Path(path).read_text())["pages"] if path else {}
