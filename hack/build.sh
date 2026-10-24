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

# Hide Material's MkDocs 2 banner without suppressing build diagnostics.
export NO_MKDOCS_2_WARNING=1

# Assemble the MkDocs site, including blog and community pages.
# BUILD_VERSIONS=no publishes this checkout at /docs/ without release snapshots.
# - Results are written to site/ as normal.
# - Run as "./hack/build.sh serve" to run a local preview server on site/ afterwards (requires `npm install -g http-server`).


# Releasing a new version:
# 1) Make a release-NN branch as normal.
# 2) Update config/versions.txt (on main), newest first, removing the oldest.
# 3) PR the result to main.

VERSIONS=()
while IFS= read -r version; do
  VERSIONS+=("$version")
done < "$(dirname "$0")/../config/versions.txt"
DOCS_BRANCHES=("${VERSIONS[@]/#/release-}")
latest=${VERSIONS[0]}
previous=("${VERSIONS[@]:1}")
: "${BUILD_VERSIONS:=yes}"

readonly TEMP="$(mktemp -d)"
readonly SITE=$PWD/site
rm -rf site/


REMOTE_BRANCH=$(git remote | grep -q upstream && echo upstream || echo origin)

# Previews publish this checkout at /docs/ without release branches or a token.
# Full builds use /development/ alongside the current release at /docs/.
CHECKOUT_DIR=docs
if [ "$BUILD_VERSIONS" != "no" ]; then
  CHECKOUT_DIR=development
  if [ "${CI:-}" == "true" ]; then
    git fetch --prune "$REMOTE_BRANCH"
  elif [[ -z "${GITHUB_TOKEN:-}" ]]; then
    # Netlify strips tokens from deploy previews; CI can build without one.
    echo "❌ Error: GITHUB_TOKEN environment variable is not set." >&2
    exit 1
  fi
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Require gnu-sed.
  if ! [ -x "$(command -v gsed)" ]; then
    echo "Error: 'gsed' is not istalled." >&2
    echo "If you are using Homebrew, install with 'brew install gnu-sed'." >&2
    exit 1
  fi
  SED_CMD=gsed
else
  SED_CMD=sed
fi


mkdir "$TEMP/content"
cp -r . "$TEMP/content/"

# Point top-level nav to docs directory.
echo -e "nav:\n- docs\n- about\n- blog\n- community" > "$TEMP/content/docs/.nav.yml"
curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/main/docs/serving-api.md -s > "$TEMP/content/docs/versioned/serving/reference/serving-api.md"
curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/main/docs/eventing-api.md -s > "$TEMP/content/docs/versioned/eventing/reference/eventing-api.md"
mv "$TEMP/content/docs/versioned" "$TEMP/content/docs/$CHECKOUT_DIR"
${SED_CMD} -i "s| versioned/| $CHECKOUT_DIR/|g" "$TEMP/content/config/redirects.yml"
# doc_base stays tied to the source tree so GitHub edit links remain correct.
echo -e "\nsamples_branch: main\nversion: $CHECKOUT_DIR\ndoc_base: /docs/versioned/" >> "$TEMP/content/docs/$CHECKOUT_DIR/.meta.yml"
versionjson="{\"version\": \"$CHECKOUT_DIR\", \"title\": \"(Pre-release)\", \"aliases\": [\"\"]}"

