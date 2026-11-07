# Hello World - Ruby

This guide describes the steps required to create the `helloworld-ruby` sample app and deploy it to your cluster.

The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`.
If `TARGET` is not specified, `World` is used as the default value. An explicitly
empty `TARGET` produces `Hello !`.

The Dockerfile uses `ruby:4.0-slim-trixie` and installs the gems pinned in
[Gemfile.lock](Gemfile.lock).

You can also download a working copy of the sample, by running the
following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-ruby
```

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured.
- (optional) The Knative CLI client [kn](https://github.com/knative/client/releases) that simplifies the deployment. Alternative you can also use [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and apply resource files directly.

## Using the sample code

After cloning and entering the sample directory above, use the checked-in files:

- [app.rb](app.rb) defines the greeting route, binds to `0.0.0.0`, and reads
  `PORT` (default `8080`).
- [Dockerfile](Dockerfile) builds the production image from the
  [official Ruby image](https://hub.docker.com/_/ruby/) and starts the app with
  the locked dependencies.
- [Gemfile](Gemfile) and [Gemfile.lock](Gemfile.lock) define the server and its
  resolved dependencies. Docker installs them; no local Ruby installation is required.
- [service.yaml](service.yaml) defines the Knative Service and configures
  `TARGET="Ruby Sample v1"`.

## Building and testing locally

Build the image, replacing `{username}` with your Docker Hub username:

```bash
docker build --pull -t docker.io/{username}/helloworld-ruby .
```

Run it locally and request the default greeting from another terminal:

```bash
docker run --rm -p 127.0.0.1:8080:8080 docker.io/{username}/helloworld-ruby
# In another terminal:
curl http://localhost:8080
# Hello World!
```

Stop the container with Ctrl-C. To test a custom greeting and port, run:

```bash
docker run --rm -p 127.0.0.1:8081:8081 -e PORT=8081 -e TARGET="Ruby Sample v1" docker.io/{username}/helloworld-ruby
# In another terminal:
curl http://localhost:8081
# Hello Ruby Sample v1!
```

The app listens on `0.0.0.0` and uses `PORT` (default `8080`). The image sets
`APP_ENV=production` so Sinatra accepts requests for the service's external hostname.

## Deploying

Stop the local container and push the image before deploying:

```bash
docker push docker.io/{username}/helloworld-ruby
```

After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster.

Choose one of the following methods to deploy the app:

 ### yaml

Edit the checked-in [service.yaml](service.yaml), replacing `{username}` in
its image reference with your Docker Hub username. Ensure that the image matches
the one you built and pushed in the previous steps.
Apply the configuration using `kubectl`:
```bash
kubectl apply --filename service.yaml
```

### kn
 * With `kn` you can deploy the service with:
```bash
kn service create helloworld-ruby --image=docker.io/{username}/helloworld-ruby --env TARGET="Ruby Sample v1"
```
This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.
The output will look like:
```
       Creating service 'helloworld-ruby' in namespace 'default':

        0.035s The Configuration is still working to reflect the latest desired specification.
        0.139s The Route is still working to reflect the latest desired specification.
        0.250s Configuration "helloworld-ruby" is waiting for a Revision to become ready.
        8.040s ...
        8.136s Ingress has not yet been reconciled.
        8.277s unsuccessfully observed a new generation
        8.398s Ready to serve.

      Service 'helloworld-ruby' created to latest revision 'helloworld-ruby-akhft-1' is available at URL:
      http://helloworld-ruby.default.1.2.3.4.sslip.io
    ```

During the creation of your service, Knative performs the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

## Verification

1. Run one of the followings commands to find the domain URL for your service.

 ### kubectl
```bash
kubectl get ksvc helloworld-ruby  --output=custom-columns=NAME:.metadata.name,URL:.status.url
```

 Example:
 ```bash
NAME                URL
helloworld-ruby     http://helloworld-ruby.default.1.2.3.4.sslip.io
 ```

 ### kn
```bash
kn service describe helloworld-ruby -o url
```
Example:
```bash
http://helloworld-ruby.default.1.2.3.4.sslip.io
```

2. Now you can make a request to your app and see the result.
Replace the following URL with the URL returned in the previous command.

 Example:

   ```bash
   curl http://helloworld-ruby.default.1.2.3.4.sslip.io
   Hello Ruby Sample v1!

   # Even easier with kn:
   curl $(kn service describe helloworld-ruby -o url)
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
kn service delete helloworld-ruby
```
