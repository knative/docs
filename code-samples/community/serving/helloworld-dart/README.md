# Hello World - Dart

A simple web app written in the [Dart](https://www.dart.dev) programming language
that you can use for testing. It reads in the env variable `TARGET` and prints
`"Hello $TARGET"`. If `TARGET` is not specified, it will use `"World"` as
`TARGET`.

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [Knative installation instructions](https://knative.dev/docs/install/) if you need to create
  one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- [dart-sdk](https://www.dart.dev/tools/sdk#install) installed and
  configured if you want to run the program locally.

## Recreating the sample code

While you can clone all of the code from this directory, we recommend you create
your hello world Dart application by using the `dart` developer tool. This takes
just a few steps:

1. Create a new Dart app using the `server_shelf` template:

   ```shell
   > dart create -t server-shelf helloworld-dart
   ```

1. If you want to run locally, install dependencies. If you only want to run in
   Docker or Knative, you can skip this step.

   ```shell
   > dart pub get
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-dart
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-dart
             env:
               - name: TARGET
                 value: "Dart Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build the container on your local machine
   docker build -t {username}/helloworld-dart .

   # Push the container to docker registry
   docker push {username}/helloworld-dart
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```bash
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-dart  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME             URL
   helloworld-dart  http://helloworld-dart.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```bash
   curl http://helloworld-dart.default.1.2.3.4.sslip.io
   Hello Dart Sample v1
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
