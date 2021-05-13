#!/bin/bash

# Builds blog and community into the site by cloning the website repo, copying blog/community dirs in, running hugo.
# Also builds previous versions if BUILD_VERSIONS=yes (see below).
# - Results are written to site/ as normal.
# - Run as "./hack/build-with-blog.sh serve" to run a local preview server on site/ afterwards (requires `npm install -g http-server`).


# Versioning:
# To release (1) make a release branch as normal (2) change the
# `knative_version` and `branch` variables in the release branch version
# of mkdocs.yml so {{ artifact }} and {{ branch }} links point to the
# right versions of things (3) Update variables below.
BUILD_VERSIONS="yes"         # TODO(jz) - detect if this is a pr preview/local and turn this off?
LATEST="0.23"                # release-$latest to /docs (HEAD builds to /development)
PREVIOUS=("0.22" "0.21")     # each release-$previous to /$previous-docs

# TODO: drop this when all the versions are in release-$version branches (in mkdocs format).
function branch_for_version() {
  if [ "$1" == "0.23" ]; then echo "mkdocs"
  elif [ "$1" == "0.22" ]; then echo "mkdocs"
  elif [ "$1" == "0.21" ]; then echo "mkdocs"
  else
    echo "No branch for version $1. Update branch_for_version function"
    exit 1
  fi
}

# Quit on error
set -e
# Echo each line
set -x

rm -rf temp
mkdir temp
rm -rf site/

if [ "$BUILD_VERSIONS" != "yes" ]; then
  # HEAD to /docs if we're not doing versioning.
  mkdocs build -f mkdocs.yml -d site/docs
else
  # Versioning: pre-release (HEAD): docs => development/
  mkdocs build -f mkdocs.yml -d site/development

  # Latest release branch to /docs
  git clone -b $(branch_for_version $LATEST) https://github.com/knative/docs "temp/docs-$LATEST" # TODO this should use the actual branch but there isnt one yet!
  pushd "temp/docs-$LATEST"
  mkdocs build -d ../../site/docs     # latest version: docs => docs/
  popd

  # Previous release branches release-$version to /$version-docs
  for version in "${PREVIOUS[@]}"
  do
    pushd "temp/docs-$LATEST"
    git checkout $(branch_for_version $version)
    mkdocs build -d "../../site/v$version-docs"   # old releases: docs => vN-docs/
    popd
  done

  # Set up the version file to point to the built docs.
  cat << EOF > site/versions.json
  [
    {"version": "docs", "title": "v$LATEST", "aliases": [""]},
EOF
  for version in "${PREVIOUS[@]}"
  do
  cat << EOF >> site/versions.json
    {"version": "v$version-docs", "title": "v$version", "aliases": [""]},
EOF
  done
  cat << EOF >> site/versions.json
    {"version": "development", "title": "(Pre-release)", "aliases": [""]}
  ]
EOF
fi

# Clone out the website and community repos for the hugo bits.
# TODO(jz) Cache this and just do a pull/update/use siblings for local dev flow.
git clone --recurse-submodules https://github.com/knative/website temp/website
git clone https://github.com/knative/community temp/community

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
PATH=${PATH}:${PWD}/node_modules/.bin
pushd temp/website
hugo
popd

# Hugo builds to public/, just copy over to site/ to match up with mkdocs
mv temp/website/public/blog site/
mv temp/website/public/community site/
mv temp/website/public/css site/
mv temp/website/public/scss site/
mv temp/website/public/webfonts site/
mv temp/website/public/images site/
mv temp/website/public/js site/

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
