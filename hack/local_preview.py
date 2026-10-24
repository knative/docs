"""Preview live working docs, optionally alongside cached release snapshots."""

import json

from mkdocs.plugins import event_priority
from mkdocs.structure.files import File, Files

from preview_releases import releases

_all_versions = False
_releases = []


def local_path(path):
    directory = "development" if _all_versions else "docs"
    return directory + "/" + path[len("versioned/"):] if path.startswith("versioned/") else path


def on_config(config):
    global _all_versions, _releases
    _all_versions = config.extra.get("preview_all_versions", False)
    _releases = releases() if _all_versions else []
    redirects = config.plugins["redirects"].config
    redirects["redirect_maps"] = {
        local_path(source): local_path(target)
        for source, target in redirects["redirect_maps"].items()
    }
    return config


@event_priority(100)
def on_files(files, config):
    # Keep live physical paths, but publish the working copy at its preview URL.
    for file in files:
        if file.src_uri.startswith("versioned/"):
            source_path = file.abs_src_path
            file.edit_uri = file.src_uri
            file.dest_uri = local_path(file.dest_uri)
            file.src_uri = local_path(file.src_uri)
            file.abs_src_path = source_path
            file.__dict__.pop("url", None)
    files = Files(list(files))

    navigation = ["  - Docs: docs"]
    if _all_versions:
        manifest = []
        for release in _releases:
            directory = release["version"]
            for path in release["path"].rglob("*"):
                if path.is_file():
                    relative = path.relative_to(release["path"]).as_posix()
                    file = File.generated(config, f"{directory}/{relative}", abs_src_path=str(path))
                    source = release["source"].removeprefix("docs/")
                    file.edit_uri = f"{source}/{relative}" if source != "docs" else relative
                    files.append(file)
            manifest.append({"version": directory, "title": release["title"]})
            if directory != "docs":
                navigation.append(f"  - {release['title']}: {directory}")
        manifest.append({"version": "development", "title": "(Pre-release)"})
        files.append(File.generated(config, "versions.json", content=json.dumps(manifest)))
        navigation.insert(1, "  - Pre-release: development")

    navigation.extend(["  - About: about", "  - Blog: blog", "  - Community: community"])
    files.append(File.generated(config, ".nav.yml", content="nav:\n" + "\n".join(navigation) + "\n"))
    return files


@event_priority(25)
def on_page_markdown(markdown, *, page, config, files):
    # Run after inherited .meta.yml metadata and before macros render includes.
    directory = page.file.src_uri.split("/", 1)[0]
    working = "development" if _all_versions else "docs"
    if directory == working:
        page.meta.update(local_preview=True, version=working, samples_branch="main",
                         doc_base="/docs/versioned/", version_warning=False)
        page.meta.pop("knative_version", None)
    for index, release in enumerate(_releases):
        if directory == release["version"]:
            page.meta.update(
                local_preview=True, version=release["title"],
                knative_version=release["title"].removeprefix("v") + ".0",
                samples_branch=release["branch"], doc_base=f"/{release['source']}/",
                version_warning=index > 0, search={"exclude": True},
            )
            break
    return markdown
