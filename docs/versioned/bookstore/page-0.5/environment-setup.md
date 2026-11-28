---
audience: developer
components:
  - eventing
  - serving
function: tutorial
---

# Environment Setup

Deploy the Bookstore frontend and Book Review backend using the provided images.
This is a larger application than the introductory tracks. Read the
[Bookstore introduction](../page-0/welcome-knative-bookstore-tutorial.md) and
[disclaimer](../disclaimer/disclaimer.md) before beginning.

## What does the final deliverable for this section look like?

- Your disposable Kubernetes cluster has Knative Serving and Eventing ready.
- The frontend and backend run in the same namespace.
- You can open the application from your browser using local port-forwarding.

Reuse your Quickstart learning cluster if you kept it. You do not need another
cluster, a cloud account, or a LoadBalancer helper for the access method on this page.

## Clone the Repository

From a directory where you keep projects, clone the repository and enter the
sample's working directory:

```bash
git clone https://github.com/knative/docs.git
cd docs/code-samples/eventing/bookstore-sample-app/start
```

If you already cloned the repository, use its existing copy and change to that
same `code-samples/eventing/bookstore-sample-app/start` directory instead.

## File Structure

The sample has two sibling directories:

- `start`: the working directory for these lessons, containing the frontend,
  backend, and starter configuration.
- `solution`: completed examples to consult when you are stuck.

When later lessons say to return to `start`, they mean this directory **inside
the cloned repository**, not a filesystem directory named `/start`. Run the
commands below from the `start` directory.

## Shortcut

These instructions use the manual steps and local port-forwarding below.
The optional `setup.sh` script instead reinstalls Knative components and waits
for real LoadBalancer addresses. Do not use it for this port-forwarding route
or run it over an existing Quickstart installation.

## Instructions

### Task 1: Set Up a Running Kubernetes Cluster with Knative Installed

If needed, [create a learning cluster](../../getting-started/quickstart-install.md),
then return here. Otherwise keep your existing cluster. Follow the shared guide's
[context and namespace checks](../../getting-started/quickstart-install.md#create-and-verify)
so commands use the disposable cluster and its `default` namespace.

Check the Knative components:

```bash
kubectl get pods -n knative-serving
kubectl get pods -n knative-eventing
```

Check that the Serving and Eventing pods are ready before deploying the Bookstore
application. If these components are missing or not ready, resolve the installation
first.

We will use `kubectl port-forward` to open a temporary connection from your
computer to a Service. It works with this tutorial's existing cluster and avoids
adapting another provider's sample cluster or relying on container IP addresses.
The forwarding command must stay running in its terminal while you use the app.

### Task 2: Running the Bookstore Web App

The frontend and backend use ordinary Kubernetes Deployments and Services,
not the Knative Service resource used in the Serving track.

#### Deploy the Frontend App

Use the pre-built image referenced by the starter configuration:

```bash
kubectl apply -f frontend/config/
kubectl rollout status deployment/bookstore-frontend
```

The rollout command waits for the frontend to become available. If it reports
an error, resolve it before opening the browser.

#### Access the frontend workload

In a dedicated terminal, using the same cluster context and namespace, run:

```bash
kubectl port-forward service/bookstore-frontend-svc 18080:80
```

Leave it running and open **http://127.0.0.1:18080** in your browser. `18080` is
on your computer; `80` is the Service's port inside the cluster.

The UI should appear. Its backend connection may be unavailable until you complete
Task 3. If port `18080` is already in use, choose another free local port and use
that port in the browser URL; do not stop an unrelated application.

The manifest uses a LoadBalancer Service, but its `EXTERNAL-IP` may remain
`<pending>` on a local cluster. That is not a blocker for this port-forwarding
route. Use the localhost URL above, not a Docker/container IP or an example IP.

### Task 3: Running the Book Review Service

Keep the frontend's port-forward running. Use another terminal for deployment,
and change back to the sample's `start` directory if necessary.

#### Deploy the Book Review Service: Node.js Server

```bash
kubectl apply -f node-server/config/
kubectl rollout status deployment/node-server
```

This starts the backend. The frontend reaches it using the internal
`node-server-svc` Service address; no public backend address is needed for the
frontend to communicate with it.

#### Access the node server backend

To check the backend directly, open another terminal and run:

```bash
kubectl port-forward service/node-server-svc 18081:80
```

Open **http://127.0.0.1:18081** to confirm that the backend responds. Then refresh
the frontend at **http://127.0.0.1:18080** and check its backend-connection status.
Do not enter the backend's localhost URL into cluster configuration; these
localhost addresses are only for your browser.

The backend check's port-forward can be stopped with ++ctrl+c++ afterward.
Keep the frontend's port-forward running for the following lessons. Neither
++ctrl+c++ nor closing a forwarding terminal deletes the application's resources.

## Troubleshooting

- Check the cluster context and namespace before investigating the application.
- `kubectl get pods` shows whether the frontend and backend pods are ready.
- Inspect the relevant application logs with `kubectl logs deployment/bookstore-frontend`
  or `kubectl logs deployment/node-server`.
- If the browser loses access, check that the corresponding port-forward terminal
  is still running and that you are using its local port in the URL.
- If a command fails, [get help](../../getting-started/next-steps.md#get-help)
  with its error rather than reinstalling Knative or creating another cluster.

## Next Step

The frontend and backend are running. Continue using the sample's `start`
directory and keep the frontend port-forward open:

[Go to Lesson 1: Send Review Comments to the Broker](../page-1/send-review-comment-to-broker.md){ .md-button .md-button--primary }
