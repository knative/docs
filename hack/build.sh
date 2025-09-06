#!/usr/bin/env bash

# Copyright 2018 The Knative Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -x

# Builds blog and community into the site by cloning the website repo, copying blog/community dirs in, running hugo.
# Also builds previous versions unless BUILD_VERSIONS=no.
# - Results are written to site/ as normal.
# - Run as "./hack/build.sh serve" to run a local preview server on site/ afterwards (requires `npm install -g http-server`).


# Releasing a new version:
# 1) Make a release-NN branch as normal.
# 2) Update VERSIONS below (on main) to include the new version, and remove the oldest
#    Order matters :-), Most recent first.
VERSIONS=("1.19" "1.18" "1.17") # Docs version, results in the url e.g. knative.dev/v1.9-docs/..
# 4) PR the result to main.
# 5) Party.

DOCS_BRANCHES=("release-${VERSIONS[0]}" "release-${VERSIONS[1]}" "release-${VERSIONS[2]}" "release-${VERSIONS[3]}")
latest=${VERSIONS[0]}
previous=("${VERSIONS[@]:1}")
GIT_SLUG="knative/docs"

readonly TEMP="$(mktemp -d)"
readonly SITE=$PWD/site
rm -rf site/

if [ "$BUILD_VERSIONS" == "no" ]; then
  # Build to root if we're not doing versioning
  mkdocs build -f mkdocs.yml -d site
else
  # Build latest version to /docs
  cp -r . "$TEMP/docs-main"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/main/docs/serving-api.md -s > "$TEMP/docs-main/docs/serving/reference/serving-api.md"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/main/docs/eventing-api.md -s > "$TEMP/docs-main/docs/eventing/reference/eventing-api.md"
  
  # Create docs directory structure
  mkdir -p "$SITE/docs"
  
  # Build latest docs to /docs
  pushd "$TEMP/docs-main"
  KNATIVE_VERSION="${VERSIONS[0]}.0" SAMPLES_BRANCH="${DOCS_BRANCHES[0]}" mkdocs build -d "$SITE/docs"
  popd

  # Build versioned docs to /vX.Y-docs/
  for i in "${!previous[@]}"; do
    version="${previous[$i]}"
    branch="${DOCS_BRANCHES[$((i+1))]}"
    
    git clone --depth 1 -b "$branch" "https://github.com/$GIT_SLUG" "$TEMP/docs-$version"
    
    # Fetch API reference docs for versioned builds
    curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/$branch/docs/serving-api.md -s > "$TEMP/docs-$version/docs/serving/reference/serving-api.md"
    curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/$branch/docs/eventing-api.md -s > "$TEMP/docs-$version/docs/eventing/reference/eventing-api.md"
    
    pushd "$TEMP/docs-$version"
    KNATIVE_VERSION="$version.0" SAMPLES_BRANCH="$branch" mkdocs build -d "$SITE/v$version-docs"
    popd
  done
  
  # Build development site
  pushd "$TEMP/docs-main"
  KNATIVE_VERSION="${VERSIONS[0]}.0" SAMPLES_BRANCH="${DOCS_BRANCHES[0]}" mkdocs build -f mkdocs.yml -d "$SITE/development"
  popd
  
  # Move non-versioned content to root level
  mkdir -p "$SITE/about"
  cp -r "$TEMP/docs-main/docs/about" "$SITE/"
  mkdir -p "$SITE/community"
  cp -r "$TEMP/docs-main/docs/community" "$SITE/"
  
  # Copy index.html and sitemap.xml to root
  cp "$SITE/docs/index.html" "$SITE/"
  cp "$SITE/docs/sitemap.xml" "$SITE/"
  
  # Create version JSON for version picker
  versionjson=""
  for i in "${!previous[@]}"; do
    version=${previous[$i]}
    versionjson+="{\"version\": \"v$version-docs\", \"title\": \"v$version\", \"aliases\": [\"\"]},"
  done
  versionjson="[{\"version\": \"docs\", \"title\": \"latest\", \"aliases\": [\"\"]},$versionjson]"
  echo "$versionjson" > "$SITE/versions.json"
fi

# Create the blog
# TODO copy templates, stylesheets, etc. into blog directory
cp -rn overrides blog/
cp -r docs/images docs/stylesheets blog/docs/
pushd blog; mkdocs build -f mkdocs.yml -d "$SITE/blog"; popd

# Handle Cookie consent
cp -r cookie-consent/js site/

# Copy go mod files so knative.dev/blahblah vanity URLs work
mkdir site/golang
cp golang/*.html site/golang/
cat golang/_redirects >> site/_redirects


# Home page is now served directly from root, no redirect needed

# Clean up
rm -rf $TEMP

if [ "$1" = "serve" ]; then
  npx http-server site
else
  echo "To serve the website run:"
  echo "npx http-server site"
fi
