"""Cache release docs for local preview, using the production release list."""

import io
import json
import logging
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import tarfile
import tempfile
from urllib.request import urlopen

from mkdocs.exceptions import PluginError

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / ".cache" / "docs-preview"
log = logging.getLogger("mkdocs")


def releases():
    versions = (ROOT / "config/versions.txt").read_text().splitlines()
    if (not versions or len(set(versions)) != len(versions)
            or any(not re.fullmatch(r"\d+\.\d+", v) for v in versions)):
        raise PluginError("config/versions.txt must list release versions, newest first")
    result = []
    for index, version in enumerate(versions):
        branch = f"release-{version}"
        destination = CACHE / branch
        marker = destination / "source.json"
        if not marker.exists():
            log.info("Preparing local preview of %s (cached after the first run)", branch)
            _prepare(branch, destination)
        result.append({
            "version": "docs" if index == 0 else f"v{version}-docs",
            "title": f"v{version}",
            "branch": branch,
            "path": destination / "docs",
            "source": json.loads(marker.read_text()),
        })
    return result


def _prepare(branch, destination):
    # Prefer already-fetched refs, without changing the user's Git repository.
    archive = None
    for prefix in ("refs/remotes/upstream/", "refs/remotes/origin/", "refs/heads/"):
        ref = prefix + branch
        found = subprocess.run(
            ["git", "rev-parse", "--verify", "--quiet", ref], cwd=ROOT,
            capture_output=True, text=True,
        )
        if found.returncode == 0:
            source = "docs/versioned"
            exists = subprocess.run(
                ["git", "cat-file", "-e", f"{ref}:{source}"], cwd=ROOT,
                capture_output=True,
            )
            if exists.returncode:
                source = "docs"
            archive = subprocess.check_output(["git", "archive", ref, source], cwd=ROOT)
            break
    if archive is None:
        # Public release archives need no GitHub token or SSH credentials.
        url = f"https://github.com/knative/docs/archive/refs/heads/{branch}.tar.gz"
        try:
            with urlopen(url, timeout=60) as response:
                archive = response.read()
        except OSError as error:
            raise PluginError(f"Unable to download {branch}: {error}") from error

    CACHE.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=CACHE) as temporary:
        stage = Path(temporary)
        with tarfile.open(fileobj=io.BytesIO(archive), mode="r:*") as tar:
            members = [m for m in tar.getmembers() if m.isfile()]
            prefixes = []
            for member in members:
                parts = PurePosixPath(member.name).parts
                if "docs" in parts:
                    index = parts.index("docs")
                    prefixes.append(parts[:index + 1])
            if not prefixes:
                raise PluginError(f"No documentation found in {branch}")
            prefix = min(prefixes, key=len)
            versioned = prefix + ("versioned",)
            if any(PurePosixPath(m.name).parts[:len(versioned)] == versioned for m in members):
                prefix = versioned
            for member in members:
                parts = PurePosixPath(member.name).parts
                if parts[:len(prefix)] != prefix:
                    continue
                relative = parts[len(prefix):]
                if not relative or ".." in relative:
                    raise PluginError(f"Unsafe archive path: {member.name}")
                target = stage.joinpath("docs", *relative)
                target.parent.mkdir(parents=True, exist_ok=True)
                with tar.extractfile(member) as source_file, target.open("wb") as output:
                    shutil.copyfileobj(source_file, output)
        if not (stage / "docs").is_dir():
            raise PluginError(f"No documentation found in {branch}")
        source = "docs/versioned" if prefix[-1] == "versioned" else "docs"
        (stage / "source.json").write_text(json.dumps(source))
        if destination.exists():
            shutil.rmtree(destination)
        stage.rename(destination)
