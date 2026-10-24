"""Fresh-process MkDocs worker for the development build graph (not dirty reload)."""

import json
import logging
import sys

from mkdocs.commands.build import build
from mkdocs.config import load_config


class CacheNotice(logging.Filter):
    def filter(self, record):
        if record.getMessage().startswith("A 'dirty' build is being performed"):
            # Only explicitly cached releases are skipped. All working/global
            # pages render from scratch, so the generic approximation warning
            # does not describe this partitioned build.
            record.msg = "Reusing complete release output; rendering working documentation."
            record.args = ()
            record.levelno = logging.INFO
            record.levelname = "INFO"
        return True


def main():
    request = json.load(sys.stdin)
    logging.basicConfig(level=request.get("log_level", logging.INFO),
                        format="%(levelname)-7s - %(message)s")
    config = load_config(request["config"], site_dir=request["site"], site_url=request["url"])
    if request.get("strict"):
        config.strict = True
    plan = {"index_out": request["index_out"]}
    if request.get("cache_index"):
        plan["cache_index"] = request["cache_index"]
        logging.getLogger("mkdocs.commands.build").addFilter(CacheNotice())
    config.extra["preview_build"] = plan
    cached = "cache_index" in plan
    config.plugins.on_startup(command="serve", dirty=cached)
    try:
        # Working/global HTML starts empty in the staging directory. The dirty
        # switch lets only our explicit CachedFile views skip release rendering;
        # it is not used as a timestamp-based live-reload policy.
        build(config, dirty=cached, serve_url=request["url"])
    finally:
        config.plugins.on_shutdown()


if __name__ == "__main__":
    main()
