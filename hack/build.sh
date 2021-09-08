#!/bin/bash

set -e
set -x

# Builds blog and community into the site by cloning the website repo, copying blog/community dirs in, running hugo.
# Also builds previous versions unless BUILD_VERSIONS=no.
# - Results are written to site/ as normal.
# - Run as "./hack/build-with-blog.sh serve" to run a local preview server on site/ afterwards (requires `npm install -g http-server`).
#
# PREREQS (Unless BUILD_BLOG=no is set):
# 1. Install Hugo: https://www.docsy.dev/docs/getting-started/#install-hugo
# 2. For Mac OSX: The script uses the `gnu` version of `sed`. To install `gnu-sed`, you use brew:
#    1. Run `brew install gnu-sed`
#    2. Add it to your `PATH`. For example, add the following line to your `~/.bash_profile`:
#      `PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"`

# Releasing a new version:
# 1) Make a release-NN branch as normal.
# 2) Update VERSIONS below (on main) to include the new version.
#    Order matters :-), Most recent first.
VERSIONS=("0.25" "0.24" "0.23" "0.22")                  # Docs version, results in the url e.g. knative.dev/docs-0.23/..
VERSIONS_GENERATORS=("mkdocs" "mkdocs" "hugo" "hugo")  # update this to always be 4 in the next two releases replace hugo with mkdocs, remove the copy of static hugo site at the bottom
RELEASE_BRANCHES=("v0.25.0" "v0.24.0")                     # Release version for serving/eventing yaml files and api references.
# 3) For now, set branches and repos for old versions of docs. (This will go away when all docs branches are release-$version).
DOCS_BRANCHES=("release-0.25" "release-0.24") # add a branch here for the next 2 releases until everything is mkdocs
REPOS=("knative" "knative" "knative")
# 4) PR the result to main.
# 5) Party.

community_branch=${COMMUNITY_BRANCH:-main}
community_repo=${COMMUNITY_REPO:-knative}
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
  git clone --depth 1 -b ${DOCS_BRANCHES[0]} https://github.com/${REPOS[0]}/docs "$TEMP/docs-$latest"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${RELEASE_BRANCHES[0]}/docs/serving-api.md -s > "$TEMP/docs-$latest/docs/reference/api/serving-api.md"
  curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${RELEASE_BRANCHES[0]}/docs/eventing-api.md -s > "$TEMP/docs-$latest/docs/reference/api/eventing-api.md"
  pushd "$TEMP/docs-$latest"; KNATIVE_VERSION=${RELEASE_BRANCHES[0]} SAMPLES_BRANCH="${DOCS_BRANCHES[0]}" mkdocs build -d $SITE/docs; popd

  # Previous release branches release-$version to /v$version-docs
  versionjson=""
  for i in "${!previous[@]}"; do
    version=${previous[$i]}
    versionjson+="{\"version\": \"v$version-docs\", \"title\": \"v$version\", \"aliases\": [\"\"]},"

    # This is a hack to make old sites links be handled by netlify redirects, we want the drop down but not the content yet
    # Just do it for older version that are mkdocs and not hugo
    if [ "${VERSIONS_GENERATORS[$i+1]}" == "mkdocs" ]; then
      echo "Building ${VERSIONS_GENERATORS[$i+1]} for previous version $version"
      git clone --depth 1 -b ${DOCS_BRANCHES[$i+1]} https://github.com/${REPOS[i+1]}/docs "$TEMP/docs-$version"
      curl -f -L --show-error https://raw.githubusercontent.com/knative/serving/${RELEASE_BRANCHES[i+1]}/docs/serving-api.md -s > "$TEMP/docs-$version/docs/reference/api/serving-api.md"
      curl -f -L --show-error https://raw.githubusercontent.com/knative/eventing/${RELEASE_BRANCHES[i+1]}/docs/eventing-api.md -s > "$TEMP/docs-$version/docs/reference/api/eventing-api.md"
      pushd "$TEMP/docs-$version"; KNATIVE_VERSION=${RELEASE_BRANCHES[i+1]} SAMPLES_BRANCH="${DOCS_BRANCHES[i+1]}" VERSION_WARNING=true mkdocs build -d "$SITE/v$version-docs"; popd
    fi

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

if [ -z "$SKIP_BLOG" ]; then
  # Clone out the website and community repos for the hugo bits.
  # This can be removed if/when we move the blog and community stuff to mkdocs.
  # TODO(jz) Cache this and just do a pull/update/use siblings for local dev flow.
  rm -rf temp
  git clone --depth 1 https://github.com/knative/website temp/website
  pushd temp/website; git submodule update --init --recursive --depth 1; popd
  git clone -b ${community_branch} --depth 1 https://github.com/${community_repo}/community temp/community

  # Move blog files into position
  mkdir -p temp/website/content/en
  cp -r blog temp/website/content/en/

  # Clone community/ in to position too
  # This is pretty weird: the base community is in docs, but then the
  # community repo is overlayed into the community/contributing subdir.
  cp -r community temp/website/content/en/
  cp -r temp/community/* temp/website/content/en/community/contributing/
  rm -r temp/website/content/en/community/contributing/elections/2021-TOC # Temp fix for markdown that confuses hugo.

  # Setup postcss to be in the PATH
  PATH=${PATH}:${PWD}/node_modules/.bin
  pushd temp/website

  # See https://github.com/knative/website/blob/main/scripts/processsourcefiles.sh#L125
  # For the reasoning behind all this.
  echo 'Converting all links in GitHub source files to Hugo supported relative links...'
  # Convert relative links to support Hugo
  find . -type f -path '*/content/*.md' ! -name '*index.md' ! -name '*README.md' \
    ! -name '*serving-api.md' ! -name '*eventing-contrib-api.md' ! -name '*eventing-api.md' \
    ! -name '*build-api.md' ! -name '*.git*' ! -path '*/.github/*' ! -path '*/hack/*' \
    ! -path '*/node_modules/*' ! -path '*/test/*' ! -path '*/themes/*' ! -path '*/vendor/*' \
    -exec sed -i '/](/ { s#(\.\.\/#(../../#g; s#(\.\/#(../#g; }' {} +
  # Convert all relative links from README.md to index.html
  find . -type f -path '*/content/*.md' ! -name 'index.md' \
      -exec sed -i '/](/ { /http/ !{s#README\.md#index.html#g} }' {} +
  # Convert all Markdown links to HTML
  find . -type f -path '*/content/*.md' \
      -exec sed -i '/](/ { /http/ !{s#\.md##g} }' {} +

  # Move about cookie page in.
  cp -rfv content-override/en/about-analytics-cookies.md content/en/

  # Run the hugo build as normal!
  hugo
  popd

  # Hugo builds to public/, just copy over to site/ to match up with mkdocs
  for d in blog community css scss webfonts images js "about-analytics-cookies"; do
    mv temp/website/public/$d site/
  done

  # Copy go mod files so knative.dev/blahblah vanity URLs work
  mkdir site/golang
  cp golang/*.html site/golang/
  cat golang/_redirects >> site/_redirects
fi

# Temporarily, copy staticly built old versions of non-mkdocs docs until these scroll out of support
# TODO(jz) remove these each release until they disappear!
cp -r archived/scss/* site/scss/
cp -r archived/v0.23-docs site/v0.23-docs
cp -r archived/v0.22-docs site/v0.22-docs

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
