---
audience: developer
components:
  - serving
  - eventing
function: reference
---

# Bookstore setup alternatives

These notes preserve alternative setup techniques for readers who already manage their environment. The [core tutorial chooses kind Quickstart, manual application deployment, and published images](environment-setup.md). Do not combine multiple installation methods on that cluster.

## Existing cluster

An existing disposable cluster needs Knative Serving, Eventing, an InMemoryChannel implementation, Broker support, and Sequence CRDs. It also needs external access to the sample's ordinary Kubernetes LoadBalancer Services and storage for PostgreSQL's persistent volume claim. Follow the [installation guides](../../install/README.md) for component installation, then verify the resource types and pod readiness as in the core setup.

Use `default`: the backend source hard-codes the database host in this namespace. Inspect the supplied source and manifests before adapting the sample to another namespace or network setup.

## Minikube

If you installed Quickstart with minikube instead of kind, keep the tunnel running in a secondary terminal:

```sh
minikube tunnel --profile knative
```

The [Quickstart installation instructions](../../getting-started/quickstart-install.md#run-the-knative-quickstart-plugin) explain the tunnel and its cleanup. Check both `bookstore-frontend-svc` and `node-server-svc` for external addresses with `kubectl get services`. When finished, stop the tunnel with `Ctrl+C`.

Example output (addresses vary):

```{ .text .no-copy }
NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)
bookstore-frontend-svc    LoadBalancer   10.99.187.173    172.18.0.6    80:31600/TCP
node-server-svc           LoadBalancer   10.101.90.35     172.18.0.8    80:31792/TCP
```

A pending address requires checking your tunnel or LoadBalancer implementation before attempting browser verification.

## Build the frontend or backend image yourself

The supplied manifests use `ghcr.io/knative/bookstore-frontend:latest` and `ghcr.io/knative/node-server:latest`. Source and Dockerfiles are in `start/frontend` and `start/node-server`.

If modifying the sample, [build a container image](https://docs.docker.com/get-started/02_our_app/), make it available to the cluster, and replace the `image` field in the corresponding Deployment manifest before applying it. Registry authentication and cluster image-pull access are your responsibility. The tutorial does not require rebuilding these images.

## Setup script

The repository retains `code-samples/eventing/bookstore-sample-app/start/setup.sh`. It is an experimental convenience script, **not** the chosen learning route and **not** equivalent to creating a Quickstart cluster.

Read the script before running it. It:

- Uses your current Kubernetes context; it does not create a cluster.
- Applies latest-release Serving, Kourier, Eventing, and in-memory Channel/Broker manifests and patches the ingress configuration.
- Requires `func` to be installed, even though the first core lesson does not use it.
- Deploys the frontend and backend from the supplied manifests.
- Waits for pod readiness and LoadBalancer addresses and prompts you to verify the browser endpoints.

It assumes cluster, storage, and LoadBalancer prerequisites have already been arranged. Do not run it on a shared cluster or on the Quickstart cluster simply to save typing: it can change the installed Knative components. It does not complete the later lessons or install Camel K. Run it only after reviewing its commands and accepting those changes on a disposable cluster.

**Return to:** [Core environment setup](environment-setup.md) · [Bookstore learning route](../page-0/welcome-knative-bookstore-tutorial.md)
