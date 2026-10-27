"""Build version-selector links without depending on Material's versioning JS."""

import json

from mkdocs.exceptions import PluginError

_versions = []
_pages = {}


def on_env(env, *, config, files):
    # All pages have been rendered by this event. Reset on every live rebuild.
    global _versions, _pages
    _versions = []
    _pages = {file.url: file.page for file in files.documentation_pages()}
    manifest = files.get_file_from_path("versions.json")
    if manifest is None:
        return env

    try:
        versions = json.loads(manifest.content_string)
    except (ValueError, OSError) as error:
        raise PluginError(f"Unable to read versions.json: {error}") from error
    if not isinstance(versions, list):
        raise PluginError("versions.json must contain a list of versions")
    for version in versions:
        if not isinstance(version, dict):
            raise PluginError("Each versions.json entry must be an object")
        directory = version.get("version")
        if (not isinstance(directory, str) or not directory
                or directory in (".", "..") or "/" in directory or "\\" in directory):
            raise PluginError("Each version must name a documentation directory")
        title = version.get("title", directory)
        if not isinstance(title, str):
            raise PluginError("Version titles must be strings")
        if any(item["version"] == directory for item in _versions):
            raise PluginError(f"Duplicate version directory: {directory}")
        _versions.append({"version": directory, "title": title})
    return env


def on_page_context(context, *, page, config, nav):
    context["version_selector"] = None
    if not _versions:
        return context
    current = next((version for version in _versions
                    if page.url.startswith(version["version"] + "/")), None)
    if current is None:
        return context  # Homepage, blog, community, and other unversioned pages.

    suffix = page.url[len(current["version"]) + 1:]
    options = []
    for version in _versions:
        directory = version["version"] + "/"
        target = _pages.get(directory + suffix)
        homepage = directory if config.use_directory_urls else directory + "index.html"
        options.append({
            "title": version["title"],
            "url": target.url if target else homepage,
            "current": version == current,
            "same_page": target is not None,
            "anchors": sorted((page.present_anchor_ids or set())
                              & (target.present_anchor_ids or set())) if target else [],
        })
    context["version_selector"] = {"title": current["title"], "options": options}
    return context
