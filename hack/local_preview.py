"""Preview this checkout at production-like URLs without assembling releases."""

from mkdocs.plugins import event_priority
from mkdocs.structure.files import File, Files


def local_path(path):
    return "docs/" + path[len("versioned/"):] if path.startswith("versioned/") else path


def on_config(config):
    # Keep historical redirects useful with the local /docs/ output layout.
    redirects = config.plugins["redirects"].config
    redirects["redirect_maps"] = {
        local_path(source): local_path(target)
        for source, target in redirects["redirect_maps"].items()
    }
    return config


@event_priority(100)
def on_files(files, config):
    # Retain physical source paths for live reload, snippets, and edit links,
    # but publish the checkout's versioned/ tree at /docs/, like the live site.
    # Run before navigation/redirect plugins index the source paths.
    for file in files:
        if file.src_uri.startswith("versioned/"):
            source_path = file.abs_src_path
            file.edit_uri = file.src_uri
            file.dest_uri = local_path(file.dest_uri)
            file.src_uri = local_path(file.src_uri)
            file.abs_src_path = source_path
            file.__dict__.pop("url", None)

    files = Files(list(files))  # Reindex the renamed source paths.
    files.append(File.generated(config, ".nav.yml", content="""nav:
  - Docs: docs
  - About: about
  - Blog: blog
  - Community: community
"""))
    return files
