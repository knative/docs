"""Incremental builds served by MkDocs' standard live-reload server."""

import argparse
import json
import logging
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
import time

from mkdocs.config import load_config
from mkdocs.livereload import LiveReloadServer

from preview_cache import signature
from preview_inputs import PreviewInputs

ROOT = Path(__file__).resolve().parent.parent
log = logging.getLogger("preview")


def link_or_copy(source, destination):
    try:
        os.link(source, destination)
    except OSError:
        shutil.copy2(source, destination)


class Builder:
    def __init__(self, workspace, sources, config_file, url, strict=False, log_level=logging.INFO):
        self.workspace = workspace
        self.published = workspace / "live"
        self.generation = None
        self.sources = sources
        self.config_file, self.url = str(config_file), url
        self.strict, self.log_level = strict, log_level
        self.index = None

    def release_pages(self):
        versions = {v["version"] for v in self.index["versions"]} - {"development"}
        return [page for page in self.index["pages"].values()
                if page["url"].split("/", 1)[0] in versions]

    def cache_valid(self, all_pages=False):
        try:
            if json.loads((self.generation / "pages.json").read_text()) != self.index:
                return False
            pages = self.index["pages"].values() if all_pages else self.release_pages()
            return all((self.generation / "site" / page["dest_uri"]).is_file()
                       for page in pages)
        except (OSError, ValueError):
            return False

    def render_pages(self, generation, reuse_releases=False):
        """Run MkDocs in a fresh process, optionally seeding it with release HTML."""
        request = {
            "config": self.config_file, "site": str(generation / "site"),
            "url": self.url, "index_out": str(generation / "pages.json"),
            "strict": self.strict, "log_level": self.log_level,
        }
        if reuse_releases:
            request["cache_index"] = str(self.generation / "pages.json")
            # Only HTML whose CachedFile explicitly skips rendering is hard-linked.
            # Static assets are copied normally by MkDocs into this fresh generation.
            for page in self.release_pages():
                destination = generation / "site" / page["dest_uri"]
                destination.parent.mkdir(parents=True, exist_ok=True)
                link_or_copy(self.generation / "site" / page["dest_uri"], destination)
        process = subprocess.Popen(
            [sys.executable, "-u", str(ROOT / "hack/dev_build.py")], cwd=ROOT,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
        )
        lines = []
        try:
            process.stdin.write(json.dumps(request))
            process.stdin.close()
            for line in process.stdout:
                print(line, end="", flush=True)
                lines.append(line)
            status = process.wait()
            if status:
                raise RuntimeError(f"MkDocs worker exited with status {status}.\n" + "".join(lines[-40:]))
        except BaseException:
            if process.poll() is None:
                process.send_signal(signal.SIGINT)
                try:
                    process.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
            raise
        return json.loads((generation / "pages.json").read_text())

    def copy_assets(self, generation, changed):
        """Copy the published site and replace only changed assets, without MkDocs."""
        shutil.copytree(self.generation / "site", generation / "site",
                        copy_function=link_or_copy)
        shutil.copy2(self.generation / "pages.json", generation / "pages.json")
        for source in changed:
            destination = generation / "site" / self.sources.asset_path(source)
            destination.parent.mkdir(parents=True, exist_ok=True)
            # Break the hard link before writing; never mutate published output.
            with tempfile.NamedTemporaryFile(dir=destination.parent, delete=False) as output:
                temporary = Path(output.name)
            shutil.copy2(source, temporary)
            os.replace(temporary, destination)
        return self.index

    def inputs_changed_during_build(self, before, after):
        """Ignore release sources first downloaded by the worker itself."""
        cache = self.sources.root / ".cache/docs-preview"
        for path in before.keys() | after.keys():
            if before.get(path) == after.get(path):
                continue
            if path not in before and Path(path).is_relative_to(cache):
                continue
            return True
        return False

    def publish(self, generation):
        """Switch the served directory only after a complete, successful build."""
        link = self.workspace / "next"
        link.symlink_to(generation / "site", target_is_directory=True)
        os.replace(link, self.published)
        previous = self.generation
        self.generation = generation
        if previous is not None:
            shutil.rmtree(previous, ignore_errors=True)

    def build(self):
        """MkDocs callback: retry changing inputs; let MkDocs handle build errors."""
        while self.build_once() == "retry":
            time.sleep(.3)

    def build_once(self):
        """Plan, render, validate, then publish. Advance caches only on success."""
        before = self.sources.snapshot()
        kind, changed = self.sources.plan(before)
        if kind == "none":
            if self.index is None or self.cache_valid(all_pages=True):
                return "none"
            log.info("Output cache is incomplete; rebuilding all versions.")
            kind = "all"
        log.info("Building %s (%d changed inputs).", kind, len(changed))
        started = time.perf_counter()
        generation = Path(tempfile.mkdtemp(prefix="build-", dir=self.workspace))
        published = False
        try:
            if kind in {"working", "assets"} and not self.cache_valid(all_pages=kind == "assets"):
                log.info("Output cache is incomplete; rebuilding all versions.")
                kind = "all"

            reuse_releases = (kind == "working" and self.index is not None
                              and len(self.index["versions"]) > 1)
            if kind == "assets":
                index = self.copy_assets(generation, changed)
            else:
                index = self.render_pages(generation, reuse_releases=reuse_releases)
            if reuse_releases and signature(index) != signature(self.index):
                log.info("Page/anchor index changed; rebuilding all versions before publishing.")
                shutil.rmtree(generation)
                generation.mkdir()
                index = self.render_pages(generation)
                kind = "all"

            after = self.sources.snapshot()
            if self.inputs_changed_during_build(before, after):
                log.info("Inputs changed during the build; retrying without publishing.")
                return "retry"
            self.publish(generation)
            published = True
            self.sources.inputs = after
            self.index = index
            rendered = 0
            if kind != "assets":
                rendered = sum(not page["cached"] for page in index["pages"].values())
            log.info("Published %s in %.2fs (%d pages rendered).", kind,
                     time.perf_counter() - started, rendered)
            return "published"
        finally:
            if not published:
                shutil.rmtree(generation, ignore_errors=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-f", "--config-file", default="mkdocs.local.yml")
    parser.add_argument("-a", "--dev-addr")
    parser.add_argument("-w", "--watch", action="append", default=[])
    parser.add_argument("--strict", action="store_true")
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("-q", "--quiet", action="store_true")
    parser.add_argument("--open", action="store_true")
    parser.add_argument("--dirtyreload", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()

    def stop(signum, frame):
        raise KeyboardInterrupt

    signal.signal(signal.SIGTERM, stop)
    if hasattr(signal, "SIGHUP"):
        signal.signal(signal.SIGHUP, stop)
    level = logging.DEBUG if args.verbose else logging.WARNING if args.quiet else logging.INFO
    logging.basicConfig(level=level, format="%(levelname)-7s - %(message)s")
    os.environ["NO_MKDOCS_2_WARNING"] = "1"
    config_file = Path(args.config_file).resolve()
    kwargs = {"dev_addr": args.dev_addr} if args.dev_addr else {}
    config = load_config(str(config_file), **kwargs)
    host, port = config.dev_addr
    address = f"[{host}]" if ":" in host else host
    url = f"http://{address}:{port}/"
    extra = [Path(path).absolute() for path in args.watch]
    sources = PreviewInputs(
        ROOT, [*config.watch, *extra, config_file, Path(config.docs_dir)],
        include_releases=config.extra.get("preview_all_versions", False),
    )
    if args.dirtyreload:
        log.info("Incremental reload is automatic; --dirtyreload is no longer needed.")
    with tempfile.TemporaryDirectory(prefix="knative-live-") as temporary:
        workspace = Path(temporary)
        sources.exclude_roots.append(workspace)
        builder = Builder(workspace, sources, config_file, url, args.strict, level)
        server = LiveReloadServer(
            builder=builder.build, host=host, port=port, root=str(builder.published),
        )
        try:
            builder.build()
            for path, recursive in sources.watched():
                server.watch(str(path), recursive=recursive)
            log.info("Live preview: %s%s/", url, "development" if sources.include_releases else "docs")
            server.serve(open_in_browser=args.open)
        except KeyboardInterrupt:
            pass
        finally:
            server.shutdown()


if __name__ == "__main__":
    main()
