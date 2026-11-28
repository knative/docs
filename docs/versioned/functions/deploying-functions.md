---
audience: developer
components:
  - functions
function: how-to
hide_prev: true
hide_next: true
---

# Deploy a function

Build, push, and deploy a function project to Kubernetes as a Knative Service
(or as a raw Kubernetes Deployment). For a guided first deployment, see
[Try Functions — Deploy to Knative](../getting-started/about-knative-functions.md#deploy-to-knative-optional).

## Requirements

- An initialized function project containing `func.yaml`
  ([create a project](running-functions.md#create-a-project) if needed).
- A Kubernetes cluster with Knative Serving installed, with your `kubectl`
  context selecting the target cluster and namespace.
- Push access to a container registry that your cluster can pull from (use a
  public repository or configure image pull secrets for private registries).
- For local builds: a running [Docker](https://docs.docker.com/get-started/get-docker/)
  engine. For remote builds: Tekton Pipelines configured on the cluster.

## Deploy from your machine

Run `func deploy` from inside the project directory. Pass `--registry <registry>`
where `<registry>` is the registry and your account namespace (for example
`ghcr.io/alice` or `docker.io/alice`), or pass `--image <full-image-name>` to
override a previous local-only `localhost/...` image tag:

=== "func"

    ```bash
    func deploy --registry <registry>
    ```

=== "kn func"

    ```bash
    kn func deploy --registry <registry>
    ```

`func` builds the image, pushes it to `<registry>/<project-name>:latest`, and
creates or updates a Knative Service with the project name.

- **Namespace:** By default, `func deploy` uses the previously deployed
  namespace recorded in the project, or your current `kubectl` namespace on
  first deploy. Pass `-n <namespace>` to target a specific namespace.
- **Private registries:** Set `FUNC_USERNAME` and `FUNC_PASSWORD` environment
  variables for registry push credentials (avoid passing `--password` on the
  command line), and ensure the target cluster namespace has pull credentials.
- **Raw Kubernetes deployer:** Add `--deployer raw` to deploy as a standard
  Kubernetes Deployment and Service instead of a Knative Service.

## Build and deploy remotely

Use `--remote` to run the build and deployment on the cluster with Tekton
Pipelines instead of a local Docker engine. Configure Tekton and pipeline RBAC
first using the
[on-cluster build guide](https://github.com/knative/func/blob/main/docs/building-functions/on_cluster_build.md){target=_blank}.

Choose one source method and pass an explicit `--image` destination (replace
`REGISTRY-USER` with your registry account namespace):

=== "Git-backed source"

    Commit your project to a Git repository the cluster pipeline can read. For
    private repositories, have your platform administrator provision pipeline
    Git access first (see the
    [Tekton authentication guide](https://tekton.dev/docs/pipelines/auth/){target=_blank}).
    If the project is in a subdirectory, set `build.source.dir` in `func.yaml`
    as shown in the on-cluster build guide.

    ```bash
    func deploy --remote \
      --image docker.io/REGISTRY-USER/my-function:latest \
      --git-url https://github.com/GIT-OWNER/GIT-REPO
    ```

    (Some CLI versions accept `--source` / `--source-dir` instead of `--git-url`;
    check `func deploy --help` for your installed CLI.)

=== "Direct upload (no Git)"

    Upload the current local project directory directly. Passing `--git-url=""`
    clears any previously configured Git URL (also remove `build.source.dir`
    from `func.yaml` if previously set):

    ```bash
    func deploy --remote \
      --image docker.io/REGISTRY-USER/my-function:latest \
      --git-url=""
    ```

(`kn func deploy` accepts the same flags.)

## Verify

Invoke the deployed function with an explicit `--target remote` so you do not
accidentally hit a locally running instance:

=== "func"

    ```bash
    func invoke --target remote
    ```

=== "kn func"

    ```bash
    kn func invoke --target remote
    ```

Confirm the response body matches your function's expected output. You can also
check status on the cluster:

- **Knative deployer (default):** `kn service describe <function-name> -n <namespace>`
- **Raw deployer (`--deployer raw`):** `kubectl get deployment/<function-name> service/<function-name> -n <namespace>`

## Update and remove

- **Update:**
    - Local builds and direct-upload remote builds: edit your code and re-run
      `func deploy` (or `func deploy --remote --git-url=""`).
    - Git-backed remote builds: commit and push your changes to the configured
      Git branch first, then re-run `func deploy --remote`.
    - With the default Knative deployer, each deploy rolls out a new Revision;
      with `--deployer raw`, it updates the Kubernetes Deployment.
- **Remove:** Run `func delete` from inside the project directory (works for
  both Knative and raw deployers). You can also delete directly with
  `kn service delete <function-name> -n <namespace>` (Knative deployer) or
  `kubectl delete deployment/<function-name> service/<function-name> -n <namespace>` (raw
  deployer). Deleting the workload does not delete the pushed image from your
  container registry.
