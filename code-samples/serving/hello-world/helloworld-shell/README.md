# Hello World - Shell

This guide describes the steps required to create the `helloworld-shell` sample app and deploy it to your
cluster.

The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`.
If `TARGET` is not specified or is empty, `World` is used as the default value.
The server listens on all interfaces on `PORT`, defaulting to `8080` when unset or empty.

The image uses BusyBox 1.38 and its `httpd` server; no language runtime or
additional application dependencies are needed.

You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-shell
```

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured.
- Optional: You can use the Knative CLI client [`kn`](https://github.com/knative/client/releases) to simplify resource creation and deployment. Alternatively, you can use `kubectl` to apply resource files directly.

## Building

Use the files in the cloned sample directory:

- [`script.sh`](script.sh) is the CGI application served by BusyBox's `httpd`.
  It returns the greeting as `text/plain`, using `World` when `TARGET` is unset or empty.
- [`Dockerfile`](Dockerfile) copies the CGI script into the BusyBox image and
  configures the listener from `PORT` at startup.

Build from this directory so Docker can find the CGI script:

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --pull --platform linux/arm64,linux/amd64 -t "{username}/helloworld-shell" --push .
   ```

## Testing locally

Build a single-platform image without pushing, then run it on a custom port:

```bash
docker build --pull -t helloworld-shell:local .
docker run --rm -d --name helloworld-shell-local -p 127.0.0.1:8081:9090 \
  -e PORT=9090 -e TARGET="Shell Sample v1" helloworld-shell:local
curl --fail http://127.0.0.1:8081/
# Hello Shell Sample v1!
docker stop helloworld-shell-local
```

Omit `TARGET` or pass `-e TARGET=` to use the `World` fallback.
Omit `PORT` to listen on 8080.

## Deploying

After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster.

Choose one of the following methods to deploy the app:

### yaml
1. Open the checked-in [`service.yaml`](service.yaml) and replace `{username}` in its
   image reference with your Docker Hub username. The manifest configures
   `TARGET="Shell Sample v1"`. Ensure that its image reference matches the image
   built and pushed in the previous step.
1. Apply the configuration using `kubectl`:
```bash
kubectl apply --filename service.yaml
```

### kn
1. With `kn` you can deploy the service with
```bash
kn service create helloworld-shell --image=docker.io/{username}/helloworld-shell --env TARGET="Shell Sample v1"
```
This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.
The output will look like:

 ```
 Creating service 'helloworld-shell' in namespace 'default':
 0.035s The Configuration is still working to reflect the latest desired specification.
 0.139s The Route is still working to reflect the latest desired specification.
 0.250s Configuration "helloworld-shell" is waiting for a Revision to become ready.
 8.040s ...
 8.136s Ingress has not yet been reconciled.
 8.277s unsuccessfully observed a new generation
 8.398s Ready to serve.

 Service 'helloworld-shell' created to latest revision 'helloworld-shell-kwdpt-1' is available at URL:
 http://helloworld-shell.default.1.2.3.4.sslip.io
 ```

During the creation of your service, Knative performs the following steps:

   - Creates of a new immutable revision for this version of the app.
   - Programs the network to create a route, ingress, service, and load balance
     for your app.
   - Automatically scales your pods up and down (including to zero active pods).

## Verification

1. Run one of the followings commands to find the domain URL for your service:

 ### kubectl
```bash
kubectl get ksvc helloworld-shell  --output=custom-columns=NAME:.metadata.name,URL:.status.url
```
Example:
```bash
NAME                URL
helloworld-shell    http://helloworld-shell.default.1.2.3.4.sslip.io
```

 ### kn
```bash
kn service describe helloworld-shell -o url
```
Example:
```bash
http://helloworld-shell.default.1.2.3.4.sslip.io
```

1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

   Example:

   ```bash
   curl http://helloworld-shell.default.1.2.3.4.sslip.io
   Hello Shell Sample v1!

   # Even easier with kn:
   curl $(kn service describe helloworld-shell -o url)
   ```

   > Note: Add `-v` option to get more details if the `curl` command failed.

## Removing

To remove the sample app from your cluster, delete the service record:

### kubectl

```bash
kubectl delete --filename service.yaml
```

### kn

```bash
kn service delete helloworld-shell
```
