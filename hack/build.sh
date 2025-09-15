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
VERSIONS=("1.19" "1.18" "1.17") # Docs version, results in the url e.g. knative.dev/docs-1.9/..
# 4) PR the result to main.
# 5) Party.

DOCS_BRANCHES=("release-${VERSIONS[0]}" "release-${VERSIONS[1]}" "release-${VERSIONS[2]}" "release-${VERSIONS[3]}")
latest=${VERSIONS[0]}
previous=("${VERSIONS[@]:1}")
GIT_SLUG="knative/docs"

readonly TEMP="$(mktemp -d)"
readonly SITE=$PWD/site
rm -rf site/

mkdir "$TEMP/content"
cp -r . "$TEMP/content/"
mkdir "$TEMP/content/docs/docs"

for path in  .nav.yml bookstore client concepts eventing functions getting-started install reference samples serving; do
  mv "$TEMP/content/docs/$path" "$TEMP/content/docs/docs/$path"
done
echo "      docs/README.md: docs/concepts/README.md" >> "$TEMP/content/config/redirects.yml"
# Copy images for now, until we clean up the above:
cp -r "$TEMP/content/docs/images" "$TEMP/content/docs/docs/images"

# Point top-level nav to docs directory.
echo -e "nav:\n- docs\n- about\n- blog\n- community" > "$TEMP/content/docs/.nav.yml"
# We use samples_branch to flag that the documentation is versioned
echo -e "\n\nsamples_branch: main" >> "$TEMP/content/docs/docs/.meta.yml"
curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/main/docs/serving-api.md -s > "$TEMP/content/docs/docs/serving/reference/serving-api.md"
curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/main/docs/eventing-api.md -s > "$TEMP/content/docs/docs/eventing/reference/eventing-api.md"
versionjson="{\"version\": \"docs\", \"title\": \"(Pre-release)\", \"aliases\": [\"\"]}"

# Temporarily force BUILD_VERSIONS (for previews), while this rewrite is testing.
BUILD_VERSIONS="yes"

if [ "$BUILD_VERSIONS" != "no" ]; then
  mv $TEMP/content/docs/docs $TEMP/content/docs/development
  echo "- Docs: development" >> "$TEMP/content/docs/.nav.yml"
  echo "      development/README.md: development/concepts/README.md" >> "$TEMP/content/config/redirects.yml"
  versionjson="{\"version\": \"docs\", \"title\": \"v$latest\", \"aliases\": [\"\"]},"  # Clear existing content, we'll add development at the _end_.

  # Handle current release specially, as we don't include a version slug
  # TODO: can we make one clone and reuse it, possibly with git worktrees?
  git clone --depth 1 -b "${DOCS_BRANCHES[0]}" "https://github.com/${GIT_SLUG}" "$TEMP/current-release"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${DOCS_BRANCHES[0]}/docs/serving-api.md -s > "$TEMP/current-release/docs/serving/reference/serving-api.md"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${DOCS_BRANCHES[0]}/docs/eventing-api.md -s > "$TEMP/current-release/docs/eventing/reference/eventing-api.md"
  cp -r "$TEMP/current-release/docs" "$TEMP/content/docs/docs"
  # Copy the nav, but strip out non-versioned content, starting with blog
  # This can be retired after we stop supporting v1.19.
  if [ ! -f "$TEMP/content/docs/docs/.nav.yml" ]; then
    sed '/- Blog:/,$d' "$TEMP/current-release/config/nav.yml" >> "$TEMP/content/docs/docs/.nav.yml"
  fi
  # Smoketests were written for Hugo, not mkdocs, so remove
  rm "$TEMP/content/docs/docs/smoketest.md"
  # Fill in meta content for macros.py
  echo -e "\n\nknative_version: ${VERSIONS[0]}.0\nsamples_branch: ${DOCS_BRANCHES[0]}" >> "$TEMP/content/docs/docs/.meta.yml"


  for i in "${!previous[@]}"; do
    version=${previous[$i]}
    versionjson+="{\"version\": \"v$version-docs\", \"title\": \"v$version\", \"aliases\": [\"\"]},"

    echo "Building for previous version $version"
    git clone --depth 1 -b ${DOCS_BRANCHES[$i+1]} https://github.com/${GIT_SLUG} "$TEMP/docs-$version"
    curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${DOCS_BRANCHES[i+1]}/docs/serving-api.md -s > "$TEMP/docs-$version/docs/serving/reference/serving-api.md"
    curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${DOCS_BRANCHES[i+1]}/docs/eventing-api.md -s > "$TEMP/docs-$version/docs/eventing/reference/eventing-api.md"
    cp -r "$TEMP/docs-$version/docs" "$TEMP/content/docs/v$version-docs"
    echo "- Docs: v${version}-docs" >> "$TEMP/content/docs/.nav.yml"
    echo "      v${version}-docs/README.md: v${version}-docs/concepts/README.md" >> "$TEMP/content/config/redirects.yml"
    # Smoketests were written for Hugo, not mkdocs, so remove
    rm "$TEMP/content/docs/v$version-docs/smoketest.md"
    # Copy the nav, but strip out non-versioned content, starting with blog
    # This can be retired after we stop supporting v1.19.
    if [ ! -f "$TEMP/content/docs/v$version-docs/.nav.yml" ]; then
      sed '/- Blog:/,$d' "$TEMP/docs-$version/config/nav.yml" >> "$TEMP/content/docs/v$version-docs/.nav.yml"
    fi
    # Fill in meta content for macros.py
    echo -e "\n\nknative_version: ${VERSIONS[i+1]}.0\nsamples_branch: ${DOCS_BRANCHES[i+1]}\nversion_warning: true" >> "$TEMP/content/docs/v$version-docs/.meta.yml"
  done

  # Put the development version at the end of the JSON list of documentation,
  # even though we put it in the directory first.
  versionjson+="{\"version\": \"development\", \"title\": \"(Pre-release)\", \"aliases\": [\"\"]}"
fi

# Only build the site _once_ -- we used to build sub-components, and it
# introduced a bunch of navigation / base-url problems.
# We pass through the command-line arguments to this script to enable --strict checks in CI.
(cd "$TEMP/content"; mkdocs build -f mkdocs.yml -d "$SITE" "$@")

# Set up the version file to point to the set of built docs.
cat << EOF > $SITE/versions.json
[
  $versionjson
]
EOF

# Handle Cookie consent
cp -r cookie-consent/js site/

# Copy go mod files so knative.dev/blahblah vanity URLs work
mkdir site/golang
cp golang/*.html site/golang/
cat golang/_redirects >> site/_redirects

# Clean up
# rm -rf $TEMP
echo "Temp dir was: $TEMP"

if [ "$1" = "serve" ]; then
  npx http-server site
else
  echo "To serve the website run:"
  echo "npx http-server site"
fi
