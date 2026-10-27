# Previewing the website locally

The Knative website uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).
For everyday edits, preview just your live checkout. Use `--all-versions` when
you want to test the version selector alongside cached release docs.
You don't need a Kubernetes cluster, Node.js, a GitHub token, or manually fetched
release branches. The release list comes from `config/versions.txt`, shared with
the production build.

## Quick start: uv

Install [uv](https://docs.astral.sh/uv/getting-started/installation/), then run
this command from a clone of this repository:

```bash
./hack/mkdocs.sh
```

uv selects Python 3.13 (from `.python-version`), downloads it if necessary,
creates `.venv/`, and installs the exact dependencies from `uv.lock`. The first
run requires internet access. Later runs reuse the environment and check that it
matches the lockfile. You don't need to install Python manually, activate the
environment, or install packages globally.

Open <http://127.0.0.1:8000/docs/>. Edit Markdown under `docs/`, save, and
the browser reloads automatically. Templates, CSS, and JavaScript also reload.
Changing a Python hook or macro automatically runs a fresh renderer process.
MkDocs serves the preview and reloads the browser after each successful rebuild.
Press **Ctrl+C** to stop.

### Where to edit

- Knative documentation: `docs/versioned/`
- Documentation navigation: `docs/versioned/.nav.yml`
- Shared snippets: `docs/snippets/`
- Blog, community, and about pages: their respective directories under `docs/`
- Website templates and styles: `overrides/` and `docs/stylesheets/`

By default, `docs/versioned/` is served at `/docs/` with no version selector.
It reads your working files directly; there is no copy step between editing
and previewing, and no release snapshots are loaded.

### Testing all versions

```bash
./hack/mkdocs.sh --all-versions
```

Open <http://127.0.0.1:8000/development/> for the working copy, labeled
**(Pre-release)** in the version selector. The latest listed release is served
at `/docs/`, and older releases at paths such as `/v1.22-docs/`. These snapshots
use already-fetched Git refs when available,
otherwise public GitHub archives. The first run can need internet access; later
runs use `.cache/docs-preview/`. Remove that cache and restart to refresh release
snapshots. Edit the working copy, not the cached files.

The initial build renders every version. During live reload, complete release
HTML is reused for ordinary working-copy edits. Historical snapshots can emit
pre-existing link/anchor warnings when they are rendered. Without the flag,
`./hack/mkdocs.sh build --strict` checks only the editable checkout.

### Incremental live reload

The development runner chooses a rebuild based on which files changed, rather
than using MkDocs' `--dirtyreload` timestamp shortcut:

- Existing CSS/JavaScript/image edits update assets without rendering pages.
- Markdown body edits rebuild the working documentation and unversioned pages,
  reusing release HTML and its complete navigation/anchor metadata.
- Page additions/deletions, navigation, snippets, templates, configuration,
  release-list changes, and Python hooks invalidate dependent versions.
- If a working build changes page URLs, metadata, titles, or anchors, all versions
  are rebuilt before publication so cached version-selector links cannot go stale.

Each render runs in a fresh MkDocs process. MkDocs' standard live-reload server
handles file watching, serving, and browser reloads. Page requests wait during
rebuilds. If a build fails, check the terminal for errors; requests wait until
you fix the problem and a rebuild succeeds. There is no browser error overlay.
Rendered release HTML is cached for the running session; source snapshots
remain cached on disk between sessions.

Changes made during a build are retried before publishing. Live reload does not
prune or otherwise change the sidebar. No incremental mode needs enabling.
Dynamic macro inputs outside the repository need an explicit `--watch /path`;
network inputs are not automatically tracked. This is a development server, not
a production server; keep it bound to localhost unless deliberately sharing it.

### Useful commands

```bash
# Use another port
./hack/mkdocs.sh serve --dev-addr 127.0.0.1:8001

# Build this checkout without starting a server (output: site/)
./hack/mkdocs.sh build

# Treat build warnings as errors
./hack/mkdocs.sh build --strict

# Sync the environment to the committed lockfile
./hack/mkdocs.sh setup
```

The legacy `--dirtyreload` flag is accepted for compatibility but is unnecessary.
To bypass the development runner and use MkDocs' normal full-rebuild server
(restart manually after changing Python hooks):

```bash
uv run --locked mkdocs serve --livereload --config-file mkdocs.local.yml
```

### Updating dependencies

`pyproject.toml` declares dependencies; `uv.lock` pins the resolved versions.
Local previews, Docker, CI, and Netlify install directly from `uv.lock`; no
`requirements.txt` export is needed.

After changing dependencies in `pyproject.toml`, run:

```bash
uv lock
./hack/mkdocs.sh build --strict
```

To update all packages within their declared constraints, use `uv lock --upgrade`
instead of `uv lock`. Commit `pyproject.toml` and `uv.lock` together when changing
dependency declarations. Preview and hosted build commands use `--locked` so a
stale lockfile fails rather than silently choosing new versions.

### Updating uv

The `tools` dependency group in `pyproject.toml` pins the uv used by CI, Netlify,
and Docker; each reads the locked version from `uv.lock`. Dependabot updates it
like any other dependency. To upgrade manually, change the pin and run `uv lock`.

`required-version` sets the minimum uv for local builds. Newer versions work.

### Troubleshooting

- **Port already in use:** choose another port with `--dev-addr` as shown above.
- **Python environment no longer works after a Python upgrade:** remove the
  generated `.venv/` directory and rerun `./hack/mkdocs.sh`.
- **uv is missing or too old:** follow the
  [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/)
  and install at least the version in `required-version` in `pyproject.toml`.
- **Dependencies changed:** run `./hack/mkdocs.sh setup` and restart the preview
  after updating Python dependencies. Installed package directories are not watched.
- **The lockfile is stale:** if you changed `pyproject.toml`, follow the dependency
  update steps above. Otherwise, make sure you checked out the matching `uv.lock`.
- **Python download fails:** check network access, or install Python 3.13 yourself;
  uv can use a compatible interpreter already on your machine.
- **Editing the runner itself:** restart after changing `hack/dev_server.py`,
  `hack/preview_inputs.py`, or `hack/preview_cache.py`. Documentation hooks and
  macros are loaded afresh automatically.
- **A release snapshot is outdated:** remove `.cache/docs-preview/` and restart
  the preview. Releases are intentionally cached rather than fetched on every
  rebuild. Your working checkout is always read live.

## Alternative: Docker

If you prefer not to install uv or manage a host environment, use a
Docker-compatible engine such as
[Docker Desktop](https://www.docker.com/products/docker-desktop) or
[colima](https://github.com/abiosoft/colima). Only the Docker CLI is required.

From the repository root:

```bash
./hack/docker/run.sh
```

Open <http://127.0.0.1:8000/docs/>. Your checkout is mounted into the container
and changes reload automatically. Press **Ctrl+C** to stop; the container is
removed automatically.

The script builds locally for your machine's architecture and installs dependencies
directly from `uv.lock`. It doesn't depend on a published Knative image, host
Python, or host uv. Container dependencies live in `/opt/venv`, separate from your
host's `.venv/`. Source edits reload immediately. Each launch checks the image
build, reusing Docker's cached layers when dependencies haven't changed.

```bash
# Include cached releases; edit the working copy at /development/
./hack/docker/run.sh --all-versions

# Choose another host port
PORT=8001 ./hack/docker/run.sh

# Check the checkout without starting a server (output: site/)
./hack/docker/run.sh build --strict
```

The default local image tag is `knative-docs:local`. Set `IMAGE` to choose a
different local build tag; the script never pushes it.

## Local preview versus a full release build

The default preview builds only the working checkout. With `--all-versions`,
it also builds cached release snapshots with the same selector as the full site.
It does not fetch API references or query GitHub releases for artifact links: all local preview pages use nightly
artifact links. It currently uses shared snippets, like the production build.
Use it to test documentation and version navigation, not release installation
artifacts.

The non-server `build` command defaults to a fast, single-checkout check with no
version selector; it also accepts `--all-versions`. Once dependencies and any
selected release snapshots are cached, preview needs no build-time network
access; external links and browser-loaded resources may still require internet
access.

Production configuration is still `mkdocs.yml`. To test release assembly, including
older versions and freshly downloaded API references, use:

```bash
# First export GITHUB_TOKEN in your shell, then:
./hack/docker/run.sh release
```

That separate workflow requires Docker, network access, and a `GITHUB_TOKEN`
[personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
It writes the complete static site to `site/`. To serve that output with Python:

```bash
python3 -m http.server 8000 --directory site
```

When you submit a pull request, a hosted preview link is also posted on the PR.