if [ "$BUILD_VERSIONS" != "no" ]; then
  # Remove pre-release documents from search.  This has to be applied to each markdown, unfortunately.
  # This needs to be done as two commands: the first ensures front-matter in files that don't have it,
  # and the seconds inserts commands into the front-matter.
  find "$TEMP/content/docs/development" -type f -name '*.md' | xargs ${SED_CMD} -i '1s/^\([^-]\)/---\n---\n\1/'
  find "$TEMP/content/docs/development" -type f -name '*.md' | xargs ${SED_CMD} -i '2isearch:\n exclude: true'
  echo "- Docs: development" >> "$TEMP/content/docs/.nav.yml"

  # Handle current release specially, as we don't include a version slug
  # Note that git worktree reuses the same git clone, so we don't need to clone 50+MB each time.
  git worktree add --detach "$TEMP/current-release" "${REMOTE_BRANCH}/${DOCS_BRANCHES[0]}"
  if [ -d "$TEMP/current-release/docs/versioned" ]; then
    cp -r "$TEMP/current-release/docs/versioned" "$TEMP/content/docs/docs"
    echo -e "\ndoc_base: /docs/versioned/" >> "$TEMP/content/docs/docs/.meta.yml"
    # Fix up redirects from old versioned/ path to docs/ and append them to redirects.
    # We only do this for development (so we can see effects) and docs (current)
    grep '^    ' "$TEMP/current-release/config/redirects.yml" | ${SED_CMD} -e 's| versioned/| docs/|g' -e 's| community/contributing/README.md$| community/contributing.md|' >> "$TEMP/content/config/redirects.yml"
  else
    cp -r "$TEMP/current-release/docs" "$TEMP/content/docs/docs"
    echo -e "\ndoc_base: /docs/" >> "$TEMP/content/docs/docs/.meta.yml"
    # Older redirects were already for /docs/, but did not have the right destination path.
    grep '^    ' "$TEMP/current-release/config/redirects.yml" | ${SED_CMD} '/:  *http/! s|: |: docs/|' >> "$TEMP/content/config/redirects.yml"
    # Copy the nav, but strip out non-versioned content, starting with blog
    # This can be retired after we stop supporting v1.19.
    if [ ! -f "$TEMP/content/docs/docs/.nav.yml" ]; then
      ${SED_CMD} '/- Blog:/,$d' "$TEMP/current-release/config/nav.yml" >> "$TEMP/content/docs/docs/.nav.yml"
    fi
    # Redirect from old homepage to concepts documentation, if it exists (pre-1.20)
    if [ -f "$TEMP/content/docs/docs/concepts/README.md" ]; then
      echo "      docs/README.md: docs/concepts/README.md" >> "$TEMP/content/config/redirects.yml"
    fi
    # Smoketests were written for Hugo, not mkdocs, so remove
    rm "$TEMP/content/docs/docs/smoketest.md"
  fi
  curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${DOCS_BRANCHES[0]}/docs/serving-api.md -s > "$TEMP/content/docs/docs/serving/reference/serving-api.md"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${DOCS_BRANCHES[0]}/docs/eventing-api.md -s > "$TEMP/content/docs/docs/eventing/reference/eventing-api.md"
  # Fill in meta content for macros.py
  echo -e "\nknative_version: ${latest}.0\nsamples_branch: ${DOCS_BRANCHES[0]}\nversion: v${latest}" >> "$TEMP/content/docs/docs/.meta.yml"
  versionjson="{\"version\": \"docs\", \"title\": \"v$latest\", \"aliases\": [\"v$latest\"]},"  # Clear existing content, we'll add development at the _end_.

  for i in "${!previous[@]}"; do
    version=${previous[$i]}

    echo "Building for previous version $version"
    git worktree add --detach "$TEMP/docs-$version" "${REMOTE_BRANCH}/${DOCS_BRANCHES[i+1]}"
    if [ -d "$TEMP/docs-$version/docs/versioned" ]; then
      cp -r "$TEMP/docs-$version/docs/versioned" "$TEMP/content/docs/v$version-docs"
      echo -e "\ndoc_base: /docs/versioned/" >> "$TEMP/content/docs/v$version-docs/.meta.yml"
    else
      cp -r "$TEMP/docs-$version/docs" "$TEMP/content/docs/v$version-docs"
      echo -e "\ndoc_base: /docs/" >> "$TEMP/content/docs/v$version-docs/.meta.yml"
      # Copy the nav, but strip out non-versioned content, starting with blog
      # This can be retired after we stop supporting v1.19.
      if [ ! -f "$TEMP/content/docs/v$version-docs/.nav.yml" ]; then
        ${SED_CMD} '/- Blog:/,$d' "$TEMP/docs-$version/config/nav.yml" >> "$TEMP/content/docs/v$version-docs/.nav.yml"
      fi
      # Redirect from old homepage to concepts documentation, if it exists (pre-1.20)
      if [ -f "$TEMP/content/docs/v${version}-docs/concepts/README.md" ]; then
        echo "      v${version}-docs/README.md: v${version}-docs/concepts/README.md" >> "$TEMP/content/config/redirects.yml"
      fi
      # Smoketests were written for Hugo, not mkdocs, so remove
      rm "$TEMP/content/docs/v$version-docs/smoketest.md"
    fi
    curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${DOCS_BRANCHES[i+1]}/docs/serving-api.md -s > "$TEMP/content/docs/v$version-docs/serving/reference/serving-api.md"
    curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${DOCS_BRANCHES[i+1]}/docs/eventing-api.md -s > "$TEMP/content/docs/v$version-docs/eventing/reference/eventing-api.md"
    echo "- Docs: v${version}-docs" >> "$TEMP/content/docs/.nav.yml"
    # Fill in meta content for macros.py
    echo -e "\nknative_version: ${version}.0\nsamples_branch: ${DOCS_BRANCHES[i+1]}\nversion_warning: true\nversion: v${version}" >> "$TEMP/content/docs/v$version-docs/.meta.yml"
    versionjson+="{\"version\": \"v$version-docs\", \"title\": \"v$version\", \"aliases\": [\"v$version\"]},"

    # Remove older-version documents from search.  This has to be applied to each markdown, unfortunately.
    # This needs to be done as two commands: the first ensures front-matter in files that don't have it,
    # and the seconds inserts commands into the front-matter.
    find "$TEMP/content/docs/v$version-docs" -type f -name '*.md' | xargs ${SED_CMD} -i '1s/^\([^-]\)/---\n---\n\1/'
    find "$TEMP/content/docs/v$version-docs" -type f -name '*.md' | xargs ${SED_CMD} -i '2isearch:\n exclude: true'
  done

  # Put the development version at the end of the JSON list of documentation,
  # even though we put it in the directory first.
  versionjson+="{\"version\": \"development\", \"title\": \"(Pre-release)\", \"aliases\": [\"\"]}"
fi

# Make the version manifest available to the selector hook during rendering.
# MkDocs also copies it into the output site as a normal static asset.
cat << EOF > "$TEMP/content/docs/versions.json"
[
  $versionjson
]
EOF

# Only build the site _once_ -- we used to build sub-components, and it
# introduced a bunch of navigation / base-url problems.
# We pass through the command-line arguments to this script to enable --strict checks in CI.
(cd "$TEMP/content"; mkdocs build -f mkdocs.yml -d "$SITE" "$@")

# Copy go mod files so knative.dev/blahblah vanity URLs work
mkdir site/golang
cp golang/*.html site/golang/
cat golang/_redirects >> site/_redirects

# Clean up
# rm -rf $TEMP
# git worktree prune
echo "Temp dir was: $TEMP"

if [ "$1" = "serve" ]; then
  npx http-server site
else
  echo "To serve the website run:"
  echo "npx http-server site"
fi
