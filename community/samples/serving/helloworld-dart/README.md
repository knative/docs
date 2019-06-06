A simple web app written in the [Dart](www.dartlang.org) programming language
that you can use for testing. It reads in the env variable `TARGET` and prints
`"Hello $TARGET"`. If `TARGET` is not specified, it will use `"World"` as
`TARGET`.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../install/README.md) if you need to create
  one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- [dart-sdk](https://www.dartlang.org/tools/sdk#install) installed and
  configured if you want to run the program locally.

## Recreating the sample code

While you can clone all of the code from this directory, it is useful to know
how to build a hello world Dart application step-by-step. This application can
be created using the following instructions.

1. Create a new directory and write `pubspec.yaml` as follows:

   ```yaml
   name: hello_world_dart
   publish_to: none # let's not accidentally publish this to pub.dartlang.org
   description: Hello world server example in Dart

   environment:
     sdk: ">=2.1.0 <3.0.0"

   dependencies:
     shelf: ^0.7.3
   ```

2. If you want to run locally, install dependencies. If you only want to run in
   Docker or Knative, you can skip this step.

   ```shell
   > pub get
   ```

3. Create a new file `bin/server.dart` and write the following code:

   ```dart
   import 'dart:io';

   import 'package:shelf/shelf.dart';
   import 'package:shelf/shelf_io.dart';

   Future main() async {
     // Find port to listen on from environment variable.
     var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

     // Read $TARGET from environment variable.
     var target = Platform.environment['TARGET'] ?? 'World';

     Response handler(Request request) => Response.ok('Hello $target');

     // Serve handler on given port.
     var server = await serve(
       Pipeline().addMiddleware(logRequests()).addHandler(handler),
       InternetAddress.anyIPv4,
       port,
     );
     print('Serving at http://${server.address.host}:${server.port}');
   }
   ```

4. Create a new file named `Dockerfile`, this file defines instructions for
   dockerizing your applications, for dart apps this can be done as follows:

   ```Dockerfile
   # Use Google's official Dart image.
   # https://hub.docker.com/r/google/dart-runtime/
   FROM google/dart-runtime
   ```

5. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
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

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-dart .

   # Push the container to docker registry
   docker push {username}/helloworld-dart
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the IP address for your service, use these commands to get the
   ingress IP for your cluster. If your cluster is new, it may take sometime for
   the service to get assigned an external IP address.

   ```shell
   # In Knative 0.2.x and prior versions, the `knative-ingressgateway` service was used instead of `istio-ingressgateway`.
   INGRESSGATEWAY=knative-ingressgateway

   # The use of `knative-ingressgateway` is deprecated in Knative v0.3.x.
   # Use `istio-ingressgateway` instead, since `knative-ingressgateway`
   # will be removed in Knative v0.4.
   if kubectl get configmap config-istio -n knative-serving &> /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
   fi

   kubectl get svc $INGRESSGATEWAY --namespace istio-system

   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   xxxxxxx-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

   ```

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-dart  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
   NAME                DOMAIN
   helloworld-dart   helloworld-dart.default.example.com
   ```

1. Now you can make a request to your app to see the result. Replace
   `{IP_ADDRESS}` with the address you see returned in the previous step.

   ```shell
   curl -H "Host: helloworld-dart.default.example.com" http://{IP_ADDRESS}
   Hello Dart Sample v1
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
