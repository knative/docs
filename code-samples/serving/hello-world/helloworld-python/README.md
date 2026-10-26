# Hello World - Python

This guide describes the steps required to create the `helloworld-python` sample
app and deploy it to your cluster.

The sample app reads a `TARGET` environment variable, and prints
`Hello ${TARGET}!`. If `TARGET` is not specified, `World` is used as the default
value. The production container uses Gunicorn and listens on `0.0.0.0:$PORT`;
`PORT` defaults to `8080` locally and is supplied by Knative in the cluster.
An explicitly empty `TARGET` produces `Hello !`.

This sample uses Python 3.14, Flask and Gunicorn.

You can also download a working copy of the sample, by running the following
commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-python
```

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured.
- (optional) The Knative CLI client
  [kn](https://github.com/knative/client/releases) can be used to simplify the
  deployment. Alternatively, you can use `kubectl`, and apply resource files
  directly.

## Build

1. Use the cloned sample directory from the commands above. The checked-in
   files provide the application and build:

   - [app.py](app.py) defines the greeting and the development entrypoint.
   - [requirements.txt](requirements.txt) pins the dependencies used by the image build.
   - [Dockerfile](Dockerfile) uses the official supported Python image and starts
     Gunicorn with one worker and eight threads, listening on `0.0.0.0:$PORT`.

2. Build and push the container to Docker Hub or your registry of choice.
   Replace `{username}` with your Docker Hub username or registry URL:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-python" --push .
   ```

## Local testing

Build a local single-platform image (no registry push needed):

```bash
docker build -t helloworld-python:local .
docker run --rm -p 127.0.0.1:8080:8080 helloworld-python:local
```

In another terminal, `curl http://localhost:8080/` should print `Hello World!`.
Stop the container with Ctrl+C. To test a custom port and greeting:

```bash
docker run --rm -e PORT=9090 -e TARGET="Python Sample v1" \
  -p 127.0.0.1:9090:9090 helloworld-python:local
```

`curl http://localhost:9090/` should print `Hello Python Sample v1!`.
Stop this container with Ctrl+C before continuing. The container always uses
Gunicorn; running `python app.py` directly is only for local development and does
not enable Flask's debugger by default.

## Deploying the app

  After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster.

  Choose one of the following methods to deploy the app:

### yaml

 1. Open the checked-in [service.yaml](service.yaml). It defines a Knative
    Service in the `default` namespace with `TARGET="Python Sample v1"`.
    Replace the placeholder image with the image you built and pushed above.

 2. Apply that configuration using `kubectl`:

 ```bash
 kubectl apply --filename service.yaml
 ```

### kn

1. With `kn` you can deploy the service with

 ```bash
 kn service create helloworld-python --image=docker.io/{username}/helloworld-python --env TARGET="Python Sample v1"
 ```

 This will wait until your service is deployed and ready, and ultimately it
 will print the URL through which you can access the service.




   During the creation of your service, Knative performs the following steps:

   - Creates a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scales your pods up and down, including scaling down to zero
     active pods.

## Verification

 1. Run one of the followings commands to find the domain URL for your service.
   > Note: If your URL includes `example.com` then consult the setup instructions for
   > configuring DNS (e.g. with `sslip.io`), or [using a Custom Domain](https://knative.dev/docs/serving/using-a-custom-domain).

 ### kubectl

 ```bash
 kubectl get ksvc helloworld-python  --output=custom-columns=NAME:.metadata.name,URL:.status.url
 ```

   Example:
 ```bash
 NAME                      URL
 helloworld-python    http://helloworld-python.default.1.2.3.4.sslip.io
 ```

 ### kn

 ```bash
 kn service describe helloworld-python -o url
 ```

   Example:
 ```bash
 http://helloworld-python.default.1.2.3.4.sslip.io
 ```

 1. Now you can make a request to your app and see the result. Replace the following URL
   with the URL returned in the previous command.

   Example:

 ```bash
 curl http://helloworld-python.default.1.2.3.4.sslip.io
 Hello Python Sample v1!

 # Even easier with kn:
 curl $(kn service describe helloworld-python -o url)
 ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing

To remove the sample app from your cluster, delete the service record:

### kubectl

```bash
kubectl delete --filename service.yaml
```

### kn

```bash
kn service delete helloworld-python
```
