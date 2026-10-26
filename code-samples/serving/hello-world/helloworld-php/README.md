# Hello World - PHP

A simple web app written in PHP that you can use for testing. It reads in an env
variable `TARGET` and prints `Hello ${TARGET}!`. If `TARGET` is not specified,
it will use `World` as the `TARGET`. PHP also treats an empty `TARGET` or the
string `0` as false, so these values use `World` as well. Responses are UTF-8
plain text: characters in `TARGET` are preserved, not interpreted as HTML.

The sample uses the official `php:8.5-apache-trixie` image (PHP 8.5 with Apache
on Debian Trixie) and PHP's production configuration. PHP 8.5 is actively
supported through December 2027 and receives security fixes through December
2029; see [PHP supported versions](https://www.php.net/supported-versions.php).
The minor-version image tag receives patch updates; rebuild with `--pull` to
pick them up.

Clone the repository and use the checked-in sample files to build and deploy
the app to your cluster:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-php
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Sample files

Use the files from the directory selected above; there is no need to
recreate them by copying code from this guide:

- [index.php](index.php) reads `TARGET` and returns the UTF-8 plain-text greeting.
- [Dockerfile](Dockerfile) packages the app with the
  [official PHP Apache image](https://hub.docker.com/_/php/), uses PHP's production
  configuration, and configures Apache to listen on `PORT` (default `8080`).
- [service.yaml](service.yaml) defines the Knative Service and sets
  `TARGET="PHP Sample v1"`. Replace `{username}` in its image reference with
  your Docker Hub username before deployment.

## Building and deploying the sample

Run the following commands from the sample directory cloned above.

First, build and push the image for either deployment method. Replace
`{username}` with your Docker Hub username:

```bash
# Build and push the container on your local machine.
docker buildx build --pull --platform linux/arm64,linux/amd64 -t "{username}/helloworld-php" --push .
```

Choose one of the following deployment methods:

### yaml

After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster. Ensure that the container image value in `service.yaml` matches the container you built in the previous step. Apply the configuration using `kubectl`:

 ```bash
 kubectl apply --filename service.yaml
 ```

### kn
 1. With `kn` you can deploy the service with

     ```bash
     kn service create helloworld-php --image=docker.io/{username}/helloworld-php --env TARGET="PHP Sample v1"
     ```

     This will wait until your service is deployed and ready, and ultimately it will print the URL through which you can access the service.

     The output will look like:
     ```
    Creating service 'helloworld-php' in namespace 'default':
    0.035s The Configuration is still working to reflect the latest desired specification.
    0.139s The Route is still working to reflect the latest desired specification.
    0.250s Configuration "helloworld-php" is waiting for a Revision to become ready.
    8.040s ...
    8.136s Ingress has not yet been reconciled.
    8.277s unsuccessfully observed a new generation
    8.398s Ready to serve.
    Service 'helloworld-php' created to latest revision 'helloworld-php-akhft-1' is available at URL: http://helloworld-php.default.1.2.3.4.xip.io
     ```

Now that your service is created, Knative will perform the following steps:

  - Create a new immutable revision for this version of the app.
  - Network programming to create a route, ingress, service, and a load balancer for your app.
  - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

 ### kubectl
 ```
 kubectl get ksvc helloworld-php --output=custom-columns=NAME:.metadata.name,URL:.status.url
 NAME                URL
 helloworld-php      http://helloworld-php.default.1.2.3.4.xip.io
 ```

 ### kn
 ```bash
kn service describe helloworld-php -o url
```
Example:
 ```bash
http://helloworld-php.default.1.2.3.4.xip.io
 ```
1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

 ```bash
curl http://helloworld-php.default.1.2.3.4.sslip.io
Hello PHP Sample v1!
 ```

## Testing locally

To test without a cluster or registry, build a local image and run it:

```bash
docker build --pull -t helloworld-php:local .
docker run --rm -p 127.0.0.1:8080:8080 helloworld-php:local
```

In another terminal, `curl http://localhost:8080` should return `Hello World!`.
Stop the container with Ctrl-C. To test a custom target and listening port, run:

```bash
docker run --rm -p 127.0.0.1:9090:9090 -e PORT=9090 -e TARGET="PHP Sample v1" helloworld-php:local
```

Then `curl http://localhost:9090` should return `Hello PHP Sample v1!`.
Port 9090 is for this Docker-only check; Knative reserves it for its queue proxy.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

### kubectl
```bash
kubectl delete --filename service.yaml
```

### kn

```bash
kn service delete helloworld-php
```
