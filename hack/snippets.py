"""Resolve both kinds of snippet includes within the current page's release."""

import json
from pathlib import Path

from jinja2 import FileSystemLoader
from mkdocs.exceptions import PluginError
from mkdocs.plugins import event_priority

# MkDocs adds this hook's directory to sys.path while loading it.
from docs_versions import is_version_directory

_default_root = None
_version_roots = {}
_loaders = {}


def on_config(config):
    # MkDocs reloads the config on every live rebuild, so this also resets the
    # Jinja loaders (and therefore Jinja's template cache) between rebuilds.
    global _default_root, _version_roots, _loaders
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
                if not is_version_directory(directory):
                    raise ValueError(f"Invalid snippet version directory: {directory!r}")
                root = snapshots / directory
                if not root.is_dir():
                    raise ValueError(f"Missing snippet snapshot: {root}")
                _version_roots[directory] = root
        except (OSError, ValueError, KeyError, TypeError) as error:
            raise PluginError(f"Unable to configure versioned snippets: {error}") from error

    # One loader per root keeps Jinja's template cache per version.
    _loaders = {root: FileSystemLoader(str(root))
                for root in (_default_root, *_version_roots.values())}

    # mkdocs-macros reports on_error_fail by calling exit(), which `mkdocs serve`
    # does not catch. Raise a normal build error instead so builds still fail
    # but the live preview server reports the error and recovers.
    macros = config.plugins["macros"]
    render = type(macros).render

    def fail_build(self, *args, **kwargs):
        try:
            return render(self, *args, **kwargs)
        except SystemExit as error:
            raise PluginError(f"Macro rendering failed in {self.page.file.src_path}") from error

    macros.render = fail_build.__get__(macros)
    return config


def _snippet_root(page, docs_dir):
    # Use the physical source path: local_preview.py changes src_uri to docs/
    # while retaining the original versioned/ source for live reload/edit links.
    # Generated pages may live outside docs_dir; they are never versioned.
    if not page.file.abs_src_path:
        return _default_root
    try:
        source = Path(page.file.abs_src_path).relative_to(docs_dir)
    except ValueError:
        return _default_root
    return _version_roots.get(source.parts[0], _default_root)


@event_priority(100)
def on_page_markdown(markdown, *, page, config, files):
    root = _snippet_root(page, config.docs_dir)

    # MkDocs constructs a new Markdown instance for each page after this event.
    options = config.mdx_configs.setdefault("pymdownx.snippets", {})
    options.update(base_path=[str(root)], check_paths=True, restrict_base_path=True)

    # Nested Jinja includes use this same loader, so they stay in this version.
    config.plugins["macros"].env.loader = _loaders[root]
    return markdown
