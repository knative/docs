# Previewing the website locally

The Knative website uses [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).
For everyday edits, preview just your checkout instead of assembling every
published release. The default preview does not need a Kubernetes cluster,
Node.js, a GitHub token, or release branches.

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

Open <http://127.0.0.1:8000/docs/>. Edit Markdown under `docs/`, save, and the
browser reloads automatically. Press **Ctrl+C** to stop.

### Where to edit

- Knative documentation: `docs/versioned/`
- Documentation navigation: `docs/versioned/.nav.yml`
- Shared snippets: `docs/snippets/`
- Blog, community, and about pages: their respective directories under `docs/`
- Website templates and styles: `overrides/` and `docs/stylesheets/`

The preview serves `docs/versioned/` at `/docs/`, so the homepage and Docs header
links work as they do on the published website. It reads your working files
directly; there is no copy step between editing and previewing.

### Contributor guidance is a separate context

Files under `contribute-to-docs/` are repository guidance read on GitHub, outside
the MkDocs `docs/` source tree. Neither this preview nor the release build
publishes them automatically. Check the rendered Markdown on your branch or PR
on GitHub, including relative links, explicit anchors, images, and copyable
template fences. Confirm that new guidance is discoverable from the
[contributor guide](../README.md) or [template index](../templates/README.md).

Template scaffolds demonstrate versioned-page metadata and MkDocs syntax.
GitHub does not render MkDocs tabs, admonitions, macros, or includes as the website
does. To check a page created from a template, preview that actual page under
`docs/`; a readable scaffold on GitHub is not a website rendering check.
Record which context you checked in the PR. Neither rendering context proves
that the documented commands work.

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

# Sync the environment to the committed lockfile
./hack/mkdocs.sh setup
```

Use normal reloads when adding/deleting pages or changing navigation, snippets,
or templates: `--dirtyreload` can leave other pages stale.

The helper is just a shortcut for uv. You can also run commands directly:

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
- **The lockfile is stale:** if you changed `pyproject.toml`, follow the dependency
  update steps above. Otherwise, make sure you checked out the matching `uv.lock`.
- **Python download fails:** check network access, or install Python 3.13 yourself;
  uv can use a compatible interpreter already on your machine.
- **Unexpected versioned artifact links or GitHub API errors:** unset
  `KNATIVE_VERSION` for the normal development preview. By default, artifact
  macros link to nightly downloads without querying GitHub releases.

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
# Choose another host port
PORT=8001 ./hack/docker/run.sh

# Faster reloads for a single existing page
./hack/docker/run.sh serve --dirtyreload

# Check the checkout without starting a server (output: site/)
./hack/docker/run.sh build --strict
```

The default local image tag is `knative-docs:local`. Set `IMAGE` to choose a
different local build tag; the script never pushes it.

## Local preview versus a full release build

The local preview builds the current checkout only, with no version selector.
It uses the API reference files already in the repository and does not fetch API
references or published release branches. Selecting a link context below does
**not** turn the checkout into a released documentation snapshot.

### Choose a release context

These examples use the host-based uv helper. With `KNATIVE_VERSION` **unset**,
installation artifact macros link to moving nightly builds. With `SAMPLES_BRANCH`
unset, the `kn` and `func` command-reference macros link to upstream `main`.
To use those defaults:

```bash
unset KNATIVE_VERSION SAMPLES_BRANCH
./hack/mkdocs.sh serve
```

To request a release context instead, choose versions appropriate to the artifacts
and installed CLIs you are checking. For example:

```bash
export KNATIVE_VERSION=1.23.0
export SAMPLES_BRANCH=knative-v1.23.0
./hack/mkdocs.sh serve
```

`KNATIVE_VERSION` requests a matching component artifact release; it does not
guarantee an exact patch version or that every component has a matching release.
If no matching tag is found, the artifact macro falls back to that repository's
latest release. Inspect the rendered download URLs and build diagnostics before
using them. `SAMPLES_BRANCH` separately selects the upstream branch or tag for
CLI-reference links; setting `KNATIVE_VERSION` alone does not change those links.
Literal upstream links in prose or snippets may still point to `main`.

Stop your existing preview with **Ctrl+C**, then restart it from the shell with
the intended variables; browser reload alone does not update the process's
environment. For a shared preview, ask its owner to restart it. On a `/docs/` page,
verify that the local-checkout notice describes nightly artifacts or the requested
release context, as appropriate. Check an artifact URL and both CLI-reference
URLs too: the notice is not proof that all links resolved to the requested version.
If the notice is missing or stale, ask the preview owner to check/restart it before
using installation links.

After dependencies are installed, the default local build with `KNATIVE_VERSION`
unset does not need release-lookup network access. An explicit artifact release
context queries the GitHub API during rendering; network access is required and
API authentication or rate limits may affect the build. External destinations,
artifact downloads, and browser-loaded resources can also require internet access.
The full release-assembly workflow below is separate and requires network access.

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
