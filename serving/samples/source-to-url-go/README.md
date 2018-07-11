# Source to URL - Go

A sample that shows how to use Knative to go from source code in a git
repository to a running application with a URL. This sample uses Go.

This sample uses the [Build](../../../build/README.md) and [Serving](../../README.md)
components of Knative to orchestrate an end-to-end deployment.

## Prerequisites

* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/install/) if you need
  to create one.
* Go installed and configured (optional, if you want to run the sample app
  locally).

## Configuring Knative

To use this sample, a few configuration steps are required before we can deploy.
You need to install a [Build Template](https://github.com/knative/build-templates)
that will be used by the sample, and register a secret for your container
registry. In this example, we'll use Docker Hub.

### Install kaniko build template

This sample leverages the [kaniko build template](https://github.com/knative/build-templates/tree/master/kaniko)
to perform a source-to-container build on the Kubernetes cluster.

To install the kaniko build template, we'll use kubectl to install the kaniko
manifest:

```shell
kubectl apply -f https://raw.githubusercontent.com/knative/build-templates/master/kaniko/kaniko.yaml
```

### Register secrets for Docker Hub

In order to push the container built from source to Docker Hub, we need to
register a secret in Kubernetes for authentication with Docker Hub.

There are [detailed instructions](https://github.com/knative/docs/blob/master/build/auth.md#basic-authentication-docker)
available, but these are the key steps.

Create a new Secret manifest, which we can use to store your Docker Hub
credentials. Save this file as `docker-secret.yaml`.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: basic-user-pass
  annotations:
    build.knative.dev/docker-0: https://index.docker.io/v1/
type: kubernetes.io/basic-auth
data:
  # Use 'echo -n "username" | base64' to generate this string
  username: BASE64_ENCODED_USERNAME
  # Use 'echo -n "password" | base64' to generate this string
  password: BASE64_ENCODED_PASSWORD
```

On Mac or Linux computers, you can use the following command line to generate
the base64 encoded values required for the manifest:

```shell
$ echo -n "username" | base64
dXNlcm5hbWU=

$ echo -n "password" | base64
cGFzc3dvcmQ=
```

After you have created the manifest file, apply it to your cluster with kubectl:

```shell
$ kubectl apply -f docker-secret.yaml
secret "basic-user-pass" created
```

## Deploying the sample

Now that you've configured your cluster accordingly, we're ready to deploy the
sample service into your cluster.

This sample uses `github.com/mchmarny/simple-app` as a basic Go application, but
you could replace this GitHub repo with your own. The only requirements are that
the repo contain a `Dockerfile` with the instructions for how to build a
container for the application.

Create a service manifest which defines the service to deploy, including where
the source code is and which build-template to use. Create a file named
`service.yaml` and copy the following definition. Make sure to replace
`{DOCKER_USERNAME}` with your own Docker Hub username.

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: app-from-source
  namespace: default
spec:
  runLatest:
    configuration:
      build:
        source:
          git:
            url: https://github.com/mchmarny/simple-app.git
            revision: master
        template:
          name: kaniko
          arguments:
          - name: IMAGE
            value: &image docker.io/{DOCKER_USERNAME}/app-from-source:latest
      revisionTemplate:
        spec:
          container:
            image: *image
            imagePullPolicy: Always
            env:
            - name: TARGET
              value: "Hello sample app!"
```

Now you can apply this manifest using kubectl, and watch the results:

```shell
# Apply the manifest
$ kubectl apply -f service.yaml
service "app-from-source" created

# Watch the pods for build and serving
$ kubectl get pods --watch
NAME                          READY     STATUS       RESTARTS   AGE
app-from-source-00001-zhddx   0/1       Init:2/3     0          7s
app-from-source-00001-zhddx   0/1       PodInitializing   0         37s
app-from-source-00001-zhddx   0/1       Completed   0         38s
app-from-source-00001-deployment-6d6ff665f9-xfhm5   0/3       Pending   0         0s
app-from-source-00001-deployment-6d6ff665f9-xfhm5   0/3       Pending   0         0s
app-from-source-00001-deployment-6d6ff665f9-xfhm5   0/3       Init:0/1   0         0s
app-from-source-00001-deployment-6d6ff665f9-xfhm5   0/3       Init:0/1   0         2s
app-from-source-00001-deployment-6d6ff665f9-xfhm5   0/3       PodInitializing   0         3s
app-from-source-00001-deployment-6d6ff665f9-xfhm5   2/3       Running   0         6s
app-from-source-00001-deployment-6d6ff665f9-xfhm5   3/3       Running   0         11s
```

Once you see the deployment pod switch to the running state, hit Ctrl+C to
escape the watch. The build and deployment have finished!

To check on the state of the service, get the service object and examine the 
status block:

```shell
$ kubectl get service.serving.knative.dev app-from-source -o yaml

[...]
status:
  conditions:
  - lastTransitionTime: 2018-07-11T20:50:18Z
    status: "True"
    type: ConfigurationsReady
  - lastTransitionTime: 2018-07-11T20:50:56Z
    status: "True"
    type: RoutesReady
  - lastTransitionTime: 2018-07-11T20:50:56Z
    status: "True"
    type: Ready
  domain: app-from-source.default.dibble.cloud
  latestCreatedRevisionName: app-from-source-00007
  latestReadyRevisionName: app-from-source-00007
  observedGeneration: 10
  traffic:
  - configurationName: app-from-source
    percent: 100
    revisionName: app-from-source-00007
```


1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in
   the previous step. Apply the configuration using `kubectl`:

    ```shell
    kubectl apply -f service.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Fetch the revision specified from GitHub and build it into a container
   * Push the container to Docker Hub
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the IP address for your service, use
   `kubectl get svc knative-ingressgateway -n istio-system` to get the ingress IP for your
   cluster. If your cluster is new, it may take sometime for the service to get asssigned
   an external IP address.

    ```shell
    $ kubectl get svc knative-ingressgateway -n istio-system

    NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
    knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

    ```

1. To find the URL for your service, use

    ```shell
    $ kubectl get services.serving.knative.dev app-from-source  -o=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
    NAME                DOMAIN
    app-from-source     app-from-source.default.example.com
    ```

1. Now you can make a request to your app to see the result. Replace
   `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: app-from-source.default.example.com" http://{IP_ADDRESS}
    Hello World!
    ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
