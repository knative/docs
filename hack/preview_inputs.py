"""Track preview inputs and choose the smallest safe rebuild."""

import hashlib
from pathlib import Path

ASSET_ROOTS = ("docs/js/", "docs/stylesheets/", "docs/images/", "overrides/assets/")
ASSET_TYPES = {".js", ".css", ".map", ".png", ".jpg", ".jpeg", ".gif", ".svg",
               ".webp", ".ico", ".woff", ".woff2", ".ttf", ".otf"}


class PreviewInputs:
    def __init__(self, root, extra_paths=(), include_releases=False):
        self.root = Path(root)
        self.include_releases = include_releases
        self.extra_paths = [Path(path) for path in extra_paths]
        self.inputs = None
        self._digests = {}
        self.exclude_roots = []

    def watched(self):
        paths = [(self.root / name, True) for name in ("docs", "overrides", "hack", "config")]
        paths.append((self.root, False))
        paths.extend((p if p.is_dir() else p.parent, p.is_dir()) for p in self.extra_paths)
        return list(dict.fromkeys((path, recursive) for path, recursive in paths if path.exists()))

    def accepts(self, path):
        path = Path(path)
        if any(path == excluded or excluded in path.parents for excluded in self.exclude_roots):
            return False
        if any(part in {".git", ".venv", "node_modules", "__pycache__"} for part in path.parts):
            return False
        if path.suffix == ".pyc" or path.name == ".DS_Store":
            return False
        if any(path == extra or extra.is_dir() and extra in path.parents for extra in self.extra_paths):
            return True
        try:
            relative = path.relative_to(self.root)
        except ValueError:
            return False
        if relative.parts and relative.parts[0] in {"docs", "overrides", "config"}:
            return True
        if relative.parts and relative.parts[0] == "hack":
            return path.suffix == ".py"
        return len(relative.parts) == 1 and (
            path.name.startswith("mkdocs") and path.suffix in {".yml", ".yaml"}
            or path.name in {"pyproject.toml", "uv.lock", "requirements.txt"}
        )

    def snapshot(self):
        candidates = set()
        for path, recursive in self.watched():
            candidates.update(path.rglob("*") if recursive else path.iterdir())
        paths = [p for p in candidates if p.is_file() and self.accepts(p)]
        # Cached source snapshots are read-only, but refreshing them must invalidate HTML.
        cache = self.root / ".cache/docs-preview"
        if self.include_releases and cache.exists():
            paths.extend(p for branch in cache.glob("release-*") for p in branch.rglob("*") if p.is_file())
        result = {}
        for path in paths:
            try:
                stat = path.stat()
                stamp = (stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns, stat.st_ctime_ns)
                previous = self._digests.get(str(path))
                if previous and previous[0] == stamp:
                    result[str(path)] = previous[1]
                else:
                    digest = hashlib.sha256(path.read_bytes()).hexdigest()
                    result[str(path)] = digest
                    self._digests[str(path)] = (stamp, digest)
            except FileNotFoundError:
                pass  # An editor's atomic rename will generate another change event.
        self._digests = {path: data for path, data in self._digests.items() if path in result}
        return result

    def asset_path(self, path):
        relative = Path(path).relative_to(self.root).as_posix()
        if relative.startswith(ASSET_ROOTS) and Path(path).suffix.lower() in ASSET_TYPES:
            prefix = "overrides/" if relative.startswith("overrides/") else "docs/"
            destination = relative.removeprefix(prefix)
            if prefix == "overrides/" and (self.root / "docs" / destination).exists():
                return None  # Let MkDocs resolve a shadowing docs asset normally.
            return destination
        return None

    def change_kind(self, path, current):
        """Existing assets and Markdown are fast paths; everything else rebuilds all."""
        try:
            relative = Path(path).relative_to(self.root).as_posix()
        except ValueError:
            return "all"  # An explicitly watched external dependency.

        # New/deleted files can change navigation or output paths. Snippets can
        # affect any version, even though they are Markdown under docs/.
        if path not in self.inputs or path not in current:
            return "all"
        if relative.startswith("docs/snippets/"):
            return "all"
        if self.asset_path(path) is not None:
            return "assets"
        if relative.startswith("docs/") and Path(path).suffix == ".md":
            return "working"
        return "all"

    def plan(self, current):
        """Return a rebuild kind and paths changed since the last successful build.

        Mixed changes use the broadest rebuild: all > working > assets > none.
        Working builds also compare the rendered page index before publication;
        changed titles, metadata, URLs or anchors force a full rebuild there.
        """
        if self.inputs is None:
            return "all", set()
        changed = {path for path in self.inputs.keys() | current.keys()
                   if self.inputs.get(path) != current.get(path)}
        kinds = {self.change_kind(path, current) for path in changed}
        for kind in ("all", "working", "assets"):
            if kind in kinds:
                return kind, changed
        return "none", changed
