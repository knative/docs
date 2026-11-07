#!/usr/bin/env bash
# Shared smoke-test plumbing. Source from a sample's ci.sh; no cluster is created here.
CI_ROOT=$(git rev-parse --show-toplevel)
CI_URL=${SAMPLE_URL:-http://127.0.0.1:18080}
CI_CLUSTER=${CLUSTER_NAME:-kind}
CI_PIDS=()
CI_TEMP=()

ci_cleanup() {
  local pid directory
  for pid in "${CI_PIDS[@]}"; do kill "$pid" 2>/dev/null || true; done
  for directory in "${CI_TEMP[@]}"; do rm -rf "$directory"; done
}

ci_load() {
  kind load docker-image "$1" --name "$CI_CLUSTER"
}

ci_deploy() {
  local name=$1 image=$2 port=${3:-8080}
  ci_load "$image"
  jq -n --arg name "$name" --arg image "$image" --argjson port "$port" '{
    apiVersion: "serving.knative.dev/v1", kind: "Service",
    metadata: {name: $name, namespace: "default"},
    spec: {template: {metadata: {annotations: {"autoscaling.knative.dev/min-scale": "1"}},
      spec: {containers: [{image: $image, imagePullPolicy: "IfNotPresent",
        ports: [{containerPort: $port}]}]}}}
  }' | kubectl apply -f -
  kubectl -n default wait --for=condition=Ready "ksvc/$name" --timeout=300s
}

ci_manifest() {
  local manifest=$1 image=$2
  ci_load "$image"
  kubectl patch --local -f "$manifest" --type=json -p "$(
    jq -cn --arg image "$image" '[
      {op: "replace", path: "/spec/template/spec/containers/0/image", value: $image},
      {op: "add", path: "/spec/template/spec/containers/0/imagePullPolicy", value: "IfNotPresent"}
    ]'
  )" -o yaml | kubectl -n default apply -f -
  kubectl -n default wait -f "$manifest" --for=condition=Ready --timeout=300s
}

ci_env() {
  # kubectl set env only supports built-in workload types, not Knative CRDs.
  local name=$1 key=$2 value=$3 env
  env=$(kubectl -n default get "ksvc/$name" -o json | jq \
    --arg key "$key" --arg value "$value" \
    '(.spec.template.spec.containers[0].env // []) | map(select(.name != $key)) + [{name: $key, value: $value}]')
  kubectl -n default patch "ksvc/$name" --type=json -p "$(
    jq -cn --argjson env "$env" \
      '[{op: "add", path: "/spec/template/spec/containers/0/env", value: $env}]'
  )"
  ci_ready "$name"
}

ci_ready() {
  local name=$1 generation
  generation=$(kubectl -n default get "ksvc/$name" -o jsonpath='{.metadata.generation}')
  kubectl -n default wait --for=jsonpath='{.status.observedGeneration}'="$generation" \
    "ksvc/$name" --timeout=300s
  kubectl -n default wait --for=condition=Ready "ksvc/$name" --timeout=300s
}

ci_host() {
  local url host
  url=$(kubectl -n default get "ksvc/$1" -o jsonpath='{.status.url}')
  host=${url#*://}
  [[ "$host" =~ ^[a-zA-Z0-9.-]+$ ]]
  printf '%s\n' "$host"
}

ci_request() {
  local name=$1 path=$2
  shift 2
  curl -fsS --max-time 30 -H "Host: $(ci_host "$name")" "$CI_URL$path" "$@"
}

ci_event() {
  local name=$1 path=$2 data=$3
  shift 3
  ci_request "$name" "$path" -H 'Content-Type: application/json' \
    -H 'Ce-Specversion: 1.0' -H 'Ce-Id: smoke-test' \
    -H 'Ce-Type: dev.knative.samples.test' -H 'Ce-Source: /smoke-test' \
    --data "$data" "$@"
}

ci_forward() {
  local resource=$1 local_port=$2 remote_port=$3
  kubectl -n default port-forward "$resource" "$local_port:$remote_port" &
  CI_PIDS+=("$!")
  for _attempt in {1..30}; do
    (true > "/dev/tcp/127.0.0.1/$local_port") 2>/dev/null && return 0
    sleep 1
  done
  echo "Timed out forwarding $resource" >&2
  return 1
}

ci_sink() {
  local image=dev.local/sample-ci-sink:ci
  docker build -t "$image" "$CI_ROOT/code-samples/serving/cloudevents/cloudevents-go/eventing/logger"
  ci_deploy ci-sink "$image"
}

ci_wait_json_log() {
  local name=$1 filter=$2 logs
  for _attempt in {1..30}; do
    logs=$(kubectl -n default logs -l "serving.knative.dev/service=$name" \
      -c user-container --tail=200 2>/dev/null || true)
    if jq -Rse "split(\"\n\") | map(fromjson?) | any(.[]; $filter)" <<< "$logs"; then
      return 0
    fi
    sleep 2
  done
  printf 'Expected event not found in %s logs:\n%s\n' "$name" "$logs" >&2
  return 1
}

ci_websocket() {
  # Only tests that need a WebSocket client install this test-only dependency.
  local venv
  venv=$(mktemp -d)
  CI_TEMP+=("$venv")
  python3 -m venv "$venv"
  "$venv/bin/pip" --disable-pip-version-check install --quiet websocket-client==1.9.0
  "$venv/bin/python" "$CI_ROOT/code-samples/ci/websocket_client.py" "$@"
}

ci_function_build() {
  # func persists build settings in func.yaml; keep the sample checkout unchanged.
  local image=$1 directory
  directory=$(mktemp -d)
  CI_TEMP+=("$directory")
  tar --exclude=.func --exclude=.git -cf - . | tar -xf - -C "$directory"
  func build --path "$directory" --image "$image" --builder=s2i --confirm=false
}

ci_maven_image() {
  local image=$1 java=$2 property=$3 directory arch
  directory=$(pwd)
  arch=$(docker info --format '{{.Architecture}}')
  case "$arch" in x86_64) arch=amd64 ;; aarch64) arch=arm64 ;; esac
  # Jib writes a tar rather than requiring access to the host Docker socket.
  docker run --rm -v "$directory:/workspace" -w /workspace "maven:3-eclipse-temurin-$java" \
    mvn -B compile jib:buildTar "-D$property=$arch" "-Djib.to.image=$image"
  docker load -i target/jib-image.tar
}

