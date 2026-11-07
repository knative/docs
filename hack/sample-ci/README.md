# Sample smoke tests

Shared CI tooling and test fixtures live in `hack/sample-ci/`, not in the
application samples. This change adds tests to existing samples only.

`.github/workflows/samples-test.yaml` finds tracked `code-samples/**/ci.sh`
files and runs each selected script in its own disposable kind cluster with
Knative Serving and Kourier installed. Scripts are sourced from their sample
directory, then the shared `main` runner is invoked. Each sample implements
`sample_test`; the runner owns strict error handling and temporary-resource
cleanup. Sourcing alone does not build or deploy.

Changes below a directory containing `ci.sh` select that directory's test.
For example, either multi-container component selects the parent integration
test. Bookstore database fixture changes also select the corresponding node
server test. Shared helpers, the capture sink, or workflow changes select all
tests. Full relative paths are used as job names to avoid collisions between
bookstore `start` and `solution` components.

`lib.sh` provides image loading, manifest substitution, Knative routing,
readiness waits, capture-sink assertions, and test-client setup. It does not
create or delete clusters. The workflow owns cluster lifecycle, so scripts
must only be run against a disposable cluster. They create resources in the
`default` namespace and are intended for a clean cluster, not repeated runs
against an existing application deployment. Common hello-world, CloudEvent,
and bookstore checks are shared; sample payloads and assertions remain in the
sample scripts. Failure diagnostics collect all pods in the disposable cluster,
without application names or label selectors in the workflow.

## Coverage added for previously untested components

| Sample | Assertions |
| --- | --- |
| Bookstore frontends (`start`, `solution`) | Build the real Next.js image; render the book page and serve a static asset through the Kubernetes Service |
| Bookstore node servers (`start`, `solution`) | Insert a CloudEvent into real PostgreSQL; verify its stored values and WebSocket delivery; forward another event to a capture sink |
| Bookstore bad-word filter | Build the actual S2I function runtime; classify clean and profane input over HTTP |
| Bookstore sentiment analysis | Build the actual S2I function runtime; classify positive/negative input and preserve the moderation result |
| Parallel functions | Exercise all six filter/switch/transform endpoints and reject an invalid event |
| Heartbeat event source | Run the real producer and capture its emitted CloudEvent |
| Spring/Vert.x CloudEvents | Build with Jib; verify response data/attributes and delivery to a sink |
| Git webhook | Verify a signed webhook updates a PR through a local API fixture; reject an invalid signature; no real GitHub credentials are needed |
| gRPC ping | Exercise unary and all 20 streaming replies through Kourier |
| Multi-container | Build both images and verify the serving container's response comes from its sidecar |
| WebSockets | Round-trip text and binary messages through Knative ingress |
| Capture logger | Capture request data/attributes and exercise successful/failed delivery responses |

These are runtime/component smoke tests, not browser automation or a full
bookstore Broker/Trigger topology test. YAML-only examples without a `ci.sh`
ancestor are not covered. The existing eventing hello-world test installs its
own Eventing components; the shared harness only installs Serving.

## Local validation

The discovery and shared-runner regression tests do not require Docker or
Kubernetes:

```sh
python3 -m unittest discover -s hack/sample-ci -p 'test_*.py' -v
```

To run a runtime test, create a **separate disposable cluster**, install Serving
and Kourier as shown in the workflow, configure `example.test` as the domain,
and forward Kourier to an unused port. Then, from the sample directory:

```sh
export KUBECONFIG=/path/to/disposable-cluster.kubeconfig
export CLUSTER_NAME=your-disposable-cluster
export SAMPLE_URL=http://127.0.0.1:28080
source ./ci.sh
main
```

Prerequisites are Bash, Docker, kind, kubectl, jq, curl, and Python 3 with venv
support. WebSocket tests install a pinned test client into a temporary venv.
The Python function tests install their own checksum-verified Functions CLI
release pinned in `lib.sh` (`knative-v1.24.0`); the workflow has no
runtime-specific installation steps. Function builds use a
temporary copy so `func` does not persist CI image names or migrate the
sample's `func.yaml`. Maven runs inside a container and Jib exports a tar;
no host Maven installation or registry push is required.

The bookstore Deployment tests additionally forward port 18081, so it must be
unused. Delete the disposable cluster when finished.
