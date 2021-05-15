#!/bin/bash

set -e
set -x

# Builds blog and community into the site by cloning the website repo, copying blog/community dirs in, running hugo.
# Also builds previous versions unless BUILD_VERSIONS=no.
# - Results are written to site/ as normal.
# - Run as "./hack/build-with-blog.sh serve" to run a local preview server on site/ afterwards (requires `npm install -g http-server`).

# Releasing a new version:
# 1) Make a release-NN branch as normal.
# 2) Update VERSIONS (on main) to include the new version.
VERSIONS=("0.23" "0.22")

# 3) For now, update the function below to map version to branch.
# This is temporary so we can use non release-N branches while we transition
# (since we'll want mkdocs versions of the last 2 releases). TODO: Drop this
# when all the versions are in release-$version branches (in mkdocs format).
function branch_for_version() {
  if [ "$1" == "0.23" ]; then echo "mkrelease-0.23"
  elif [ "$1" == "0.22" ]; then echo "mkrelease-0.22"
  elif [ "$1" == "0.21" ]; then echo "mkversion2"
  else
    echo "No branch for version $1. Update branch_for_version function"
    exit 1
  fi
}

# 4) PR the result to main.
# 5) Party.

repo=${DOCS_REPO:-knative}
latest=${VERSIONS[0]}
previous=("${VERSIONS[@]:1}")

rm -rf temp
mkdir temp
rm -rf site/

if [ "$BUILD_VERSIONS" == "no" ]; then
  # HEAD to /docs if we're not doing versioning.
  mkdocs build -f mkdocs.yml -d site/docs
else
  # Versioning: pre-release (HEAD): docs => development/
  mkdocs build -f mkdocs.yml -d site/development

  # Latest release branch to /docs
  git clone --depth 1 -b $(branch_for_version $latest) https://github.com/$repo/docs "temp/docs-$latest"
  pushd "temp/docs-$latest"
  KNATIVE_VERSION=$latest mkdocs build -d ../../site/docs
  popd

  # Previous release branches release-$version to /v$version-docs
  versionjson=""
  for version in "${previous[@]}"
  do
    git clone --depth 1 -b $(branch_for_version $version) https://github.com/$repo/docs "temp/docs-$version"
    pushd "temp/docs-$version"
    versionjson+="{\"version\": \"v$version-docs\", \"title\": \"v$version\", \"aliases\": [\"\"]},"
    KNATIVE_VERSION=$version VERSION_WARNING=true mkdocs build -d "../../site/v$version-docs"
    popd
  done

  # Set up the version file to point to the built docs.
  cat << EOF > site/versions.json
  [
    {"version": "docs", "title": "v$latest", "aliases": [""]},
    $versionjson
    {"version": "development", "title": "(Pre-release)", "aliases": [""]}
  ]
EOF
fi

if [ -z "$SKIP_BLOG" ]; then
  # Clone out the website and community repos for the hugo bits.
  # TODO(jz) Cache this and just do a pull/update/use siblings for local dev flow.
  git clone --depth 1 https://github.com/knative/website temp/website
  pushd temp/website; git submodule update --init --recursive --depth 1; popd
  git clone --depth 1 https://github.com/knative/community temp/community

  # Move blog files into position
  mkdir -p temp/website/content/en
  cp -r blog temp/website/content/en/

  # Clone community/ in to position too
  # This is pretty weird: the base community is in docs, but then the
  # community repo is overlayed into the community/contributing subdir.
  cp -r community temp/website/content/en/
  cp -r temp/community/* temp/website/content/en/community/contributing/
  rm -r temp/website/content/en/community/contributing/elections/2021-TOC # Temp fix for markdown that confuses hugo.

  # Run the hugo build as normal!

  # need postcss cli in PATH
  pushd temp/website
  npx hugo
  popd

  # Hugo builds to public/, just copy over to site/ to match up with mkdocs
  for d in blog community css scss webfonts images js; do
    mv temp/website/public/$d site/
  done
fi

# Home page is served from docs, so add a redirect.
# TODO(jz) in production this should be done with a netlify 301 (or maybe just copy docs/index up with a base set).
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
   window.location.replace(window.location.href+"docs/");
  </script>
</head>
<body>
  Redirecting to <a href="docs/">docs/</a>...
</body>
</html>
EOF

# Clean up
rm -rf temp

if [ "$1" = "serve" ]; then
  pushd site
  npx http-server
  popd
fi
