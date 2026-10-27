"""Incremental preview server; render in a worker, then publish completed output."""

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import io
import json
import logging
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import threading
import time
from urllib.parse import parse_qs, urlsplit
import webbrowser

from mkdocs.config import load_config
from watchdog.events import FileSystemEventHandler
from watchdog.observers.polling import PollingObserver

from preview_cache import signature
from preview_inputs import PreviewInputs

ROOT = Path(__file__).resolve().parent.parent
log = logging.getLogger("preview")

# The server injects this only into served HTML, never into production output.
RELOAD_SCRIPT = r"""
(async () => {
  let revision = Number(document.currentScript.dataset.revision);
  let initial = true;
  while (true) {
    try {
      const response = await fetch(`/__preview_changes?revision=${revision}&initial=${initial ? 1 : 0}`, {cache: "no-store"});
      if (!response.ok) throw new Error(response.status);
      const update = await response.json();
      if (update.closed) throw new Error("Preview restarting");
      initial = false;
      if (update.error) {
        let overlay = document.getElementById("__preview_error");
        if (!overlay) {
          overlay = document.createElement("pre");
          overlay.id = "__preview_error";
          overlay.style.cssText = "position:fixed;inset:auto 0 0;z-index:2147483647;max-height:40vh;overflow:auto;margin:0;padding:1rem;background:#7f1d1d;color:white;white-space:pre-wrap;font:14px monospace";
          document.body.append(overlay);
        }
        overlay.textContent = "Build failed — showing the last successful build.\n\n" + update.error;
        revision = update.revision;
      } else if (update.revision !== revision) {
        location.reload();
        return;
      }
    } catch {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
})();
"""


class State:
    def __init__(self, workspace):
        self.workspace = workspace
        self.published = workspace / "live"
        self.generation = None
        self.condition = threading.Condition()
        self.source_revision = 0
        self.revision = int(time.time() * 1000)
        self.error = None
        self.closed = False

    def changed(self):
        with self.condition:
            self.source_revision += 1
            self.condition.notify_all()

    def publish(self, generation=None, error=None):
        with self.condition:
            previous = self.generation
            if generation is not None:
                link = self.workspace / "next"
                link.unlink(missing_ok=True)
                link.symlink_to(generation / "site", target_is_directory=True)
                os.replace(link, self.published)
                self.generation = generation
            self.error = error
            self.revision = max(self.revision + 1, int(time.time() * 1000))
            self.condition.notify_all()
        if generation is not None and previous is not None:
            shutil.rmtree(previous, ignore_errors=True)

    def wait(self, processed):
        with self.condition:
            self.condition.wait_for(lambda: self.source_revision != processed or self.closed)
            while not self.closed:
                current = self.source_revision
                if not self.condition.wait_for(lambda: self.source_revision != current, timeout=.3):
                    return current
            return self.source_revision


class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, format, *args):
        # Build summaries matter more than hundreds of successful asset requests.
        if len(args) > 1 and str(args[1]).isdigit() and int(args[1]) >= 400:
            log.warning(format, *args)

    def list_directory(self, path):
        self.send_error(404)
        return None

    def reply(self, body, content_type):
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        try:
            request = urlsplit(self.path)
            state = self.server.state
            if request.path == "/__preview_reload.js":
                self.reply(RELOAD_SCRIPT.encode(), "application/javascript; charset=utf-8")
            elif request.path == "/__preview_changes":
                query = parse_qs(request.query)
                try:
                    revision = int(query.get("revision", ["-1"])[0])
                except ValueError:
                    self.send_error(400)
                    return
                with state.condition:
                    if query.get("initial") != ["1"]:
                        state.condition.wait_for(
                            lambda: state.revision != revision or state.closed, timeout=30)
                    body = json.dumps({"revision": state.revision, "error": state.error,
                                       "closed": state.closed}).encode()
                self.reply(body, "application/json")
            else:
                # Timestamp granularity must not make rapid asset edits return a stale 304.
                if "If-Modified-Since" in self.headers:
                    del self.headers["If-Modified-Since"]
                super().do_GET()
        except (BrokenPipeError, ConnectionResetError):
            pass  # Browsers cancel long polls and asset requests during navigation.

    def send_head(self):
        state = self.server.state
        path = Path(self.translate_path(self.path))
        if self.path.split("?", 1)[0].endswith("/"):
            path = path / "index.html"
        if path.suffix == ".html":
            with state.condition:
                try:
                    content = path.read_bytes()
                except OSError:
                    return super().send_head()
                script = (f'<script src="/__preview_reload.js" '
                          f'data-revision="{state.revision}"></script>').encode()
            end = content.rfind(b"</body>")
            content = content[:end] + script + content[end:] if end >= 0 else content + script
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            return io.BytesIO(content)
        # Open static files against the same generation as publication. Their
        # descriptors remain valid even when the previous directory is removed.
        with state.condition:
            return super().send_head()


def link_or_copy(source, destination):
    try:
        os.link(source, destination)
    except OSError:
        shutil.copy2(source, destination)


