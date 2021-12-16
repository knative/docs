#!/bin/bash

set -e
set -x

# Builds blog and community into the site by cloning the website repo, copying blog/community dirs in, running hugo.
# Also builds previous versions unless BUILD_VERSIONS=no.
# - Results are written to site/ as normal.
# - Run as "./hack/build.sh serve" to run a local preview server on site/ afterwards (requires `npm install -g http-server`).


# Releasing a new version:
# 1) Make a release-NN branch as normal.
# 2) Update VERSIONS and RELEASE_BRANCHES below (on main) to include the new version, and remove the oldest
#    Order matters :-), Most recent first.
VERSIONS=("1.1" "1.0" "0.26" "0.25")                  # Docs version, results in the url e.g. knative.dev/docs-0.23/..
RELEASE_BRANCHES=("knative-v1.1.0" "knative-v1.0.0" "v0.26.0" "v0.25.0") # Release version for serving/eventing yaml files and api references.
# 4) PR the result to main.
# 5) Party.

DOCS_BRANCHES=("release-${VERSIONS[0]}" "release-${VERSIONS[1]}" "release-${VERSIONS[2]}" "release-${VERSIONS[3]}")
latest=${VERSIONS[0]}
previous=("${VERSIONS[@]:1}")

readonly TEMP="$(mktemp -d)"
readonly SITE=$PWD/site
rm -rf site/

if [ "$BUILD_VERSIONS" == "no" ]; then
  # HEAD to /docs if we're not doing versioning.
  mkdocs build -f mkdocs.yml -d site/docs
else
  # Versioning: pre-release (HEAD): docs => development/
  cp -r . $TEMP/docs-main
  curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/main/docs/serving-api.md -s > "$TEMP/docs-main/docs/reference/api/serving-api.md"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/main/docs/eventing-api.md -s > "$TEMP/docs-main/docs/reference/api/eventing-api.md"
  pushd "$TEMP/docs-main"; mkdocs build -f mkdocs.yml -d $SITE/development; popd

  # Latest release branch to /docs
  git clone --depth 1 -b ${DOCS_BRANCHES[0]} https://github.com/knative/docs "$TEMP/docs-$latest"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${RELEASE_BRANCHES[0]}/docs/serving-api.md -s > "$TEMP/docs-$latest/docs/reference/api/serving-api.md"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${RELEASE_BRANCHES[0]}/docs/eventing-api.md -s > "$TEMP/docs-$latest/docs/reference/api/eventing-api.md"
  pushd "$TEMP/docs-$latest"; KNATIVE_VERSION=${RELEASE_BRANCHES[0]} SAMPLES_BRANCH="${DOCS_BRANCHES[0]}" mkdocs build -d $SITE/docs; popd

  # Previous release branches release-$version to /v$version-docs
  versionjson=""
  for i in "${!previous[@]}"; do
    version=${previous[$i]}
    versionjson+="{\"version\": \"v$version-docs\", \"title\": \"v$version\", \"aliases\": [\"\"]},"

    echo "Building for previous version $version"
    git clone --depth 1 -b ${DOCS_BRANCHES[$i+1]} https://github.com/knative/docs "$TEMP/docs-$version"
    curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${RELEASE_BRANCHES[i+1]}/docs/serving-api.md -s > "$TEMP/docs-$version/docs/reference/api/serving-api.md"
    curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${RELEASE_BRANCHES[i+1]}/docs/eventing-api.md -s > "$TEMP/docs-$version/docs/reference/api/eventing-api.md"
    pushd "$TEMP/docs-$version"; KNATIVE_VERSION=${RELEASE_BRANCHES[i+1]} SAMPLES_BRANCH="${DOCS_BRANCHES[i+1]}" VERSION_WARNING=true mkdocs build -d "$SITE/v$version-docs"; popd

  done

  # Set up the version file to point to the built docs.
  cat << EOF > $SITE/versions.json
  [
    {"version": "docs", "title": "v$latest", "aliases": [""]},
    $versionjson
    {"version": "development", "title": "(Pre-release)", "aliases": [""]}
  ]
EOF
fi

# Create the blog
# TODO copy templates, stylesheets, etc. into blog directory
cp -r overrides blog/
cp -r docs/images docs/stylesheets blog/docs/
cd blog/
mkdocs build -f mkdocs.yml -d ../site/blog
cd -

# Handle Cookie consent
cp -r cookie-consent/js site/

# Copy go mod files so knative.dev/blahblah vanity URLs work
mkdir site/golang
cp golang/*.html site/golang/
cat golang/_redirects >> site/_redirects


# Home page is served from docs, so add a redirect.
cat << EOF > site/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Redirecting</title>
  <noscript>
    <meta http-equiv="refresh" content="1; url=docs/" />
  </noscript>
  <script>
   window.location.replace("docs/");
  </script>
</head>
<body>
  Redirecting to <a href="docs/">docs/</a>...
</body>
</html>
EOF

# Clean up
rm -rf $TEMP

if [ "$1" = "serve" ]; then
  npx http-server site
else
  echo "To serve the website run:"
  echo "npx http-server site"
fi
