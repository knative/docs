"""Resolve both kinds of snippet includes within the current page's release."""

import json
from pathlib import Path

from jinja2 import FileSystemLoader
from mkdocs.exceptions import PluginError
from mkdocs.plugins import event_priority

_default_root = None
_version_roots = {}


def on_config(config):
    global _default_root, _version_roots
    docs = Path(config.docs_dir)
    _default_root = docs / "snippets"
    _version_roots = {}
    snapshots = docs.parent / ".snippets"
    if snapshots.is_dir():
        # build.sh creates this private directory and the public version manifest
        # together. Never substitute checkout snippets for a missing snapshot.
        try:
            versions = json.loads((docs / "versions.json").read_text())
            for version in versions:
                directory = version["version"]
                if (not isinstance(directory, str) or not directory
                        or directory in (".", "..") or "/" in directory or "\\" in directory):
                    raise ValueError("Invalid snippet version directory")
                root = snapshots / directory
                if not root.is_dir():
                    raise ValueError(f"Missing snippet snapshot: {root}")
                _version_roots[directory] = root
        except (OSError, ValueError, KeyError, TypeError) as error:
            raise PluginError(f"Unable to configure versioned snippets: {error}") from error
    return config


@event_priority(100)
def on_page_markdown(markdown, *, page, config, files):
    # Use the physical source path: local_preview.py changes src_uri to docs/
    # while retaining the original versioned/ source for live reload/edit links.
    source = Path(page.file.abs_src_path).relative_to(config.docs_dir)
    root = _version_roots.get(source.parts[0], _default_root)

    # MkDocs constructs a new Markdown instance for each page after this event.
    options = config.mdx_configs.setdefault("pymdownx.snippets", {})
    options.update(base_path=[str(root)], check_paths=True, restrict_base_path=True)

    # A fresh loader also isolates Jinja's template cache between versions (and
    # live rebuilds). Nested Jinja includes use this same loader.
    config.plugins["macros"].env.loader = FileSystemLoader(str(root))
    return markdown
