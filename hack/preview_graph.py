"""Conservative, output-aware dependencies for the development preview."""

from graphlib import TopologicalSorter
import hashlib
from pathlib import Path

ASSET_ROOTS = ("docs/js/", "docs/stylesheets/", "docs/images/", "overrides/assets/")
ASSET_TYPES = {".js", ".css", ".map", ".png", ".jpg", ".jpeg", ".gif", ".svg",
               ".webp", ".ico", ".woff", ".woff2", ".ttf", ".otf"}


class BuildGraph:
    dependencies = {
        "working-source": set(), "release-source": set(), "shared": set(),
        "templates": set(), "assets": set(),
        "working-pages": {"working-source", "shared"},
        "release-pages": {"release-source", "shared"},
        "page-index": {"working-pages", "release-pages"},
        "working-html": {"working-pages", "page-index", "templates"},
        "release-html": {"release-pages", "page-index", "templates"},
        "site": {"working-html", "release-html", "assets"},
    }

    def __init__(self, root, extra_paths=(), include_releases=False):
        self.root = Path(root)
        self.include_releases = include_releases
        self.extra_paths = [Path(path) for path in extra_paths]
        self.order = tuple(TopologicalSorter(self.dependencies).static_order())
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

    def plan(self, current):
        if self.inputs is None:
            return "all", set(), set(self.dependencies)
        changed = {path for path in self.inputs.keys() | current.keys()
                   if self.inputs.get(path) != current.get(path)}
        leaves = set()
        for path in changed:
            try:
                relative = Path(path).relative_to(self.root).as_posix()
            except ValueError:
                leaves.add("shared")
                continue
            if relative.startswith(".cache/docs-preview/"):
                leaves.add("release-source")
            elif relative.startswith("docs/snippets/"):
                leaves.add("shared")
            elif self.asset_path(path) is not None and path in self.inputs and path in current:
                leaves.add("assets")
            elif relative.startswith("docs/") and Path(path).suffix == ".md":
                leaves.add("working-source")
                if path not in self.inputs or path not in current:
                    leaves.add("page-index")
            elif relative.startswith("overrides/"):
                leaves.add("templates")
            else:
                leaves.add("shared")
        affected = set(leaves)
        for node in self.order:
            # An index is a semantic boundary: body edits need not change its output.
            if any(dep in affected and (dep != "page-index" or dep in leaves)
                   for dep in self.dependencies[node]):
                affected.add(node)
        kind = ("all" if "release-html" in affected else "working"
                if "working-html" in affected else "assets" if changed else "none")
        return kind, changed, affected
