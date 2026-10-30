# Knative Secrets - Go

A standard-library Go web app that reads a Kubernetes Secret mounted as a file.
It returns a safe success message, **never the secret's contents**. No cloud
account, credentials, SDK or external service is required.

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/secrets-go
```

## Before you begin

- A Kubernetes cluster with
  [Knative Serving installed](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- Docker and `kubectl`, plus a container registry you can push to and the cluster
  can pull from.

## Sample files

- [secrets.go](secrets.go): HTTP server. It reads `SECRET_FILE` on every request,
  defaulting to `/var/secret/message`, and listens on `PORT` (default `8080`).
- [secret.yaml](secret.yaml): an Opaque Secret named `mounted-secret` with a
  `message` key containing the non-sensitive example value `demonstration-only`.
- [service.yaml](service.yaml): Knative Service with that Secret mounted read-only
  at `/var/secret`. Its key becomes the filename `message`.
- [Dockerfile](Dockerfile) and [go.mod](go.mod): pinned Go build and a non-root,
  minimal final image. There are no third-party Go modules.

Only use demonstration values with this sample. Never commit real Secret values.
Kubernetes Secret manifests contain data, not encryption; restrict their access
and configure encryption at rest as appropriate for your cluster.

## Build and deploy

1. In [service.yaml](service.yaml), replace `docker.io/{username}/secrets-go` with
   the image reference you will build and push. These manifests use the `default`
   namespace; if you choose another, change **both** manifests consistently.

1. Build and push the sample, substituting your registry username:

   ```bash
   docker buildx build --platform linux/arm64,linux/amd64 \
     -t docker.io/{username}/secrets-go --push .
   ```

1. Create the sample Secret before the Knative Service:

   ```bash
   kubectl apply --filename secret.yaml
   kubectl apply --filename service.yaml
   kubectl wait --for=condition=Ready ksvc/secrets-go --timeout=180s
   ```

1. Request the actual Knative route:

   ```bash
   URL=$(kubectl get ksvc secrets-go -o jsonpath='{.status.url}')
   curl --fail-with-body "$URL"
   ```

   Expected response: `Secret file loaded.` followed by a newline. The response
   does not reveal the value, length or path of the Secret file.

## Updates and errors

The app reopens the file on every request rather than caching it. Kubernetes
projects Secret updates **eventually**, not immediately. This sample mounts the
whole volume (not `subPath`), so updates can reach the running app without a pod
restart.

To demonstrate a behavior change using only sample data, set the file to empty:

```bash
kubectl patch secret mounted-secret --type=merge -p '{"stringData":{"message":""}}'
# Repeat after the projected volume has updated; expect HTTP 503:
curl -i "$URL"
```

The exact body becomes `Secret file is empty.` followed by a newline. Whitespace-
only files are also treated as empty. Restore the checked-in sample value:

```bash
kubectl apply --filename secret.yaml
# After projection, expect HTTP 200 and "Secret file loaded." again:
curl -i "$URL"
```

A missing or unreadable file returns HTTP 503 with `Secret file unavailable.` and
a newline. No underlying filesystem error, path or content is returned or logged.
The server still starts, so Knative's default TCP readiness is not proof that the
file can be read; check the HTTP response too. A missing **Kubernetes Secret** is
different: the required volume cannot mount and the new pod/revision cannot become
Ready until the Secret exists.

To use a different file path, add `SECRET_FILE` to the container's environment in
[service.yaml](service.yaml) and adjust the volume mount or projected filename to
match. For a custom Knative port, set the container's `ports[].containerPort`;
Knative supplies `PORT`. Outside Knative, set `PORT` directly, or leave it unset
for port 8080.

## Cleanup

```bash
kubectl delete --filename service.yaml
kubectl delete --filename secret.yaml
```

Remove your unused local sample image tags after testing. Do not prune unrelated
Docker images, volumes or shared cluster resources.
