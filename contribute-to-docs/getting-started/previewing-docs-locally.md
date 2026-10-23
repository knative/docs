# Previewing the website locally

The Knative website uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).
For everyday edits, preview just your checkout instead of assembling every
published release. You don't need a Kubernetes cluster, Node.js, a GitHub token,
or release branches.

## Quick start: Python

You need Python 3 with `venv` and `pip` installed. On Debian/Ubuntu, you may need
the `python3-venv` package. Run these commands from a clone of this repository:

```bash
./hack/mkdocs.sh
```

The first run creates `.venv/` and installs `requirements.txt` (internet access is
required). Later runs reuse that environment, installing dependencies again only
when `requirements.txt` changes. You don't need to activate the virtual environment
or install packages globally.

Open <http://127.0.0.1:8000/docs/>. Edit Markdown under `docs/`, save, and the
browser reloads automatically. Press **Ctrl+C** to stop.

### Where to edit

- Product documentation: `docs/versioned/`
- Product navigation: `docs/versioned/.nav.yml`
- Shared snippets: `docs/snippets/`
- Blog, community, and about pages: their respective directories under `docs/`
- Website templates and styles: `overrides/` and `docs/stylesheets/`

The preview serves `docs/versioned/` at `/docs/`, so the homepage and Docs header
links work as they do on the published website. It reads your working files
directly; there is no copy step between editing and previewing.

### Useful commands

```bash
# Use another port
./hack/mkdocs.sh serve --dev-addr 127.0.0.1:8001

# Faster reloads for edits to a single existing page
./hack/mkdocs.sh serve --dirtyreload

# Build this checkout without starting a server (output: site/)
./hack/mkdocs.sh build

# Treat build warnings as errors
./hack/mkdocs.sh build --strict

# Refresh Python dependencies explicitly
./hack/mkdocs.sh setup
```

Use normal reloads when adding/deleting pages or changing navigation, snippets,
or templates: `--dirtyreload` can leave other pages stale.

To use an existing Python environment instead of the helper:

```bash
python -m pip install -r requirements.txt
python -m mkdocs serve --livereload --config-file mkdocs.local.yml
```

### Troubleshooting

- **Port already in use:** choose another port with `--dev-addr` as shown above.
- **Python environment no longer works after a Python upgrade:** remove the
  generated `.venv/` directory and rerun `./hack/mkdocs.sh`.
- **Dependency installation fails:** ensure your Python has `venv` and `pip`.
  Set `PYTHON=/path/to/python3` when first running the helper to select a different
  interpreter.
- **Unexpected versioned artifact links or GitHub API errors:** unset
  `KNATIVE_VERSION` for the normal development preview. By default, artifact
  macros link to nightly downloads without querying GitHub releases.

## Alternative: Docker

If you prefer not to install Python, use a Docker-compatible engine such as
[Docker Desktop](https://www.docker.com/products/docker-desktop) or
[colima](https://github.com/abiosoft/colima):

```bash
./hack/docker/run.sh

# Optional: choose a different host port
./hack/docker/run.sh 8001
```

Open <http://127.0.0.1:8000/docs/> (or the port you selected). Your checkout is
mounted into the container and changes reload automatically. Press **Ctrl+C** to
stop. The script uses the same `mkdocs.local.yml` configuration as the Python
preview. The published container uses amd64, so ARM machines require emulation.

## Local preview versus a full release build

The local preview builds the current checkout only, with no version selector.
It uses the API reference files already in the repository and development/nightly
artifact links. It does not fetch API references or published release branches.
After dependencies are installed, the preview build needs no network access;
external links and browser-loaded resources may still require internet access.

Production configuration is still `mkdocs.yml`. To test release assembly, including
older versions and freshly downloaded API references, use:

```bash
./hack/docker/test.sh
```

That separate workflow requires Docker, network access, and a `GITHUB_TOKEN`
[personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
It writes the complete static site to `site/`. To serve that output with Python:

```bash
python3 -m http.server 8000 --directory site
```

When you submit a pull request, a hosted preview link is also posted on the PR.