ci_bookstore_deploy() {
  local manifest=$1 image=$2
  ci_load "$image"
  kubectl create --dry-run=client -f "$manifest" -o json | \
    jq --arg image "$image" '
      def update:
        if .kind == "Deployment" then
          .spec.template.spec.containers[0].image = $image |
          .spec.template.spec.containers[0].imagePullPolicy = "IfNotPresent" |
          .spec.template.spec.containers[0].readinessProbe //= {
            tcpSocket: {port: .spec.template.spec.containers[0].ports[0].containerPort},
            periodSeconds: 1
          }
        else . end;
      if .kind == "List" then .items |= map(update) else update end
    ' | kubectl -n default apply -f -
}

ci_bookstore_node() {
  local image=$1
  ci_sink
  kubectl -n default run postgresql --image=postgres:15 --restart=Never \
    --env=POSTGRES_DB=mydatabase --env=POSTGRES_USER=myuser --env=POSTGRES_PASSWORD=mypassword
  kubectl -n default expose pod postgresql --port=5432
  kubectl -n default wait --for=condition=Ready pod/postgresql --timeout=120s
  local ready=false
  for _attempt in {1..30}; do
    if kubectl -n default exec postgresql -- pg_isready -U myuser -d mydatabase; then
      ready=true
      break
    fi
    sleep 2
  done
  [[ "$ready" == true ]]
  kubectl -n default exec -i postgresql -- psql -v ON_ERROR_STOP=1 -U myuser -d mydatabase \
    < ../db-service/sample.sql
  ci_bookstore_deploy config/100-deployment.yaml "$image"
  kubectl -n default set env deployment/node-server \
    PGHOST=postgresql K_SINK=http://ci-sink.default.svc.cluster.local
  kubectl -n default rollout status deployment/node-server --timeout=300s
  ci_forward service/node-server-svc 18081 80
  local response rows
  [[ $(curl -fsS --max-time 30 http://127.0.0.1:18081/) == 'Hello, world!' ]]
  response=$(curl -fsS --max-time 30 http://127.0.0.1:18081/insert \
    -H 'Content-Type: application/json' -H 'Ce-Specversion: 1.0' \
    -H 'Ce-Id: smoke-insert' -H 'Ce-Type: moderated-comment' -H 'Ce-Source: /smoke-test' \
    --data '{"reviewText":"CI bookstore review","sentimentResult":"positive"}')
  jq -e '.success == true and .message == "Review inserted successfully"' <<< "$response"
  rows=$(kubectl -n default exec postgresql -- psql -At -U myuser -d mydatabase \
    -c "SELECT count(*) FROM book_reviews WHERE content = 'CI bookstore review' AND sentiment = 'positive';")
  [[ "$rows" == 1 ]]
  ci_websocket --url ws://127.0.0.1:18081/comments --review 'CI bookstore review'
  response=$(curl -fsS --max-time 30 http://127.0.0.1:18081/add \
    -H 'Content-Type: application/json' -H 'Ce-Specversion: 1.0' \
    -H 'Ce-Id: smoke-forward' -H 'Ce-Type: new-review-comment' -H 'Ce-Source: /smoke-test' \
    --data '{"reviewText":"CI forwarded review"}')
  jq -e '.success == true' <<< "$response"
  ci_wait_json_log ci-sink '.headers["Ce-Id"] == ["smoke-forward"] and .body.reviewText == "CI forwarded review"'
}
