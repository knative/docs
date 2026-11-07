#!/usr/bin/env bash
# Print the test matrix for a PR diff. Run from the repository root.
set -euo pipefail
base=$1
diff_range="$base...HEAD"
directories=()
shared=$(git diff --name-only --no-renames "$diff_range" -- \
  .github/workflows/samples-test.yaml hack/sample-ci/ \
  code-samples/serving/cloudevents/cloudevents-go/eventing/logger/)
while IFS= read -r -d '' script; do
  directory=${script%/ci.sh}
  paths=("$directory/")
  case "$directory" in
    code-samples/eventing/bookstore-sample-app/*/node-server)
      # The database fixtures are siblings of each node-server component.
      paths+=("${directory%/node-server}/db-service/")
      ;;
  esac
  changed=$(git diff --name-only --no-renames "$diff_range" -- "${paths[@]}")
  if [[ -n "$shared" || -n "$changed" ]]; then
    directories+=("$directory")
  fi
done < <(git ls-files -z -- 'code-samples/**/ci.sh')
for directory in "${directories[@]}"; do
  jq -cn --arg directory "$directory" --arg name "${directory#code-samples/}" \
    '{directory: $directory, name: $name}'
done | jq -sc 'unique_by(.directory)'