class Builder:
    def __init__(self, state, sources, config_file, url, strict=False, log_level=logging.INFO):
        self.state = state
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
            if json.loads((self.state.generation / "pages.json").read_text()) != self.index:
                return False
            pages = self.index["pages"].values() if all_pages else self.release_pages()
            return all((self.state.generation / "site" / page["dest_uri"]).is_file()
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
            request["cache_index"] = str(self.state.generation / "pages.json")
            # Only HTML whose CachedFile explicitly skips rendering is hard-linked.
            # Static assets are copied normally by MkDocs into this fresh generation.
            for page in self.release_pages():
                destination = generation / "site" / page["dest_uri"]
                destination.parent.mkdir(parents=True, exist_ok=True)
                link_or_copy(self.state.generation / "site" / page["dest_uri"], destination)
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
        shutil.copytree(self.state.generation / "site", generation / "site",
                        copy_function=link_or_copy)
        shutil.copy2(self.state.generation / "pages.json", generation / "pages.json")
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

    def build(self, revision):
        """Plan, render, validate, then publish. Never publish changed inputs.

        Only a successful publication advances the input snapshot and page index.
        A failed or superseded build leaves the last successful site untouched.
        """
        before = self.sources.snapshot()
        kind, changed = self.sources.plan(before)
        if kind == "none":
            if self.index is not None and not self.cache_valid(all_pages=True):
                kind = "all"
                log.info("Output cache is incomplete; rebuilding all versions.")
            else:
                if self.state.error:
                    self.state.publish()  # Restored inputs already match the last good output.
                    log.info("Inputs restored; the last successful build is current again.")
                return "none"
        log.info("Building %s (%d changed inputs).", kind, len(changed))
        started = time.perf_counter()
        generation = Path(tempfile.mkdtemp(prefix="build-", dir=self.state.workspace))
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
            with self.state.condition:
                if revision != self.state.source_revision:
                    log.info("Inputs changed during the build; retrying without publishing.")
                    return "retry"
            if reuse_releases and signature(index) != signature(self.index):
                log.info("Page/anchor index changed; rebuilding all versions before publishing.")
                shutil.rmtree(generation)
                generation.mkdir()
                index = self.render_pages(generation)
                kind = "all"

            rendered = 0
            if kind != "assets":
                rendered = sum(not page["cached"] for page in index["pages"].values())
            after = self.sources.snapshot()
            unstable = self.inputs_changed_during_build(before, after)
            with self.state.condition:
                if revision != self.state.source_revision or unstable:
                    log.info("Inputs changed during the build; retrying without publishing.")
                    return "retry"
                self.state.publish(generation)
                published = True
                self.sources.inputs = after
                self.index = index
            log.info("Published %s in %.2fs (%d pages rendered).", kind,
                     time.perf_counter() - started, rendered)
            return "published"
        except Exception as error:
            with self.state.condition:
                if revision != self.state.source_revision:
                    log.info("Inputs changed after a failed build; retrying the latest inputs.")
                    return "retry"
            log.error("Build failed; keeping the last successful site.\n%s", error)
            self.state.publish(error=str(error))
            return "failed"
        finally:
            if not published:
                shutil.rmtree(generation, ignore_errors=True)


class Changes(FileSystemEventHandler):
    def __init__(self, state, sources):
        self.state = state
        self.sources = sources

    def on_any_event(self, event):
        if event.event_type not in {"modified", "created", "deleted", "moved"}:
            return
        if event.is_directory and event.event_type == "modified":
            return
        paths = (event.src_path, getattr(event, "dest_path", ""))
        if any(self.sources.accepts(path) for path in paths if path):
            self.state.changed()


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
        state = State(Path(temporary))
        sources.exclude_roots.append(state.workspace)
        builder = Builder(state, sources, config_file, url, args.strict, level)
        observer = PollingObserver(timeout=.3)
        for path, recursive in sources.watched():
            observer.schedule(Changes(state, sources), str(path), recursive=recursive)
        observer.start()
        server = thread = None
        try:
            while True:
                revision = state.source_revision
                result = builder.build(revision)
                if result != "retry":
                    break
                state.wait(revision - 1)
            if result == "failed":
                raise SystemExit(1)
            handler = partial(Handler, directory=str(state.published))
            class Server(ThreadingHTTPServer):
                address_family = socket.AF_INET6 if ":" in host else socket.AF_INET

            server = Server((host, port), handler)
            server.state = state
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            log.info("Serving on %s", url)
            log.info("Live preview: %s%s/", url, "development" if len(builder.index["versions"]) > 1 else "docs")
            if args.open:
                webbrowser.open(url + ("development/" if len(builder.index["versions"]) > 1 else "docs/"))
            processed = revision
            while True:
                revision = state.wait(processed)
                result = builder.build(revision)
                processed = revision - 1 if result == "retry" else revision
        except KeyboardInterrupt:
            pass
        finally:
            with state.condition:
                state.closed = True
                state.condition.notify_all()
            observer.stop()
            observer.join()
            if server is not None:
                server.shutdown()
                server.server_close()
                thread.join()


if __name__ == "__main__":
    main()
