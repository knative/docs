# Hello World - Shell

This guide describes the steps required to create the `helloworld-shell` sample app and deploy it to your
cluster.

The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`.
If `TARGET` is not specified, `World` is used as the default value.

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

1. Create a new file named `script.sh` and paste the following script. This will run BusyBox' `http` returning a friendly welcome message as `plain/text` plus some extra information:

  ```bash
  #!/bin/sh

  # Print out CGI header
  # See https://tools.ietf.org/html/draft-robinson-www-interface-00
  # for the full CGI specification
  echo -e "Content-Type: text/plain\n"

  # Use environment variable TARGET or "World" if not set
  echo "Hello ${TARGET:=World}!"

  # In this script you can perform more dynamic actions, too.
  # Like printing the date, checking CGI environment variables, ...
  ```

1. Create a new file named `Dockerfile` and copy the following code block into it.

   ```docker
   # Busybox image that contains the simple 'httpd'
   # https://git.busybox.net/busybox/tree/networking/httpd.c
   FROM busybox

   # Serve from this directory
   WORKDIR /var/www

   # Prepare httpd command for being started via init
   # This indirection is required for proper SIGTERM handling
   RUN echo "::sysinit:httpd -vv -p 8080 -u daemon -h /var/www" > /etc/inittab

   # Copy over our CGI script and make it executable
   COPY --chown=daemon:daemon script.sh cgi-bin/index.cgi
   RUN chmod 755 cgi-bin/index.cgi

   # Startup init which in turn starts httpd
   CMD init
   ```

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build the container on your local machine
   docker build -t {username}/helloworld-shell .

   # Push the container to docker registry
   docker push {username}/helloworld-shell
   ```

## Deploying

After the build has completed and the container is pushed to Docker Hub, you can deploy the app into your cluster.

Choose one of the following methods to deploy the app:

### yaml
1. Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{username}` with your Docker Hub username.
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld-shell
  namespace: default
spec:
  template:
    spec:
      containers:
        - image: docker.io/{username}/helloworld-shell
          env:
            - name: TARGET
              value: "Shell Sample v1"
```
Ensure that the container image value in `service.yaml` matches the container you built in the previous step.
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
